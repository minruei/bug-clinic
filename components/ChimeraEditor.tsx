'use client'

import { useState } from 'react'
import CodeMirror from '@uiw/react-codemirror'
import { html } from '@codemirror/lang-html'
import { css } from '@codemirror/lang-css'
import { javascript } from '@codemirror/lang-javascript'
import { colorPicker } from '@replit/codemirror-css-color-picker'

export type ChimeraCode = {
  html: string
  css: string
  js: string
}

// 還沒改過的合成獸：一個方形身體，毛色用變數，買了毛色零件就能改
export const starterChimera: ChimeraCode = {
  html: '<div class="chimera">\n  <div class="body"></div>\n  <!-- 零件裝在這裡 -->\n</div>',
  css: `.chimera {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  margin: 0;
}

.body {
  --fur-color: #b4b2a9;
  width: 120px;
  height: 100px;
  background: var(--fur-color);
  border: 4px solid #4a3426;
}`,
  js: '// 讓合成獸動起來的程式寫在這裡\n',
}

// 每一格用對應的語法上色；CSS 格多一個色票，色碼旁邊會出現小色塊，點了可以選色
const tabs = [
  { key: 'html', label: 'HTML 骨架', extensions: [html()] },
  { key: 'css', label: 'CSS 烤漆', extensions: [css(), colorPicker] },
  { key: 'js', label: 'JS 引擎', extensions: [javascript()] },
] as const

// 把三格程式碼組成一整個網頁，丟進 iframe 顯示
function buildPage(code: ChimeraCode) {
  return `<!doctype html>
<html>
<head>
<style>body { margin: 0; } ${code.css}</style>
</head>
<body>
${code.html}
<script>${code.js}</script>
</body>
</html>`
}

export type EditorTab = keyof ChimeraCode

const PART_MARKER = '<!-- 零件裝在這裡 -->'

// 把零件的程式碼加進合成獸：HTML 插在「零件裝在這裡」那行前面，CSS 和 JS 接在最後面
export function installPart(code: ChimeraCode, part: ChimeraCode): ChimeraCode {
  let html = code.html
  if (part.html) {
    html = html.includes(PART_MARKER)
      ? html.replace(PART_MARKER, `${part.html}\n  ${PART_MARKER}`)
      : `${html}\n${part.html}`
  }

  return {
    html,
    css: part.css ? `${code.css}\n\n${part.css}` : code.css,
    js: part.js ? `${code.js}\n${part.js}` : code.js,
  }
}

// 零件的每一段程式碼都已經在合成獸裡，就算裝過了
export function isInstalled(code: ChimeraCode, part: ChimeraCode) {
  return (Object.keys(part) as EditorTab[]).every((key) => code[key].includes(part[key]))
}

type EditorProps = {
  // 程式碼和目前分頁放在實驗室頁面保管，商店的「裝上」按鈕才改得到
  code: ChimeraCode
  onChange: (code: ChimeraCode) => void
  tab: EditorTab
  onTabChange: (tab: EditorTab) => void
  // 有傳 onSave 才會出現存檔按鈕，回傳 true 代表存成功
  onSave?: (code: ChimeraCode) => Promise<boolean>
}

// 合成獸編輯器：左邊改程式碼，右邊即時預覽
export function ChimeraEditor({ code, onChange, tab, onTabChange, onSave }: EditorProps) {
  const [status, setStatus] = useState('')

  async function save() {
    if (!onSave) return
    setStatus('存檔中…')
    const ok = await onSave(code)
    setStatus(ok ? '存好了！' : '存檔失敗，再試一次')
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
          {status && <span className="muted">{status}</span>}
        </div>
      )}
    </>
  )
}
