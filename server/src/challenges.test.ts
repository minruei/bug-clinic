import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import {
  DAILY_REWARD,
  challenges,
  findColor,
  isBluish,
  isReddish,
  pickChallenge,
  publicChallenge,
  stripJsComments,
  taipeiDate,
  type ChimeraCode,
} from './challenges'

describe('taipeiDate', () => {
  it('UTC 15:59 和 16:00 是台灣的不同天', () => {
    expect(taipeiDate(new Date('2026-11-14T15:59:59Z'))).toBe('2026-11-14')
    expect(taipeiDate(new Date('2026-11-14T16:00:00Z'))).toBe('2026-11-15')
  })

  it('台灣午夜前後一秒', () => {
    // 台灣 23:59:59 = UTC 15:59:59，台灣 00:00:00 = UTC 16:00:00
    expect(taipeiDate(new Date('2026-11-14T23:59:59+08:00'))).toBe('2026-11-14')
    expect(taipeiDate(new Date('2026-11-15T00:00:00+08:00'))).toBe('2026-11-15')
  })

  it('UTC 還是前一天，台灣已經是隔天', () => {
    // UTC 11/14 20:00 = 台灣 11/15 04:00
    expect(taipeiDate(new Date('2026-11-14T20:00:00Z'))).toBe('2026-11-15')
  })

  it('美國伺服器的時間換算成台灣日期', () => {
    // 美西 11/14 09:30（UTC-8）= 台灣 11/15 01:30
    expect(taipeiDate(new Date('2026-11-14T09:30:00-08:00'))).toBe('2026-11-15')
  })

  it('日本凌晨 0:30 在台灣還是前一天', () => {
    expect(taipeiDate(new Date('2026-11-15T00:30:00+09:00'))).toBe('2026-11-14')
  })

  it('跨月和跨年', () => {
    expect(taipeiDate(new Date('2026-11-30T16:00:00Z'))).toBe('2026-12-01')
    expect(taipeiDate(new Date('2026-12-31T16:00:00Z'))).toBe('2027-01-01')
    expect(taipeiDate(new Date('2026-12-31T15:59:59Z'))).toBe('2026-12-31')
  })

  it('月和日都補成兩位數', () => {
    expect(taipeiDate(new Date('2027-03-05T04:00:00Z'))).toBe('2027-03-05')
  })
})

describe('pickChallenge', () => {
  it('同一天一定是同一題', () => {
    expect(pickChallenge('2026-11-14').key).toBe(pickChallenge('2026-11-14').key)
  })

  it('隔天換題', () => {
    expect(pickChallenge('2026-11-15').key).not.toBe(pickChallenge('2026-11-14').key)
    expect(pickChallenge('2027-01-01').key).not.toBe(pickChallenge('2026-12-31').key)
  })

  it('連續幾天剛好輪完所有題目，每題各一次', () => {
    const keys = new Set<string>()
    const start = Date.UTC(2026, 10, 14)
    for (let i = 0; i < challenges.length; i++) {
      const date = new Date(start + i * 86400000).toISOString().slice(0, 10)
      keys.add(pickChallenge(date).key)
    }
    expect(keys.size).toBe(challenges.length)
  })

  it('起始日以前、很久以後的日期也選得到題目', () => {
    expect(pickChallenge('2025-06-01')).toBeDefined()
    expect(pickChallenge('2099-12-31')).toBeDefined()
  })

  it('台灣午夜換日就換題', () => {
    const before = pickChallenge(taipeiDate(new Date('2026-11-14T15:59:59Z')))
    const after = pickChallenge(taipeiDate(new Date('2026-11-14T16:00:00Z')))
    expect(after.key).not.toBe(before.key)
  })

  it('日期格式不對就丟錯誤', () => {
    expect(() => pickChallenge('2026/11/14')).toThrow()
  })
})

describe('題目清單', () => {
  it('至少 7 題，key 不重複，獎勵 20 金幣', () => {
    expect(challenges.length).toBeGreaterThanOrEqual(7)
    expect(new Set(challenges.map((c) => c.key)).size).toBe(challenges.length)
    expect(DAILY_REWARD).toBe(20)
  })

  it('JS 題 2 到 3 題，都有 moveId', () => {
    const withMove = challenges.filter((c) => c.moveId)
    expect(withMove.length).toBeGreaterThanOrEqual(2)
    expect(withMove.length).toBeLessThanOrEqual(3)
  })

  // 後端的 Docker 只有 server/，不能 import 前端的 lib/moves.ts，這裡讀檔案文字確認 id 真的存在
  it('moveId 都是動作參考裡有的招式', () => {
    const moves = readFileSync(join(__dirname, '../../lib/moves.ts'), 'utf8')
    for (const c of challenges.filter((c) => c.moveId)) {
      expect(moves).toContain(`id: '${c.moveId}'`)
    }
  })

  it('給前端的資料不含檢查函式', () => {
    const data = publicChallenge(challenges[0])
    expect(data).not.toHaveProperty('check')
    expect(data.reward).toBe(20)
  })
})

describe('顏色', () => {
  it('各種寫法的紅色', () => {
    for (const v of ['#f00', '#FF0000', '#e53935', 'red', 'RED', 'rgb(220, 20, 60)', 'rgb(220 20 60)', 'hsl(0, 80%, 50%)', 'hsl(350 80% 50%)']) {
      expect(isReddish(findColor(v)!), v).toBe(true)
    }
  })

  it('不是紅色的', () => {
    for (const v of ['#b4b2a9', 'blue', '#000', '#fff', 'pink', 'orange']) {
      const c = findColor(v)
      expect(!!c && isReddish(c), v).toBe(false)
    }
  })

  it('藍色系', () => {
    for (const v of ['#42a5f5', 'blue', 'navy', 'skyblue', 'rgb(30, 144, 255)', 'hsl(220 70% 60%)']) {
      expect(isBluish(findColor(v)!), v).toBe(true)
    }
  })

  it('var() 這類算不出來的回 null', () => {
    expect(findColor('var(--eye-color)')).toBeNull()
  })
})

describe('stripJsComments', () => {
  it('拿掉 // 和 /* */ 註解，字串裡的 // 保留', () => {
    const code = `const a = 'http://x.com'; // 註解\n/* 區塊\n註解 */ const b = 1;`
    const out = stripJsComments(code)
    expect(out).toContain("'http://x.com'")
    expect(out).not.toContain('註解')
    expect(out).toContain('const b = 1;')
  })
})

// 跟正式版預設合成獸一樣的樣子（沒有 .speech），前端的 lib/chimera.ts 不能 import，這裡自己寫一份
const BASE_HTML = `<div class="chimera">
  <div class="body">
    <!-- 零件裝在這裡 -->
  </div>
</div>`

const BASE_CSS = `.chimera {
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

.body.jump {
  animation: jump 0.4s ease-out;
}

@keyframes jump {
  50% {
    translate: 0 -30px;
  }
}`

const BASE_JS = `const body = document.querySelector('.body');

body.addEventListener('click', () => {
  body.classList.add('jump');
});

body.addEventListener('animationend', () => {
  body.classList.remove('jump');
});
`

const base: ChimeraCode = { html: BASE_HTML, css: BASE_CSS, js: BASE_JS }

// 有眼睛零件的合成獸
const EYES_HTML = BASE_HTML.replace(
  '<!-- 零件裝在這裡 -->',
  '<div class="eye-round left"><div class="eye-round-pupil"></div></div>\n    <div class="eye-round right"><div class="eye-round-pupil"></div></div>',
)

const withCss = (css: string): ChimeraCode => ({ ...base, css: `${BASE_CSS}\n\n${css}` })
const withHtml = (inner: string): ChimeraCode => ({
  ...base,
  html: BASE_HTML.replace('<!-- 零件裝在這裡 -->', inner),
})
const withJs = (js: string): ChimeraCode => ({ ...base, js: `${BASE_JS}\n${js}` })

const challenge = (key: string) => {
  const c = challenges.find((c) => c.key === key)
  if (!c) throw new Error(`找不到題目 ${key}`)
  return c
}

type Sample = [string, ChimeraCode]

// 每一題：會過的樣本、不會過的樣本；預設合成獸一定不會過
const samples: Record<string, { pass: Sample[]; fail: Sample[] }> = {
  'red-eyes': {
    pass: [
      ['.eye 改成紅色', { ...withCss('.eye { background: #e53935; }'), html: EYES_HTML }],
      ['零件的 class 和 background-color', withCss('.eye-round { background-color: red; }')],
      ['動作參考的 [class^="eye"] 寫法', withCss('.body [class^="eye"] { background: rgb(200, 30, 30); }')],
      ['多餘空白、大寫屬性和顏色', withCss('  .eye-star   {\n\n  BACKGROUND :   #FF0000  !important ;\n}')],
    ],
    fail: [
      ['寫在註解裡', withCss('/* .eye { background: red; } */')],
      ['藍色眼睛', withCss('.eye { background: blue; }')],
      ['class 大小寫不同（.Eye 選不到眼睛）', withCss('.Eye { background: red; }')],
      ['改的是身體不是眼睛', withCss('.body { background: red; }')],
      ['後面又改回黑色', withCss('.eye { background: red; }\n.eye { background: #000; }')],
    ],
  },
  'round-body': {
    pass: [
      ['50%', withCss('.body { border-radius: 50%; }')],
      ['夠大的 px', withCss('.body { border-radius: 60px; }')],
      ['多餘空白、大寫屬性', withCss('.chimera   >   .body {   BORDER-RADIUS:50% ; }')],
      ['斜線寫法只看前面', withCss('.body { border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%; }')],
    ],
    fail: [
      ['寫在註解裡', withCss('/* .body { border-radius: 50%; } */')],
      ['只有一點點圓', withCss('.body { border-radius: 8px; }')],
      ['只有上面圓（麵包形）', withCss('.body { border-radius: 60px 60px 8px 8px; }')],
      ['class 大小寫不同', withCss('.Body { border-radius: 50%; }')],
      ['只在跳的時候圓', withCss('.body.jump { border-radius: 50%; }')],
    ],
  },
  'click-happy': {
    pass: [
      ['click 加上 happy', withJs("body.addEventListener('click', () => { body.classList.add('happy'); });")],
      ['雙引號、多餘空白', withJs('body.addEventListener(  "click" ,()=>{  body.classList.add(  "happy"  ) })')],
      ['toggle 也可以', withJs('body.addEventListener(`click`, () => body.classList.toggle(`happy`))')],
      ['onclick 寫法', withJs("body.onclick = () => { body.classList.add('happy'); };")],
    ],
    fail: [
      ['寫在註解裡', withJs("// body.classList.add('happy');")],
      ['寫在區塊註解裡', withJs("/*\nbody.classList.add('happy');\n*/")],
      ['class 大小寫不同', withJs("body.addEventListener('click', () => { body.classList.add('Happy'); });")],
      ['事件名稱大小寫不同', withJs("body.addEventListener('Click', () => { body.classList.add('happy'); });")],
      ['沒有 click 事件', { ...base, js: "document.querySelector('.body').classList.add('happy');" }],
      ['預設有 click，但 happy 加在 click 外面', withJs("body.classList.add('happy');")],
    ],
  },
  'wide-body': {
    pass: [
      ['剛好 160px', withCss('.body { width: 160px; }')],
      ['多餘空白、大寫', withCss('.body{WIDTH :  200PX}')],
      ['用 rem', withCss('.body { width: 12rem; }')],
    ],
    fail: [
      ['寫在註解裡', withCss('/* .body { width: 200px; } */')],
      ['159px', withCss('.body { width: 159px; }')],
      ['改的是 .chimera', withCss('.chimera { width: 300px; }')],
      ['class 大小寫不同', withCss('.BODY { width: 200px; }')],
      ['百分比算不出 px', withCss('.body { width: 80%; }')],
    ],
  },
  'name-tag': {
    pass: [
      ['p 標籤', withHtml('<p>小怪</p>')],
      ['大寫標籤、單引號 class、多餘空白', withHtml("<SPAN  class = 'name' >  阿呆  </SPAN>")],
      ['包在零件裡面', withHtml('<div class="eye"><b>咪</b></div>')],
    ],
    fail: [
      ['寫在註解裡', withHtml('<!-- <p>小怪</p> -->')],
      ['元素是空的', withHtml('<p>   </p>')],
      ['寫在身體外面', { ...base, html: `${BASE_HTML}\n<p>小怪</p>` }],
      ['class 大小寫不同（Body 不是身體）', { ...base, html: '<div class="Body"><p>小怪</p></div>' }],
      ['script 裡的字不算', withHtml('<script>const name = 1</script>')],
    ],
  },
  'color-interval': {
    pass: [
      [
        '動作參考的寫法',
        withJs("setInterval(() => {\n  body.style.setProperty('--fur-color', 'hsl(' + Math.random() * 360 + ' 70% 65%)');\n}, 1000);"),
      ],
      ['多餘空白、雙引號', withJs('setInterval (  function () { body.style.setProperty(  "--fur-color" , "blue" ) } , 1000 )')],
      ['改 style.background', withJs("setInterval(() => { body.style.background = 'red'; }, 1000);")],
    ],
    fail: [
      ['寫在註解裡', withJs("// setInterval(() => body.style.setProperty('--fur-color', 'red'), 1000);")],
      ['只有改顏色，沒有 setInterval', withJs("body.style.setProperty('--fur-color', 'red');")],
      ['setInterval 大小寫不同', withJs("SetInterval(() => body.style.setProperty('--fur-color', 'red'), 1000);")],
      ['變數名稱大小寫不同', withJs("setInterval(() => body.style.setProperty('--Fur-Color', 'red'), 1000);")],
      ['改顏色寫在 setInterval 前面', withJs("body.style.setProperty('--fur-color', 'red');\nsetInterval(() => {}, 1000);")],
      ['改顏色寫在 setInterval 後面但不在裡面', withJs("setInterval(() => {}, 1000);\nbody.style.setProperty('--fur-color', 'red');")],
    ],
  },
  'blue-fur': {
    pass: [
      ['改 .body 的 --fur-color', withCss('.body { --fur-color: #42a5f5; }')],
      ['多餘空白、大寫顏色', withCss('.body   {   --fur-color :   ROYALBLUE ;}')],
      ['hsl', withCss('.body { --fur-color: hsl(210 80% 60%); }')],
    ],
    fail: [
      ['寫在註解裡', withCss('/* .body { --fur-color: blue; } */')],
      ['紅色', withCss('.body { --fur-color: red; }')],
      ['變數名稱大小寫不同', withCss('.body { --Fur-Color: blue; }')],
      ['寫在 :root 會被 .body 蓋掉', withCss(':root { --fur-color: blue; }')],
    ],
  },
  'two-horns': {
    pass: [
      ['兩個 .horn', withHtml('<div class="horn left"></div>\n<div class="horn right"></div>')],
      ['不同款的角、大寫標籤', withHtml('<DIV class="horn-cat"></DIV><span class="horn-ox"></span>')],
      ['三個角', withHtml('<i class="horn"></i><i class="horn"></i><i class="horn"></i>')],
    ],
    fail: [
      ['寫在註解裡', withHtml('<div class="horn"></div>\n<!-- <div class="horn"></div> -->')],
      ['只有一個角', withHtml('<div class="horn"></div>')],
      ['一個角加上它自己的分岔', withHtml('<div class="horn-deer"><div class="horn-deer-branch"></div></div>')],
      ['class 大小寫不同', withHtml('<div class="Horn"></div><div class="HORN"></div>')],
    ],
  },
  'dblclick-toggle': {
    pass: [
      ['動作參考的寫法', withJs("body.addEventListener('dblclick', () => {\n  body.classList.toggle('squint');\n});")],
      ['多餘空白、雙引號', withJs('body.addEventListener (  "dblclick",()=>body.classList.toggle(  "sleepy"  ))')],
    ],
    fail: [
      ['寫在註解裡', withJs("/* body.addEventListener('dblclick', () => body.classList.toggle('squint')); */")],
      ['用 add 不是 toggle', withJs("body.addEventListener('dblclick', () => body.classList.add('squint'));")],
      ['事件名稱大小寫不同', withJs("body.addEventListener('dblClick', () => body.classList.toggle('squint'));")],
      ['只有 click', withJs("body.addEventListener('click', () => body.classList.toggle('squint'));")],
      ['toggle 寫在 dblclick 外面', withJs("body.addEventListener('dblclick', () => {});\nbody.classList.toggle('squint');")],
    ],
  },
  'body-shadow': {
    pass: [
      ['box-shadow', withCss('.body { box-shadow: 4px 4px 0 #4a3426; }')],
      ['多餘空白、大寫屬性', withCss('.body{BOX-SHADOW :0 0 10px rgba(0,0,0,.5)}')],
    ],
    fail: [
      ['寫在註解裡', withCss('/* .body { box-shadow: 4px 4px 0 #000; } */')],
      ['none', withCss('.body { box-shadow: 4px 4px 0 #000; }\n.body { box-shadow: NONE; }')],
      ['class 大小寫不同', withCss('.Body { box-shadow: 4px 4px 0 #000; }')],
      ['加在 .chimera', withCss('.chimera { box-shadow: 4px 4px 0 #000; }')],
    ],
  },
}

describe('過關檢查', () => {
  it('每一題都有測試樣本', () => {
    expect(Object.keys(samples).sort()).toEqual(challenges.map((c) => c.key).sort())
  })

  for (const [key, { pass, fail }] of Object.entries(samples)) {
    describe(key, () => {
      it('預設合成獸不會過', () => {
        expect(challenge(key).check(base)).toBe(false)
      })
      for (const [name, code] of pass) {
        it(`會過：${name}`, () => expect(challenge(key).check(code)).toBe(true))
      }
      for (const [name, code] of fail) {
        it(`不會過：${name}`, () => expect(challenge(key).check(code)).toBe(false))
      }
    })
  }
})
