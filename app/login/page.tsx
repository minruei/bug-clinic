'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Pixel } from '@/components/Pixel'
import { api, saveToken } from '@/lib/api'

export default function LoginPage() {
  const router = useRouter()
  const [mode, setMode] = useState<'login' | 'register'>('login')
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    // 不要讓表單自己重新整理頁面
    e.preventDefault()
    setMessage('')

    // 註冊：先建立帳號，成功後接著登入
    if (mode === 'register') {
      const result = await api('/api/user', 'POST', { name, email, password })
      if (result.error) {
        setMessage(result.message)
        return
      }
    }

    // 登入：拿到 token 存起來，回首頁
    const result = await api('/api/user/auth', 'PUT', { email, password })
    if (result.error) {
      setMessage(result.message)
      return
    }
    saveToken(result.data.token)
    router.push('/')
  }

  return (
    <main className="wrap">
      <Link href="/" className="back">
        ← 回診所
      </Link>

      <form className="card form" onSubmit={handleSubmit}>
        <h1>
          <Pixel name="doctor" size={44} /> {mode === 'login' ? '獸醫上班囉' : '成為除蟲獸醫'}
        </h1>

        {mode === 'register' && (
          <label>
            怎麼稱呼你？
            <input value={name} onChange={(e) => setName(e.target.value)} required />
          </label>
        )}
        <label>
          電子郵件
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label>
          密碼
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </label>

        {message && <p className="error">{message}</p>}

        <button type="submit" className="btn">
          {mode === 'login' ? '打卡上班' : '報到並上班'}
        </button>

        <button
          type="button"
          className="switch"
          onClick={() => {
            setMode(mode === 'login' ? 'register' : 'login')
            setMessage('')
          }}
        >
          {mode === 'login' ? '還不是除蟲獸醫？來報到' : '已經是除蟲獸醫？打卡上班'}
        </button>
      </form>
    </main>
  )
}
