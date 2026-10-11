'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { cases } from '@/lib/cases'
import { player, daily } from '@/lib/clinic'

const TIME = 60

type Stage = 'find' | 'treat' | 'cured' | 'failed'

export default function Clinic() {
  const [index, setIndex] = useState(0)
  const [hp, setHp] = useState(TIME)
  const [stage, setStage] = useState<Stage>('find')
  const [wrongLine, setWrongLine] = useState<number | null>(null)
  const [wrongOption, setWrongOption] = useState<number | null>(null)
  const [mistakes, setMistakes] = useState(0)
  const [copied, setCopied] = useState(false)

  const patient = cases[index]
  const playing = stage === 'find' || stage === 'treat'
  const isDaily = index === daily.caseIndex

  // 看診中每秒扣一點生命值
  useEffect(() => {
    if (!playing) return
    const timer = setInterval(() => {
      setHp((prev) => {
        if (prev <= 1) {
          setStage('failed')
          return 0
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timer)
  }, [playing])

  function pickLine(line: number) {
    if (stage !== 'find') return
    if (line === patient.bugLine) {
      setStage('treat')
      setWrongLine(null)
    } else {
      setWrongLine(line)
      setMistakes((prev) => prev + 1)
      setHp((prev) => Math.max(prev - 5, 1))
    }
  }

  function pickOption(i: number) {
    if (i === patient.answer) {
      setStage('cured')
    } else {
      setWrongOption(i)
      setMistakes((prev) => prev + 1)
      setHp((prev) => Math.max(prev - 5, 1))
    }
  }

  function next() {
    setIndex((prev) => (prev + 1) % cases.length)
    setHp(TIME)
    setStage('find')
    setWrongLine(null)
    setWrongOption(null)
    setMistakes(0)
    setCopied(false)
  }

  // 分享時不透露答案，只顯示秒數和失誤
  const shareText = `除蟲動物診所 今日病患 #${daily.no}
${patient.emoji} ${TIME - hp} 秒治癒 ${'🩺'.repeat(3 - Math.min(mistakes, 2))}${'❌'.repeat(Math.min(mistakes, 2))}
🔥 連續打卡 ${player.streak + 1} 天`

  async function share() {
    await navigator.clipboard.writeText(shareText)
    setCopied(true)
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
          {isDaily ? `📅 今日病患 #${daily.no}` : `練習病患 ${index} / ${cases.length - 1}`}
        </span>
      </header>

      <section className="card patient">
        <div className={`pet ${playing ? 'shake' : ''}`}>
          {patient.emoji}
          <span className="face">{face}</span>
        </div>
        <div className="grow">
          <p className="name">
            {patient.pet}
            <span className="tag">{patient.topic}</span>
          </p>
          <div className="bar">
            <div className={`fill hp ${hpColor}`} style={{ width: `${(hp / TIME) * 100}%` }} />
          </div>
          <p className="muted">生命值 {hp} 秒</p>
        </div>
      </section>

      <section className="card symptom">
        <p className="muted">症狀</p>
        <p className="mono">{patient.symptom}</p>
      </section>

      {playing && (
        <p className="hint">
          {stage === 'find' && '🔍 第一步：點出 bug 躲在哪一行'}
          {stage === 'treat' && '💊 第二步：選擇正確的藥'}
        </p>
      )}

      <section className="code">
        {patient.code.map((text, i) => {
          const line = i + 1
          const found = stage !== 'find' && line === patient.bugLine
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

      {stage === 'treat' && (
        <section className="options">
          {patient.options.map((opt, i) => (
            <button
              key={opt}
              className={`option ${wrongOption === i ? 'wrong' : ''}`}
              onClick={() => pickOption(i)}
            >
              💊 <span className="mono">{opt}</span>
            </button>
          ))}
        </section>
      )}

      {stage === 'cured' && (
        <section className="card result ok">
          <p className="big">🎉 {patient.pet} 康復了！</p>
          <p>{patient.note}</p>
          <p className="muted">診療費 🪙 +30　經驗值 +20　已收進病歷本</p>
          {isDaily && (
            <>
              <p className="checkin">
                ✅ 打卡成功！連續 {player.streak + 1} 天，再 1 天 🦌 麒麟就會來訪
              </p>
              <pre className="share">{shareText}</pre>
              <button className="btn ghost" onClick={share}>
                {copied ? '已複製，貼給朋友吧' : '分享成績'}
              </button>
            </>
          )}
          <button className="btn" onClick={next}>
            {isDaily ? '再練習一題' : '下一位病患'}
          </button>
        </section>
      )}

      {stage === 'failed' && (
        <section className="card result bad">
          <p className="big">🚑 {patient.pet} 先轉去住院部</p>
          <p>{patient.note}</p>
          <p className="muted">三天後會回來複診，再挑戰一次</p>
          <button className="btn" onClick={next}>
            下一位病患
          </button>
        </section>
      )}
    </main>
  )
}
