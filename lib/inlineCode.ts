// 說明文字裡用反引號包起來的地方是程式碼，例如「在 `.body` 裡加一行」
// 拆成一段一段，畫面再把程式碼那幾段顯示成行內程式碼的標籤；新手教程和動作參考都用這個
export type TextPart = { text: string; code: boolean }

export function splitInlineCode(text: string): TextPart[] {
  return text
    .split('`')
    .map((part, i) => ({ text: part, code: i % 2 === 1 }))
    .filter((part) => part.text)
}

// 後端傳來的說明文字沒有反引號，把裡面看起來像程式碼的英數字段落包起來，畫面才會顯示成行內程式碼
// 例如「在 .body 加上 border-radius，用 50% 最圓」裡的 .body、border-radius、50%
// HTML、CSS、JS 這幾個說的是格子名稱，不包
const PLAIN_WORDS = new Set(['HTML', 'CSS', 'JS'])

export function markCode(text: string) {
  return text.replace(/[\x21-\x7e](?:[\x20-\x7e]*[\x21-\x7e])?/g, (run) => {
    // 句尾的逗號、句點是句子的標點，不算程式碼；分號是 CSS 宣告的一部分，留著
    const code = run.replace(/[,.]+$/, '')
    const rest = run.slice(code.length)
    if (!/[\w#%]/.test(code) || PLAIN_WORDS.has(code)) return run
    return `\`${code}\`${rest}`
  })
}
