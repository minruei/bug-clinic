'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { daily, week, beasts, rooms } from '@/lib/clinic'
import { cases } from '@/lib/cases'
import { api, clearToken } from '@/lib/api'
import { EXP_PER_LEVEL, levelFromExp, expInLevel } from '@/lib/level'

type User = {
  id: number
  name: string
  email: string
  coins: number
  exp: number
}

type Attempt = {
  id: number
  pet_name: string
  emoji: string
  topic: string
  is_correct: number
  mistakes: number
  seconds_used: number
  finished_at: string
}

// 打卡和神獸還沒做後端，先用示範資料
const streak = 5
const leaveTickets = 1

export default function Home() {
  const [user, setUser] = useState<User | null>(null)
  const [attempts, setAttempts] = useState<Attempt[]>([])
  const [loaded, setLoaded] = useState(false)

  // 進首頁時跟後端拿目前使用者和病歷本
  useEffect(() => {
    async function load() {
      const auth = await api('/api/user/auth')
      setUser(auth.data)
      if (auth.data) {
        const records = await api('/api/attempts')
        setAttempts(records.data)
      }
      setLoaded(true)
    }
    load()
  }, [])

  function logout() {
    clearToken()
    setUser(null)
    setAttempts([])
  }

  const exp = user?.exp ?? 0
  const level = levelFromExp(exp)
  const percent = Math.round((expInLevel(exp) / EXP_PER_LEVEL) * 100)
  const cured = attempts.filter((a) => a.is_correct).length
  const today = cases[daily.caseIndex]
  const nextBeast = beasts.find((b) => b.days > streak)

  return (
    <main className="wrap">
      <header className="top">
        <div>
          <p className="eyebrow">Bug Clinic</p>
          <h1>除蟲動物診所</h1>
        </div>
        {user ? (
          <div className="stats">
            <span>🪙 {user.coins}</span>
            <span>💉 已治癒 {cured}</span>
          </div>
        ) : (
          loaded && (
            <Link href="/login" className="btn">
              登入
            </Link>
          )
        )}
      </header>

      <section className="card daily">
        <div className="pet">{today.emoji}</div>
        <div className="grow">
          <p className="muted">📅 今日病患 #{daily.no}</p>
          <p className="big">
            {today.pet} 身體不舒服，正在等你
            <span className="tag">{today.topic}</span>
          </p>
          <p className="muted">全世界的醫生今天都在救同一隻</p>
        </div>
        <Link href="/clinic" className="btn">
          開始看診
        </Link>
      </section>

      <section className="two">
        <div className="card">
          <p className="name">🔥 連續打卡 {streak} 天</p>
          <div className="week">
            {week.map((d) => (
              <div key={d.day} className={`dot ${d.done ? 'done' : ''}`}>
                <span>{d.done ? '✓' : ''}</span>
                <small>{d.day}</small>
              </div>
            ))}
          </div>
          <p className="muted">🎫 請假券 {leaveTickets} 張，斷一天也不會歸零</p>
        </div>

        <div className="card doctor">
          <div className="avatar">👨‍⚕️</div>
          {user ? (
            <div className="grow">
              <p className="name">
                {user.name}
                <span className="tag">診所 Lv.{level}</span>
              </p>
              <div className="bar">
                <div className="fill exp" style={{ width: `${percent}%` }} />
              </div>
              <p className="muted">
                經驗值 {expInLevel(exp)} / {EXP_PER_LEVEL}
              </p>
              <button className="switch" onClick={logout}>
                下班登出
              </button>
            </div>
          ) : (
            <p className="grow muted">登入之後，看診會累積經驗值和金幣</p>
          )}
        </div>
      </section>

      <h2>神獸來訪</h2>
      {nextBeast && (
        <p className="muted">
          再打卡 {nextBeast.days - streak} 天，{nextBeast.icon} {nextBeast.name}
          就會來診所求診
        </p>
      )}
      <section className="beasts">
        {beasts.map((b) => {
          const met = streak >= b.days
          return (
            <div key={b.name} className={`beast ${met ? '' : 'locked'}`}>
              <span className="icon">{met ? b.icon : '❔'}</span>
              <p className="name">{met ? b.name : '???'}</p>
              <p className="muted">{met ? b.desc : `連續 ${b.days} 天`}</p>
            </div>
          )
        })}
      </section>

      <h2>我的診所</h2>
      <section className="rooms">
        {rooms.map((room) => {
          const locked = room.unlock > level
          return (
            <div key={room.name} className={`room ${locked ? 'locked' : ''}`}>
              <span className="icon">{locked ? '🔒' : room.icon}</span>
              <p className="name">{room.name}</p>
              <p className="muted">{locked ? `Lv.${room.unlock} 解鎖` : room.desc}</p>
            </div>
          )
        })}
      </section>

      <h2>病歷本</h2>
      <section className="card">
        {attempts.length === 0 && (
          <p className="muted">
            {user ? '還沒有看診紀錄，去看第一隻病患吧' : '登入之後，這裡會出現你的看診紀錄'}
          </p>
        )}
        {attempts.map((a) => (
          <div key={a.id} className="record">
            <span>
              {a.emoji} {a.pet_name}
            </span>
            <span className="tag">{a.topic}</span>
            <span className="grow">
              {a.is_correct ? '✅ 治好了' : '❌ 沒治好，再複習一次'}
              <br />
              <small className="muted">
                花了 {a.seconds_used} 秒，點錯 {a.mistakes} 次
              </small>
            </span>
            <span className="muted">
              {new Date(a.finished_at).toLocaleString('zh-TW', {
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                hour12: false,
              })}
            </span>
          </div>
        ))}
      </section>

      <p className="footnote">打卡和神獸目前是示範資料，插畫繪製中</p>
    </main>
  )
}