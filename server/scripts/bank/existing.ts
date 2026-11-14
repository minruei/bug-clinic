// 從 seed.sql 和 add-bank.sql 讀出現有的 100 題，出新題時拿來比對有沒有重複
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

export type Existing = {
  id: number
  pet_name: string
  topic: string
  error_message: string
  code: string
  bug_line: number
  options: { text: string; correct: boolean }[]
}

// 把 VALUES (...) 裡的值一個一個切出來，字串裡的 '' 和 \n 還原
function splitValues(s: string) {
  const out: (string | number | boolean | null)[] = []
  const re = /'((?:[^']|'')*)'|(-?\d+)|(NULL|TRUE|FALSE)/g
  let m: RegExpExecArray | null
  while ((m = re.exec(s))) {
    if (m[1] !== undefined) out.push(m[1].replace(/''/g, "'").replace(/\\n/g, '\n'))
    else if (m[2] !== undefined) out.push(Number(m[2]))
    else out.push(m[3] === 'NULL' ? null : m[3] === 'TRUE')
  }
  return out
}

export function loadExisting(dbDir: string): Existing[] {
  const list = new Map<number, Existing>()
  for (const file of ['seed.sql', 'add-bank.sql']) {
    const sql = readFileSync(join(dbDir, file), 'utf8')
    const problemRe = /INSERT INTO problems \(([^)]*)\) VALUES\s*\((.*?)\);\n/gs
    let m: RegExpExecArray | null
    while ((m = problemRe.exec(sql))) {
      const cols = m[1].split(',').map((c) => c.trim())
      const vals = splitValues(m[2])
      const row = Object.fromEntries(cols.map((c, i) => [c, vals[i]]))
      list.set(Number(row.id), {
        id: Number(row.id),
        pet_name: String(row.pet_name),
        topic: String(row.topic),
        error_message: String(row.error_message),
        code: String(row.code),
        bug_line: Number(row.bug_line),
        options: [],
      })
    }
    const optionRe = /INSERT INTO problem_options[^;]*?VALUES\s*(.*?);\n/gs
    while ((m = optionRe.exec(sql))) {
      for (const line of m[1].split(/\),\s*\n?\(/)) {
        const [problemId, text, correct] = splitValues(line)
        list.get(Number(problemId))?.options.push({ text: String(text), correct: !!correct })
      }
    }
  }
  return [...list.values()].sort((a, b) => a.id - b.id)
}
