import express from 'express'
import cors from 'cors'
import type { RowDataPacket, ResultSetHeader } from 'mysql2'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { pool } from './db'
import { getUser } from './auth'
import { TIME_LIMIT, EXP_REWARD, remainingLife, coinsFor } from './game'

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
    'SELECT id, name, email, coins, exp FROM users WHERE id = ?',
    [tokenUser.id],
  )
  res.json({ data: rows[0] ?? null })
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
    await pool.query(
      `UPDATE attempts
       SET is_correct = TRUE, mistakes = ?, seconds_used = ?,
           coins_earned = ?, exp_earned = ?, finished_at = NOW()
       WHERE id = ?`,
      [mistakes, seconds, coins, EXP_REWARD, attempt.id],
    )
    await pool.query('UPDATE users SET coins = coins + ?, exp = exp + ? WHERE id = ?', [
      coins,
      EXP_REWARD,
      user.id,
    ])
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

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})