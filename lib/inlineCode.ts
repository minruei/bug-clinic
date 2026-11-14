// 說明文字裡用反引號包起來的地方是程式碼，例如「在 `.body` 裡加一行」
// 拆成一段一段，畫面再把程式碼那幾段顯示成行內程式碼的標籤；新手教程和動作參考都用這個
export type TextPart = { text: string; code: boolean }

export function splitInlineCode(text: string): TextPart[] {
  return text
    .split('`')
    .map((part, i) => ({ text: part, code: i % 2 === 1 }))
    .filter((part) => part.text)
}
