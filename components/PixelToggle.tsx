'use client'

type Props = {
  pixel: boolean
  onChange: (pixel: boolean) => void
  // 放在編輯器預覽或遊玩模式，位置各自用 class 決定
  className: string
}

// 像素模式的開關：預覽畫面變成 4px 的馬賽克，玩家自己寫的圓形、斜線也會變成像素風
// 用 aria-pressed 告訴螢幕閱讀器現在是開還是關
export function PixelToggle({ pixel, onChange, className }: Props) {
  return (
    <button
      className={`pixel-toggle ${className}`}
      onClick={() => onChange(!pixel)}
      aria-pressed={pixel}
    >
      <span className="pixel-toggle-box" aria-hidden="true" />
      像素模式
    </button>
  )
}
