// 合成獸程式碼的純函式：裝零件、卸零件、組成網頁
// 不放在 ChimeraEditor.tsx，測試和商店預覽用的時候才不會載入 CodeMirror

export type ChimeraCode = {
  html: string
  css: string
  js: string
}

// 合成獸的身體：一個方形身體，毛色用變數，買了毛色零件就能改
// 零件裝在 .body 裡面，身體動的時候零件會跟著一起動
// .body 的 position: relative 讓零件的 calc(50% ± Npx) 以身體中心為準；身體在畫面正中央，所以位置跟以前一樣
// 對話框放在 .body 外面，換位置的動作寫在 .chimera，對話框才會跟著走、不跟著身體轉
// 對話框的預設文字，教程第二步要玩家換成自己想說的話
export const SPEECH_PLACEHOLDER = '……'

const BODY_HTML = `<div class="chimera">
  <div class="speech">${SPEECH_PLACEHOLDER}</div>
  <div class="body">
    <!-- 零件裝在這裡 -->
  </div>
</div>`

const BODY_CSS = `.chimera {
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
}

/* 對話框：跟 .body 同一層，跟著 .chimera 換位置，身體轉圈、發抖、跳的時候不會跟著變形 */
/* 擺在頭的正上方，抬高到角的上面：身體高 108px，頂端在 50% - 54px，再往上 46px */
/* 寬度最多到預覽框寬度少一點（100vw 是預覽框的寬度），手機上也不會超出去；夠寬，長的句子也只要兩三行 */
.speech {
  position: absolute;
  bottom: calc(50% + 100px);
  left: 50%;
  translate: -50% 0;
  z-index: 1;
  box-sizing: border-box;
  width: max-content;
  max-width: calc(100vw - 16px);
  padding: 6px 10px;
  background: #ffffff;
  border: 3px solid #4a3426;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.4;
  text-align: center;
  overflow-wrap: anywhere;
}

/* 指向合成獸的小尾巴：深色三角形當邊框，上面再疊一個白色三角形 */
.speech::before,
.speech::after {
  content: '';
  position: absolute;
  left: 50%;
  translate: -50% 0;
  border-left: 8px solid transparent;
  border-right: 8px solid transparent;
}

.speech::before {
  top: 100%;
  border-top: 12px solid #4a3426;
}

.speech::after {
  top: calc(100% - 4px);
  border-left-width: 6px;
  border-right-width: 6px;
  border-top: 9px solid #ffffff;
}`

// 合成獸的動作一律這樣寫：CSS 寫「怎麼動」（@keyframes 加上一個 class），JS 只決定「什麼時候動」（加上、拿掉 class）
// 跳用 translate 不用 transform，才不會蓋掉零件或其他程式設的 transform
export const JUMP_CSS = `/* 點一下往上跳再落下，改 -30px 調跳多高、改 0.4s 調多快 */
.body.jump {
  animation: jump 0.4s ease-out;
}

@keyframes jump {
  50% {
    translate: 0 -30px;
  }
}`

export const JUMP_JS = `// 點一下合成獸，牠會跳起來
const body = document.querySelector('.body');

body.addEventListener('click', () => {
  body.classList.add('jump');
});

// 動畫播完就把 class 拿掉，下次才能再跳
body.addEventListener('animationend', () => {
  body.classList.remove('jump');
});
`

// 教程第四步要玩家自己補上的那一行
export const JUMP_LINE = "body.classList.add('jump');"
export const JUMP_PLACEHOLDER = '// 在這裡加上一行，讓合成獸跳起來'

// 新手教程用的練習合成獸：CSS 已經寫好怎麼跳，JS 留一個空格讓玩家補上「什麼時候跳」
// 跟正式版分開，教程怎麼改都不會影響玩家自己的合成獸
export const practiceChimera: ChimeraCode = {
  html: BODY_HTML,
  css: `${BODY_CSS}\n\n${JUMP_CSS}`,
  js: JUMP_JS.replace(JUMP_LINE, JUMP_PLACEHOLDER),
}

// 還沒改過的合成獸（新玩家、按「還原預設」都是這隻）：點一下就會跳
export const starterChimera: ChimeraCode = {
  html: BODY_HTML,
  css: `${BODY_CSS}\n\n${JUMP_CSS}`,
  js: JUMP_JS,
}

// 編輯器的預覽用：放在玩家的 JS 前面，有事就用 postMessage 告訴外面的頁面
// 預覽是 sandbox iframe，裡面發生什麼外面看不到，要靠 postMessage 傳
// 1. 抓到錯誤，把訊息和行號傳出去，給錯誤主控台用
// 2. 玩家點了合成獸、某個元素被加上 jump，而且那個元素真的套用了 jump 動畫，就回報一聲，給新手教程判斷「真的跳起來了」
//    看 class 變化，不等 animationstart：分頁在背景時畫面不更新，animationstart 不會觸發
// 3. 對話框實際顯示的文字，一開始回報一次，之後文字變了再回報，給新手教程判斷「真的說話了」
// 4. .body 實際算出來的 border-radius，一開始回報一次，之後 class 或 style 變了再回報，給新手教程判斷「真的變形了」
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
  var clicked = false
  document.addEventListener('click', function () { clicked = true }, true)
  function sendShape() {
    var body = document.querySelector('.body')
    parent.postMessage({ type: 'chimera-shape', radius: body ? getComputedStyle(body).borderRadius : null }, '*')
  }
  sendShape()
  new MutationObserver(function (records) {
    sendShape()
    records.forEach(function (record) {
      var el = record.target
      if (!clicked || !el.classList.contains('jump')) return
      if (getComputedStyle(el).animationName.indexOf('jump') === -1) return
      parent.postMessage({ type: 'chimera-jump' }, '*')
    })
  }).observe(document.documentElement, { attributes: true, attributeFilter: ['class', 'style'], subtree: true })
  function sendSpeech() {
    var speech = document.querySelector('.speech')
    parent.postMessage({ type: 'chimera-speech', text: speech ? speech.textContent : null }, '*')
  }
  sendSpeech()
  new MutationObserver(sendSpeech).observe(document.body, {
    childList: true,
    characterData: true,
    subtree: true,
  })
})()
</script>`

// 編輯器的預覽傳出來的事件，新手教程拿來判斷玩家真的做到了
export type PreviewEvent =
  | { type: 'jump' }
  | { type: 'speech'; text: string | null }
  | { type: 'shape'; radius: string | null }

type PageOptions = {
  // 只有編輯器的預覽要接錯誤主控台，商店卡片和詳情框的預覽不用
  catchErrors?: boolean
  // 商店卡片和詳情框只是要看零件，不顯示對話框；接在 CSS 最後面蓋過原本的樣式，不改到程式碼
  hideSpeech?: boolean
}

// 玩家 JS 前面那一段；buildPage 和行號換算都用這個，兩邊才不會對不上
function pageBeforeJs(code: ChimeraCode, options: PageOptions) {
  return `<!doctype html>
<html>
<head>
<style>body { margin: 0; } ${code.css}${options.hideSpeech ? '\n.speech { display: none; }' : ''}</style>
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

// 商店卡片和詳情框的預覽：零件裝在預設合成獸上的樣子，extraCss 給卡片縮小用
export function partPreviewPage(part: InstallablePart, extraCss = '') {
  const page = installPart(starterChimera, part)
  return buildPage({ ...page, css: page.css + extraCss }, { hideSpeech: true })
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

// HTML 裡有沒有 class 含 chimera 的外框
export function hasChimeraWrapper(html: string) {
  return /class\s*=\s*["']([^"']*\s)?chimera(\s[^"']*)?["']/.test(html)
}

// 會呼吸的身體這類零件寫在外層 .chimera 上，玩家把外框刪掉的話就套不上去，也不會報錯
// 裝這種零件時，HTML 沒有外框就整段包一層 <div class="chimera">
function wrapWithChimera(html: string) {
  return `<div class="chimera">\n  ${indent(html.trim(), '  ')}\n</div>`
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

  if (/\.chimera\b/.test(part.code.css) && !hasChimeraWrapper(html)) {
    html = wrapWithChimera(html)
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
