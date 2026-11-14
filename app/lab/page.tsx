'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { Pixel } from '@/components/Pixel'
import { ChimeraEditor, CodeViewer } from '@/components/ChimeraEditor'
import {
  buildPage,
  installPart,
  installedPartId,
  removePart,
  slots,
  starterChimera,
  type ChimeraCode,
  type EditorTab,
  type Slot,
} from '@/lib/chimera'
import { Tutorial } from '@/components/Tutorial'

type Part = {
  id: number
  name: string
  category: 'html' | 'css' | 'js'
  slot: Slot
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

// 商店卡片的預覽縮小一點，翅膀和尾巴才放得進小框框
// 手機上卡片更窄，iframe 寬度小於 160px 時再縮小一點
const PREVIEW_CSS = `
.chimera { transform: scale(0.55); }
@media (max-width: 160px) { .chimera { transform: scale(0.38); } }
body { overflow: hidden; }`

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
  const [tutorialDone, setTutorialDone] = useState(false)
  // 商店現在看的是哪個部位
  const [shopSlot, setShopSlot] = useState<Slot>('body')
  // 正在看哪個零件的詳情，null 是詳情框收起來
  const [viewingId, setViewingId] = useState<number | null>(null)
  const detailRef = useRef<HTMLElement>(null)
  // 上一次裝上、換上、卸下之前的程式碼，按「復原」就放回去；null 代表沒有可以復原的
  const [undoCode, setUndoCode] = useState<ChimeraCode | null>(null)
  // 教程用一隻全新的練習用合成獸，玩家自己的合成獸先收在這裡，結束時放回去
  // 不是 null 就代表教程正在進行（練習模式）
  const [practiceBackup, setPracticeBackup] = useState<ChimeraCode | null>(null)
  const practicing = practiceBackup !== null

  useEffect(() => {
    async function load() {
      const [userRes, partsRes] = await Promise.all([api('/api/user/auth'), api('/api/parts')])
      setLoggedIn(!!userRes.data)
      setCoins(userRes.data?.coins ?? 0)
      setTutorialDone(!!userRes.data?.tutorial_done)
      setParts(partsRes.data ?? [])

      // 有登入才去拿存檔，沒存過就用預設的樣子
      const saved = userRes.data ? await api('/api/chimera') : null
      const myCode = saved?.data?.code ?? starterChimera

      // 有登入、還沒做過教程：自動進入練習模式，自己的合成獸先收起來
      if (userRes.data && !userRes.data.tutorial_done) {
        setPracticeBackup(myCode)
        setCode(starterChimera)
      } else {
        setCode(myCode)
      }
    }
    load()
  }, [])

  async function saveChimera(code: ChimeraCode) {
    const res = await api('/api/chimera', 'PUT', { code })
    return !res.error
  }

  // 再玩一次：把自己的合成獸收起來，換一隻預設的來練習，不會動到存檔
  function startPractice() {
    if (!code) return
    setPracticeBackup(code)
    setCode(starterChimera)
    setTab('css')
    setMessage('')
    setUndoCode(null)
  }

  // 結束練習（完成、跳過、離開都一樣）：把自己的合成獸放回編輯器
  function endPractice(text: string) {
    if (practiceBackup) setCode(practiceBackup)
    setPracticeBackup(null)
    setMessage(text)
    setUndoCode(null)
  }

  // 教程四步都做完：第一次做請後端發獎勵，再玩一次就只是結束練習
  // 練習用的合成獸不存檔；成功回 null，失敗回錯誤訊息給教程顯示
  async function finishTutorial() {
    if (tutorialDone) {
      endPractice('練習完成！你的合成獸已經放回來了')
      return null
    }

    const res = await api('/api/tutorial/complete', 'POST')
    if (res.error) return res.message

    setCoins(res.data.coins)
    setTutorialDone(true)
    endPractice(`完成新手教程，拿到 ${res.data.reward} 金幣！你的合成獸已經放回來了`)
    return null
  }

  // 每個零件裝在預設合成獸上的樣子，零件清單沒變就不用重算
  const previews = useMemo(() => {
    const pages: Record<number, string> = {}
    for (const part of parts) {
      const partCode = parsePartCode(part)
      if (!partCode) continue
      const page = installPart(starterChimera, { ...part, code: partCode })
      pages[part.id] = buildPage({ ...page, css: page.css + PREVIEW_CSS })
    }
    return pages
  }, [parts])

  // 裝上零件：同部位原本的零件整段換掉，編輯器切到零件分類那一格
  // 不跳確認視窗，換錯了可以按「復原」
  function install(part: Part) {
    const partCode = parsePartCode(part)
    if (!code || !partCode) return
    // 練習用的合成獸不會存檔，裝上零件也會在離開練習時消失，所以先擋住
    if (practicing) {
      setMessage('練習中不能裝零件，完成或離開練習後再裝')
      return
    }

    const action = installedPartId(code, part.slot) === null ? '裝上' : '換上'
    setUndoCode(code)
    setCode(installPart(code, { ...part, code: partCode }))
    setTab(part.category)
    setMessage(`已${action}${part.name}，記得按存檔`)
  }

  // 卸下零件：把這個部位的標記段落拿掉
  function uninstall(part: Part) {
    if (!code) return
    if (practicing) {
      setMessage('練習中不能卸下零件，完成或離開練習後再卸下')
      return
    }
    setUndoCode(code)
    setCode(removePart(code, part.slot))
    setMessage(`已卸下${part.name}，記得按存檔`)
  }

  // 復原最近一次的零件動作，連玩家在那段改過的內容一起放回來
  function undo() {
    if (!undoCode) return
    setCode(undoCode)
    setUndoCode(null)
    setMessage('已復原')
  }

  // 玩家自己在編輯器打字之後就不能復原了，不然會把打的字一起蓋掉
  function editCode(next: ChimeraCode) {
    setCode(next)
    setUndoCode(null)
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

    setUndoCode(null)
    // 用後端回傳的新餘額更新畫面，不用重新整理
    setCoins(res.data.coins)
    setParts((prev) =>
      prev.map((p) =>
        p.id === part.id ? { ...p, owned: true, starter_code: res.data.starter_code } : p,
      ),
    )
    setMessage(`買到${part.name}了！`)
  }

  // 詳情畫面顯示零件原本的程式碼，不加標記；預覽是裝在預設合成獸上的原尺寸樣子
  const viewingPart = parts.find((p) => p.id === viewingId)
  const viewingCode = viewingPart ? parsePartCode(viewingPart) : null
  let detailPage = ''
  if (viewingPart && viewingCode) {
    const page = installPart(starterChimera, { ...viewingPart, code: viewingCode })
    detailPage = buildPage({ ...page, css: `${page.css}\nbody { overflow: hidden; }` })
  }

  // 打開或換一個零件的詳情時，捲到詳情框；從下面的卡片點上來，不捲的話會看不到
  // 要等詳情框畫出來才捲得到，所以放在 effect 裡
  useEffect(() => {
    if (viewingId !== null) {
      detailRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }, [viewingId])

  // 卡片和詳情框共用的按鈕
  // 沒買：購買；買了沒裝：裝上（同部位有別的零件叫換上）；裝在身上：卸下
  function partButton(part: Part) {
    const currentId = code ? installedPartId(code, part.slot) : null
    if (part.owned && currentId === part.id) {
      return (
        <button className="btn ghost" onClick={() => uninstall(part)}>
          卸下
        </button>
      )
    }
    if (part.owned) {
      return (
        <button className="btn" onClick={() => install(part)}>
          {currentId === null ? '裝上' : '換上'}
        </button>
      )
    }

    let label = '購買'
    if (coins < part.price) label = '金幣不夠'
    else if (buyingId === part.id) label = '購買中…'
    return (
      <button
        className="btn"
        onClick={() => buy(part)}
        disabled={!loggedIn || coins < part.price || buyingId !== null}
      >
        {label}
      </button>
    )
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

      <h2>{practicing ? '練習用合成獸' : '我的合成獸'}</h2>
      {code && practicing && (
        <Tutorial
          code={code}
          onChange={setCode}
          tab={tab}
          onTabChange={setTab}
          replay={tutorialDone}
          onFinish={finishTutorial}
          onSkip={() =>
            endPractice(
              tutorialDone
                ? '離開練習，你的合成獸已經放回來了'
                : '先跳過教程，下次進實驗室還會出現，也可以按「開始新手教程」',
            )
          }
        />
      )}
      {code && loggedIn && !practicing && (
        <button className="btn ghost tutorial-replay" onClick={startPractice}>
          {tutorialDone ? '再玩一次新手教程' : '開始新手教程（完成送 20 金幣）'}
        </button>
      )}
      {code && (
        <ChimeraEditor
          code={code}
          onChange={editCode}
          tab={tab}
          onTabChange={setTab}
          // 教程中不給存檔，避免練習用的合成獸蓋掉自己的作品
          onSave={loggedIn && !practicing ? saveChimera : undefined}
        />
      )}

      {message && (
        <p className="lab-message">
          {message}
          {undoCode && (
            <button className="btn ghost lab-undo" onClick={undo}>
              復原
            </button>
          )}
        </p>
      )}

      <h2>零件商店</h2>
      {viewingPart && viewingCode && (
        // 零件詳情框：開在分頁和卡片上面，底下的卡片照樣可以點
        <section className="part-detail" ref={detailRef}>
          <div className="part-detail-head">
            <span className="tag">{categoryLabel[viewingPart.category]}</span>
            <p className="part-detail-name">{viewingPart.name}</p>
            {viewingPart.owned ? (
              <p className="muted">已擁有</p>
            ) : (
              <p className="price">
                <Pixel name="coin" size={18} /> {viewingPart.price}
              </p>
            )}
            {partButton(viewingPart)}
            <button
              className="part-detail-close"
              onClick={() => setViewingId(null)}
              aria-label="收起零件詳情"
            >
              ✕
            </button>
          </div>
          <div className="part-detail-body">
            {/* 原尺寸預覽，會動的零件在這裡也點得動 */}
            <iframe
              className="part-detail-preview"
              title={`${viewingPart.name}預覽`}
              sandbox="allow-scripts"
              srcDoc={detailPage}
            />
            <CodeViewer code={viewingCode} label={viewingPart.name} />
          </div>
        </section>
      )}
      <div className="slot-tabs">
        {slots.map((s) => (
          <button
            key={s.key}
            className={`slot-tab ${shopSlot === s.key ? 'active' : ''}`}
            onClick={() => setShopSlot(s.key)}
          >
            {s.label}
          </button>
        ))}
      </div>
      <section className="parts">
        {parts
          .filter((part) => part.slot === shopSlot)
          .map((part) => (
            <div
              key={part.id}
              className={`part ${part.owned ? 'owned' : ''} ${viewingId === part.id ? 'viewing' : ''}`}
            >
              {/* 預覽跟編輯器一樣只開 allow-scripts，JS 零件在這裡也點得動 */}
              <iframe
                className="part-preview"
                title={`${part.name}預覽`}
                sandbox="allow-scripts"
                srcDoc={previews[part.id]}
              />
              <span className="tag">{categoryLabel[part.category]}</span>
              <p className="name">{part.name}</p>
              {part.owned ? (
                <p className="muted">已擁有</p>
              ) : (
                <p className="price">
                  <Pixel name="coin" size={18} /> {part.price}
                </p>
              )}
              {partButton(part)}
              <button className="part-code-btn" onClick={() => setViewingId(part.id)}>
                {viewingId === part.id ? '正在看程式碼' : '看程式碼'}
              </button>
            </div>
          ))}
      </section>
    </main>
  )
}
