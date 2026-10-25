'use client'

import { useState } from 'react'
import { Pixel } from '@/components/Pixel'

// 下班登出、上班登入共用的門：滑過去門半開，按下去播完開關門動畫才執行 onDone
// 想換圖只要替換 public/pixel 裡的 door-closed、door-half、door-open 三張
const FRAME_MS = 180
const FRAMES = {
  // 上班：門慢慢打開走進去
  in: ['door-half', 'door-open', 'door-open'],
  // 下班：門打開走出去再關上
  out: ['door-open', 'door-half', 'door-closed'],
}

type Props = {
  direction: 'in' | 'out'
  label: string
  doneLabel: string
  onDone: () => void
}

export function DoorButton({ direction, label, doneLabel, onDone }: Props) {
  const [frame, setFrame] = useState('door-closed')
  const [busy, setBusy] = useState(false)

  function go() {
    if (busy) return
    setBusy(true)
    // 一格一格換圖，像翻頁動畫
    FRAMES[direction].forEach((name, i) => {
      setTimeout(() => setFrame(name), i * FRAME_MS)
    })
    setTimeout(onDone, FRAMES[direction].length * FRAME_MS + 120)
  }

  return (
    <button
      className="door-btn"
      onClick={go}
      onMouseEnter={() => !busy && setFrame('door-half')}
      onMouseLeave={() => !busy && setFrame('door-closed')}
    >
      <Pixel name={frame} size={32} alt="" />
      {busy ? doneLabel : label}
    </button>
  )
}
