// 錯誤主控台的一筆錯誤；line 是 JS 引擎格裡的第幾行，對不到就是 null
export type ConsoleError = {
  line: number | null
  message: string
  count: number
}

// 主控台最多顯示幾筆
export const MAX_ERRORS = 5

// 加一筆錯誤：同一行同一個訊息合併成一筆、次數加一，例如點了好幾次都出錯
// 不一樣的錯誤最多留 5 筆，再多的就不收了，先出現的錯誤通常才是原因
export function addConsoleError(
  list: ConsoleError[],
  error: { line: number | null; message: string },
): ConsoleError[] {
  const same = list.findIndex((e) => e.line === error.line && e.message === error.message)
  if (same !== -1) {
    return list.map((e, i) => (i === same ? { ...e, count: e.count + 1 } : e))
  }
  if (list.length >= MAX_ERRORS) return list
  return [...list, { ...error, count: 1 }]
}

// 主控台顯示的文字，例如「JS 第 3 行：tail is not defined」
export function formatConsoleError(error: ConsoleError) {
  const where = error.line ? `JS 第 ${error.line} 行` : 'JS'
  const times = error.count > 1 ? `（${error.count} 次）` : ''
  return `${where}：${error.message}${times}`
}
