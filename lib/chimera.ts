// 合成獸程式碼的純函式：裝零件、卸零件、組成網頁
// 不放在 ChimeraEditor.tsx，測試和商店預覽用的時候才不會載入 CodeMirror

export type ChimeraCode = {
  html: string
  css: string
  js: string
}

// 還沒改過的合成獸：一個方形身體，毛色用變數，買了毛色零件就能改
// 零件裝在 .body 裡面，身體動的時候零件會跟著一起動
// .body 的 position: relative 讓零件的 calc(50% ± Npx) 以身體中心為準；身體在畫面正中央，所以位置跟以前一樣
export const starterChimera: ChimeraCode = {
  html: '<div class="chimera">\n  <div class="body">\n    <!-- 零件裝在這裡 -->\n  </div>\n</div>',
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
  position: relative;
  width: 120px;
  height: 100px;
  background: var(--fur-color);
  border: 4px solid #4a3426;
}`,
  js: '// 讓合成獸動起來的程式寫在這裡\n',
}

// 錯誤主控台用：放在玩家的 JS 前面，抓到錯誤就把訊息和行號傳給外面的頁面
// 預覽是 sandbox iframe，錯誤不會自己跑出來，要靠 postMessage 傳
// 只抓得到 JS 執行時的錯誤；CSS、HTML 寫錯瀏覽器不會報錯，無窮迴圈會讓預覽卡住也抓不到
const ERROR_CATCHER = `<script>
(function () {
  function send(message, line) {
    parent.postMessage({ type: 'chimera-error', message: String(message), line: line || null }, '*')
  }
  window.addEventListener('error', function (e) {
    send(e.error && e.error.message ? e.error.message : e.message, e.lineno)
  })
  window.addEventListener('unhandledrejection', function (e) {
    var reason = e.reason
    var found = reason && reason.stack ? /about:srcdoc:(\\d+)/.exec(reason.stack) : null
    send(reason && reason.message ? reason.message : reason, found ? Number(found[1]) : null)
  })
})()
</script>`

type PageOptions = {
  // 只有編輯器的預覽要接錯誤主控台，商店卡片和詳情框的預覽不用
  catchErrors?: boolean
}

// 玩家 JS 前面那一段；buildPage 和行號換算都用這個，兩邊才不會對不上
function pageBeforeJs(code: ChimeraCode, options: PageOptions) {
  return `<!doctype html>
<html>
<head>
<style>body { margin: 0; } ${code.css}</style>
</head>
<body>
${code.html}
${options.catchErrors ? ERROR_CATCHER : ''}
<script>
`
}

// 把三格程式碼組成一整個網頁，丟進 iframe 顯示；商店卡片的預覽也用這個
// 玩家的 JS 放在自己的 script 裡，從新的一行開始，寫錯了也不會影響前面抓錯誤的程式
export function buildPage(code: ChimeraCode, options: PageOptions = {}) {
  return `${pageBeforeJs(code, options)}${code.js}
</script>
</body>
</html>`
}

// 錯誤回報的行號是整個預覽頁的第幾行，換算成 JS 引擎格裡的第幾行
// 不是玩家 JS 裡的行（例如寫在 HTML 的 onclick），或根本沒有行號，就回 null
export function toJsLine(code: ChimeraCode, pageLine: number | null, options: PageOptions = {}) {
  if (!pageLine) return null
  const linesBefore = pageBeforeJs(code, options).split('\n').length - 1
  const line = pageLine - linesBefore
  return line >= 1 && line <= code.js.split('\n').length ? line : null
}

export type EditorTab = keyof ChimeraCode

// 合成獸的部位，商店分頁也照這個順序
export const slots = [
  { key: 'body', label: '身體' },
  { key: 'horn', label: '角' },
  { key: 'eyes', label: '眼睛' },
  { key: 'mouth', label: '嘴巴' },
  { key: 'pattern', label: '花紋' },
  { key: 'wings', label: '翅膀' },
  { key: 'tail', label: '尾巴' },
  { key: 'feet', label: '腳' },
  { key: 'accessory', label: '配件' },
] as const

export type Slot = (typeof slots)[number]['key']

export type InstallablePart = {
  id: number
  slot: Slot
  name: string
  code: ChimeraCode
}

const PART_MARKER = '<!-- 零件裝在這裡 -->'

// 找出某個部位的標記段落，例如 <!-- [horn:7] 鹿角 開始 --> 到 <!-- [horn:7] 結束 -->
// 部位名稱寫死在正規表達式裡，[horn:數字] 不會配到 [tail:數字]
// 裝上時多加的換行也一起抓（HTML 在後面，CSS 兩個、JS 一個在前面），卸下後才會跟原本一模一樣
function slotBlocks(tab: EditorTab, slot: Slot) {
  const tag = `\\[${slot}:\\d+\\]`
  if (tab === 'html') {
    return new RegExp(`<!-- ${tag} [^\\n]*? 開始 -->[\\s\\S]*?<!-- ${tag} 結束 -->\\n?[ \\t]*`, 'g')
  }
  if (tab === 'css') {
    return new RegExp(`\\n{0,2}/\\* ${tag} [^\\n]*? 開始 \\*/[\\s\\S]*?/\\* ${tag} 結束 \\*/`, 'g')
  }
  return new RegExp(`\\n?// ${tag} [^\\n]*? 開始[\\s\\S]*?// ${tag} 結束`, 'g')
}

// 把零件的三格程式碼各自用標記包起來，空的那格不加
// HTML 先不縮排，放進去的時候再照那一行的縮排補上
function wrapPart(part: InstallablePart): ChimeraCode {
  const tag = `[${part.slot}:${part.id}]`
  const { html, css, js } = part.code
  return {
    html: html ? `<!-- ${tag} ${part.name} 開始 -->\n${html}\n<!-- ${tag} 結束 -->` : '',
    css: css ? `/* ${tag} ${part.name} 開始 */\n${css}\n/* ${tag} 結束 */` : '',
    js: js ? `// ${tag} ${part.name} 開始\n${js}\n// ${tag} 結束` : '',
  }
}

// 從 index 往前找到行首，回傳這一行前面的空白，用來對齊縮排
function indentAt(text: string, index: number) {
  const lineStart = text.lastIndexOf('\n', index - 1) + 1
  return text.slice(lineStart, index).match(/^[ \t]*$/)?.[0] ?? ''
}

function indent(text: string, spaces: string) {
  return text.split('\n').join(`\n${spaces}`)
}

// 裝上零件：同部位的舊段落整段拿掉，再放新的
// HTML 原本就有同部位段落的話換在原位置，玩家自己排好的順序不會亂掉；沒有才插到「零件裝在這裡」前面
// 新的合成獸「零件裝在這裡」在 .body 裡面，11/14 以前存的在 .body 外面，兩種都照那一行的位置插
// CSS 和 JS 接在最後面
export function installPart(code: ChimeraCode, part: InstallablePart): ChimeraCode {
  const wrapped = wrapPart(part)

  let replaced = false
  let html = code.html.replace(
    slotBlocks('html', part.slot),
    (_match, offset: number, text: string) => {
      if (replaced) return ''
      replaced = true
      const spaces = indentAt(text, offset)
      return wrapped.html ? `${indent(wrapped.html, spaces)}\n${spaces}` : ''
    },
  )
  if (!replaced && wrapped.html) {
    const at = html.indexOf(PART_MARKER)
    if (at === -1) {
      html = `${html}\n${wrapped.html}`
    } else {
      const spaces = indentAt(html, at)
      html = `${html.slice(0, at)}${indent(wrapped.html, spaces)}\n${spaces}${html.slice(at)}`
    }
  }

  const css = code.css.replace(slotBlocks('css', part.slot), '')
  const js = code.js.replace(slotBlocks('js', part.slot), '')

  return {
    html,
    css: wrapped.css ? `${css}\n\n${wrapped.css}` : css,
    js: wrapped.js ? `${js}\n${wrapped.js}` : js,
  }
}

// 卸下零件：這個部位的標記段落三格都拿掉
export function removePart(code: ChimeraCode, slot: Slot): ChimeraCode {
  return {
    html: code.html.replace(slotBlocks('html', slot), ''),
    css: code.css.replace(slotBlocks('css', slot), ''),
    js: code.js.replace(slotBlocks('js', slot), ''),
  }
}

// 從標記找出這個部位裝的是哪個零件，沒裝回 null
// 11/14 以前裝的零件沒有標記，這裡找不到，會當成沒裝
export function installedPartId(code: ChimeraCode, slot: Slot): number | null {
  const pattern = new RegExp(`\\[${slot}:(\\d+)\\] [^\\n]*? 開始`)
  for (const text of [code.html, code.css, code.js]) {
    const match = text.match(pattern)
    if (match) return Number(match[1])
  }
  return null
}
