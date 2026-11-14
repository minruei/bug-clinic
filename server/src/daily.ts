import { Router } from 'express'
import type { RowDataPacket } from 'mysql2'
import { pool } from './db'
import { getUser } from './auth'
import { DAILY_REWARD, pickChallenge, publicChallenge, taipeiDate, type ChimeraCode } from './challenges'

// 每日任務的 API
// 「今天」由後端用台灣時間算，題目也由後端依日期決定，前端不能自己選日期或選題
// 領獎時不相信前端說「過關了」：後端讀資料庫裡存檔的程式碼，自己再檢查一次（檢查的方式寫在 challenges.ts）
export const dailyRouter = Router()

// 今天的題目和今天領過沒；不回檢查函式，只回題目文字
dailyRouter.get('/api/daily', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const date = taipeiDate(new Date())
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id FROM daily_claims WHERE user_id = ? AND claim_date = ?',
    [user.id, date],
  )

  res.json({ data: { date, ...publicChallenge(pickChallenge(date)), claimed: rows.length > 0 } })
})

// 存檔的程式碼是一段 JSON 文字，拆回三格；沒存過或格式不對回 null
async function savedCode(userId: number): Promise<ChimeraCode | null> {
  const [rows] = await pool.query<RowDataPacket[]>('SELECT code FROM chimeras WHERE user_id = ?', [
    userId,
  ])
  if (!rows[0]) return null
  try {
    const { html, css, js } = JSON.parse(rows[0].code)
    if (typeof html !== 'string' || typeof css !== 'string' || typeof js !== 'string') return null
    return { html, css, js }
  } catch {
    return null
  }
}

// 領取今天的獎勵
// 前端在 sandbox 檢查通過後，要先存檔再呼叫這裡；後端檢查的是存檔的版本
dailyRouter.post('/api/daily/claim', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const date = taipeiDate(new Date())
  const challenge = pickChallenge(date)

  // 前端 23:59 打開題目、00:01 才按領取：題目已經換了，不能拿昨天的題目領今天的獎勵
  if (req.body?.key !== challenge.key) {
    res.status(409).json({ error: true, message: '今天的題目已經換了，請重新整理' })
    return
  }

  const code = await savedCode(user.id)
  if (!code) {
    res.status(400).json({ error: true, message: '請先存檔再領取' })
    return
  }
  if (!challenge.check(code)) {
    res.status(400).json({ error: true, message: `還沒完成喔：${challenge.hint}` })
    return
  }

  const conn = await pool.getConnection()
  try {
    await conn.beginTransaction()

    // 先寫領取紀錄：(user_id, claim_date) 有 UNIQUE，今天領過就會撞到，同時送很多次也只有第一次成功
    try {
      await conn.query(
        'INSERT INTO daily_claims (user_id, claim_date, challenge_key, reward) VALUES (?, ?, ?, ?)',
        [user.id, date, challenge.key, DAILY_REWARD],
      )
    } catch (err) {
      if ((err as { code?: string }).code === 'ER_DUP_ENTRY') {
        await conn.rollback()
        res.status(400).json({ error: true, message: '今天已經領過了' })
        return
      }
      throw err
    }

    await conn.query('UPDATE users SET coins = coins + ? WHERE id = ?', [DAILY_REWARD, user.id])

    // 金幣明細記一筆，reason 是 daily，attempt_id、part_id、order_id 都留 NULL
    await conn.query(
      `INSERT INTO coin_transactions (user_id, amount, reason)
       VALUES (?, ?, 'daily')`,
      [user.id, DAILY_REWARD],
    )

    const [rows] = await conn.query<RowDataPacket[]>('SELECT coins FROM users WHERE id = ?', [
      user.id,
    ])

    await conn.commit()
    res.json({ data: { coins: rows[0].coins, reward: DAILY_REWARD } })
  } catch {
    await conn.rollback()
    res.status(500).json({ error: true, message: '領取失敗，請稍後再試' })
  } finally {
    conn.release()
  }
})
