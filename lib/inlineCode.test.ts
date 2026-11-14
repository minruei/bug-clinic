import { describe, expect, it } from 'vitest'
import { splitInlineCode } from '@/lib/inlineCode'

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
