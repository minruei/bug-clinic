// 每日任務的題目、遊戲日期、選題、過關檢查，全部是純函式，不碰資料庫，方便單元測試
//
// 前端和後端的分工：
// - 前端在預覽的 sandbox iframe 裡真的把程式跑起來檢查，玩家馬上看到結果
// - 後端不相信前端說的「過關了」，領獎時自己讀資料庫裡存檔的程式碼，用這裡的檢查函式再判斷一次
// 後端不能執行玩家的程式碼（在伺服器跑瀏覽器太重，也有安全問題），所以這裡是看程式碼的寫法：
// - CSS、HTML 的題目：解析出規則和元素，可以準確判斷
// - JS 的題目：只能確認「寫法對」（有沒有用對事件和 class），沒辦法確認「真的動了」，真的動起來交給前端檢查
// 檢查前一律先拿掉註解，寫在註解裡的程式碼不算
// 題目不依賴對話框（正式版沒有 .speech），也不看零件的位置數值（零件定位會改）

export type ChimeraCode = {
  html: string
  css: string
  js: string
}

// 難度：只改一格 CSS 是簡單，要動到 HTML 或兩格是普通，JS 題是挑戰
export type DailyLevel = '簡單' | '普通' | '挑戰'

export type Challenge = {
  key: string
  title: string
  description: string
  level: DailyLevel
  // 提示分三層，玩家按「再多一點提示」才看到下一層
  // 第 1 層：方向，要改哪一格、改什麼；後端說「還沒完成喔」時也顯示這一層
  hint: string
  // 第 2 層：去哪裡找參考（零件商店的「看程式碼」或動作參考的某一招），不叫玩家去買零件
  reference: string
  // 第 3 層：可以直接貼的範例程式碼，貼在預設合成獸上就能過關
  // html 貼在「零件裝在這裡」那一行上面，css、js 貼在那一格的最後面
  example: Partial<ChimeraCode>
  // 動作參考裡可以參考的招式 id（lib/moves.ts），JS 題才有
  moveId?: string
  check: (code: ChimeraCode) => boolean
}

// 每題的獎勵金幣
export const DAILY_REWARD = 20

// 「今天」統一用台灣時間算，伺服器在哪個時區都一樣；換日是台灣的午夜（日本凌晨 1 點）
// 用 formatToParts 自己組，不靠某個語系剛好輸出 YYYY-MM-DD
const taipeiFormatter = new Intl.DateTimeFormat('en-US', {
  timeZone: 'Asia/Taipei',
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
})

export function taipeiDate(now: Date): string {
  const parts = taipeiFormatter.formatToParts(now)
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? ''
  return `${get('year')}-${get('month')}-${get('day')}`
}

// 第一天出第一題，之後每天換下一題，出完一輪再從頭
const FIRST_DAY = Date.UTC(2026, 0, 1)
const DAY_MS = 24 * 60 * 60 * 1000

// 從遊戲日期算出今天是第幾題，前端不能自己選題
export function pickChallenge(date: string): Challenge {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(date)
  if (!match) throw new Error(`日期格式不對：${date}`)
  const day = Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]))
  const days = Math.round((day - FIRST_DAY) / DAY_MS)
  // 起始日以前的日期 days 是負的，取餘數後再補成正的
  const index = ((days % challenges.length) + challenges.length) % challenges.length
  return challenges[index]
}

// 給前端看的題目：不含檢查函式
export function publicChallenge(challenge: Challenge) {
  const { key, title, description, level, hint, reference, example, moveId } = challenge
  return {
    key,
    title,
    description,
    level,
    hint,
    reference,
    example,
    moveId: moveId ?? null,
    reward: DAILY_REWARD,
  }
}

export function stripCssComments(css: string) {
  return css.replace(/\/\*[\s\S]*?(\*\/|$)/g, ' ')
}

export function stripHtmlComments(html: string) {
  return html.replace(/<!--[\s\S]*?(-->|$)/g, ' ')
}

// JS 的註解要一個字一個字看：字串裡的 // 不是註解（例如網址），不能直接用正規表達式全部刪掉
export function stripJsComments(js: string) {
  let out = ''
  let i = 0
  while (i < js.length) {
    const ch = js[i]
    const next = js[i + 1]
    if (ch === '"' || ch === "'" || ch === '`') {
      // 整段字串原樣保留，遇到反斜線就連下一個字一起跳過
      let j = i + 1
      while (j < js.length && js[j] !== ch) j += js[j] === '\\' ? 2 : 1
      out += js.slice(i, j + 1)
      i = j + 1
    } else if (ch === '/' && next === '/') {
      while (i < js.length && js[i] !== '\n') i++
    } else if (ch === '/' && next === '*') {
      const end = js.indexOf('*/', i + 2)
      i = end === -1 ? js.length : end + 2
      out += ' '
    } else {
      out += ch
      i++
    }
  }
  return out
}

type Declaration = { prop: string; value: string }
type CssRule = { selectors: string[]; decls: Declaration[] }

// 找到 { 對應的 }，中間有巢狀的大括號也算得對；沒有關起來就到最後
function matchBrace(text: string, open: number) {
  let depth = 0
  for (let i = open; i < text.length; i++) {
    if (text[i] === '{') depth++
    if (text[i] === '}' && --depth === 0) return i
  }
  return text.length
}

// 屬性名稱不分大小寫（BORDER-RADIUS 也有效），一律轉小寫
// 但 -- 開頭的變數名稱要分大小寫（--Fur-Color 和 --fur-color 是不同的變數），保持原樣
function parseDeclarations(block: string): Declaration[] {
  // 規則裡面又包規則（CSS 巢狀寫法）的部分先拿掉，只看這一層的宣告
  let flat = block
  while (flat.includes('{')) {
    const open = flat.indexOf('{')
    const start = Math.max(flat.lastIndexOf(';', open), flat.lastIndexOf('}', open)) + 1
    flat = flat.slice(0, start) + flat.slice(matchBrace(flat, open) + 1)
  }
  return flat
    .split(';')
    .map((part) => {
      const colon = part.indexOf(':')
      if (colon === -1) return null
      const rawProp = part.slice(0, colon).trim()
      const prop = rawProp.startsWith('--') ? rawProp : rawProp.toLowerCase()
      const value = part
        .slice(colon + 1)
        .replace(/!\s*important\s*$/i, '')
        .trim()
      return prop && value ? { prop, value } : null
    })
    .filter((d): d is Declaration => d !== null)
}

function collectRules(text: string, rules: CssRule[]) {
  let i = 0
  while (i < text.length) {
    const open = text.indexOf('{', i)
    if (open === -1) break
    // 前面可能有 @import ...; 這種不帶大括號的敘述，只取最後一個分號後面
    const raw = text.slice(i, open)
    const prelude = raw.slice(raw.lastIndexOf(';') + 1).trim()
    const close = matchBrace(text, open)
    const inner = text.slice(open + 1, close)
    if (prelude.startsWith('@')) {
      // @media 這類裡面還是一般規則，往裡面找；@keyframes 裡的 50% { } 不是選擇器，跳過
      if (/^@(media|supports|layer|container)\b/i.test(prelude)) collectRules(inner, rules)
    } else if (prelude) {
      rules.push({
        selectors: prelude
          .split(',')
          .map((s) => s.trim().replace(/\s+/g, ' '))
          .filter(Boolean),
        decls: parseDeclarations(inner),
      })
    }
    i = close + 1
  }
}

export function parseCss(css: string): CssRule[] {
  const rules: CssRule[] = []
  collectRules(stripCssComments(css), rules)
  return rules
}

// 選擇器最後一段，也就是真正被選到的元素：.chimera > .body 的最後一段是 .body
function lastCompound(selector: string) {
  const parts = selector.split(/\s*[>+~]\s*|\s+/).filter(Boolean)
  return parts[parts.length - 1] ?? ''
}

// 選到身體本身：.body、.chimera .body 都算；.body.jump、.body:hover 是特定狀態，不算
// class 名稱分大小寫，.Body 選不到身體
const isBody = (selector: string) => lastCompound(selector) === '.body'

// 選到眼睛：.eye、.eye-round 這些眼睛零件，或動作參考常用的 [class^="eye"]
const isEye = (selector: string) => {
  const last = lastCompound(selector)
  return /^\.eye[\w-]*$/.test(last) || /^\[class[\^*|~]?=\s*["']?eye[\w-]*["']?\]$/.test(last)
}

// 照順序找符合選擇器的規則，回傳最後一個宣告的值（後寫的蓋掉先寫的）
function lastValue(css: string, match: (selector: string) => boolean, props: string[]) {
  let found: string | null = null
  for (const rule of parseCss(css)) {
    if (!rule.selectors.some(match)) continue
    for (const decl of rule.decls) {
      if (props.includes(decl.prop)) found = decl.value
    }
  }
  return found
}

type Hsl = { h: number; s: number; l: number }

const NAMED_COLORS: Record<string, string> = {
  red: '#ff0000',
  darkred: '#8b0000',
  crimson: '#dc143c',
  firebrick: '#b22222',
  indianred: '#cd5c5c',
  tomato: '#ff6347',
  orangered: '#ff4500',
  maroon: '#800000',
  blue: '#0000ff',
  navy: '#000080',
  darkblue: '#00008b',
  mediumblue: '#0000cd',
  royalblue: '#4169e1',
  dodgerblue: '#1e90ff',
  deepskyblue: '#00bfff',
  skyblue: '#87ceeb',
  lightblue: '#add8e6',
  steelblue: '#4682b4',
  cornflowerblue: '#6495ed',
  powderblue: '#b0e0e6',
  white: '#ffffff',
  black: '#000000',
  gray: '#808080',
  grey: '#808080',
  green: '#008000',
  yellow: '#ffff00',
  orange: '#ffa500',
  pink: '#ffc0cb',
  purple: '#800080',
}

function rgbToHsl(r: number, g: number, b: number): Hsl {
  const [rr, gg, bb] = [r / 255, g / 255, b / 255]
  const max = Math.max(rr, gg, bb)
  const min = Math.min(rr, gg, bb)
  const l = (max + min) / 2
  const d = max - min
  if (d === 0) return { h: 0, s: 0, l }
  const s = d / (1 - Math.abs(2 * l - 1))
  let h: number
  if (max === rr) h = ((gg - bb) / d) % 6
  else if (max === gg) h = (bb - rr) / d + 2
  else h = (rr - gg) / d + 4
  return { h: (h * 60 + 360) % 360, s, l }
}

function parseHex(hex: string): Hsl | null {
  let h = hex.slice(1)
  if (h.length === 3 || h.length === 4) h = [...h].map((c) => c + c).join('')
  if (h.length !== 6 && h.length !== 8) return null
  const n = (i: number) => parseInt(h.slice(i, i + 2), 16)
  return rgbToHsl(n(0), n(2), n(4))
}

// 一個顏色值，看得懂 #hex、rgb()、hsl() 和常見的顏色名稱；var() 這類算不出來的回 null
export function parseColor(token: string): Hsl | null {
  const t = token.trim().toLowerCase()
  if (t.startsWith('#')) return /^#[0-9a-f]+$/.test(t) ? parseHex(t) : null
  const fn = /^(rgba?|hsla?)\(([^)]*)\)$/.exec(t)
  if (fn) {
    const nums = fn[2].split(/[\s,/]+/).filter(Boolean)
    if (nums.length < 3) return null
    if (fn[1].startsWith('rgb')) {
      const [r, g, b] = nums.slice(0, 3).map((v) =>
        v.endsWith('%') ? parseFloat(v) * 2.55 : parseFloat(v),
      )
      return [r, g, b].some(Number.isNaN) ? null : rgbToHsl(r, g, b)
    }
    const h = parseFloat(nums[0])
    const s = parseFloat(nums[1]) / 100
    const l = parseFloat(nums[2]) / 100
    return [h, s, l].some(Number.isNaN) ? null : { h: ((h % 360) + 360) % 360, s, l }
  }
  return NAMED_COLORS[t] ? parseHex(NAMED_COLORS[t]) : null
}

// 從一整個值裡找第一個顏色，例如 background: #f00 url(x.png) 抓到 #f00
export function findColor(value: string): Hsl | null {
  const tokens = value.match(/#[0-9a-fA-F]+|(?:rgba?|hsla?)\([^)]*\)|[a-zA-Z]+/g) ?? []
  for (const token of tokens) {
    const color = parseColor(token)
    if (color) return color
  }
  return null
}

// 要有一點鮮豔，太灰、太黑、太白都看不出顏色
const vivid = (c: Hsl) => c.s >= 0.3 && c.l >= 0.15 && c.l <= 0.85
export const isReddish = (c: Hsl) => vivid(c) && (c.h <= 20 || c.h >= 340)
export const isBluish = (c: Hsl) => vivid(c) && c.h >= 185 && c.h <= 260

// 換成 px 比較；百分比回傳 unit '%'，其他看不懂的單位回 null
function parseLength(token: string): { n: number; unit: 'px' | '%' } | null {
  const m = /^(-?\d*\.?\d+)(px|em|rem|%)?$/i.exec(token.trim())
  if (!m) return null
  const n = parseFloat(m[1])
  const unit = (m[2] ?? '').toLowerCase()
  if (unit === '%') return { n, unit: '%' }
  if (unit === 'em' || unit === 'rem') return { n: n * 16, unit: 'px' }
  if (unit === 'px' || n === 0) return { n, unit: 'px' }
  return null
}

type HtmlElement = {
  tag: string
  classes: string[]
  parent: HtmlElement | null
  text: string
}

const VOID_TAGS = new Set(['area', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source', 'track', 'wbr'])

// 簡單的 HTML 解析：只要知道每個元素的 class、上一層是誰、自己這層的文字
// 標籤名稱和屬性名稱不分大小寫，class 的值分大小寫
export function parseHtml(html: string): HtmlElement[] {
  const text = stripHtmlComments(html)
  const elements: HtmlElement[] = []
  const stack: HtmlElement[] = []
  const tagRe = /<(\/?)([a-zA-Z][\w-]*)([^>]*)>/g
  let last = 0
  let m: RegExpExecArray | null
  while ((m = tagRe.exec(text))) {
    if (stack.length) stack[stack.length - 1].text += text.slice(last, m.index)
    last = tagRe.lastIndex
    const [, closing, rawTag, attrs] = m
    const tag = rawTag.toLowerCase()
    if (closing) {
      // 關到最近一個同名的標籤，中間忘記關的一起收掉
      for (let i = stack.length - 1; i >= 0; i--) {
        if (stack[i].tag === tag) {
          stack.length = i
          break
        }
      }
      continue
    }
    const cls = /(?:^|\s)class\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/i.exec(attrs)
    const element: HtmlElement = {
      tag,
      classes: (cls?.[1] ?? cls?.[2] ?? cls?.[3] ?? '').split(/\s+/).filter(Boolean),
      parent: stack[stack.length - 1] ?? null,
      text: '',
    }
    elements.push(element)
    if (!VOID_TAGS.has(tag) && !attrs.trim().endsWith('/')) stack.push(element)
  }
  return elements
}

function hasAncestor(el: HtmlElement, match: (a: HtmlElement) => boolean) {
  for (let p = el.parent; p; p = p.parent) if (match(p)) return true
  return false
}

const isHorn = (el: HtmlElement) => el.classes.some((c) => c.startsWith('horn'))

// 字串可以用單引號、雙引號、反引號
const Q = `['"\`]`

// 從字串開頭的引號跳到結尾的引號，回傳結尾引號的位置
function skipString(code: string, i: number) {
  const quote = code[i]
  let j = i + 1
  while (j < code.length && code[j] !== quote) j += code[j] === '\\' ? 2 : 1
  return j
}

// 從 start 之後第一個 ( 開始，到對應的 ) 為止，例如 setInterval(...) 括號裡的整段
// 字串裡的括號不算
function callArgs(code: string, start: number) {
  const open = code.indexOf('(', start)
  if (open === -1) return ''
  let depth = 0
  for (let i = open; i < code.length; i++) {
    const ch = code[i]
    if (ch === '"' || ch === "'" || ch === '`') i = skipString(code, i)
    else if (ch === '(') depth++
    else if (ch === ')' && --depth === 0) return code.slice(open, i + 1)
  }
  return code.slice(open)
}

// 從 start 開始到這一句結束（括號外的分號或換行），給 body.onclick = ... 用
function statementAfter(code: string, start: number) {
  let depth = 0
  for (let i = start; i < code.length; i++) {
    const ch = code[i]
    if (ch === '"' || ch === "'" || ch === '`') i = skipString(code, i)
    else if ('([{'.includes(ch)) depth++
    else if (')]}'.includes(ch)) depth--
    else if (depth <= 0 && (ch === ';' || ch === '\n') && code.slice(start, i).trim()) {
      return code.slice(start, i)
    }
  }
  return code.slice(start)
}

// 某個事件的處理函式內容：addEventListener('click', ...) 括號裡的整段，或 .onclick = 後面那一句
// 只看處理函式裡面，預設合成獸本來就有 click 事件，不能「有 click」加上「別的地方有 add」就算過
// 事件名稱分大小寫（'Click' 不會觸發），跟瀏覽器一樣
function handlers(code: string, event: string) {
  const bodies: string[] = []
  for (const m of code.matchAll(new RegExp(`addEventListener\\s*\\(\\s*${Q}${event}${Q}`, 'g'))) {
    bodies.push(callArgs(code, m.index))
  }
  for (const m of code.matchAll(new RegExp(`\\.on${event}\\s*=`, 'g'))) {
    bodies.push(statementAfter(code, m.index + m[0].length))
  }
  return bodies
}

export const challenges: Challenge[] = [
  {
    key: 'red-eyes',
    title: '紅眼睛',
    description: '把合成獸的眼睛變成紅色。',
    level: '普通',
    hint: '眼睛要兩格一起改：HTML 放兩個 class 是 eye 的元素，CSS 的 .eye 把 background 設成紅色系，例如 #e53935。',
    reference: '零件商店的「眼睛」分頁，點任何一個眼睛零件的「看程式碼」，就看得到眼睛的 HTML 和 CSS 怎麼寫，不用買。',
    example: {
      html: `<div class="eye left"></div>
<div class="eye right"></div>`,
      css: `.eye {
  position: absolute;
  top: 30%;
  width: 14px;
  height: 14px;
  background: #e53935;
}

.eye.left {
  left: 25%;
}

.eye.right {
  right: 25%;
}`,
    },
    check: ({ css }) => {
      const value = lastValue(css, isEye, ['background', 'background-color'])
      const color = value ? findColor(value) : null
      return !!color && isReddish(color)
    },
  },
  {
    key: 'round-body',
    title: '圓滾滾',
    description: '把身體變成圓的。',
    level: '簡單',
    hint: '在 CSS 烤漆的 .body 加上 border-radius，四個角都要夠圓：至少 25% 或 30px，用 50% 最圓。',
    reference: '零件商店的「身體」分頁，點「圓滾滾」的「看程式碼」，看它的 border-radius 怎麼寫。',
    example: {
      css: `.body {
  border-radius: 50%;
}`,
    },
    // 每個角都要夠圓：百分比至少 25%，或至少 30px（em 換算成 16px）
    // 斜線後面是垂直半徑，只看前面的水平半徑
    check: ({ css }) => {
      const value = lastValue(css, isBody, ['border-radius'])
      if (!value) return false
      const tokens = value.split('/')[0].trim().split(/\s+/)
      return tokens.every((token) => {
        const len = parseLength(token)
        if (!len) return false
        return len.unit === '%' ? len.n >= 25 : len.n >= 30
      })
    },
  },
  {
    key: 'click-happy',
    title: '點一下就開心',
    description: '點一下身體，讓身體加上 happy 這個 class。',
    level: '挑戰',
    hint: "在 JS 引擎的 click 事件裡，幫身體加上 happy 這個 class：body.classList.add('happy')。",
    reference: '動作參考第 5 招「點一下轉一圈」：一樣是點一下就幫身體加上 class，把 spin 換成 happy 就好。',
    example: {
      js: `body.addEventListener('click', () => {
  body.classList.add('happy');
});`,
      css: `/* 開心的時候毛色變亮 */
.body.happy {
  --fur-color: #f2d16b;
}`,
    },
    moveId: 'click-spin',
    // 後端看不到真的點下去的結果，只確認 click 的處理函式裡有加上 happy
    check: ({ js }) => {
      const adds = new RegExp(`classList\\s*\\.\\s*(?:add|toggle)\\s*\\([^)]*${Q}happy${Q}`)
      return handlers(stripJsComments(js), 'click').some((body) => adds.test(body))
    },
  },
  {
    key: 'wide-body',
    title: '大胖子',
    description: '讓身體變寬，寬度 160px 以上。',
    level: '簡單',
    hint: '在 CSS 烤漆的 .body 把 width 改成 160px 以上。',
    reference: '零件商店的「身體」分頁，點「扁扁胖胖」的「看程式碼」，看它怎麼把身體變寬。',
    example: {
      css: `.body {
  width: 180px;
}`,
    },
    check: ({ css }) => {
      const value = lastValue(css, isBody, ['width'])
      const len = value ? parseLength(value) : null
      return !!len && len.unit === 'px' && len.n >= 160
    },
  },
  {
    key: 'name-tag',
    title: '取個名字',
    description: '在身體裡加一個元素，寫上合成獸的名字。',
    level: '普通',
    hint: '在 HTML 骨架的 <div class="body"> 裡面加一個元素，裡面寫上名字，例如 <p>小怪</p>。',
    reference: '打開 HTML 骨架，找到「零件裝在這裡」那一行，它就在 .body 裡面，寫在那一行上面的東西都會在身體裡。',
    example: {
      html: '<p class="name">小怪</p>',
      css: `.name {
  position: absolute;
  bottom: 4px;
  width: 100%;
  margin: 0;
  text-align: center;
}`,
    },
    // .body 裡面的某個元素（不含 .body 自己）有文字；script、style 裡的字不算
    check: ({ html }) =>
      parseHtml(html).some(
        (el) =>
          el.tag !== 'script' &&
          el.tag !== 'style' &&
          el.text.trim() !== '' &&
          hasAncestor(el, (a) => a.classes.includes('body')),
      ),
  },
  {
    key: 'color-interval',
    title: '變色龍',
    description: '用 setInterval 讓合成獸每秒換一次毛色。',
    level: '挑戰',
    hint: "在 JS 引擎用 setInterval，每 1000 毫秒用 body.style.setProperty('--fur-color', 新顏色) 換一次毛色。",
    reference: '動作參考第 6 招「定時眨眼」看 setInterval 怎麼寫，第 13 招「每次點換隨機顏色」看怎麼算出隨機的顏色。',
    example: {
      js: `setInterval(() => {
  const hue = Math.floor(Math.random() * 360);
  body.style.setProperty('--fur-color', 'hsl(' + hue + ' 70% 65%)');
}, 1000);`,
    },
    moveId: 'blink-interval',
    // setInterval 的括號裡有改毛色或背景色的寫法
    check: ({ js }) => {
      const code = stripJsComments(js)
      const changesColor = new RegExp(
        `setProperty\\s*\\(\\s*${Q}--fur-color${Q}|\\.style\\.(?:background|backgroundColor)\\s*=`,
      )
      return [...code.matchAll(/\bsetInterval\s*\(/g)].some((m) =>
        changesColor.test(callArgs(code, m.index)),
      )
    },
  },
  {
    key: 'blue-fur',
    title: '藍色的毛',
    description: '把合成獸的毛色變成藍色系。',
    level: '簡單',
    hint: '在 CSS 烤漆的 .body 把 --fur-color 改成藍色系，例如 #42a5f5。',
    reference: 'CSS 烤漆最上面的 .body 就有 --fur-color，色碼旁邊的小色塊點下去可以直接選顏色。',
    example: {
      css: `.body {
  --fur-color: #42a5f5;
}`,
    },
    // 只看 .body 的 --fur-color：寫在 :root 會被 .body 自己的 --fur-color 蓋掉，畫面不會變藍
    check: ({ css }) => {
      const value = lastValue(css, isBody, ['--fur-color'])
      const color = value ? findColor(value) : null
      return !!color && isBluish(color)
    },
  },
  {
    key: 'two-horns',
    title: '雙角獸',
    description: '讓合成獸有兩支以上的角。',
    level: '普通',
    hint: '在 HTML 骨架放兩個 class 開頭是 horn 的元素，再用 CSS 畫出角的樣子。',
    reference: '零件商店的「角」分頁，點「雙角」的「看程式碼」，就看得到兩支角的 HTML 和 CSS，不用買。',
    example: {
      html: `<div class="horn left"></div>
<div class="horn right"></div>`,
      css: `.horn {
  position: absolute;
  top: -24px;
  width: 12px;
  height: 20px;
  background: #fbf8f1;
  border: 4px solid #4a3426;
  border-bottom: 0;
}

.horn.left {
  left: 20%;
}

.horn.right {
  right: 20%;
}`,
    },
    // 一支角裡面的小零件（例如鹿角的分岔）不另外算，只算最外層的角
    check: ({ html }) =>
      parseHtml(html).filter((el) => isHorn(el) && !hasAncestor(el, isHorn)).length >= 2,
  },
  {
    key: 'dblclick-toggle',
    title: '點兩下換表情',
    description: '點兩下身體，用 classList.toggle 切換一個 class。',
    level: '挑戰',
    hint: "在 JS 引擎加一個 dblclick 事件，裡面寫 body.classList.toggle('squint')，再到 CSS 寫 .body.squint 的樣子。",
    reference: '動作參考第 3 招「點兩下換表情」：dblclick 加上 classList.toggle，就是這一題要的寫法。',
    example: {
      js: `body.addEventListener('dblclick', () => {
  body.classList.toggle('squint');
});`,
      css: `/* 點兩下壓扁，再點兩下變回來 */
.body.squint {
  scale: 1 0.8;
}`,
    },
    moveId: 'dblclick-squint',
    // dblclick 的處理函式裡有 classList.toggle
    check: ({ js }) => {
      const toggles = new RegExp(`classList\\s*\\.\\s*toggle\\s*\\(\\s*${Q}[\\w-]+${Q}`)
      return handlers(stripJsComments(js), 'dblclick').some((body) => toggles.test(body))
    },
  },
  {
    key: 'body-shadow',
    title: '影子',
    description: '幫身體加上陰影。',
    level: '簡單',
    hint: '在 CSS 烤漆的 .body 加上 box-shadow，例如 box-shadow: 8px 8px 0 #4a3426;',
    reference: '零件商店的「身體」分頁，點「布丁」的「看程式碼」，它也是用 box-shadow 畫出焦糖那一層。',
    example: {
      css: `.body {
  box-shadow: 8px 8px 0 #4a3426;
}`,
    },
    check: ({ css }) => {
      const value = lastValue(css, isBody, ['box-shadow'])
      return !!value && value.toLowerCase() !== 'none'
    },
  },
]
