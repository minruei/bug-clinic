import type { AddressInfo } from 'node:net'
import type { Server } from 'node:http'
import express from 'express'
import { afterAll, beforeAll, describe, expect, it } from 'vitest'
import { loginLimit, orderLimit } from './limits'

// 開一個只有登入、付款兩個路由的小 server，跟正式的一樣信任一層 proxy
let server: Server
let base = ''

beforeAll(async () => {
  const app = express()
  app.set('trust proxy', 1)
  // 網址帶 ?ok 當作密碼正確回 200，沒帶就是密碼錯誤回 400，跟正式的登入 API 一樣
  app.put('/login', loginLimit, (req, res) => {
    if ('ok' in req.query) res.json({ data: { ok: true } })
    else res.status(400).json({ error: true, message: '電子郵件或密碼錯誤' })
  })
  app.post('/orders', orderLimit, (req, res) => {
    res.json({ data: { ok: true } })
  })
  await new Promise<void>((resolve) => {
    server = app.listen(0, () => resolve())
  })
  base = `http://localhost:${(server.address() as AddressInfo).port}`
})

afterAll(() => {
  server.close()
})

// 用 X-Forwarded-For 假裝是不同的玩家，就像 Nginx 傳過來的
function hit(path: string, method: string, ip: string) {
  return fetch(base + path, { method, headers: { 'X-Forwarded-For': ip } })
}

describe('流量限制', () => {
  it('登入失敗第 11 次回 429，格式跟其他 API 一樣', async () => {
    for (let i = 0; i < 10; i++) {
      expect((await hit('/login', 'PUT', '1.1.1.1')).status).toBe(400)
    }
    const res = await hit('/login', 'PUT', '1.1.1.1')
    expect(res.status).toBe(429)
    expect(await res.json()).toEqual({ error: true, message: '嘗試太多次，請稍後再試' })
  })

  it('不同玩家的 IP 各算各的，一個被擋不會影響別人', async () => {
    expect((await hit('/login?ok', 'PUT', '2.2.2.2')).status).toBe(200)
  })

  it('登入成功不計入，成功很多次也不會被擋', async () => {
    for (let i = 0; i < 15; i++) {
      expect((await hit('/login?ok', 'PUT', '4.4.4.4')).status).toBe(200)
    }
    // 成功 15 次之後，失敗的額度還是完整的 10 次
    for (let i = 0; i < 10; i++) {
      expect((await hit('/login', 'PUT', '4.4.4.4')).status).toBe(400)
    }
    expect((await hit('/login', 'PUT', '4.4.4.4')).status).toBe(429)
  })

  it('付款第 6 次回 429', async () => {
    for (let i = 0; i < 5; i++) {
      expect((await hit('/orders', 'POST', '3.3.3.3')).status).toBe(200)
    }
    const res = await hit('/orders', 'POST', '3.3.3.3')
    expect(res.status).toBe(429)
    expect((await res.json()).error).toBe(true)
  })
})
