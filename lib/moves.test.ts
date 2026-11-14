import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { starterChimera } from '@/lib/chimera'
import { addMove, hasMove, hasNeededPart, moveDemoPage, moves, type Move } from '@/lib/moves'

const hop = moves.find((m) => m.id === 'click-hop') as Move
const spin = moves.find((m) => m.id === 'click-spin') as Move
const blink = moves.find((m) => m.id === 'blink-interval') as Move

// 假的元素：只做招式會用到的那幾個方法，事件記下來，測試時自己觸發
function fakeElement() {
  const listeners: Record<string, ((event: unknown) => void)[]> = {}
  const classes = new Set<string>()
  const element = {
    listeners,
    classes,
    textContent: '',
    classList: {
      add: (...names: string[]) => names.forEach((n) => classes.add(n)),
      remove: (...names: string[]) => names.forEach((n) => classes.delete(n)),
      toggle: (name: string) => (classes.has(name) ? classes.delete(name) : classes.add(name)),
      contains: (name: string) => classes.has(name),
    },
    // CSS 變數記在這裡，測試可以看 JS 把 --walk-x 改成多少
    vars: {} as Record<string, string>,
    style: {
      setProperty(name: string, value: string) {
        element.vars[name] = value
      },
      getPropertyValue(name: string) {
        return element.vars[name] ?? ''
      },
    },
    className: '',
    children: [] as unknown[],
    append(child: unknown) {
      this.children.push(child)
    },
    addEventListener: (type: string, fn: (event: unknown) => void) => {
      ;(listeners[type] ??= []).push(fn)
    },
    getBoundingClientRect: () => ({ left: 100, top: 100, width: 120, height: 100 }),
  }
  return element
}

type FakeElement = ReturnType<typeof fakeElement>

// 在假的 document 上執行一段 JS；found 決定 querySelector 找不找得到元素，missing 裡的選擇器一律找不到
function run(js: string, found: boolean, missing: string[] = []) {
  const elements: Record<string, FakeElement> = {}
  const created: FakeElement[] = []
  const document = {
    ...fakeElement(),
    querySelector: (selector: string) => {
      if (!found || missing.includes(selector)) return null
      return (elements[selector] ??= fakeElement())
    },
    createElement: () => {
      const element = fakeElement()
      created.push(element)
      return element
    },
  }
  const window = { innerWidth: 400, innerHeight: 320 }
  new Function('document', 'window', js)(document, window)
  return { document, elements, created }
}

// 把每個元素收到的事件都觸發一次
function fireAll(target: FakeElement) {
  const event = {
    key: 'ArrowLeft',
    code: 'Space',
    clientX: 10,
    clientY: 10,
    preventDefault: () => {},
  }
  for (const fns of Object.values(target.listeners)) fns.forEach((fn) => fn(event))
}

describe('動作參考資料', () => {
  it('20 招，每級 5 招，id 不重複', () => {
    expect(moves).toHaveLength(20)
    for (const level of [1, 2, 3, 4]) {
      expect(moves.filter((m) => m.level === level)).toHaveLength(5)
    }
    expect(new Set(moves.map((m) => m.id)).size).toBe(20)
  })

  it('每招都有觀念、效果、CSS、JS 和逐行解釋', () => {
    for (const move of moves) {
      expect(move.concept, move.id).not.toBe('')
      expect(move.effect, move.id).not.toBe('')
      expect(move.css, move.id).not.toBe('')
      expect(move.explain.length, move.id).toBeGreaterThan(0)
      // JS 整段用 { } 包起來，裡面的 const 才不會跟預設程式碼撞名
      expect(move.js.startsWith('{\n'), move.id).toBe(true)
      expect(move.js.endsWith('\n}'), move.id).toBe(true)
    }
  })

  it('CSS 的大括號都有成對', () => {
    for (const move of moves) {
      const open = move.css.split('{').length
      const close = move.css.split('}').length
      expect(open, move.id).toBe(close)
    }
  })
})

describe('addMove', () => {
  it('接在 CSS 和 JS 最後面，用標記包起來，原本的程式碼不動', () => {
    const next = addMove(starterChimera, hop)
    expect(next.html).toBe(starterChimera.html)
    expect(next.css.startsWith(starterChimera.css.trimEnd())).toBe(true)
    expect(next.js.startsWith(starterChimera.js.trimEnd())).toBe(true)
    expect(next.css).toContain(
      `/* [move:click-hop] 點一下跳 開始 */\n${hop.css}\n/* [move:click-hop] 結束 */`,
    )
    expect(next.js).toContain(
      `// [move:click-hop] 點一下跳 開始\n${hop.js}\n// [move:click-hop] 結束`,
    )
  })

  it('加過的招式不會重複加', () => {
    const once = addMove(starterChimera, hop)
    expect(hasMove(starterChimera, hop)).toBe(false)
    expect(hasMove(once, hop)).toBe(true)
    expect(addMove(once, hop)).toBe(once)
  })

  it('只剩一格有標記（另一格被玩家刪掉）也算加過', () => {
    const once = addMove(starterChimera, hop)
    expect(hasMove({ ...once, css: starterChimera.css }, hop)).toBe(true)
  })

  it('不同招式各自判斷，可以接著加', () => {
    const both = addMove(addMove(starterChimera, hop), spin)
    expect(hasMove(both, hop)).toBe(true)
    expect(hasMove(both, spin)).toBe(true)
    expect(both.js.indexOf('[move:click-hop]')).toBeLessThan(both.js.indexOf('[move:click-spin]'))
  })

  it('20 招各自加進預設程式碼，都沒有語法錯誤或重複宣告', () => {
    for (const move of moves) {
      const { js } = addMove(starterChimera, move)
      expect(() => new Function(js), move.id).not.toThrow()
    }
  })

  it('20 招全部加在一起也沒有語法錯誤或重複宣告', () => {
    const all = moves.reduce(addMove, starterChimera)
    expect(() => new Function(all.js)).not.toThrow()
  })
})

describe('招式執行起來', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })
  afterEach(() => {
    vi.useRealTimers()
  })

  it('找不到身體、對話框時什麼都不做，也不會報錯', () => {
    for (const move of moves) {
      expect(() => run(move.js, false), move.id).not.toThrow()
    }
  })

  it('找得到元素時，觸發事件、時間往前走都不會報錯', () => {
    for (const move of moves) {
      const { document, elements } = run(move.js, true)
      expect(() => {
        fireAll(document)
        Object.values(elements).forEach(fireAll)
        vi.advanceTimersByTime(15000)
      }, move.id).not.toThrow()
    }
  })

  it('點一下跳：點了加上 hop，動畫播完拿掉', () => {
    const { elements } = run(hop.js, true)
    const body = elements['.body']
    body.listeners.click[0]({})
    expect(body.classes.has('hop')).toBe(true)
    body.listeners.animationend[0]({})
    expect(body.classes.has('hop')).toBe(false)
  })

  it('被戳計數、隨機說一句話：沒有對話框就生一個放進 .chimera，點了換文字', () => {
    for (const id of ['poke-count', 'random-line']) {
      const move = moves.find((m) => m.id === id) as Move
      const { elements, created } = run(move.js, true, ['.speech'])
      expect(created, id).toHaveLength(1)
      expect(created[0].className, id).toBe('speech')
      expect(elements['.chimera'].children, id).toEqual([created[0]])
      elements['.body'].listeners.click[0]({})
      expect(created[0].textContent, id).not.toBe('')
    }
  })

  it('已經有對話框（教程怪物、舊存檔）就直接用，不會多生一個', () => {
    for (const id of ['poke-count', 'random-line']) {
      const move = moves.find((m) => m.id === id) as Move
      const { elements, created } = run(move.js, true)
      expect(created, id).toHaveLength(0)
      elements['.body'].listeners.click[0]({})
      expect(elements['.speech'].textContent, id).not.toBe('')
    }
  })

  it('方向鍵走路：上下鍵改 --walk-y，左右鍵改 --walk-x，走到框的邊邊就停', () => {
    const walk = moves.find((m) => m.id === 'arrow-walk') as Move
    const { document, elements } = run(walk.js, true)
    const press = (key: string) =>
      document.listeners.keydown.forEach((fn) => fn({ key, preventDefault: () => {} }))
    const chimera = elements['.chimera']

    press('ArrowUp')
    press('ArrowRight')
    expect(chimera.vars).toEqual({ '--walk-x': '20px', '--walk-y': '-20px' })

    // 預覽框 400×320：左右最遠 130px，上下最遠 90px
    for (let i = 0; i < 20; i++) press('ArrowDown')
    for (let i = 0; i < 20; i++) press('ArrowLeft')
    expect(chimera.vars).toEqual({ '--walk-x': '-130px', '--walk-y': '90px' })
  })

  it('方向鍵以外的鍵不會動', () => {
    const walk = moves.find((m) => m.id === 'arrow-walk') as Move
    const { document, elements } = run(walk.js, true)
    document.listeners.keydown.forEach((fn) => fn({ key: 'a', preventDefault: () => {} }))
    expect(elements['.chimera'].vars).toEqual({})
  })

  it('點哪裡走過去：點的位置換算成離中間多遠，x、y 都會變，點在邊邊也不會走出框', () => {
    const walk = moves.find((m) => m.id === 'click-walk') as Move
    const { document, elements } = run(walk.js, true)
    const click = (clientX: number, clientY: number) =>
      document.listeners.click.forEach((fn) => fn({ clientX, clientY }))

    click(250, 100)
    expect(elements['.chimera'].vars).toEqual({ '--walk-x': '50px', '--walk-y': '-60px' })

    click(0, 320)
    expect(elements['.chimera'].vars).toEqual({ '--walk-x': '-130px', '--walk-y': '90px' })
  })

  it('兩招都用 translate 移動 .chimera，有上下兩個方向', () => {
    for (const id of ['arrow-walk', 'click-walk']) {
      const move = moves.find((m) => m.id === id) as Move
      expect(move.css, id).toContain('translate: var(--walk-x, 0px) var(--walk-y, 0px);')
    }
  })

  it('招式改過名字，以前加過的也認得出來', () => {
    const walk = moves.find((m) => m.id === 'arrow-walk') as Move
    const old = {
      ...starterChimera,
      css: `${starterChimera.css}\n/* [move:arrow-walk] 方向鍵左右走 開始 */\n/* [move:arrow-walk] 結束 */`,
    }
    expect(hasMove(old, walk)).toBe(true)
  })

  it('定時眨眼：每 3 秒加上 blink，0.2 秒後拿掉', () => {
    const { elements } = run(blink.js, true)
    const body = elements['.body']
    vi.advanceTimersByTime(3000)
    expect(body.classes.has('blink')).toBe(true)
    vi.advanceTimersByTime(200)
    expect(body.classes.has('blink')).toBe(false)
  })
})

describe('hasNeededPart', () => {
  it('不需要零件的招式一律算有', () => {
    expect(hasNeededPart(starterChimera, hop)).toBe(true)
  })

  it('看 class 開頭，哪一款眼睛都算', () => {
    expect(hasNeededPart(starterChimera, blink)).toBe(false)
    const withEyes = { ...starterChimera, html: '<div class="eye-round left"></div>' }
    expect(hasNeededPart(withEyes, blink)).toBe(true)
  })
})

describe('moveDemoPage', () => {
  it('示範預覽有這一招，需要眼睛的會先裝上示範用的眼睛', () => {
    const page = moveDemoPage(blink)
    expect(page).toContain('[move:blink-interval]')
    expect(page).toContain('class="eye left"')
  })

  it('不需要零件的就是預設合成獸加上這一招', () => {
    const page = moveDemoPage(hop)
    expect(page).toContain('[move:click-hop]')
    expect(page).not.toContain('class="eye')
  })
})
