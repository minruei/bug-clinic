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
  html: '<div class="chimera">\n  <div class="body"></div>\n</div>',
  css: `.chimera {
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

type EditorProps = {
  initial?: ChimeraCode
  // 有傳 onSave 才會出現存檔按鈕，回傳 true 代表存成功
  onSave?: (code: ChimeraCode) => Promise<boolean>
}

// 合成獸編輯器：左邊改程式碼，右邊即時預覽
export function ChimeraEditor({ initial = starterChimera, onSave }: EditorProps) {
  const [code, setCode] = useState<ChimeraCode>(initial)
  const [tab, setTab] = useState<keyof ChimeraCode>('css')
  const [status, setStatus] = useState('')

  async function save() {
    if (!onSave) return
    setStatus('存檔中…')
    const ok = await onSave(code)
    setStatus(ok ? '存好了！' : '存檔失敗，再試一次')
  }

  function reset() {
    setCode(starterChimera)
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
                onClick={() => setTab(t.key)}
              >
                {t.label}
              </button>
            ))}
          </div>
          <CodeMirror
            className="editor-cm"
            value={code[tab]}
            onChange={(value) => setCode({ ...code, [tab]: value })}
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
