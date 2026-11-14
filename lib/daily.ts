// 每日任務的前端檢查
// 分兩層，兩層都過才算完成：
// 1. 寫法檢查：直接用後端的 challenges.ts，跟領獎時後端的判斷一模一樣，前端不會比後端寬鬆
// 2. 效果檢查：在 sandbox 預覽裡真的跑起來，量畫面上的結果（真的點一下、真的等兩秒），只會比後端嚴格
import { challenges, isBluish, isReddish, parseColor } from '@/server/src/challenges'
import { buildPage, type ChimeraCode } from '@/lib/chimera'

// GET /api/daily 回傳的今日任務
export type DailyTask = {
  date: string
  key: string
  title: string
  description: string
  level: '簡單' | '普通' | '挑戰'
  // 三層提示：方向、去哪裡找參考、可以直接貼的範例
  hint: string
  reference: string
  example: Partial<ChimeraCode>
  moveId: string | null
  reward: number
  claimed: boolean
}

// 第 3 層提示：範例程式碼分成幾格，每一格寫清楚要貼在哪裡
export const examplePlaces: { tab: keyof ChimeraCode; where: string }[] = [
  { tab: 'html', where: '貼到 HTML 骨架裡 `<!-- 零件裝在這裡 -->` 那一行的上面' },
  { tab: 'css', where: '貼到 CSS 烤漆的最後面' },
  { tab: 'js', where: '貼到 JS 引擎的最後面' },
]

// 照第 3 層提示把範例貼到程式碼裡，測試用：確認貼上去就會過關
export function pasteExample(code: ChimeraCode, example: Partial<ChimeraCode>): ChimeraCode {
  const marker = '<!-- 零件裝在這裡 -->'
  return {
    html: example.html ? code.html.replace(marker, `${example.html}\n${marker}`) : code.html,
    css: example.css ? `${code.css}\n\n${example.css}` : code.css,
    js: example.js ? `${code.js}\n${example.js}` : code.js,
  }
}

// 預覽裡量到的東西，每題只量自己需要的那幾項
export type DailyMeasure = {
  eyeColors?: string[]
  radius?: string[]
  width?: number
  hasNameText?: boolean
  happyAfterClick?: boolean
  furChanged?: boolean
  furColor?: string
  horns?: number
  toggledAfterDblclick?: boolean
  shadow?: string
}

// 放在玩家的 JS 後面執行：等一下讓玩家的程式先跑完，量好再用 postMessage 傳出去
// 只量畫面上真的看得到的結果；模擬點擊只發生在這個檢查用的預覽裡，不會影響編輯器的預覽
// 看不看得到用 getComputedStyle 判斷，不用 getClientRects：分頁在背景時預覽不會排版，量位置會拿到 0
const MEASURE_SCRIPT = `<script>
(function () {
  var key = KEY
  var body = document.querySelector('.body')
  function done(measure) {
    parent.postMessage({ type: 'daily-check', key: key, measure: measure }, '*')
  }
  function furColor() {
    if (!body) return ''
    var probe = document.createElement('span')
    probe.style.color = 'var(--fur-color)'
    body.appendChild(probe)
    var color = getComputedStyle(probe).color
    probe.remove()
    return color + '|' + getComputedStyle(body).backgroundColor
  }
  function snapshot() {
    return Array.prototype.map.call(document.querySelectorAll('*'), function (el) {
      return el.className && el.className.baseVal === undefined ? el.className : ''
    }).join('|')
  }
  function shown(el) {
    for (var e = el; e; e = e.parentElement) {
      var s = getComputedStyle(e)
      if (s.display === 'none' || s.visibility === 'hidden') return false
    }
    return true
  }
  function ownText(el) {
    return Array.prototype.filter.call(el.childNodes, function (n) { return n.nodeType === 3 })
      .map(function (n) { return n.textContent }).join('').trim()
  }
  function topLevel(prefix) {
    return Array.prototype.filter.call(document.querySelectorAll('[class]'), function (el) {
      var mine = Array.prototype.some.call(el.classList, function (c) { return c.indexOf(prefix) === 0 })
      if (!mine || !shown(el)) return false
      for (var p = el.parentElement; p; p = p.parentElement) {
        if (Array.prototype.some.call(p.classList, function (c) { return c.indexOf(prefix) === 0 })) return false
      }
      return true
    })
  }
  setTimeout(function () {
    if (!body) return done({})
    var style = getComputedStyle(body)
    if (key === 'red-eyes') {
      done({ eyeColors: topLevel('eye').map(function (el) { return getComputedStyle(el).backgroundColor }) })
    } else if (key === 'round-body') {
      done({ radius: [style.borderTopLeftRadius, style.borderTopRightRadius, style.borderBottomRightRadius, style.borderBottomLeftRadius] })
    } else if (key === 'wide-body') {
      done({ width: parseFloat(style.width) })
    } else if (key === 'name-tag') {
      done({ hasNameText: Array.prototype.some.call(body.querySelectorAll('*'), function (el) {
        return el.tagName !== 'SCRIPT' && el.tagName !== 'STYLE' && ownText(el) !== '' && shown(el)
      }) })
    } else if (key === 'click-happy') {
      body.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      done({ happyAfterClick: body.classList.contains('happy') })
    } else if (key === 'dblclick-toggle') {
      var before = snapshot()
      body.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }))
      done({ toggledAfterDblclick: snapshot() !== before })
    } else if (key === 'color-interval') {
      var first = furColor()
      setTimeout(function () { done({ furChanged: furColor() !== first }) }, 2200)
    } else if (key === 'blue-fur') {
      done({ furColor: furColor().split('|')[0] })
    } else if (key === 'two-horns') {
      done({ horns: topLevel('horn').length })
    } else if (key === 'body-shadow') {
      done({ shadow: style.boxShadow })
    } else {
      done({})
    }
  }, 300)
})()
</script>`

// 檢查用的預覽頁：玩家的三格程式碼，最後面接上量測的程式
// 插在最後一個 </body> 前面，玩家的 HTML 裡就算寫了 </body> 也不會插錯地方
export function dailyCheckPage(code: ChimeraCode, key: string) {
  const page = buildPage(code)
  const at = page.lastIndexOf('</body>')
  return `${page.slice(0, at)}${MEASURE_SCRIPT.replace('KEY', JSON.stringify(key))}\n${page.slice(at)}`
}

// 一個圓角夠不夠圓：跟後端一樣，百分比至少 25%，或至少 30px；橢圓角只看第一個值
function roundEnough(value: string) {
  const first = value.trim().split(/\s+/)[0] ?? ''
  const n = parseFloat(first)
  if (Number.isNaN(n)) return false
  return first.endsWith('%') ? n >= 25 : n >= 30
}

// 每一題看預覽量到的結果
const effectChecks: Record<string, (m: DailyMeasure) => boolean> = {
  'red-eyes': (m) =>
    (m.eyeColors ?? []).some((c) => {
      const color = parseColor(c)
      return !!color && isReddish(color)
    }),
  'round-body': (m) => (m.radius ?? []).length === 4 && (m.radius ?? []).every(roundEnough),
  'click-happy': (m) => m.happyAfterClick === true,
  'wide-body': (m) => (m.width ?? 0) >= 160,
  'name-tag': (m) => m.hasNameText === true,
  'color-interval': (m) => m.furChanged === true,
  'blue-fur': (m) => {
    const color = m.furColor ? parseColor(m.furColor) : null
    return !!color && isBluish(color)
  },
  'two-horns': (m) => (m.horns ?? 0) >= 2,
  'dblclick-toggle': (m) => m.toggledAfterDblclick === true,
  'body-shadow': (m) => !!m.shadow && m.shadow !== 'none',
}

export const dailyKeys = Object.keys(effectChecks)

// 寫法和效果都過了才算完成；不認得的題目一律不過，前端不會比後端寬鬆
export function passesDaily(key: string, code: ChimeraCode, measure: DailyMeasure) {
  const challenge = challenges.find((c) => c.key === key)
  const effect = effectChecks[key]
  if (!challenge || !effect) return false
  return challenge.check(code) && effect(measure)
}
