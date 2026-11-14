'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import CodeMirror, { type ReactCodeMirrorRef } from '@uiw/react-codemirror'
import { html } from '@codemirror/lang-html'
import { css } from '@codemirror/lang-css'
import { javascript } from '@codemirror/lang-javascript'
import { colorPicker } from '@replit/codemirror-css-color-picker'

import {
  buildPage,
  starterChimera,
  toJsLine,
  type ChimeraCode,
  type PreviewEvent,
  type EditorTab,
} from '@/lib/chimera'
import { addConsoleError, formatConsoleError, type ConsoleError } from '@/lib/console'
import { VersionPanel } from '@/components/VersionPanel'
import { PixelToggle } from '@/components/PixelToggle'
import { PlayMode } from '@/components/PlayMode'

// 每一格用對應的語法上色；CSS 格多一個色票，色碼旁邊會出現小色塊，點了可以選色
const tabs = [
  { key: 'html', label: 'HTML 骨架', extensions: [html()] },
  { key: 'css', label: 'CSS 烤漆', extensions: [css(), colorPicker] },
  { key: 'js', label: 'JS 引擎', extensions: [javascript()] },
] as const

type EditorProps = {
  // 程式碼和目前分頁放在實驗室頁面保管，商店的「裝上」按鈕才改得到
  code: ChimeraCode
  onChange: (code: ChimeraCode) => void
  tab: EditorTab
  onTabChange: (tab: EditorTab) => void
  // 有傳 onSave 才會出現存檔按鈕，回傳 true 代表存成功
  onSave?: (code: ChimeraCode) => Promise<boolean>
  // 有傳 onRestore 才會出現版本紀錄，選好的版本交給實驗室頁面放進編輯器
  onRestore?: (code: ChimeraCode, label: string) => void
  // 新手教程用：預覽裡的合成獸真的跳起來、對話框的文字變了，就連同當下的程式碼交出去
  onPreview?: (code: ChimeraCode, event: PreviewEvent) => void
  // 程式碼區可不可以收起來；新手教程進行中不行，玩家才不會找不到要改的地方
  canCollapse?: boolean
  // 可不可以進遊玩模式；新手教程進行中不行
  canPlay?: boolean
}

// 合成獸編輯器：左邊改程式碼，右邊即時預覽
export function ChimeraEditor({
  code,
  onChange,
  tab,
  onTabChange,
  onSave,
  onRestore,
  onPreview,
  canCollapse = true,
  canPlay = true,
}: EditorProps) {
  const [status, setStatus] = useState('')
  // 程式碼區收起來了沒，不存檔，重新整理就恢復打開
  const [collapsedState, setCollapsed] = useState(false)
  const collapsed = canCollapse && collapsedState
  const [playing, setPlaying] = useState(false)
  // 像素模式：預覽變成 4px 的馬賽克，遊玩模式也用同一個開關；不存檔，重新整理就恢復關閉
  const [pixel, setPixel] = useState(false)
  const playButtonRef = useRef<HTMLButtonElement>(null)

  const [showVersions, setShowVersions] = useState(false)
  // 存檔成功幾次，版本紀錄看到數字變了就重新拿列表
  const [savedCount, setSavedCount] = useState(0)

  // 錯誤主控台：預覽頁抓到錯誤會 postMessage 出來
  // 錯誤跟著是哪一版的預覽頁一起記，程式碼一改預覽頁就不一樣，舊的錯誤自然不顯示
  const page = buildPage(code, { catchErrors: true, pixel })
  const previewRef = useRef<HTMLIFrameElement>(null)
  const [errors, setErrors] = useState<{ page: string; list: ConsoleError[] }>({
    page: '',
    list: [],
  })
  const consoleErrors = errors.page === page ? errors.list : []

  // 離開遊玩模式：玩的時候抓到的錯誤放進主控台，焦點放回「遊玩」按鈕
  // 用 preventScroll 讓畫面停在原本的位置
  const closePlay = useCallback(
    (playErrors: ConsoleError[]) => {
      setPlaying(false)
      if (playErrors.length) {
        setErrors((prev) => {
          let list = prev.page === page ? prev.list : []
          for (const e of playErrors) {
            for (let i = 0; i < e.count; i++) list = addConsoleError(list, e)
          }
          return { page, list }
        })
      }
      playButtonRef.current?.focus({ preventScroll: true })
    },
    [page],
  )

  useEffect(() => {
    function onMessage(event: MessageEvent) {
      // 只收自己這個預覽 iframe 傳來的，商店卡片的預覽或其他頁面傳的都不理
      if (event.source !== previewRef.current?.contentWindow) return
      if (event.data?.type === 'chimera-jump') {
        onPreview?.(code, { type: 'jump' })
        return
      }
      if (event.data?.type === 'chimera-shape') {
        const radius = typeof event.data.radius === 'string' ? event.data.radius : null
        onPreview?.(code, { type: 'shape', radius })
        return
      }
      if (event.data?.type === 'chimera-speech') {
        const text = typeof event.data.text === 'string' ? event.data.text : null
        onPreview?.(code, { type: 'speech', text })
        return
      }
      if (event.data?.type !== 'chimera-error') return
      const error = {
        line: toJsLine(code, event.data.line, { catchErrors: true, pixel }),
        message: String(event.data.message),
      }
      setErrors((prev) => ({
        page,
        list: addConsoleError(prev.page === page ? prev.list : [], error),
      }))
    }
    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [code, page, pixel, onPreview])

  // 點主控台的錯誤：切到 JS 格，游標移到出錯的那一行
  // 要等 JS 格的內容換上去才能移，所以先記在 jumpLine，等分頁換好再移
  const cmRef = useRef<ReactCodeMirrorRef>(null)
  const jumpLine = useRef<number | null>(null)

  function jumpTo(line: number | null) {
    jumpLine.current = line
    if (tab === 'js') moveToLine()
    else onTabChange('js')
  }

  function moveToLine() {
    const view = cmRef.current?.view
    const line = jumpLine.current
    jumpLine.current = null
    if (!view || !line) return
    const target = view.state.doc.line(Math.min(line, view.state.doc.lines))
    view.dispatch({ selection: { anchor: target.from }, scrollIntoView: true })
    view.focus()
  }

  useEffect(() => {
    // 只有換分頁的時候才需要跑
    if (tab === 'js' && jumpLine.current) moveToLine()
  }, [tab])

  // 換分頁就打開程式碼區，例如裝上零件、加了動作，編輯器切過去的時候
  useEffect(() => {
    setCollapsed(false)
  }, [tab])

  // 點目前開著的分頁就收起來；收起來的時候點任一分頁就打開那一格
  function clickTab(key: EditorTab) {
    if (collapsed) {
      setCollapsed(false)
      onTabChange(key)
    } else if (key === tab) {
      if (canCollapse) setCollapsed(true)
    } else {
      onTabChange(key)
    }
  }

  async function save() {
    if (!onSave) return
    setStatus('存檔中…')
    const ok = await onSave(code)
    setStatus(ok ? '存好了！' : '存檔失敗，再試一次')
    if (ok) setSavedCount((n) => n + 1)
  }

  function reset() {
    onChange(starterChimera)
    setStatus('已還原成預設的樣子，按存檔才會覆蓋舊的')
  }

  return (
    <>
      <section className={`editor ${collapsed ? 'collapsed' : ''}`}>
        <div className="editor-code">
          <div className={`editor-tabs main ${canCollapse ? 'with-toggle' : ''}`}>
            {tabs.map((t) => (
              <button
                key={t.key}
                className={`editor-tab ${tab === t.key && !collapsed ? 'active' : ''}`}
                onClick={() => clickTab(t.key)}
              >
                {t.label}
                {/* 收起來的時候看不到主控台，有錯誤就在 JS 分頁上顯示幾個 */}
                {t.key === 'js' && collapsed && consoleErrors.length > 0 && (
                  <span className="editor-tab-errors" aria-label={`${consoleErrors.length} 個錯誤`}>
                    {consoleErrors.length}
                  </span>
                )}
              </button>
            ))}
            {canCollapse && (
              <button
                className="editor-collapse"
                onClick={() => setCollapsed((v) => !v)}
                aria-label={collapsed ? '打開程式碼區' : '收起程式碼區'}
                aria-expanded={!collapsed}
              >
                {/* 用 SVG 畫箭頭，字元的上下留白每種字體不一樣，會對不正 */}
                <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true">
                  <path
                    d={collapsed ? 'M2 4.5l5 5 5-5' : 'M2 9.5l5-5 5 5'}
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2.5"
                    strokeLinecap="square"
                  />
                </svg>
              </button>
            )}
          </div>
          <CodeMirror
            ref={cmRef}
            className="editor-cm"
            value={code[tab]}
            onChange={(value) => onChange({ ...code, [tab]: value })}
            extensions={[...tabs.find((t) => t.key === tab)!.extensions]}
            theme="dark"
            basicSetup={{ foldGutter: false, autocompletion: false }}
            aria-label={`${tab} 程式碼`}
          />
        </div>

        <div className="editor-preview-wrap">
          {/* sandbox 只開 allow-scripts：裡面的 JS 可以跑，但碰不到外面的 localStorage 和頁面 */}
          <iframe
            ref={previewRef}
            className="editor-preview"
            title="合成獸預覽"
            sandbox="allow-scripts"
            srcDoc={page}
          />
          <PixelToggle pixel={pixel} onChange={setPixel} className="editor-pixel" />
          {canPlay && (
            <button
              ref={playButtonRef}
              className="btn editor-play"
              onClick={() => setPlaying(true)}
            >
              遊玩
            </button>
          )}
        </div>
      </section>
      <section className="console" aria-live="polite" hidden={collapsed}>
        <p className="console-title">主控台</p>
        {consoleErrors.length ? (
          <ul className="console-list">
            {consoleErrors.map((e) => (
              <li key={`${e.line}-${e.message}`}>
                <button className="console-error" onClick={() => jumpTo(e.line)}>
                  {formatConsoleError(e)}
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <p className="console-ok">沒有錯誤</p>
        )}
      </section>
      {onSave && (
        <div className="editor-actions">
          <button className="btn" onClick={save}>
            存檔
          </button>
          <button className="btn ghost" onClick={reset}>
            還原預設
          </button>
          {onRestore && (
            <button className="btn ghost" onClick={() => setShowVersions((v) => !v)}>
              {showVersions ? '收起版本紀錄' : '版本紀錄'}
            </button>
          )}
          {status && <span className="muted">{status}</span>}
        </div>
      )}
      {playing && canPlay && (
        <PlayMode code={code} onClose={closePlay} pixel={pixel} onPixelChange={setPixel} />
      )}
      {onSave && onRestore && showVersions && (
        <VersionPanel savedCount={savedCount} onRestore={onRestore} />
      )}
    </>
  )
}

type CodeViewerProps = {
  code: ChimeraCode
  // 零件名稱，給螢幕閱讀器用
  label: string
}

// 零件詳情裡的唯讀程式碼：語法上色跟編輯器一樣，但不能改
// 只顯示有內容的分頁，例如花紋零件只有 CSS
export function CodeViewer({ code, label }: CodeViewerProps) {
  const [tab, setTab] = useState<EditorTab>('html')
  const available = tabs.filter((t) => code[t.key])
  // 換看另一個零件時，原本開的分頁可能是空的，就改開第一個有內容的
  const current = available.find((t) => t.key === tab) ?? available[0]
  if (!current) return null

  return (
    <div className="editor-code code-viewer">
      <div className="editor-tabs">
        {available.map((t) => (
          <button
            key={t.key}
            className={`editor-tab ${current.key === t.key ? 'active' : ''}`}
            onClick={() => setTab(t.key)}
          >
            {t.label}
          </button>
        ))}
      </div>
      <CodeMirror
        className="editor-cm"
        value={code[current.key]}
        extensions={[...current.extensions]}
        theme="dark"
        readOnly
        editable={false}
        basicSetup={{ foldGutter: false, autocompletion: false }}
        aria-label={`${label}的 ${current.label}`}
      />
    </div>
  )
}
