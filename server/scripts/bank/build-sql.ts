// 把兩批收下的題目寫成 db/add-bank-2.sql
// 每個主題 20 題照難度由淺到深排 id，正確答案輪流放在第 1、2、3 個
// 執行：npx tsx scripts/bank/build-sql.ts
import { readFileSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { parseArgs } from 'node:util'
import { topics } from './topics'
import type { Draft } from './verify'

type Accepted = Draft & {
  topic_key: string
  pet_name: string
  emoji: string
  topic: string
  batch: string
}

const { values: args } = parseArgs({
  options: {
    batches: { type: 'string', default: '1,2' },
    out: { type: 'string', default: resolve(__dirname, '../../db/add-bank-2.sql') },
  },
})
const OUT = resolve(__dirname, 'out')
const FIRST_ID = 101
const PER_TOPIC = 20

const all: Accepted[] = args.batches
  .split(',')
  .flatMap((b) => JSON.parse(readFileSync(join(OUT, `batch-${b}.json`), 'utf8')))

// 字串放進 SQL：反斜線、單引號跳脫，換行寫成 \n，跟 add-bank.sql 一樣
const q = (s: string) =>
  `'${s.replace(/\\/g, '\\\\').replace(/'/g, "''").replace(/\r?\n/g, '\\n').replace(/\t/g, '\\t')}'`

const lines = [
  '-- 題庫擴充第二波：每隻動物再加 20 題，總共 300 題',
  '-- 只新增不刪除；每一筆都先檢查 id 在不在，重複執行不會重複新增',
  '-- 執行前先確認 SELECT MAX(id) FROM problems; 是 100',
  'SET NAMES utf8mb4;',
]

let id = FIRST_ID
topics.forEach((t, ti) => {
  const list = all
    .filter((p) => p.topic_key === t.key)
    .sort((a, b) => a.difficulty - b.difficulty || a.batch.localeCompare(b.batch))
  if (list.length !== PER_TOPIC)
    throw new Error(`${t.pet_name} 有 ${list.length} 題，應該是 ${PER_TOPIC} 題`)

  lines.push('', `-- ${t.pet_name}：${t.topic}`)
  list.forEach((p, i) => {
    const correct = p.options.find((o) => o.correct)!
    const wrong = p.options.filter((o) => !o.correct)
    const pos = (i + ti) % 3
    const options = [...wrong.slice(0, pos), correct, ...wrong.slice(pos)]

    lines.push(
      `INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)`,
      `SELECT ${id}, ${q(t.pet_name)}, ${q(t.emoji)}, ${q(t.topic)}, ${q(p.error_message)}, ${q(p.symptom_zh)}, ${q(p.code)}, ${p.bug_line}, ${q(p.explanation)}`,
      `FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = ${id});`,
      `INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)`,
      `SELECT * FROM (`,
      options
        .map(
          (o, k) =>
            `  SELECT ${id} AS problem_id, ${q(o.text)} AS option_text, ${o.correct ? 'TRUE' : 'FALSE'} AS is_correct, ${k + 1} AS sort_order`,
        )
        .join('\n  UNION ALL\n'),
      `) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = ${id});`,
    )
    id++
  })
})

lines.push('', 'SELECT pet_name, COUNT(*) AS 題數 FROM problems GROUP BY pet_name;', '')
writeFileSync(args.out, lines.join('\n'))
console.log(`寫入 ${id - FIRST_ID} 題，id ${FIRST_ID} 到 ${id - 1}`)
