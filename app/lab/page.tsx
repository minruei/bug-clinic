'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { Pixel } from '@/components/Pixel'
import { ChimeraEditor } from '@/components/ChimeraEditor'

type Part = {
  id: number
  name: string
  category: 'html' | 'css' | 'js'
  price: number
  sprite: string
  owned: boolean
  starter_code: string | null
}

// 分類標籤照改裝賽車的比喻：HTML 是骨架、CSS 是烤漆、JS 是引擎
const categoryLabel = {
  html: 'HTML 骨架',
  css: 'CSS 烤漆',
  js: 'JS 引擎',
}

// 合成獸實驗室：先做零件商店，用金幣買零件藍圖
export default function LabPage() {
  const [parts, setParts] = useState<Part[]>([])
  const [coins, setCoins] = useState(0)
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)
  // 正在買哪一個零件，買的時候按鈕先鎖住，避免連點
  const [buyingId, setBuyingId] = useState<number | null>(null)
  const [message, setMessage] = useState('')

  useEffect(() => {
    async function load() {
      const [userRes, partsRes] = await Promise.all([api('/api/user/auth'), api('/api/parts')])
      setLoggedIn(!!userRes.data)
      setCoins(userRes.data?.coins ?? 0)
      setParts(partsRes.data ?? [])
    }
    load()
  }, [])

  async function buy(part: Part) {
    setBuyingId(part.id)
    setMessage('')

    const res = await api(`/api/parts/${part.id}/purchase`, 'POST')
    setBuyingId(null)

    if (res.error) {
      setMessage(res.message)
      return
    }

    // 用後端回傳的新餘額更新畫面，不用重新整理
    setCoins(res.data.coins)
    setParts((prev) =>
      prev.map((p) =>
        p.id === part.id ? { ...p, owned: true, starter_code: res.data.starter_code } : p,
      ),
    )
    setMessage(`買到${part.name}了！`)
  }

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        {loggedIn && (
          <span className="muted">
            <Pixel name="coin" size={18} /> {coins}
          </span>
        )}
      </header>

      <div>
        <p className="eyebrow">Lab</p>
        <h1>合成獸實驗室</h1>
        <p className="muted">用治好動物賺來的金幣買零件，再自己改程式碼，打造你的合成獸</p>
      </div>

      {loggedIn === false && (
        <section className="card">
          <p>登入之後才能買零件</p>
          <Link href="/login" className="btn">
            去登入
          </Link>
        </section>
      )}

      <h2>我的合成獸</h2>
      <ChimeraEditor />

      {message && <p className="lab-message">{message}</p>}

      <h2>零件商店</h2>
      <section className="parts">
        {parts.map((part) => {
          const canAfford = coins >= part.price

          let label = '購買'
          if (part.owned) label = '已擁有'
          else if (!canAfford) label = '金幣不夠'
          else if (buyingId === part.id) label = '購買中…'

          return (
            <div key={part.id} className={`part ${part.owned ? 'owned' : ''}`}>
              <span className="tag">{categoryLabel[part.category]}</span>
              <p className="name">{part.name}</p>
              <p className="price">
                <Pixel name="coin" size={18} /> {part.price}
              </p>
              <button
                className="btn"
                onClick={() => buy(part)}
                disabled={!loggedIn || part.owned || !canAfford || buyingId !== null}
              >
                {label}
              </button>
            </div>
          )
        })}
      </section>
    </main>
  )
}
