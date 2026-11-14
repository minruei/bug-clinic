'use client'

import { useEffect, useRef, useState } from 'react'
import { toJsLine, type ChimeraCode } from '@/lib/chimera'
import { addConsoleError, type ConsoleError } from '@/lib/console'
import { PLAY_EXIT, playPage } from '@/lib/play'

type Props = {
  // 編輯器現在的程式碼，還沒存檔也可以玩
  code: ChimeraCode
  // 關掉時把玩的時候抓到的錯誤交回去，編輯器的主控台才看得到
  onClose: (errors: ConsoleError[]) => void
}

// 遊玩模式：合成獸放大到接近全螢幕，可以點、可以按鍵盤玩自己寫的動作
// 蓋在整個頁面上面，底下的編輯器沒有拿掉，關掉之後程式碼和捲動位置都跟原本一樣
export function PlayMode({ code, onClose }: Props) {
  const frameRef = useRef<HTMLIFrameElement>(null)
  const [errors, setErrors] = useState<ConsoleError[]>([])
  // Esc 是在 effect 裡收的，用 ref 拿到最新的錯誤
  const errorsRef = useRef(errors)
  useEffect(() => {
    errorsRef.current = errors
  }, [errors])
  const page = playPage(code)

  // 預覽傳來的訊息：Esc 就關掉，錯誤就記下來；只收自己這個預覽的
  useEffect(() => {
    function onMessage(event: MessageEvent) {
      if (event.source !== frameRef.current?.contentWindow) return
      if (event.data?.type === PLAY_EXIT) onClose(errorsRef.current)
      if (event.data?.type === 'chimera-error') {
        const error = {
          line: toJsLine(code, event.data.line, { catchErrors: true }),
          message: String(event.data.message),
        }
        setErrors((prev) => addConsoleError(prev, error))
      }
    }
    // 焦點在 X 按鈕這些外面的地方時，Esc 由外面的頁面收
    function onKey(event: KeyboardEvent) {
      if (event.key === 'Escape') onClose(errorsRef.current)
    }
    window.addEventListener('message', onMessage)
    window.addEventListener('keydown', onKey)
    return () => {
      window.removeEventListener('message', onMessage)
      window.removeEventListener('keydown', onKey)
    }
  }, [code, onClose])

  // 玩的時候底下的頁面不要跟著捲；關掉時放回原本的設定，捲動位置不會變
  useEffect(() => {
    const before = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = before
    }
  }, [])

  return (
    <div className="play-mode" role="dialog" aria-modal="true" aria-label="遊玩模式">
      <iframe
        ref={frameRef}
        className="play-mode-preview"
        title="遊玩模式的合成獸"
        sandbox="allow-scripts"
        srcDoc={page}
        // 載入好就讓預覽拿到焦點，方向鍵、空白鍵不用先點一下就能用
        onLoad={(e) => e.currentTarget.focus()}
      />
      <button className="play-mode-close" onClick={() => onClose(errors)} aria-label="離開遊玩模式">
        <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true">
          <path d="M3 3l12 12M15 3L3 15" stroke="currentColor" strokeWidth="3" />
        </svg>
      </button>
      {errors.length > 0 && (
        // 有錯誤時角落顯示幾個，點了回到編輯器看主控台
        <button
          className="play-mode-errors"
          onClick={() => onClose(errors)}
          aria-label={`有 ${errors.length} 個錯誤，回到編輯器看主控台`}
        >
          {errors.length}
        </button>
      )}
    </div>
  )
}
