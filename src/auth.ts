import type { Request } from 'express'
import jwt from 'jsonwebtoken'

type TokenUser = { id: number; name: string; email: string }

// 從 Authorization header 取出 Bearer Token 並驗證
// 沒帶、過期或被竄改都回 null
export function getUser(req: Request): TokenUser | null {
  const header = req.headers.authorization
  if (!header?.startsWith('Bearer ')) return null

  const token = header.slice(7)
  try {
    return jwt.verify(token, process.env.JWT_SECRET as string) as TokenUser
  } catch {
    return null
  }
}