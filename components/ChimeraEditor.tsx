'use client'

import { useState } from 'react'
import CodeMirror from '@uiw/react-codemirror'
import { html } from '@codemirror/lang-html'
import { css } from '@codemirror/lang-css'
import { javascript } from '@codemirror/lang-javascript'
import { colorPicker } from '@replit/codemirror-css-color-picker'

import { buildPage, starterChimera, type ChimeraCode, type EditorTab } from '@/lib/chimera'
import { VersionPanel } from '@/components/VersionPanel'

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
}

// 合成獸編輯器：左邊改程式碼，右邊即時預覽
export function ChimeraEditor({
  code,
  onChange,
  tab,
  onTabChange,
  onSave,
  onRestore,
}: EditorProps) {
  const [status, setStatus] = useState('')
  const [showVersions, setShowVersions] = useState(false)
  // 存檔成功幾次，版本紀錄看到數字變了就重新拿列表
  const [savedCount, setSavedCount] = useState(0)

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
      <section className="editor">
        <div className="editor-code">
          <div className="editor-tabs">
            {tabs.map((t) => (
              <button
                key={t.key}
                className={`editor-tab ${tab === t.key ? 'active' : ''}`}
                onClick={() => onTabChange(t.key)}
              >
                {t.label}
              </button>
            ))}
          </div>
          <CodeMirror
            className="editor-cm"
            value={code[tab]}
            onChange={(value) => onChange({ ...code, [tab]: value })}
            extensions={[...tabs.find((t) => t.key === tab)!.extensions]}
            theme="dark"
            basicSetup={{ foldGutter: false, autocompletion: false }}
            aria-label={`${tab} 程式碼`}
          />
        </div>

        {/* sandbox 只開 allow-scripts：裡面的 JS 可以跑，但碰不到外面的 localStorage 和頁面 */}
        <iframe
          className="editor-preview"
          title="合成獸預覽"
          sandbox="allow-scripts"
          srcDoc={buildPage(code)}
        />
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
