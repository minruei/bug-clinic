import { splitInlineCode } from '@/lib/inlineCode'

// 把說明文字裡用反引號包起來的程式碼，顯示成淡黃底的行內程式碼標籤
export function CodeText({ text }: { text: string }) {
  return (
    <>
      {splitInlineCode(text).map((part, i) =>
        part.code ? (
          <code key={i} className="inline-code">
            {part.text}
          </code>
        ) : (
          part.text
        ),
      )}
    </>
  )
}
