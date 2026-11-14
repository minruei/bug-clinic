import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { pool } from './db'

// 每個玩家最多留幾個版本
export const KEEP_VERSIONS = 20

// 存檔：在同一個 transaction 裡更新合成獸、加一筆版本、刪掉超過 20 筆的舊版本
// 跟最新一筆版本一模一樣就不新增，連按存檔不會塞滿紀錄
// 回傳這次有沒有新增版本
export async function saveChimera(userId: number, code: string) {
  const conn = await pool.getConnection()
  try {
    await conn.beginTransaction()

    // user_id 有 UNIQUE：沒有這個玩家的資料就新增，已經有就改成新的程式碼
    await conn.query(
      `INSERT INTO chimeras (user_id, code) VALUES (?, ?)
       ON DUPLICATE KEY UPDATE code = ?`,
      [userId, code, code],
    )

    // FOR UPDATE 鎖住最新一筆，同時存兩次也不會都覺得「跟上一版不一樣」
    const [latest] = await conn.query<RowDataPacket[]>(
      'SELECT code FROM chimera_versions WHERE user_id = ? ORDER BY id DESC LIMIT 1 FOR UPDATE',
      [userId],
    )
    const added = latest[0]?.code !== code

    if (added) {
      await conn.query('INSERT INTO chimera_versions (user_id, code) VALUES (?, ?)', [
        userId,
        code,
      ])
      // 找出第 20 新的那筆，比它舊的都刪掉；不到 20 筆時子查詢是 NULL，什麼都不會刪
      // MySQL 不能在 DELETE 的子查詢直接查同一張表，所以多包一層
      await conn.query<ResultSetHeader>(
        `DELETE FROM chimera_versions
         WHERE user_id = ? AND id < (
           SELECT id FROM (
             SELECT id FROM chimera_versions WHERE user_id = ?
             ORDER BY id DESC LIMIT 1 OFFSET ?
           ) AS kept
         )`,
        [userId, userId, KEEP_VERSIONS - 1],
      )
    }

    await conn.commit()
    return added
  } catch (err) {
    await conn.rollback()
    throw err
  } finally {
    conn.release()
  }
}

// 自己的版本列表，新的在前；只回時間，不回程式碼
export async function listVersions(userId: number) {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id, created_at FROM chimera_versions WHERE user_id = ? ORDER BY id DESC',
    [userId],
  )
  return rows.map((r) => ({ id: r.id as number, createdAt: r.created_at as Date }))
}

// 拿一個版本的程式碼；WHERE 同時比對 user_id，別人的版本查不到，回 null
export async function getVersion(userId: number, id: number) {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id, code, created_at FROM chimera_versions WHERE id = ? AND user_id = ?',
    [id, userId],
  )
  const row = rows[0]
  if (!row) return null
  return { id: row.id as number, code: JSON.parse(row.code), createdAt: row.created_at as Date }
}
