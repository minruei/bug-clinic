import type { Pool, RowDataPacket } from 'mysql2/promise'
import { pool } from './db'

// 題目照 id 排：同一隻動物的題目由淺到深，下一題和首頁推薦都靠這個順序
// 不回傳 bug_line、explanation、is_correct，答案只留在後端
export async function listProblems(db: Pick<Pool, 'query'> = pool) {
  const [problems] = await db.query<RowDataPacket[]>(
    'SELECT id, pet_name, emoji, topic, error_message, symptom_zh, code FROM problems ORDER BY id',
  )
  const [options] = await db.query<RowDataPacket[]>(
    'SELECT id, problem_id, option_text FROM problem_options ORDER BY problem_id, sort_order',
  )

  // 把選項放進各自的題目底下
  return problems.map((p) => ({
    ...p,
    options: options.filter((o) => o.problem_id === p.id),
  }))
}
