import { describe, expect, it } from 'vitest'
import type { Pool } from 'mysql2/promise'
import { listProblems } from './problems'

// 假的資料庫：題目故意存成亂序，SQL 有 ORDER BY id 才照 id 排好，跟 MySQL 一樣
function fakeDb() {
  const problems = [
    { id: 12, pet_name: '小橘' },
    { id: 1, pet_name: '小橘' },
    { id: 101, pet_name: '小橘' },
    { id: 11, pet_name: '小橘' },
  ]
  const options = [
    { id: 1, problem_id: 1, option_text: 'a' },
    { id: 2, problem_id: 1, option_text: 'b' },
    { id: 3, problem_id: 101, option_text: 'c' },
  ]
  const sqls: string[] = []
  const query = async (sql: string) => {
    sqls.push(sql)
    if (sql.includes('FROM problems')) {
      const rows = /ORDER BY id\b/.test(sql) ? [...problems].sort((a, b) => a.id - b.id) : problems
      return [rows, []]
    }
    return [options, []]
  }
  return { db: { query } as unknown as Pick<Pool, 'query'>, sqls }
}

type Row = { id: number; options: { option_text: string }[] }

describe('listProblems', () => {
  it('題目照 id 由小到大回傳', async () => {
    const { db, sqls } = fakeDb()
    const list = (await listProblems(db)) as unknown as Row[]
    expect(list.map((p) => p.id)).toEqual([1, 11, 12, 101])
    expect(sqls[0]).toMatch(/ORDER BY id$/)
  })

  it('選項放在各自的題目底下', async () => {
    const { db } = fakeDb()
    const list = (await listProblems(db)) as unknown as Row[]
    expect(list[0].options.map((o) => o.option_text)).toEqual(['a', 'b'])
    expect(list[1].options).toEqual([])
    expect(list[3].options).toHaveLength(1)
  })
})
