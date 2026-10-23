import express from 'express'
import type { RowDataPacket, ResultSetHeader } from 'mysql2'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { pool } from './db'
import { getUser } from './auth'
import { TIME_LIMIT, EXP_REWARD, remainingLife, coinsFor } from './game'

// 找出這個使用者、還沒結束的看診，順便拿到題目的答案
// 不是本人的或已結束的都找不到，避免偷用別人的紀錄或重複領獎勵
async function findOpenAttempt(attemptId: number, userId: number) {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT a.id, a.problem_id, a.mistakes, a.started_at, p.bug_line, p.explanation
     FROM attempts a
     JOIN problems p ON a.problem_id = p.id
     WHERE a.id = ? AND a.user_id = ? AND a.finished_at IS NULL`,
    [attemptId, userId],
  )
  return rows[0]
}

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

  res.json({ token })
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
    'SELECT id, name, email, coins, exp FROM users WHERE id = ?',
    [tokenUser.id],
  )
  res.json({ data: rows[0] ?? null })
})

// 開始看診：建立一筆練習紀錄，開始時間由資料庫自動記錄
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

  res.json({ attemptId: result.insertId })
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
    res.json({ correct: true })
    return
  }

  await pool.query('UPDATE attempts SET mistakes = mistakes + 1 WHERE id = ?', [attempt.id])
  res.json({ correct: false })
})

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})