'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { RecordList, type AttemptRecord } from '@/components/RecordList'

// 病歷本：每一次看診的完整紀錄，新的在最前面
export default function RecordsPage() {
  const [records, setRecords] = useState<AttemptRecord[]>([])
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)

  useEffect(() => {
    async function load() {
      const res = await api('/api/attempts')
      if (res.error) {
        setLoggedIn(false)
        return
      }
      setLoggedIn(true)
      setRecords(res.data ?? [])
    }
    load()
  }, [])

  const cured = records.filter((r) => r.is_correct).length

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        {loggedIn && (
          <span className="muted">
            看診 {records.length} 次，治好 {cured} 次
          </span>
        )}
      </header>

      <div>
        <p className="eyebrow">Records</p>
        <h1>病歷本</h1>
        <p className="muted">每一次看診的結果、花了幾秒、點錯幾次，都記在這裡</p>
      </div>

      {loggedIn === false && (
        <section className="card">
          <p>登入之後，這裡會出現你的看診紀錄</p>
          <Link href="/login" className="btn">
            去登入
          </Link>
        </section>
      )}

      {loggedIn && records.length === 0 && (
        <section className="card">
          <p>還沒有看診紀錄，先去小診療室看第一位吧。</p>
          <Link href="/clinic" className="btn">
            去看診
          </Link>
        </section>
      )}

      {records.length > 0 && (
        <section className="card">
          <RecordList records={records} />
        </section>
      )}
    </main>
  )
}
