import { describe, expect, it } from 'vitest'
import { buildPage, starterChimera, toJsLine, type ChimeraCode } from '@/lib/chimera'
import { MAX_ERRORS, addConsoleError, formatConsoleError, type ConsoleError } from '@/lib/console'

const code: ChimeraCode = {
  ...starterChimera,
  js: "const body = document.querySelector('.body')\nbody.addEventListener('click', () => {\n  tail.classList.add('wag')\n})",
}

// 在預覽頁裡找某一段文字在第幾行，用來模擬瀏覽器回報的行號
function pageLineOf(page: string, text: string) {
  return page.slice(0, page.indexOf(text)).split('\n').length
}

describe('toJsLine', () => {
  const page = buildPage(code, { catchErrors: true })

  it('預覽頁的行號換算成 JS 引擎格裡的第幾行', () => {
    expect(toJsLine(code, pageLineOf(page, 'const body ='), { catchErrors: true })).toBe(1)
    expect(toJsLine(code, pageLineOf(page, 'tail.classList'), { catchErrors: true })).toBe(3)
  })

  it('有沒有接主控台，換算出來都對', () => {
    const plain = buildPage(code)
    expect(toJsLine(code, pageLineOf(plain, 'tail.classList'))).toBe(3)
  })

  it('HTML、CSS 多了幾行，換算還是對的', () => {
    const longer = { ...code, html: `${code.html}\n<p>一</p>\n<p>二</p>`, css: `${code.css}\n\n\n` }
    const longerPage = buildPage(longer, { catchErrors: true })
    expect(toJsLine(longer, pageLineOf(longerPage, 'tail.classList'), { catchErrors: true })).toBe(
      3,
    )
  })

  it('玩家在 HTML 裡寫了 script，也不會算錯', () => {
    const tricky = { ...code, html: `${code.html}\n<script>\n// 我自己的\n</script>` }
    const trickyPage = buildPage(tricky, { catchErrors: true })
    expect(toJsLine(tricky, pageLineOf(trickyPage, 'tail.classList'), { catchErrors: true })).toBe(
      3,
    )
  })

  it('不在玩家 JS 裡的行、沒有行號，都回 null', () => {
    expect(toJsLine(code, 1, { catchErrors: true })).toBeNull()
    expect(toJsLine(code, pageLineOf(page, '</body>'), { catchErrors: true })).toBeNull()
    expect(toJsLine(code, null, { catchErrors: true })).toBeNull()
  })

  it('只有編輯器的預覽才放抓錯誤的程式', () => {
    expect(page).toContain('chimera-error')
    expect(buildPage(code)).not.toContain('chimera-error')
  })
})

describe('addConsoleError', () => {
  const tailError = { line: 3, message: 'tail is not defined' }

  it('同一行同一個訊息合併成一筆，次數加一', () => {
    let list: ConsoleError[] = []
    list = addConsoleError(list, tailError)
    list = addConsoleError(list, tailError)
    list = addConsoleError(list, tailError)
    expect(list).toEqual([{ ...tailError, count: 3 }])
  })

  it('不同行或不同訊息分開算', () => {
    let list: ConsoleError[] = []
    list = addConsoleError(list, tailError)
    list = addConsoleError(list, { ...tailError, line: 4 })
    list = addConsoleError(list, { ...tailError, message: 'x is not defined' })
    expect(list).toHaveLength(3)
  })

  it('最多 5 筆，之後的新錯誤不收，但已經有的還是會加次數', () => {
    let list: ConsoleError[] = []
    for (let i = 1; i <= 8; i++) list = addConsoleError(list, { line: i, message: '錯了' })
    expect(list).toHaveLength(MAX_ERRORS)
    expect(list.map((e) => e.line)).toEqual([1, 2, 3, 4, 5])

    list = addConsoleError(list, { line: 1, message: '錯了' })
    expect(list[0].count).toBe(2)
  })
})

describe('formatConsoleError', () => {
  it('有行號、出現一次', () => {
    expect(formatConsoleError({ line: 3, message: 'tail is not defined', count: 1 })).toBe(
      'JS 第 3 行：tail is not defined',
    )
  })

  it('出現很多次會標次數', () => {
    expect(formatConsoleError({ line: 3, message: 'tail is not defined', count: 4 })).toBe(
      'JS 第 3 行：tail is not defined（4 次）',
    )
  })

  it('沒有行號就不寫第幾行', () => {
    expect(formatConsoleError({ line: null, message: '出錯了', count: 1 })).toBe('JS：出錯了')
  })
})
