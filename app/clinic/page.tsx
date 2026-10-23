'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'

type Option = {
  id: number
  option_text: string
}

type Problem = {
  id: number
  pet_name: string
  emoji: string
  topic: string
  error_message: string
  code: string
  options: Option[]
}

// ready：還沒開始；find：找錯誤行；treat：選答案；cured / failed：結束
type Stage = 'ready' | 'find' | 'treat' | 'cured' | 'failed'

// 看診結束後，後端回傳的結果
type Result = {
  coins?: number
  exp?: number
  secondsUsed?: number
  correctOption?: string
  explanation: string
}

const MISTAKE_PENALTY = 5

export default function Clinic() {
  const [problems, setProblems] = useState<Problem[]>([])
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)
  const [index, setIndex] = useState(0)
  const [attemptId, setAttemptId] = useState<number | null>(null)
  const [timeLimit, setTimeLimit] = useState(60)
  const [hp, setHp] = useState(60)
  const [stage, setStage] = useState<Stage>('ready')
  const [foundLine, setFoundLine] = useState<number | null>(null)
  const [wrongLine, setWrongLine] = useState<number | null>(null)
  const [wrongOption, setWrongOption] = useState<number | null>(null)
  const [result, setResult] = useState<Result | null>(null)

  const problem = problems[index]
  const playing = stage === 'find' || stage === 'treat'

  // 進頁面時拿題目，並確認有沒有登入
  useEffect(() => {
    async function load() {
      const list = await api('/api/problems')
      setProblems(list)
      const auth = await api('/api/user/auth')
      setLoggedIn(auth.data !== null)
    }
    load()
  }, [])

  // 看診中每秒扣一點生命值，只是畫面顯示，真正的時間由後端計算
  useEffect(() => {
    if (!playing) return
    const timer = setInterval(() => {
      setHp((prev) => Math.max(prev - 1, 0))
    }, 1000)
    return () => clearInterval(timer)
  }, [playing])

  // 生命值歸零：不送答案，讓後端判定失敗並公布答案
  useEffect(() => {
    if (!playing || hp > 0 || attemptId === null) return
    async function timeUp() {
      const data = await api(`/api/attempts/${attemptId}/answer`, 'POST', {})
      if (data.status === 'failed') {
        setResult(data)
        setStage('failed')
      }
    }
    timeUp()
  }, [hp, playing, attemptId])

  // 開始看診：後端建立紀錄並開始計時
  async function start() {
    const data = await api('/api/attempts', 'POST', { problemId: problem.id })
    if (data.error) return
    setAttemptId(data.attemptId)
    setTimeLimit(data.timeLimit)
    setHp(data.timeLimit)
    setStage('find')
  }

  // 點某一行：交給後端判斷是不是錯誤行
  async function pickLine(line: number) {
    if (stage !== 'find') return
    const data = await api(`/api/attempts/${attemptId}/line`, 'POST', { line })
    if (data.correct) {
      setFoundLine(line)
      setWrongLine(null)
      setStage('treat')
    } else {
      setWrongLine(line)
      setHp((prev) => Math.max(prev - MISTAKE_PENALTY, 0))
    }
  }

  // 選答案：後端回傳 cured、wrong 或 failed
  async function pickOption(optionId: number) {
    const data = await api(`/api/attempts/${attemptId}/answer`, 'POST', { optionId })
    if (data.status === 'cured') {
      setResult(data)
      setStage('cured')
    } else if (data.status === 'failed') {
      setResult(data)
      setStage('failed')
    } else if (data.status === 'wrong') {
      setWrongOption(optionId)
      // 用後端算的生命值，跟畫面倒數對齊
      setHp(data.life)
    }
  }

  // 下一位病患：清空畫面，回到還沒開始的狀態
  function next() {
    setIndex((prev) => (prev + 1) % problems.length)
    setAttemptId(null)
    setStage('ready')
    setFoundLine(null)
    setWrongLine(null)
    setWrongOption(null)
    setResult(null)
  }

  if (loggedIn === false) {
    return (
      <main className="wrap">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <section className="card result">
          <p className="big">🩺 看診前要先打卡上班</p>
          <p className="muted">登入之後，看診紀錄、金幣和經驗值才會存下來</p>
          <Link href="/login" className="btn">
            去登入
          </Link>
        </section>
      </main>
    )
  }

  if (!problem) {
    return (
      <main className="wrap">
        <p className="muted">病患資料讀取中...</p>
      </main>
    )
  }

  const face = stage === 'cured' ? '😊' : stage === 'failed' ? '😵' : hp < 20 ? '😣' : '🤒'
  const hpColor = hp < 20 ? 'low' : hp < 40 ? 'mid' : ''

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <span className="muted">
          病患 {index + 1} / {problems.length}
        </span>
      </header>

      <section className="card patient">
        <div className={`pet ${playing ? 'shake' : ''}`}>
          {problem.emoji}
          <span className="face">{face}</span>
        </div>
        <div className="grow">
          <p className="name">
            {problem.pet_name}
            <span className="tag">{problem.topic}</span>
          </p>
          <div className="bar">
            <div className={`fill hp ${hpColor}`} style={{ width: `${(hp / timeLimit) * 100}%` }} />
          </div>
          <p className="muted">生命值 {hp} 秒</p>
        </div>
      </section>

      <section className="card symptom">
        <p className="muted">症狀</p>
        <p className="mono">{problem.error_message}</p>
      </section>

      {stage === 'ready' && (
        <button className="btn" onClick={start}>
          開始看診（倒數 {timeLimit} 秒）
        </button>
      )}

      {playing && (
        <p className="hint">
          {stage === 'find' && '🔍 第一步：點出 bug 躲在哪一行'}
          {stage === 'treat' && '💊 第二步：選擇正確的藥'}
        </p>
      )}

      {/* 按下開始才顯示程式碼，避免先偷看再計時 */}
      {stage !== 'ready' && (
        <section className="code">
          {problem.code.split('\n').map((text, i) => {
            const line = i + 1
            const found = line === foundLine
            return (
              <button
                key={line}
                className={`line ${found ? 'found' : ''} ${wrongLine === line ? 'wrong' : ''}`}
                onClick={() => pickLine(line)}
              >
                <span className="num">{line}</span>
                <span>{text || ' '}</span>
                {found && <span className="bug">🐛</span>}
              </button>
            )
          })}
        </section>
      )}

      {stage === 'treat' && (
        <section className="options">
          {problem.options.map((opt) => (
            <button
              key={opt.id}
              className={`option ${wrongOption === opt.id ? 'wrong' : ''}`}
              onClick={() => pickOption(opt.id)}
            >
              💊 <span className="mono">{opt.option_text}</span>
            </button>
          ))}
        </section>
      )}

      {stage === 'cured' && result && (
        <section className="card result ok">
          <p className="big">🎉 {problem.pet_name} 康復了！</p>
          <p>{result.explanation}</p>
          <p className="muted">
            花了 {result.secondsUsed} 秒　診療費 🪙 +{result.coins}　經驗值 +{result.exp}
          </p>
          <button className="btn" onClick={next}>
            下一位病患
          </button>
        </section>
      )}

      {stage === 'failed' && result && (
        <section className="card result bad">
          <p className="big">🚑 {problem.pet_name} 先轉去住院部</p>
          <p>
            正確的藥：<span className="mono">{result.correctOption}</span>
          </p>
          <p>{result.explanation}</p>
          <p className="muted">已記進病歷本，之後再來複習</p>
          <button className="btn" onClick={next}>
            下一位病患
          </button>
        </section>
      )}
    </main>
  )
}