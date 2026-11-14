import { describe, expect, it } from 'vitest'
import { markCode, splitInlineCode } from '@/lib/inlineCode'

describe('splitInlineCode', () => {
  it('反引號包起來的是程式碼，其他是一般文字', () => {
    expect(splitInlineCode('在 `.body` 裡加一行 `border-radius`')).toEqual([
      { text: '在 ', code: false },
      { text: '.body', code: true },
      { text: ' 裡加一行 ', code: false },
      { text: 'border-radius', code: true },
    ])
  })

  it('程式碼裡的引號、角括號、分號都原樣保留', () => {
    expect(
      splitInlineCode(`寫 \`body.classList.add('jump');\` 和 \`<div class="speech">\``),
    ).toEqual([
      { text: '寫 ', code: false },
      { text: "body.classList.add('jump');", code: true },
      { text: ' 和 ', code: false },
      { text: '<div class="speech">', code: true },
    ])
  })

  it('沒有反引號就整段是一般文字', () => {
    expect(splitInlineCode('形狀也是長什麼樣子')).toEqual([
      { text: '形狀也是長什麼樣子', code: false },
    ])
  })

  it('開頭就是程式碼、空字串都沒問題', () => {
    expect(splitInlineCode('`#e8a33d` 是橘色')).toEqual([
      { text: '#e8a33d', code: true },
      { text: ' 是橘色', code: false },
    ])
    expect(splitInlineCode('')).toEqual([])
  })
})

describe('markCode', () => {
  it('把說明裡的英數字程式碼包成行內程式碼', () => {
    expect(markCode('在 .body 加上 border-radius，用 50% 最圓')).toBe(
      '在 `.body` 加上 `border-radius`，用 `50%` 最圓',
    )
  })

  it('中間有空白的一整段算同一段，句尾的分號留在程式碼裡', () => {
    expect(markCode('例如 box-shadow: 4px 4px 0 #4a3426;')).toBe(
      '例如 `box-shadow: 4px 4px 0 #4a3426;`',
    )
  })

  it('HTML、CSS、JS 這種格子名稱不包', () => {
    expect(markCode('在 HTML 的 <div class="body"> 裡面')).toBe(
      '在 HTML 的 `<div class="body">` 裡面',
    )
  })

  it('句尾的逗號、句點不算程式碼', () => {
    expect(markCode("寫 body.classList.add('happy'). 好")).toBe(
      "寫 `body.classList.add('happy')`. 好",
    )
  })
})
