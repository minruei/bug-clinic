import express from 'express'
import type { RowDataPacket } from 'mysql2'
import { pool } from './db'

const app = express()
const port = 8000

app.get('/', (req, res) => {
  res.send('Bug Clinic API 運作中')
})

// 取得所有題目和選項
// 不回傳 bug_line、explanation、is_correct，答案只留在後端
app.get('/api/problems', async (req, res) => {
  const [problems] = await pool.query<RowDataPacket[]>(
    'SELECT id, pet_name, emoji, topic, error_message, code FROM problems',
  )
  const [options] = await pool.query<RowDataPacket[]>(
    'SELECT id, problem_id, option_text FROM problem_options ORDER BY problem_id, sort_order',
  )

  // 把選項放進各自的題目底下
  const result = problems.map((p) => ({
    ...p,
    options: options.filter((o) => o.problem_id === p.id),
  }))

  res.json(result)
})

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})