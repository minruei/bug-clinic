'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { Pixel } from '@/components/Pixel'
import {
  ChimeraEditor,
  installPart,
  isInstalled,
  starterChimera,
  type ChimeraCode,
  type EditorTab,
} from '@/components/ChimeraEditor'

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

// 零件的起始程式碼存成 JSON 文字，拆成 html、css、js 三段
// 舊格式只有一段文字的話，就整段放進零件分類對應的那一格
function parsePartCode(part: Part): ChimeraCode | null {
  if (!part.starter_code) return null
  try {
    const parsed = JSON.parse(part.starter_code)
    return { html: parsed.html ?? '', css: parsed.css ?? '', js: parsed.js ?? '' }
  } catch {
    return { html: '', css: '', js: '', [part.category]: part.starter_code }
  }
}

// 合成獸實驗室：先做零件商店，用金幣買零件藍圖
export default function LabPage() {
  const [parts, setParts] = useState<Part[]>([])
  const [coins, setCoins] = useState(0)
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)
  // 正在買哪一個零件，買的時候按鈕先鎖住，避免連點
  const [buyingId, setBuyingId] = useState<number | null>(null)
  const [message, setMessage] = useState('')
  // 合成獸的程式碼放在這一層保管，編輯器和商店都改得到；null 代表還在讀取
  const [code, setCode] = useState<ChimeraCode | null>(null)
  const [tab, setTab] = useState<EditorTab>('css')

  useEffect(() => {
    async function load() {
      const [userRes, partsRes] = await Promise.all([api('/api/user/auth'), api('/api/parts')])
      setLoggedIn(!!userRes.data)
      setCoins(userRes.data?.coins ?? 0)
      setParts(partsRes.data ?? [])

      // 有登入才去拿存檔，沒存過就用預設的樣子
      const saved = userRes.data ? await api('/api/chimera') : null
      setCode(saved?.data?.code ?? starterChimera)
    }
    load()
  }, [])

  async function saveChimera(code: ChimeraCode) {
    const res = await api('/api/chimera', 'PUT', { code })
    return !res.error
  }

  // 裝上零件：把零件的程式碼加進合成獸，編輯器切到零件分類那一格
  function install(part: Part) {
    const partCode = parsePartCode(part)
    if (!code || !partCode) return
    setCode(installPart(code, partCode))
    setTab(part.category)
    setMessage(`裝上${part.name}了！記得按存檔`)
  }

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
            <Pixel name="coin" size={18} /> {coins}{' '}
            <Link href="/coins" className="coin-link">
              買金幣
            </Link>
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
      {code && (
        <ChimeraEditor
          code={code}
          onChange={setCode}
          tab={tab}
          onTabChange={setTab}
          onSave={loggedIn ? saveChimera : undefined}
        />
      )}

      {message && <p className="lab-message">{message}</p>}

      <h2>零件商店</h2>
      <section className="parts">
        {parts.map((part) => {
          const canAfford = coins >= part.price
          const partCode = parsePartCode(part)
          const installed = !!code && !!partCode && isInstalled(code, partCode)

          // 買過的零件按鈕變成「裝上」，沒買過的維持購買
          if (part.owned) {
            return (
              <div key={part.id} className="part owned">
                <span className="tag">{categoryLabel[part.category]}</span>
                <p className="name">{part.name}</p>
                <p className="muted">已擁有</p>
                <button className="btn" onClick={() => install(part)} disabled={installed}>
                  {installed ? '已裝上' : '裝上'}
                </button>
              </div>
            )
          }

          let label = '購買'
          if (!canAfford) label = '金幣不夠'
          else if (buyingId === part.id) label = '購買中…'

          return (
            <div key={part.id} className="part">
              <span className="tag">{categoryLabel[part.category]}</span>
              <p className="name">{part.name}</p>
              <p className="price">
                <Pixel name="coin" size={18} /> {part.price}
              </p>
              <button
                className="btn"
                onClick={() => buy(part)}
                disabled={!loggedIn || !canAfford || buyingId !== null}
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
