'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { rooms } from '@/lib/clinic'
import { beasts, unlockedBeasts } from '@/lib/dex'
import { Pixel, PetIcon } from '@/components/Pixel'
import { DoorButton } from '@/components/DoorButton'
import { WeekCard } from '@/components/WeekCard'
import { petLabel } from '@/lib/pets'
import { api, clearToken } from '@/lib/api'
import { type AttemptRecord } from '@/components/RecordList'

type User = {
  id: number
  name: string
  email: string
  coins: number
  exp: number
}

type Attempt = AttemptRecord

type Problem = {
  id: number
  pet_name: string
  emoji: string
  topic: string
}

type ReviewItem = Problem & {
  tries: number
  cured: number | string
}

type Next = {
  problem: Problem
  icon: string
  label: string
  title: string
  note: string
}

// 決定下一位病患：先回診弱點，再看新題目，都治好了就複習
function pickNext(problems: Problem[], review: ReviewItem[], loggedIn: boolean): Next | null {
  if (problems.length === 0) return null

  const weak = review.find((r) => Number(r.cured) < r.tries)
  if (weak) {
    return {
      problem: weak,
      icon: 'sick',
      label: '回診',
      title: `${petLabel(weak.pet_name)} 上次沒治好，回來找你了`,
      note: `治好 ${Number(weak.cured)} / ${weak.tries} 次，這是你的弱點`,
    }
  }

  const seen = new Set(review.map((r) => r.id))
  const fresh = problems.find((p) => !seen.has(p.id))
  if (fresh) {
    return {
      problem: fresh,
      icon: 'star',
      label: '初診',
      title: `${petLabel(fresh.pet_name)} 第一次來看診`,
      note: loggedIn ? '這是你還沒練過的新觀念' : '登入之後，會依照你的弱點推薦病患',
    }
  }

  const again = review[Math.floor(Math.random() * review.length)]
  return {
    problem: again,
    icon: 'cured',
    label: '複診',
    title: `${petLabel(again.pet_name)} 回來做健康檢查`,
    note: '你治好過了，再練一次加深印象',
  }
}

export default function Home() {
  const [user, setUser] = useState<User | null>(null)
  const [attempts, setAttempts] = useState<Attempt[]>([])
  const [problems, setProblems] = useState<Problem[]>([])
  const [review, setReview] = useState<ReviewItem[]>([])
  const [loaded, setLoaded] = useState(false)
  const router = useRouter()

  // 進首頁時跟後端拿使用者、題目、病歷本和複習紀錄
  useEffect(() => {
    async function load() {
      const list = await api('/api/problems')
      setProblems(list.data ?? [])
      const auth = await api('/api/user/auth')
      setUser(auth.data)
      if (auth.data) {
        const records = await api('/api/attempts')
        setAttempts(records.data ?? [])
        const rows = await api('/api/review')
        setReview(rows.data ?? [])
      }
      setLoaded(true)
    }
    load()
  }, [])

  function logout() {
    clearToken()
    setUser(null)
    setAttempts([])
    setReview([])
  }

  const next = loaded ? pickNext(problems, review, !!user) : null
  const curedPets = new Set(attempts.filter((a) => a.is_correct).map((a) => a.pet_name))
  // 一隻動物有很多題，動物的數量要用名字去重複來算
  const petCount = new Set(problems.map((p) => p.pet_name)).size
  const unlocked = unlockedBeasts(attempts, petCount)

  return (
    <main className="wrap">
      <header className="top">
        <div>
          <p className="eyebrow">Bug Clinic</p>
          <h1>除蟲動物診所</h1>
        </div>
        {user ? (
          <div className="stats">
            <span>
              <Pixel name="coin" size={22} /> {user.coins}
            </span>
          </div>
        ) : null}
      </header>

      <section className="card daily">
        {next ? (
          <>
            <div className="pet">
              <PetIcon pet={next.problem.pet_name} emoji={next.problem.emoji} size={72} />
            </div>
            <div className="grow">
              <p className="muted">
                今天推薦你看這一位 <Pixel name={next.icon} size={18} /> {next.label}
              </p>
              <p className="big">
                {next.title}
                <span className="tag">{next.problem.topic}</span>
              </p>
              <p className="muted">{next.note}</p>
            </div>
            <Link href={`/clinic?id=${next.problem.id}`} className="btn">
              看這一位
            </Link>
          </>
        ) : (
          <p className="muted">病患資料讀取中...</p>
        )}
      </section>

      <section className="two">
        {/* 圖鑑進度：治好的動物和解鎖的神獸 */}
        <Link href="/dex" className="card room-link">
          <p className="name">
            <Pixel name="dex" size={22} /> 我的圖鑑
          </p>
          <p className="muted">
            動物 {curedPets.size} / {petCount}，神獸 {unlocked.size} / {beasts.length}
          </p>
          <div className="bar">
            <div
              className="fill exp"
              style={{
                width: `${((curedPets.size + unlocked.size) / Math.max(petCount + beasts.length, 1)) * 100}%`,
              }}
            />
          </div>
          <p className="muted">治好動物、達成里程碑，就能收集神獸 →</p>
        </Link>

        <div className="card doctor">
          <div className="avatar">
            <Pixel name="doctor" size={64} alt="除蟲獸醫" />
          </div>
          {user ? (
            <div className="grow">
              <p className="name">{user.name}</p>
              <p className="muted">
                <Pixel name="coin" size={18} /> {user.coins} 金幣，之後可以用來解鎖新的房間
              </p>
              <DoorButton
                direction="out"
                label="下班登出"
                doneLabel="下班囉，明天見"
                onDone={logout}
              />
            </div>
          ) : (
            <>
              <p className="grow muted">登入之後，治好動物可以賺金幣，練習紀錄也會存下來</p>
              <DoorButton
                direction="in"
                label="上班登入"
                doneLabel="上班囉"
                onDone={() => router.push('/login')}
              />
            </>
          )}
        </div>
      </section>

      <h2>我的診所</h2>
      <section className="rooms">
        {rooms.map((room) => {
          const locked = !!room.locked
          const content = (
            <>
              <Pixel name={room.pixel} size={48} />
              <p className="name">{room.name}</p>
              <p className="tag">{room.tag}</p>
              <p className="muted">{room.desc}</p>
            </>
          )
          // 開放而且有頁面的診間，整張卡片都可以點
          return room.href && !locked ? (
            <Link key={room.name} href={room.href} className="room room-link">
              {content}
            </Link>
          ) : (
            <div key={room.name} className={`room ${locked ? 'locked' : ''}`}>
              {content}
            </div>
          )
        })}
      </section>
      {user && <WeekCard attempts={attempts} />}
    </main>
  )
}
