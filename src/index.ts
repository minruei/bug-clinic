import express from 'express'
import type { RowDataPacket } from 'mysql2'
import bcrypt from 'bcryptjs'
import { pool } from './db'

const app = express()
const port = 8000
// 讓 req.body 能讀到前端送來的 JSON
app.use(express.json())

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
  
    res.json({ ok: true })
  })

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})