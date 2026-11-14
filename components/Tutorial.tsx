'use client'

import { useState } from 'react'
import type { ChimeraCode, EditorTab } from '@/lib/chimera'
import { FINISH_VOICE, steps, type Progress } from '@/lib/tutorial'

const tabLabel = {
  html: 'HTML 骨架',
  css: 'CSS 烤漆',
  js: 'JS 引擎',
}

type TutorialProps = {
  code: ChimeraCode
  // 預覽裡發生的事：對話框的文字、有沒有真的跳起來，第二步和第四步看這個過關
  progress: Progress
  // 編輯器現在開在哪一格，不是這一步要改的那格時，才顯示「打開」按鈕
  tab: EditorTab
  onTabChange: (tab: EditorTab) => void
  // 全部做完後按領獎：存檔加領金幣，回傳錯誤訊息，成功回 null
  onFinish: () => Promise<string | null>
  onSkip: () => void
  // 再玩一次的練習模式：不發獎勵，按鈕文字也不一樣
  replay?: boolean
}

// 新手教程：放在編輯器上面，一步一步帶玩家改三格程式碼
export function Tutorial({
  code,
  progress,
  tab,
  onTabChange,
  onFinish,
  onSkip,
  replay = false,
}: TutorialProps) {
  const [finishing, setFinishing] = useState(false)
  const [error, setError] = useState('')

  // 每一步完成沒有，都是從目前的程式碼算出來的，不用另外記
  const doneList = steps.map((step) => step.done(code, progress))
  const current = doneList.indexOf(false)
  const allDone = current === -1

  async function finish() {
    setFinishing(true)
    setError('')
    const message = await onFinish()
    setFinishing(false)
    if (message) setError(message)
  }

  return (
    <section className="tutorial">
      <div className="tutorial-head">
        <p className="tutorial-title">新手教程：改四個地方，認識三格程式碼</p>
        <button className="tutorial-skip" onClick={onSkip}>
          {replay ? '離開練習' : '先跳過'}
        </button>
      </div>

      <p className="muted">這是一隻練習用的合成獸，怎麼改都不會影響你自己的作品</p>

      <ol className="tutorial-steps">
        {steps.map((step, i) => {
          let state = 'todo'
          if (doneList[i]) state = 'done'
          else if (i === current) state = 'now'

          return (
            <li key={step.title} className={`tutorial-step ${state}`}>
              <span className="tutorial-mark">{doneList[i] ? '✔' : i + 1}</span>
              <div>
                <p className="tutorial-step-title">{step.title}</p>
                {state === 'now' && (
                  <>
                    <p className="tutorial-voice">「{step.voice}」</p>
                    <p>
                      <b>要做什麼：</b>
                      {step.todo}
                    </p>
                    <p className="muted">
                      <b>為什麼是這一格：</b>
                      {step.why}
                    </p>
                    <p className="muted">
                      <b>卡住了？</b>
                      {step.stuck}
                    </p>
                    {/* 不在玩家打字時自動切分頁：刪到一半剛好達成條件就被切走，
                        接下來打的字會寫進別的格子。改成按鈕，讓玩家自己決定什麼時候換 */}
                    {tab !== step.tab && (
                      <button className="btn ghost" onClick={() => onTabChange(step.tab)}>
                        打開{tabLabel[step.tab]}
                      </button>
                    )}
                  </>
                )}
              </div>
            </li>
          )
        })}
      </ol>

      {allDone && (
        <div className="tutorial-finish">
          <div>
            <p className="tutorial-voice">「{FINISH_VOICE}」</p>
            <p className="muted">四個都完成了，你已經改過 HTML、CSS、JS 三格</p>
          </div>
          {replay ? (
            <button className="btn" onClick={finish}>
              完成練習，回到我的合成獸
            </button>
          ) : (
            <button className="btn" onClick={finish} disabled={finishing}>
              {finishing ? '領取中…' : '領 20 金幣'}
            </button>
          )}
        </div>
      )}
      {error && <p className="tutorial-error">{error}</p>}
    </section>
  )
}
