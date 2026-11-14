'use client'

import { useEffect, useRef, useState } from 'react'
import { CodeText } from '@/components/CodeText'
import type { ChimeraCode } from '@/lib/chimera'
import {
  hasMove,
  moveDemoPage,
  moveLevels,
  moves,
  needLabel,
  type Move,
  type MoveLevel,
} from '@/lib/moves'

type Props = {
  // 玩家現在的程式碼，用來判斷哪幾招已經加過
  code: ChimeraCode
  onAdd: (move: Move) => void
}

// 動作參考：放在編輯器下面，可以展開收合
// 每一招平常只顯示一行，點了才展開；同一時間只展開一招，示範預覽也只開那一招的
export function MoveGuide({ code, onAdd }: Props) {
  const [open, setOpen] = useState(false)
  const [level, setLevel] = useState<MoveLevel>(1)
  const [openId, setOpenId] = useState<string | null>(null)
  const [showDemo, setShowDemo] = useState(false)
  const openRef = useRef<HTMLElement>(null)

  // 展開一招時，上面那招會收起來、畫面跟著跳，所以捲到這一招的開頭
  // 要等新的那招畫出來才捲得到，所以放在 effect 裡
  useEffect(() => {
    if (openId) openRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, [openId])

  function toggleMove(id: string) {
    setOpenId(openId === id ? null : id)
    setShowDemo(false)
  }

  function changeLevel(next: MoveLevel) {
    setLevel(next)
    setOpenId(null)
    setShowDemo(false)
  }

  return (
    <section className="move-guide">
      <button className="move-guide-toggle" onClick={() => setOpen((v) => !v)} aria-expanded={open}>
        <span>動作參考</span>
        <span className="muted">{open ? '▲' : '▼'}</span>
      </button>

      {open && (
        <div className="move-guide-body">
          <div className="move-levels">
            {moveLevels.map((l) => (
              <button
                key={l.level}
                className={`slot-tab ${level === l.level ? 'active' : ''}`}
                onClick={() => changeLevel(l.level)}
              >
                {l.label}
              </button>
            ))}
          </div>

          {moves
            .filter((move) => move.level === level)
            .map((move) => {
              const expanded = openId === move.id
              const added = hasMove(code, move)
              return (
                <article
                  key={move.id}
                  className={`move-card ${expanded ? 'open' : ''}`}
                  ref={expanded ? openRef : undefined}
                >
                  <button
                    className="move-head"
                    onClick={() => toggleMove(move.id)}
                    aria-expanded={expanded}
                  >
                    <span className="move-number">{moves.indexOf(move) + 1}</span>
                    {/* 名稱和零件標籤包在一起，手機上太長就在這裡換行，箭頭留在右邊 */}
                    <span className="move-title">
                      <span className="move-name">{move.name}</span>
                      {move.needs && (
                        <span className="move-need">需要{needLabel[move.needs]}零件</span>
                      )}
                    </span>
                    <span className="move-arrow">{expanded ? '▲' : '▼'}</span>
                  </button>

                  {expanded && (
                    <div className="move-body">
                      <p>
                        <b>學到什麼：</b>
                        <CodeText text={move.concept} />
                      </p>
                      <p>
                        <b>效果：</b>
                        <CodeText text={move.effect} />
                      </p>

                      {move.keyboard && (
                        <p className="move-key">要用鍵盤：先點一下預覽區，再按鍵盤</p>
                      )}

                      <div className="move-actions">
                        <button className="btn" onClick={() => onAdd(move)} disabled={added}>
                          {added ? '已經加過了' : '放進我的合成獸'}
                        </button>
                        <button className="btn ghost" onClick={() => setShowDemo((v) => !v)}>
                          {showDemo ? '收起示範' : '看示範'}
                        </button>
                      </div>

                      {/* 示範預覽跟編輯器一樣只開 allow-scripts，可以直接點、按鍵盤試 */}
                      {showDemo && (
                        <iframe
                          className="move-demo-preview"
                          title={`${move.name}示範`}
                          sandbox="allow-scripts"
                          srcDoc={moveDemoPage(move)}
                        />
                      )}

                      <p className="move-code-label">CSS 烤漆</p>
                      <pre className="move-code">
                        <code>{move.css}</code>
                      </pre>
                      <p className="move-code-label">JS 引擎</p>
                      <pre className="move-code">
                        <code>{move.js}</code>
                      </pre>

                      <p className="move-code-label">一行一行看</p>
                      <ul className="move-explain">
                        {move.explain.map((line) => (
                          <li key={line}>
                            <CodeText text={line} />
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}
                </article>
              )
            })}
        </div>
      )}
    </section>
  )
}
