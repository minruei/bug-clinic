// 存檔時間顯示成「11/14 16:52:08」，帶秒數，一分鐘內存好幾次也分得出來
// 跟病歷本一樣用瀏覽器自己的時區；timeZone 是給測試固定時區用的
export function formatSavedAt(value: string | Date, timeZone?: string) {
  const formatter = new Intl.DateTimeFormat('zh-TW', {
    timeZone,
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  })
  const parts = Object.fromEntries(
    formatter.formatToParts(new Date(value)).map((p) => [p.type, p.value]),
  )
  return `${parts.month}/${parts.day} ${parts.hour}:${parts.minute}:${parts.second}`
}
