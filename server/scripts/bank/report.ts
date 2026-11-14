// 整理一批的結果：通過率、淘汰原因、花費，每個主題抽 3 題寫成 md 給人抽查
// 執行：npx tsx scripts/bank/report.ts --batch 1
import { existsSync, readFileSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { parseArgs } from 'node:util'
import { topics } from './topics'
import type { Draft, Verified } from './verify'

const { values: args } = parseArgs({
  options: {
    batch: { type: 'string', default: '1' },
    samples: { type: 'string', default: '3' },
  },
})
const batch = args.batch
const OUT = resolve(__dirname, 'out')
const read = (file: string) => JSON.parse(readFileSync(join(OUT, file), 'utf8'))

type Accepted = Draft & { topic_key: string; pet_name: string; topic: string; verified: Verified }
type Rejected = { topic_key: string; stage: string; reasons: string[] }

const accepted: Accepted[] = read(`batch-${batch}.json`)
const rejected: Rejected[] = read(`rejects-${batch}.json`)
const cost = existsSync(join(OUT, 'cost.json')) ? read('cost.json') : { usd: 0 }

// 把淘汰原因歸成幾類
function bucket(r: Rejected) {
  const first = r.reasons[0] ?? ''
  if (r.stage === 'manual') return '抽查：不符合主題'
  if (r.stage === 'api') return 'API 回應失敗'
  if (r.stage === 'similar') return '跟同主題題目太像'
  if (r.stage === 'format') return `格式：${first.replace(/\d+/g, 'N')}`
  if (r.stage === 'run') {
    if (first.startsWith('錯誤選項也能修好')) return '執行：錯誤選項也能修好'
    return `執行：${first.split('：')[0]}`
  }
  const text = r.reasons.join(' ')
  if (/重複/.test(text)) return '審核：觀念重複'
  if (/錯誤選項|選項/.test(text)) return '審核：選項有問題'
  if (/error_message|symptom|症狀|錯誤訊息/.test(text)) return '審核：症狀跟程式不一致'
  if (/explanation|解說/.test(text)) return '審核：解說不正確'
  if (/難度/.test(text)) return '審核：難度標示不合理'
  return '審核：其他'
}

const lines: string[] = [`# 題庫第 ${batch} 批抽查`, '']
// 出題階段的淘汰，和收下後照新規則改寫時的淘汰分開算
const isRevise = (r: Rejected) => r.stage.startsWith('revise') || r.stage === 'manual'
const genRejected = rejected.filter((r) => !isRevise(r))
const reviseRejected = rejected.filter(isRevise)
const genAccepted = accepted.length + reviseRejected.length
const pct = (a: number, b: number) => (b ? `${((a / b) * 100).toFixed(0)}%` : '-')
const revisedKept = accepted.filter((p) => (p as { revised?: boolean }).revised).length
lines.push(
  `收下 ${accepted.length} 題：舊題照新規則改寫後留下 ${revisedKept} 題，新出 ${accepted.length - revisedKept} 題補齊。`,
  `出題通過率 ${pct(genAccepted, genAccepted + genRejected.length)}（出題 ${genAccepted + genRejected.length} 次，驗證通過 ${genAccepted} 次）。`,
  `累計花費 US$${cost.usd.toFixed(2)}（含試跑和改寫）。`,
  '',
  '| 主題 | 最後收下 | 出題通過 | 出題淘汰 | 出題通過率 | 改寫或抽查淘汰 | 真的執行 | 只做審核 |',
  '| --- | --- | --- | --- | --- | --- | --- | --- |',
)
for (const t of topics) {
  const a = accepted.filter((p) => p.topic_key === t.key)
  const g = genRejected.filter((p) => p.topic_key === t.key).length
  const rv = reviseRejected.filter((p) => p.topic_key === t.key).length
  const run = a.filter((p) => p.verified.mode === 'run').length
  lines.push(
    `| ${t.pet_name} ${t.topic} | ${a.length} | ${a.length + rv} | ${g} | ${pct(a.length + rv, a.length + rv + g)} | ${rv} | ${run} | ${a.length - run} |`,
  )
}

function table(title: string, list: Rejected[]) {
  const counts = new Map<string, number>()
  for (const r of list) counts.set(bucket(r), (counts.get(bucket(r)) ?? 0) + 1)
  lines.push('', `## ${title}`, '', '| 原因 | 次數 |', '| --- | --- |')
  for (const [k, v] of [...counts].sort((a, b) => b[1] - a[1])) lines.push(`| ${k} | ${v} |`)
}
table('出題淘汰原因', genRejected)
table('改寫和抽查淘汰原因', reviseRejected)

// 第二批之後，把兩批加起來，給簡報用
if (batch === '2') {
  const both = ['1', '2'].map((b) => ({
    a: read(`batch-${b}.json`) as Accepted[],
    r: (read(`rejects-${b}.json`) as Rejected[]).filter((x) => !isRevise(x)),
    rv: (read(`rejects-${b}.json`) as Rejected[]).filter(isRevise),
  }))
  const acc = both.flatMap((x) => x.a)
  const passed = both.reduce((n, x) => n + x.a.length + x.rv.length, 0)
  const tries = passed + both.reduce((n, x) => n + x.r.length, 0)
  const run = acc.filter((p) => p.verified.mode === 'run').length
  lines.push(
    '',
    '## 兩批合計',
    '',
    `- 新增題目：${acc.length} 題（題庫總共 ${100 + acc.length} 題）`,
    `- 各主題：${topics.map((t) => `${t.pet_name} ${acc.filter((p) => p.topic_key === t.key).length}`).join('、')}`,
    `- 總通過率：${pct(passed, tries)}（出題 ${tries} 次，驗證通過 ${passed} 次）`,
    `- 真的執行驗證：${run} 題；只做交叉審核：${acc.length - run} 題`,
    `- 總花費：US$${cost.usd.toFixed(2)}`,
  )
}

const mark = (code: string, bug: number) =>
  code
    .split('\n')
    .map((l, i) => `${i + 1 === bug ? '>' : ' '} ${String(i + 1).padStart(2)} | ${l}`)
    .join('\n')
// 輸出裡的暫存資料夾路徑拿掉，只留檔名
const clean = (s: string) => s.replace(/(file:\/\/)?\/\S*\/case-[\d-]+\//g, '')
const fence = (s: string) => '```\n' + clean(s).replace(/^\n+|\s+$/g, '') + '\n```'
const lang: Record<string, string> = {
  tsc: 'TypeScript 編譯',
  node: 'Node.js 執行',
  sql: 'MySQL 執行',
  review: '只做交叉審核',
}

const levels = Number(args.samples) === 2 ? [2, 3] : [1, 2, 3]
const pickNote = levels.length === 2 ? '每個主題挑中、深各一題。' : '每個主題挑淺、中、深各一題。'
lines.push('', '## 抽查題目', '', `${pickNote}程式碼前面有 > 的是 bug 那一行。`)
for (const t of topics) {
  const a = accepted.filter((p) => p.topic_key === t.key)
  const picks = levels
    .map((lv) => a.find((p) => p.difficulty === lv))
    .filter((p) => p) as Accepted[]
  for (const p of a) if (picks.length < levels.length && !picks.includes(p)) picks.push(p)
  lines.push('', `### ${t.pet_name}（${t.topic}）`)
  for (const p of picks) {
    lines.push(
      '',
      `#### 難度 ${p.difficulty}：${p.concept}`,
      '',
      `驗證方式：${lang[p.check.runner === 'review' || p.verified.mode === 'review' ? 'review' : p.check.runner]}`,
      '',
      `症狀：${p.error_message}`,
      '',
      `中文：${p.symptom_zh}`,
      '',
      fence(mark(p.code, p.bug_line)),
      '',
      '選項：',
      '',
      ...p.options.map((o) => `- ${o.correct ? '**正確**' : '錯誤'}：\`${o.text.trim()}\``),
      '',
      '解說：',
      '',
      ...p.explanation.split('\n').map((l) => `- ${l}`),
    )
    if (p.verified.mode === 'run') {
      lines.push(
        '',
        '有 bug 時實際輸出：',
        '',
        fence(p.verified.buggy!.out.split('\n').slice(0, 6).join('\n')),
        '',
        '換上正確選項後的輸出：',
        '',
        fence(
          p.verified.fixed!.out.split('\n').slice(0, 6).join('\n') || '（沒有輸出，也沒有錯誤）',
        ),
      )
    }
  }
}

writeFileSync(join(OUT, `review-batch-${batch}.md`), lines.join('\n') + '\n')
console.log(lines.slice(0, 40).join('\n'))
