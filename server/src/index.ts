import express from 'express'
import cors from 'cors'
import type { RowDataPacket, ResultSetHeader } from 'mysql2'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { pool } from './db'
import { getUser } from './auth'
import { TIME_LIMIT, EXP_REWARD, TUTORIAL_REWARD, remainingLife, coinsFor } from './game'
import { coinPackages, findPackage, payByPrime } from './payment'

// 找出這個使用者、還沒結束的看診，順便拿到題目的答案和經過秒數
// 不是本人的或已結束的都找不到，避免偷用別人的紀錄或重複領獎勵
async function findOpenAttempt(attemptId: number, userId: number) {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT a.id, a.problem_id, a.mistakes, p.bug_line, p.explanation,
            TIMESTAMPDIFF(SECOND, a.started_at, NOW()) AS seconds_used
     FROM attempts a
     JOIN problems p ON a.problem_id = p.id
     WHERE a.id = ? AND a.user_id = ? AND a.finished_at IS NULL`,
    [attemptId, userId],
  )
  return rows[0]
}

// 回傳格式統一：成功一律是 { data: ... }，失敗一律是 { error: true, message: ... }
// 前端只要先看有沒有 error，再從 data 拿資料
const app = express()
const port = 8000

// 讓 req.body 能讀到前端送來的 JSON
app.use(express.json())

// 只允許自己的前端呼叫 API，FRONTEND_URL 可以用逗號放多個網址（本機和線上）
app.use(cors({ origin: process.env.FRONTEND_URL?.split(',') }))

app.get('/', (req, res) => {
  res.send('Bug Clinic API 運作中')
})

// 取得所有題目和選項
// 不回傳 bug_line、explanation、is_correct，答案只留在後端
app.get('/api/problems', async (req, res) => {
  const [problems] = await pool.query<RowDataPacket[]>(
    'SELECT id, pet_name, emoji, topic, error_message, symptom_zh, code FROM problems',
  )
  const [options] = await pool.query<RowDataPacket[]>(
    'SELECT id, problem_id, option_text FROM problem_options ORDER BY problem_id, sort_order',
  )

  // 把選項放進各自的題目底下
  const result = problems.map((p) => ({
    ...p,
    options: options.filter((o) => o.problem_id === p.id),
  }))

  res.json({ data: result })
})

// 註冊：信箱重複回 400，密碼雜湊後才存進資料庫
app.post('/api/user', async (req, res) => {
  const { name, email, password } = req.body

  if (!name || !email || !password) {
    res.status(400).json({ error: true, message: '請填寫所有欄位' })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>('SELECT id FROM users WHERE email = ?', [email])
  if (rows.length > 0) {
    res.status(400).json({ error: true, message: '重複的電子郵件' })
    return
  }

  const passwordHash = await bcrypt.hash(password, 10)
  await pool.query('INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)', [
    name,
    email,
    passwordHash,
  ])

  res.json({ data: { ok: true } })
})

// 登入：帳密正確就發 JWT，7 天後失效
app.put('/api/user/auth', async (req, res) => {
  const { email, password } = req.body

  if (!email || !password) {
    res.status(400).json({ error: true, message: '請填寫所有欄位' })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id, name, email, password_hash FROM users WHERE email = ?',
    [email],
  )
  const user = rows[0]

  // 信箱不存在或密碼錯都回同一句，避免被猜出哪些信箱有註冊
  if (!user || !(await bcrypt.compare(password, user.password_hash))) {
    res.status(400).json({ error: true, message: '電子郵件或密碼錯誤' })
    return
  }

  const token = jwt.sign(
    { id: user.id, name: user.name, email: user.email },
    process.env.JWT_SECRET as string,
    { expiresIn: '7d' },
  )

  res.json({ data: { token } })
})

// 取得目前登入的使用者，沒登入回 data: null
// 金幣和經驗值會變動，所以每次都從資料庫拿最新的
app.get('/api/user/auth', async (req, res) => {
  const tokenUser = getUser(req)
  if (!tokenUser) {
    res.json({ data: null })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id, name, email, coins, exp, tutorial_done FROM users WHERE id = ?',
    [tokenUser.id],
  )
  const user = rows[0]
  // MySQL 的 BOOLEAN 讀出來是 0 或 1，轉成 true / false 給前端
  res.json({ data: user ? { ...user, tutorial_done: !!user.tutorial_done } : null })
})

// 開始看診：建立一筆練習紀錄，開始時間由資料庫自動記錄
// 回傳時間限制，前端倒數和後端規則才會一致
app.post('/api/attempts', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const { problemId } = req.body
  const [problems] = await pool.query<RowDataPacket[]>('SELECT id FROM problems WHERE id = ?', [
    problemId,
  ])
  if (problems.length === 0) {
    res.status(400).json({ error: true, message: '找不到這個題目' })
    return
  }

  const [result] = await pool.query<ResultSetHeader>(
    'INSERT INTO attempts (user_id, problem_id) VALUES (?, ?)',
    [user.id, problemId],
  )

  res.json({ data: { attemptId: result.insertId, timeLimit: TIME_LIMIT } })
})

// 檢查點的那一行：錯了就把點錯次數加 1
app.post('/api/attempts/:id/line', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const attempt = await findOpenAttempt(Number(req.params.id), user.id)
  if (!attempt) {
    res.status(400).json({ error: true, message: '找不到這次看診' })
    return
  }

  if (Number(req.body.line) === attempt.bug_line) {
    res.json({ data: { correct: true } })
    return
  }

  await pool.query('UPDATE attempts SET mistakes = mistakes + 1 WHERE id = ?', [attempt.id])
  res.json({ data: { correct: false } })
})

// 選藥：只有一次機會，答對發獎勵；選錯、生命值歸零或沒選（前端時間到）都判定失敗，公布答案
// 不給重選，是因為猜到對為止沒有學習意義，失敗的題目會進住院部複習
app.post('/api/attempts/:id/answer', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const attempt = await findOpenAttempt(Number(req.params.id), user.id)
  if (!attempt) {
    res.status(400).json({ error: true, message: '找不到這次看診' })
    return
  }

  const [options] = await pool.query<RowDataPacket[]>(
    'SELECT id, option_text, is_correct FROM problem_options WHERE problem_id = ?',
    [attempt.problem_id],
  )
  const correctOption = options.find((o) => o.is_correct)
  const picked = options.find((o) => o.id === Number(req.body.optionId))

  let mistakes = attempt.mistakes
  if (picked && !picked.is_correct) mistakes += 1

  const seconds = attempt.seconds_used
  const life = remainingLife(seconds, mistakes)

  if (picked?.is_correct && life > 0) {
    const coins = coinsFor(life)

    // 結束看診、加金幣經驗、寫金幣明細，三件事放在同一個 transaction
    const conn = await pool.getConnection()
    try {
      await conn.beginTransaction()

      // 加上 finished_at IS NULL：同一次看診同時送來好幾次答案，只有第一次改得到
      // 後面幾次改到 0 筆，就知道已經領過獎勵，直接取消
      const [result] = await conn.query<ResultSetHeader>(
        `UPDATE attempts
         SET is_correct = TRUE, mistakes = ?, seconds_used = ?,
             coins_earned = ?, exp_earned = ?, finished_at = NOW()
         WHERE id = ? AND finished_at IS NULL`,
        [mistakes, seconds, coins, EXP_REWARD, attempt.id],
      )
      if (result.affectedRows === 0) {
        await conn.rollback()
        res.status(400).json({ error: true, message: '這次看診已經結束' })
        return
      }

      await conn.query('UPDATE users SET coins = coins + ?, exp = exp + ? WHERE id = ?', [
        coins,
        EXP_REWARD,
        user.id,
      ])
      await conn.query(
        `INSERT INTO coin_transactions (user_id, amount, reason, attempt_id)
         VALUES (?, ?, 'attempt', ?)`,
        [user.id, coins, attempt.id],
      )

      await conn.commit()
    } catch {
      await conn.rollback()
      res.status(500).json({ error: true, message: '送出失敗，請稍後再試' })
      return
    } finally {
      conn.release()
    }

    res.json({
      data: {
        status: 'cured',
        coins,
        exp: EXP_REWARD,
        secondsUsed: seconds,
        explanation: attempt.explanation,
      },
    })
    return
  }

  if (life <= 0 || !picked || !picked.is_correct) {
    await pool.query(
      `UPDATE attempts
       SET is_correct = FALSE, mistakes = ?, seconds_used = ?, finished_at = NOW()
       WHERE id = ?`,
      [mistakes, seconds, attempt.id],
    )
    res.json({
      data: {
        status: 'failed',
        correctOption: correctOption?.option_text,
        explanation: attempt.explanation,
      },
    })
    return
  }
})

// 讀取自己的練習紀錄（病歷本），成功失敗都列出來，方便複習
// 只拿已結束的看診，看到一半的不會出現，答案不會提早洩漏
app.get('/api/attempts', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT a.id, a.problem_id, p.pet_name, p.emoji, p.topic, p.explanation,
            a.is_correct, a.mistakes, a.seconds_used,
            a.coins_earned, a.exp_earned, a.finished_at
     FROM attempts a
     JOIN problems p ON a.problem_id = p.id
     WHERE a.user_id = ? AND a.finished_at IS NOT NULL
     ORDER BY a.finished_at DESC`,
    [user.id],
  )

  res.json({ data: rows })
})

// 住院部：列出自己看過的每一題和治好率，治好率低的排前面，就是自己的弱點
// 只算已經結束的看診，所以可以附上正確答案和解說
app.get('/api/review', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.id, p.pet_name, p.emoji, p.topic, p.explanation,
            (SELECT o.option_text FROM problem_options o
             WHERE o.problem_id = p.id AND o.is_correct = TRUE LIMIT 1) AS correct_option,
            COUNT(*) AS tries,
            SUM(a.is_correct) AS cured,
            MAX(a.finished_at) AS last_at
     FROM attempts a
     JOIN problems p ON a.problem_id = p.id
     WHERE a.user_id = ? AND a.finished_at IS NOT NULL
     GROUP BY p.id
     ORDER BY SUM(a.is_correct) / COUNT(*) ASC, last_at DESC`,
    [user.id],
  )

  res.json({ data: rows })
})

// 零件商店：列出所有零件，有登入的話標出自己買過哪些
// 沒登入也能逛，owned 一律是 false
// 起始程式碼一律回傳，商店卡片要拿來畫預覽；編輯器本來就能隨便寫，藏起來也保護不了什麼
// 能不能裝上還是看 owned
// 排序照商店分頁的部位順序，同部位再照價格
app.get('/api/parts', async (req, res) => {
  const user = getUser(req)

  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.id, p.name, p.category, p.slot, p.price, p.sprite, p.starter_code,
            up.id IS NOT NULL AS owned
     FROM parts p
     LEFT JOIN user_parts up ON up.part_id = p.id AND up.user_id = ?
     ORDER BY FIELD(p.slot, 'body', 'horn', 'eyes', 'mouth', 'pattern',
                    'wings', 'tail', 'feet', 'accessory'),
              p.price, p.id`,
    [user?.id ?? 0],
  )

  // MySQL 回傳的 owned 是 0 或 1，轉成 true / false 給前端
  const result = rows.map((r) => ({ ...r, owned: Boolean(r.owned) }))

  res.json({ data: result })
})

// 買零件：扣金幣、記錄擁有、寫明細，三件事放在同一個 transaction
// 任何一步失敗就全部取消，不會發生扣了錢卻沒拿到零件
app.post('/api/parts/:id/purchase', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  // transaction 裡每一句都要用同一條連線，所以從連線池借一條出來
  const conn = await pool.getConnection()

  try {
    await conn.beginTransaction()

    // 第一句就用 FOR UPDATE 鎖住這個玩家，連點送來的第二次購買會在這裡排隊
    // 一定要放在最前面，排到的時候後面查到的才會是上一次買完的最新資料
    const [users] = await conn.query<RowDataPacket[]>(
      'SELECT coins FROM users WHERE id = ? FOR UPDATE',
      [user.id],
    )
    const coins = users[0]?.coins ?? 0

    const [parts] = await conn.query<RowDataPacket[]>(
      'SELECT id, price, starter_code FROM parts WHERE id = ?',
      [Number(req.params.id)],
    )
    const part = parts[0]
    if (!part) {
      await conn.rollback()
      res.status(400).json({ error: true, message: '找不到這個零件' })
      return
    }

    const [owned] = await conn.query<RowDataPacket[]>(
      'SELECT id FROM user_parts WHERE user_id = ? AND part_id = ?',
      [user.id, part.id],
    )
    if (owned.length > 0) {
      await conn.rollback()
      res.status(400).json({ error: true, message: '已經買過這個零件' })
      return
    }

    if (coins < part.price) {
      await conn.rollback()
      res.status(400).json({ error: true, message: '金幣不夠' })
      return
    }

    await conn.query('UPDATE users SET coins = coins - ? WHERE id = ?', [part.price, user.id])
    await conn.query('INSERT INTO user_parts (user_id, part_id) VALUES (?, ?)', [user.id, part.id])
    await conn.query(
      `INSERT INTO coin_transactions (user_id, amount, reason, part_id)
       VALUES (?, ?, 'purchase', ?)`,
      [user.id, -part.price, part.id],
    )

    await conn.commit()

    // 回傳新的餘額和起始程式碼，前端不用再查一次
    res.json({ data: { coins: coins - part.price, starter_code: part.starter_code } })
  } catch {
    // 中途出錯（例如資料庫斷線），前面做的全部取消
    await conn.rollback()
    res.status(500).json({ error: true, message: '購買失敗，請稍後再試' })
  } finally {
    // 不管成功失敗都要把連線還回連線池
    conn.release()
  }
})

// 完成新手教程：發一次獎勵金幣
// 跟答對發獎勵同一招：UPDATE 加上 WHERE tutorial_done = FALSE，
// 同時送很多次也只有第一次改得到（affectedRows = 1），其他次都是 0，不會重複領
app.post('/api/tutorial/complete', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const conn = await pool.getConnection()
  try {
    await conn.beginTransaction()

    const [result] = await conn.query<ResultSetHeader>(
      'UPDATE users SET tutorial_done = TRUE, coins = coins + ? WHERE id = ? AND tutorial_done = FALSE',
      [TUTORIAL_REWARD, user.id],
    )
    if (result.affectedRows === 0) {
      await conn.rollback()
      res.status(400).json({ error: true, message: '已經領過教程獎勵了' })
      return
    }

    // 金幣明細記一筆，reason 是 tutorial，attempt_id、part_id、order_id 都留 NULL
    await conn.query(
      `INSERT INTO coin_transactions (user_id, amount, reason)
       VALUES (?, ?, 'tutorial')`,
      [user.id, TUTORIAL_REWARD],
    )

    const [rows] = await conn.query<RowDataPacket[]>('SELECT coins FROM users WHERE id = ?', [
      user.id,
    ])

    await conn.commit()
    res.json({ data: { coins: rows[0].coins, reward: TUTORIAL_REWARD } })
  } catch {
    await conn.rollback()
    res.status(500).json({ error: true, message: '領取失敗，請稍後再試' })
  } finally {
    conn.release()
  }
})

// 讀取自己的合成獸，沒存過回 data: null，前端就用預設的樣子
// 資料庫裡是一段 JSON 文字，拆回 html、css、js 三格再回傳
app.get('/api/chimera', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT name, code, updated_at FROM chimeras WHERE user_id = ?',
    [user.id],
  )
  const chimera = rows[0]
  if (!chimera) {
    res.json({ data: null })
    return
  }

  res.json({
    data: { name: chimera.name, code: JSON.parse(chimera.code), updatedAt: chimera.updated_at },
  })
})

// 存檔：一個玩家只有一隻，第一次存是新增，之後都是覆蓋
app.put('/api/chimera', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const { html, css, js } = req.body?.code ?? {}
  if (typeof html !== 'string' || typeof css !== 'string' || typeof js !== 'string') {
    res.status(400).json({ error: true, message: '程式碼格式不對' })
    return
  }

  // 三格包成一段 JSON 文字存進 code 欄位，限制長度避免塞爆資料庫
  const code = JSON.stringify({ html, css, js })
  if (code.length > 20000) {
    res.status(400).json({ error: true, message: '程式碼太長了，最多 20000 字' })
    return
  }

  // user_id 有 UNIQUE：沒有這個玩家的資料就新增，已經有就改成新的程式碼
  await pool.query(
    `INSERT INTO chimeras (user_id, code) VALUES (?, ?)
     ON DUPLICATE KEY UPDATE code = ?`,
    [user.id, code, code],
  )

  res.json({ data: { ok: true } })
})

// 金幣方案列表，不用登入也能看
app.get('/api/coin-packages', (req, res) => {
  res.json({ data: coinPackages })
})

// 買金幣：建立訂單 → 向 TapPay 收款 → 成功才加金幣
app.post('/api/orders', async (req, res) => {
  const user = getUser(req)
  if (!user) {
    res.status(403).json({ error: true, message: '請先登入' })
    return
  }

  const { prime, packageId } = req.body ?? {}
  const pack = findPackage(packageId)
  if (typeof prime !== 'string' || !prime || !pack) {
    res.status(400).json({ error: true, message: '付款資料不完整' })
    return
  }

  // 1. 先建立一筆未付款的訂單，之後不管成功失敗都查得到
  const orderNumber = `${Date.now()}${Math.floor(Math.random() * 1000)}`
  const [created] = await pool.query<ResultSetHeader>(
    'INSERT INTO orders (number, user_id, amount, coins) VALUES (?, ?, ?, ?)',
    [orderNumber, user.id, pack.amount, pack.coins],
  )
  const orderId = created.insertId

  // 2. 向 TapPay 收款。這一步要等外部服務，所以放在 transaction 外面，不佔住資料庫
  const payment = await payByPrime({
    prime,
    amount: pack.amount,
    details: pack.name,
    orderNumber,
    cardholder: { name: user.name, email: user.email, phone_number: '0912345678' },
  })

  if (payment.status !== 0) {
    await pool.query("UPDATE orders SET status = 'FAILED', message = ? WHERE id = ?", [
      payment.msg,
      orderId,
    ])
    res.status(400).json({ error: true, message: `付款失敗：${payment.msg}` })
    return
  }

  // 3. 收款成功：訂單改成已付款、加金幣、寫明細，三件事綁在同一個 transaction
  const conn = await pool.getConnection()
  try {
    await conn.beginTransaction()

    // 只有還沒付款的訂單改得到，避免同一筆訂單加兩次金幣
    const [paid] = await conn.query<ResultSetHeader>(
      `UPDATE orders SET status = 'PAID', rec_trade_id = ?, paid_at = NOW()
       WHERE id = ? AND status = 'UNPAID'`,
      [payment.rec_trade_id ?? null, orderId],
    )
    if (paid.affectedRows === 0) {
      await conn.rollback()
      res.status(400).json({ error: true, message: '這筆訂單已經處理過了' })
      return
    }

    await conn.query('UPDATE users SET coins = coins + ? WHERE id = ?', [pack.coins, user.id])
    await conn.query(
      `INSERT INTO coin_transactions (user_id, amount, reason, order_id)
       VALUES (?, ?, 'payment', ?)`,
      [user.id, pack.coins, orderId],
    )

    const [rows] = await conn.query<RowDataPacket[]>('SELECT coins FROM users WHERE id = ?', [
      user.id,
    ])
    await conn.commit()

    res.json({ data: { number: orderNumber, coins: rows[0].coins, added: pack.coins } })
  } catch {
    // 錢已經收了但加金幣失敗：訂單會停在 UNPAID，之後可以用 rec_trade_id 查帳補發
    await conn.rollback()
    res.status(500).json({ error: true, message: '付款成功但加金幣失敗，請聯絡我們' })
  } finally {
    conn.release()
  }
})

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
