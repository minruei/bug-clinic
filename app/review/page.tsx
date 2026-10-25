'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { Pixel, PetIcon } from '@/components/Pixel'
import { petLabel } from '@/lib/pets'
import { type AttemptRecord } from '@/components/RecordList'

type ReviewItem = {
  id: number
  pet_name: string
  emoji: string
  topic: string
  explanation: string
  correct_option: string
  tries: number
  cured: number | string
}

// 住院部：沒治好的動物會留院，回去再看診一次治好才出院
// 跟小診療室的差別：小診療室是練新的題目，住院部是專門處理自己的弱點
export default function ReviewPage() {
  const [items, setItems] = useState<ReviewItem[]>([])
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)
  const [records, setRecords] = useState<AttemptRecord[]>([])

  useEffect(() => {
    async function load() {
      const data = await api('/api/review')
      if (data.error) {
        setLoggedIn(false)
        return
      }
      setLoggedIn(true)
      setItems(data.data ?? [])
      const history = await api('/api/attempts')
      setRecords(history.data ?? [])
    }
    load()
  }, [])

  // 每一題最後一次看診的結果，紀錄是新的在前面，所以第一次遇到的就是最新的
  const lastCured = new Map<number, boolean>()
  for (const r of records) {
    if (!lastCured.has(r.problem_id)) lastCured.set(r.problem_id, !!r.is_correct)
  }
  // 最後一次沒治好的留院，治好就出院
  const inpatients = items.filter((item) => lastCured.get(item.id) === false)
  const discharged = items.filter((item) => lastCured.get(item.id) === true)
  const weakTopics = [...new Set(inpatients.map((item) => item.topic))]

  if (loggedIn === false) {
    return (
      <main className="wrap">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <section className="card result">
          <p className="big">
            <Pixel name="ward" size={28} /> 住院部要先打卡上班才能進來
          </p>
          <p className="muted">登入之後，這裡會整理你看過的每一題和你的弱點</p>
          <Link href="/login" className="btn">
            去登入
          </Link>
        </section>
      </main>
    )
  }

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <span className="muted">
          留院 {inpatients.length}，已出院 {discharged.length}
        </span>
      </header>

      <div>
        <p className="eyebrow">Ward</p>
        <h1>住院部</h1>
        <p className="muted">
          錯題區：沒治好的動物會留下來住院。先打開解說複習觀念，再看診一次，治好牠就能出院
        </p>
      </div>

      {loggedIn && items.length === 0 && (
        <section className="card">
          <p>住院部現在是空的，先去小診療室看第一位吧。</p>
          <Link href="/clinic" className="btn">
            去看診
          </Link>
        </section>
      )}

      {loggedIn && items.length > 0 && inpatients.length === 0 && (
        <section className="card weak-topics done">
          <p>
            <Pixel name="cured" size={22} /> 目前沒有留院的動物，你看過的觀念都治好了
          </p>
        </section>
      )}

      {inpatients.length > 0 && (
        <>
          <h2>留院中</h2>
          <section className="card weak-topics">
            <p>
              還沒治好的觀念：<strong>{weakTopics.join('、')}</strong>
            </p>
            <p className="muted">先打開解說複習，再按「再看診一次」，治好就能出院</p>
          </section>
          <section className="review-list">
            {inpatients.map((item) => (
              <ReviewCard key={item.id} item={item} sick />
            ))}
          </section>
        </>
      )}

      {discharged.length > 0 && (
        <>
          <h2>已出院</h2>
          <p className="muted">治好過的觀念，想複習可以打開解說</p>
          <section className="review-list">
            {discharged.map((item) => (
              <ReviewCard key={item.id} item={item} />
            ))}
          </section>
        </>
      )}
    </main>
  )
}

// sick：留院中的動物顯示昏迷的樣子
function ReviewCard({ item, sick = false }: { item: ReviewItem; sick?: boolean }) {
  const cured = Number(item.cured)
  const rate = Math.round((cured / item.tries) * 100)
  const color = rate < 50 ? 'low' : rate < 100 ? 'mid' : ''

  return (
    <div className="card review-card">
      <div className="review-head">
        <p className="name">
          <PetIcon
            pet={item.pet_name}
            emoji={item.emoji}
            size={32}
            mood={sick ? 'coma' : 'normal'}
          />{' '}
          {petLabel(item.pet_name)}
          <span className="tag">{item.topic}</span>
        </p>
        <span className="muted">
          治好 {cured} / {item.tries} 次
        </span>
      </div>
      <div className="bar">
        <div className={`fill hp ${color}`} style={{ width: `${rate}%` }} />
      </div>
      {/* details 是 HTML 內建的展開收合，不用另外寫狀態 */}
      <details>
        <summary>看觀念解說</summary>
        <p>
          正確的藥：<span className="mono">{item.correct_option}</span>
        </p>
        <p>{item.explanation}</p>
      </details>
      <Link href={`/clinic?id=${item.id}`} className="btn ghost">
        再看診一次
      </Link>
    </div>
  )
}
