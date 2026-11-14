import 'dotenv/config'
import type { ResultSetHeader } from 'mysql2'
import { afterAll, describe, expect, it } from 'vitest'
import { pool } from './db'
import {
  KEEP_VERSIONS,
  MAX_CODE_BYTES,
  chimeraCodeJson,
  getVersion,
  listVersions,
  saveChimera,
} from './versions'

// 這組測試要連資料庫：本機有 .env 才跑，CI 沒有資料庫就跳過
// import db 只會建立連線池，真的查詢才會連線，所以 CI 跳過時不會出錯
// 本機要先跑過 server/db/add-versions.sql
const hasDb = !!process.env.DB_HOST

// 存檔前的檢查不用連資料庫，CI 也會跑
describe('存檔的程式碼格式', () => {
  it('四格都是字串就包成 JSON，零件形狀一起存', () => {
    const result = chimeraCodeJson({ html: '<p></p>', css: 'p {}', js: '', shapes: '.a {}' })
    expect(result).toEqual({
      code: JSON.stringify({ html: '<p></p>', css: 'p {}', js: '', shapes: '.a {}' }),
    })
  })

  it('舊版前端沒送零件形狀，存成空字串', () => {
    const result = chimeraCodeJson({ html: '', css: '', js: '' })
    expect(result).toEqual({ code: JSON.stringify({ html: '', css: '', js: '', shapes: '' }) })
  })

  it('格式不對就不存：少一格、不是字串、零件形狀不是字串', () => {
    expect(chimeraCodeJson(undefined)).toEqual({ error: '程式碼格式不對' })
    expect(chimeraCodeJson({ html: '', css: '' })).toEqual({ error: '程式碼格式不對' })
    expect(chimeraCodeJson({ html: '', css: 1, js: '' })).toEqual({ error: '程式碼格式不對' })
    expect(chimeraCodeJson({ html: '', css: '', js: '', shapes: null })).toEqual({
      error: '程式碼格式不對',
    })
  })

  it('長度用位元組算：英文剛好在上限內可以存，中文字一個算 3 個', () => {
    const room = MAX_CODE_BYTES - JSON.stringify({ html: '', css: '', js: '', shapes: '' }).length
    expect('code' in chimeraCodeJson({ html: '', css: 'a'.repeat(room), js: '' })).toBe(true)
    expect('error' in chimeraCodeJson({ html: '', css: 'a'.repeat(room + 1), js: '' })).toBe(true)
    // 中文字的字數只有上限的三分之一多一點，換成位元組就超過了
    const chinese = '字'.repeat(Math.ceil(room / 3) + 1)
    expect('error' in chimeraCodeJson({ html: '', css: chinese, js: '' })).toBe(true)
  })
})

describe.skipIf(!hasDb)('版本紀錄（連本機資料庫）', () => {
  const userIds: number[] = []

  // 開兩個測試用的玩家，測完整個刪掉，版本會跟著 ON DELETE CASCADE 一起刪
  async function makeUser() {
    const [result] = await pool.query<ResultSetHeader>(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      ['版本測試', `versions-${Date.now()}-${Math.random()}@test.local`, 'x'],
    )
    userIds.push(result.insertId)
    return result.insertId
  }

  const codeOf = (n: number) => JSON.stringify({ html: '', css: `/* 第 ${n} 次 */`, js: '' })

  afterAll(async () => {
    if (userIds.length) await pool.query('DELETE FROM users WHERE id IN (?)', [userIds])
    await pool.end()
  })

  it('存檔 22 次只留最新 20 筆，新的在前', async () => {
    const userId = await makeUser()
    for (let i = 1; i <= 22; i++) {
      expect(await saveChimera(userId, codeOf(i))).toBe(true)
    }

    const list = await listVersions(userId)
    expect(list).toHaveLength(KEEP_VERSIONS)

    const newest = await getVersion(userId, list[0].id)
    const oldest = await getVersion(userId, list[list.length - 1].id)
    expect(newest?.code.css).toBe('/* 第 22 次 */')
    expect(oldest?.code.css).toBe('/* 第 3 次 */')
  })

  it('跟最新一筆一模一樣就不新增版本', async () => {
    const userId = await makeUser()
    expect(await saveChimera(userId, codeOf(1))).toBe(true)
    expect(await saveChimera(userId, codeOf(1))).toBe(false)
    expect(await listVersions(userId)).toHaveLength(1)

    // 改回之前存過、但不是最新的內容，還是要新增
    expect(await saveChimera(userId, codeOf(2))).toBe(true)
    expect(await saveChimera(userId, codeOf(1))).toBe(true)
    expect(await listVersions(userId)).toHaveLength(3)
  })

  it('拿不到別人的版本', async () => {
    const owner = await makeUser()
    const other = await makeUser()
    await saveChimera(owner, codeOf(1))
    const [mine] = await listVersions(owner)

    expect(await getVersion(owner, mine.id)).not.toBeNull()
    expect(await getVersion(other, mine.id)).toBeNull()
  })
})
