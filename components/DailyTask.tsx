'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { api } from '@/lib/api'
import { CodeText } from '@/components/CodeText'
import { Pixel } from '@/components/Pixel'
import type { ChimeraCode } from '@/lib/chimera'
import {
  dailyCheckPage,
  examplePlaces,
  passesDaily,
  type DailyMeasure,
  type DailyTask as Task,
} from '@/lib/daily'
import { markCode } from '@/lib/inlineCode'
import { moves } from '@/lib/moves'

type Props = {
  // 玩家現在的程式碼，按「檢查」的那一刻拿去檢查和存檔
  code: ChimeraCode
  // 實驗室頁面的存檔，成功回 true
  onSave: (code: ChimeraCode) => Promise<boolean>
  // 領到獎勵後的金幣餘額，給右上角更新
  onCoins: (coins: number) => void
  // 點「參考動作」，請動作參考打開那一招
  onShowMove: (moveId: string) => void
}

// 難度標籤的顏色
const levelClass: Record<string, string> = { 簡單: 'easy', 普通: 'normal', 挑戰: 'hard' }

// 檢查要多久沒回應才算失敗：變色龍那題要等兩秒多看毛色有沒有變
const CHECK_TIMEOUT = 6000

// 每日任務卡片：今天的題目、說明、提示、獎勵
// 領取順序：在預覽裡檢查 → 通過才存檔 → 存檔成功才領獎；後端領獎時會拿存檔的程式碼再檢查一次
export function DailyTask({ code, onSave, onCoins, onShowMove }: Props) {
  const [task, setTask] = useState<Task | null>(null)
  // 正在檢查的那一版程式碼，有值就會放一個看不見的預覽進去量
  const [checking, setChecking] = useState<ChimeraCode | null>(null)
  const [busy, setBusy] = useState('')
  const [message, setMessage] = useState('')
  const [failed, setFailed] = useState(false)
  // 409：過了午夜題目換了，請玩家重新整理題目
  const [stale, setStale] = useState(false)
  // 看到第幾層提示：一開始只有第 1 層，按「再多一點提示」才往下
  const [hintLevel, setHintLevel] = useState(1)
  const frameRef = useRef<HTMLIFrameElement>(null)

  // 上一次拿到的是哪一題，換題的時候提示從第 1 層重新開始
  const keyRef = useRef<string | null>(null)

  const load = useCallback(async () => {
    const res = await api('/api/daily')
    const next: Task | null = res.error ? null : res.data
    if (next?.key !== keyRef.current) setHintLevel(1)
    keyRef.current = next?.key ?? null
    setTask(next)
  }, [])

  useEffect(() => {
    load()
  }, [load])

  // 通過檢查：先存檔，存好了才領獎
  const claim = useCallback(
    async (current: Task, checked: ChimeraCode) => {
      setBusy('存檔中…')
      const saved = await onSave(checked)
      if (!saved) {
        setBusy('')
        setFailed(true)
        setMessage('存檔失敗，再試一次')
        return
      }

      setBusy('領取中…')
      const res = await api('/api/daily/claim', 'POST', { key: current.key })
      setBusy('')
      if (res.error) {
        setFailed(true)
        setMessage(res.message)
        if (res.status === 409) {
          setStale(true)
          return
        }
        // 例如「今天已經領過了」：重新拿一次題目，卡片會變成已完成
        load()
        return
      }

      onCoins(res.data.coins)
      setTask({ ...current, claimed: true })
      setFailed(false)
      setMessage(`完成了！拿到 ${res.data.reward} 金幣`)
    },
    [onSave, onCoins, load],
  )

  // 檢查用的預覽量好之後會 postMessage 回來；只收自己那個 iframe 傳的
  useEffect(() => {
    if (!checking || !task) return
    const current = task
    const checked = checking

    function finish(passed: boolean, text = '') {
      setChecking(null)
      if (passed) {
        claim(current, checked)
      } else {
        setBusy('')
        setFailed(true)
        setMessage(text)
      }
    }

    function onMessage(event: MessageEvent) {
      if (event.source !== frameRef.current?.contentWindow) return
      if (event.data?.type !== 'daily-check' || event.data.key !== current.key) return
      const measure: DailyMeasure = event.data.measure ?? {}
      const passed = passesDaily(current.key, checked, measure)
      finish(passed, passed ? '' : `還沒完成喔：${current.hint}`)
    }

    const timer = setTimeout(
      () => finish(false, '檢查沒有回應，看看主控台有沒有錯誤，再試一次'),
      CHECK_TIMEOUT,
    )
    window.addEventListener('message', onMessage)
    return () => {
      clearTimeout(timer)
      window.removeEventListener('message', onMessage)
    }
  }, [checking, task, claim])

  function check() {
    setMessage('')
    setFailed(false)
    setBusy('檢查中…')
    setChecking(code)
  }

  async function refresh() {
    setStale(false)
    setMessage('')
    await load()
  }

  if (!task) return null
  const move = task.moveId ? moves.find((m) => m.id === task.moveId) : undefined

  return (
    <section className="daily-task">
      <div className="daily-task-head">
        <span className="tag">每日任務</span>
        <h3 className="daily-task-title">{task.title}</h3>
        {/* 難度和金幣包在一起：手機上放不下時兩個一起換到下一行 */}
        <span className="daily-task-meta">
          <span className={`daily-task-level level-${levelClass[task.level] ?? 'easy'}`}>
            難度：{task.level}
          </span>
          <span className="daily-task-reward">
            <Pixel name="coin" size={18} /> {task.reward}
          </span>
        </span>
      </div>
      <p>
        <CodeText text={markCode(task.description)} />
      </p>
      <div className="daily-task-hints">
        <p>
          <b>提示 1：</b>
          <CodeText text={markCode(task.hint)} />
        </p>
        {hintLevel >= 2 && (
          <p>
            <b>提示 2：</b>
            <CodeText text={markCode(task.reference)} />
          </p>
        )}
        {hintLevel >= 3 && (
          <div className="daily-task-example">
            <b>提示 3：直接貼上就能過關</b>
            {examplePlaces
              .filter((place) => task.example[place.tab])
              .map((place) => (
                <div key={place.tab}>
                  <p className="move-code-label">
                    <CodeText text={place.where} />
                  </p>
                  <pre className="move-code">
                    <code>{task.example[place.tab]}</code>
                  </pre>
                </div>
              ))}
          </div>
        )}
        {hintLevel < 3 && (
          <button className="daily-task-more" onClick={() => setHintLevel((n) => n + 1)}>
            再多一點提示
          </button>
        )}
      </div>

      <div className="daily-task-actions">
        {task.claimed ? (
          <p className="daily-task-done">今天已完成，明天再來</p>
        ) : (
          <button className="btn" onClick={check} disabled={!!busy || stale}>
            {busy || '檢查並領取'}
          </button>
        )}
        {move && (
          <button className="btn ghost" onClick={() => onShowMove(move.id)}>
            參考動作：{move.name}
          </button>
        )}
      </div>

      {message && (
        <p className={failed ? 'daily-task-error' : 'daily-task-ok'} aria-live="polite">
          <CodeText text={markCode(message)} />
        </p>
      )}
      {stale && (
        <button className="btn ghost" onClick={refresh}>
          重新整理題目
        </button>
      )}

      {/* 檢查用的預覽：跟編輯器一樣只開 allow-scripts，放在畫面外面，量完就拿掉 */}
      {checking && (
        <iframe
          ref={frameRef}
          className="daily-task-check"
          title="每日任務檢查"
          sandbox="allow-scripts"
          srcDoc={dailyCheckPage(checking, task.key)}
          aria-hidden="true"
          tabIndex={-1}
        />
      )}
    </section>
  )
}
