'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { Pixel, PetIcon } from '@/components/Pixel'
import { pets, petLabel, onePerPet } from '@/lib/pets'

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
  symptom_zh: string | null
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
  // 小診療室先選主題；從首頁推薦或住院部帶 ?id= 進來就直接看那一題
  const [choosing, setChoosing] = useState(true)

  const problem = problems[index]
  const playing = stage === 'find' || stage === 'treat'

  // 進頁面時拿題目，並確認有沒有登入
  useEffect(() => {
    async function load() {
      const res = await api('/api/problems')
      const list: Problem[] = res.data ?? []
      setProblems(list)
      // 從住院部點「再看診一次」會帶著 ?id=，直接跳到那一題
      const id = Number(new URLSearchParams(window.location.search).get('id'))
      const found = list.findIndex((p) => p.id === id)
      if (found >= 0) {
        setIndex(found)
        setChoosing(false)
      }
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
      const { data } = await api(`/api/attempts/${attemptId}/answer`, 'POST', {})
      if (data?.status === 'failed') {
        setResult(data)
        setStage('failed')
      }
    }
    timeUp()
  }, [hp, playing, attemptId])

  // 開始看診：後端建立紀錄並開始計時
  async function start() {
    const res = await api('/api/attempts', 'POST', { problemId: problem.id })
    if (res.error) return
    const data = res.data
    setAttemptId(data.attemptId)
    setTimeLimit(data.timeLimit)
    setHp(data.timeLimit)
    setStage('find')
  }

  // 點某一行：交給後端判斷是不是錯誤行
  async function pickLine(line: number) {
    if (stage !== 'find') return
    const { data } = await api(`/api/attempts/${attemptId}/line`, 'POST', { line })
    if (data?.correct) {
      setFoundLine(line)
      setWrongLine(null)
      setStage('treat')
    } else {
      setWrongLine(line)
      setHp((prev) => Math.max(prev - MISTAKE_PENALTY, 0))
    }
  }

  // 選答案：只有一次機會，後端回傳 cured 或 failed
  async function pickOption(optionId: number) {
    const { data } = await api(`/api/attempts/${attemptId}/answer`, 'POST', { optionId })
    if (!data) return
    if (data.status === 'cured') {
      setResult(data)
      setStage('cured')
    } else if (data.status === 'failed') {
      // 記下選錯的是哪一個，結果畫面拿來對照正確答案
      setWrongOption(optionId)
      setResult(data)
      setStage('failed')
    }
  }

  // 隨機挑一題，避免挑到跟現在同一題
  function pickRandom() {
    if (problems.length < 2) return
    let i = index
    while (i === index) i = Math.floor(Math.random() * problems.length)
    choose(i)
  }

  // 選好主題，進到看診畫面
  function choose(i: number) {
    setIndex(i)
    setChoosing(false)
  }

  // 看完一位：預設直接接下一題，一直練下去；按「換主題」才回到選主題畫面
  function next(backToTopics = false) {
    if (backToTopics) setChoosing(true)
    else {
      // 同一隻動物的下一題，做到最後一題再從頭開始，同一個觀念一直練下去
      const same = problems.filter((p) => p.pet_name === problem.pet_name)
      const nextOne = same[(same.indexOf(problem) + 1) % same.length]
      setIndex(problems.indexOf(nextOne))
    }
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
          <p className="big">
            <Pixel name="clinic" size={28} /> 看診前要先打卡上班
          </p>
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

  if (choosing) {
    return (
      <main className="wrap">
        <header className="top">
          <Link href="/" className="back">
            ← 回診所
          </Link>
          <button className="btn ghost" onClick={pickRandom}>
            <Pixel name="dice" size={22} /> 隨機抽一位
          </button>
        </header>
        <div>
          <p className="eyebrow">Clinic</p>
          <h1>小診療室</h1>
          <p className="muted">選一個想練習的觀念，每隻動物負責一種常見的 bug</p>
        </div>
        <section className="topic-grid">
          {onePerPet(problems).map((p) => (
            <button
              key={p.pet_name}
              className="beast room-link topic"
              onClick={() => choose(problems.indexOf(p))}
            >
              <PetIcon pet={p.pet_name} emoji={p.emoji} size={56} />
              <p className="name">{petLabel(p.pet_name)}</p>
              <p className="tag">{p.topic}</p>
              <p className="muted">{pets[p.pet_name]?.hint}</p>
              <p className="muted">
                共 {problems.filter((q) => q.pet_name === p.pet_name).length} 題
              </p>
            </button>
          ))}
        </section>
      </main>
    )
  }

  // 同一隻動物的所有題目，用來顯示第幾題
  const sameTopic = problems.filter((p) => p.pet_name === problem.pet_name)
  // 病患的樣子：失敗昏迷，看診中血量不到一半就虛弱
  const mood = stage === 'failed' ? 'coma' : playing && hp < timeLimit / 2 ? 'weak' : 'normal'
  // 健康狀態：治好愛心、失敗 OK 繃、血量低心碎、其他發燒
  const face =
    stage === 'cured' ? 'cured' : stage === 'failed' ? 'failed' : hp < 20 ? 'danger' : 'sick'
  const hpColor = hp < 20 ? 'low' : hp < 40 ? 'mid' : ''

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <span className="muted">
          {problem.topic}　第 {sameTopic.indexOf(problem) + 1} / {sameTopic.length} 題
        </span>
      </header>

      {/* 電腦版左右兩欄：左邊病患和操作，右邊程式碼 */}
      <div className="clinic-grid">
        <div className="clinic-side">
          <section className="card patient">
            <div className={`pet ${playing ? 'shake' : ''}`}>
              <PetIcon pet={problem.pet_name} emoji={problem.emoji} size={80} mood={mood} />
              <span className="face">
                <Pixel name={face} size={32} />
              </span>
            </div>
            <div className="grow">
              <p className="name">
                {petLabel(problem.pet_name)}
                <span className="tag">{problem.topic}</span>
              </p>
              {pets[problem.pet_name] && (
                <p className="muted hint">
                  <Pixel name="bulb" size={18} /> {pets[problem.pet_name].hint}
                </p>
              )}
              <div className="bar">
                <div
                  className={`fill hp ${hpColor}`}
                  style={{ width: `${(hp / timeLimit) * 100}%` }}
                />
              </div>
              <p className="muted">生命值 {hp} 秒</p>
            </div>
          </section>

          {/* 每一題都是英文原文加中文：英文是真的會看到的樣子，中文幫忙理解 */}
          <section className="card symptom">
            <p className="muted">症狀</p>
            <p className="mono">{problem.error_message}</p>
            {problem.symptom_zh && <p className="muted">中文：{problem.symptom_zh}</p>}
          </section>

          {stage === 'ready' && (
            <>
              <button className="btn ghost" onClick={() => setChoosing(true)}>
                換一個主題
              </button>
              <button className="btn" onClick={start}>
                開始看診（倒數 {timeLimit} 秒）
              </button>
            </>
          )}

          {playing && (
            <p className="hint">
              {stage === 'find' && (
                <>
                  <Pixel name="magnifier" size={22} /> 第一步：點出 bug 躲在哪一行
                </>
              )}
              {stage === 'treat' && (
                <>
                  <Pixel name="pill" size={22} /> 第二步：選擇正確的藥
                </>
              )}
            </p>
          )}

          {stage === 'treat' && (
            <section className="options">
              {problem.options.map((opt) => (
                <button
                  key={opt.id}
                  className={`option ${wrongOption === opt.id ? 'wrong' : ''}`}
                  onClick={() => pickOption(opt.id)}
                >
                  <Pixel name="pill" size={22} /> <span className="mono">{opt.option_text}</span>
                </button>
              ))}
            </section>
          )}

          {stage === 'cured' && result && (
            <section className="card result ok">
              <p className="big">
                <Pixel name="cured" size={28} /> {petLabel(problem.pet_name)} 康復了！
              </p>
              <p>{result.explanation}</p>
              <p className="muted">
                花了 {result.secondsUsed} 秒　診療費 <Pixel name="coin" size={18} /> +{result.coins}
              </p>
              <div className="result-actions">
                <button className="btn" onClick={() => next()}>
                  下一題
                </button>
                <button className="btn ghost" onClick={() => next(true)}>
                  換主題
                </button>
              </div>
            </section>
          )}

          {stage === 'failed' && result && (
            <section className="card result bad">
              <p className="big">
                <Pixel name="failed" size={28} /> {petLabel(problem.pet_name)} 先轉去住院部
              </p>
              {wrongOption !== null && (
                <p>
                  你選的藥：
                  <span className="mono">
                    {problem.options.find((o) => o.id === wrongOption)?.option_text}
                  </span>
                </p>
              )}
              <p>
                正確的藥：<span className="mono">{result.correctOption}</span>
              </p>
              <p>{result.explanation}</p>
              <p className="muted">這題已經送進住院部，之後可以回去複習</p>
              <div className="result-actions">
                <button className="btn" onClick={() => next()}>
                  下一題
                </button>
                <button className="btn ghost" onClick={() => next(true)}>
                  換主題
                </button>
              </div>
            </section>
          )}
        </div>

        <div className="clinic-main">
          {/* 按下開始才顯示程式碼，避免先偷看再計時 */}
          {stage === 'ready' ? (
            <section className="card code-placeholder">
              <p className="muted">按下開始看診，病歷上的程式碼才會出現</p>
            </section>
          ) : (
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
                    {found && (
                      <span className="bug">
                        <Pixel name="bug" size={20} />
                      </span>
                    )}
                  </button>
                )
              })}
            </section>
          )}
        </div>
      </div>
    </main>
  )
}
