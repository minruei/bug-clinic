// 程式碼相似度：切成 token，每 3 個一組，算兩題共有的組數比例（Jaccard）
function shingles(code: string) {
  const tokens = code.match(/[A-Za-z_$][\w$]*|\d+|"[^"]*"|'[^']*'|`[^`]*`|\S/g) ?? []
  const set = new Set<string>()
  for (let i = 0; i + 2 < tokens.length; i++) set.add(tokens.slice(i, i + 3).join(' '))
  return set
}

export function similarity(a: string, b: string) {
  const sa = shingles(a)
  const sb = shingles(b)
  if (sa.size === 0 || sb.size === 0) return 0
  let common = 0
  for (const s of sa) if (sb.has(s)) common++
  return common / (sa.size + sb.size - common)
}

// 跟清單裡最像的那一題
export function mostSimilar<T extends { code: string }>(code: string, list: T[]) {
  let best: { item: T; score: number } | null = null
  for (const item of list) {
    const score = similarity(code, item.code)
    if (!best || score > best.score) best = { item, score }
  }
  return best
}
