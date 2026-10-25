'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { api } from '@/lib/api'
import { beasts, unlockedBeasts, type DexAttempt } from '@/lib/dex'
import { Pixel, PetIcon, Rarity } from '@/components/Pixel'
import { pets, petLabel, onePerPet } from '@/lib/pets'

type Problem = {
  id: number
  pet_name: string
  emoji: string
  topic: string
}

// 圖鑑：治好的動物會點亮，達成里程碑會收集到神獸
export default function DexPage() {
  const [problems, setProblems] = useState<Problem[]>([])
  const [attempts, setAttempts] = useState<DexAttempt[]>([])
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)

  useEffect(() => {
    async function load() {
      const list = await api('/api/problems')
      setProblems(list.data ?? [])
      const auth = await api('/api/user/auth')
      setLoggedIn(!!auth.data)
      if (auth.data) {
        const records = await api('/api/attempts')
        setAttempts(records.data ?? [])
      }
    }
    load()
  }, [])

  const curedPets = new Set(attempts.filter((a) => a.is_correct).map((a) => a.pet_name))
  const animals = onePerPet(problems)
  const unlocked = unlockedBeasts(attempts, animals.length)
  // 每隻動物治好了幾題不同的題目
  const curedIds = new Set(attempts.filter((a) => a.is_correct).map((a) => a.problem_id))
  const curedOf = (pet: string) =>
    problems.filter((p) => p.pet_name === pet && curedIds.has(p.id)).length
  const totalOf = (pet: string) => problems.filter((p) => p.pet_name === pet).length

  return (
    <main className="wrap">
      <header className="top">
        <Link href="/" className="back">
          ← 回診所
        </Link>
        <span className="muted">
          收集 {curedPets.size + unlocked.size} / {animals.length + beasts.length}
        </span>
      </header>

      <h1>圖鑑</h1>
      {loggedIn === false && (
        <p className="muted">
          <Link href="/login">登入</Link>之後，治好的動物和收集到的神獸會出現在這裡
        </p>
      )}

      <div className="section-head">
        <h2>動物圖鑑</h2>
        <span className="muted">
          {curedPets.size} / {animals.length}
        </span>
      </div>
      <section className="dex-grid">
        {animals.map((p) => {
          const met = curedPets.has(p.pet_name)
          return (
            <Link
              key={p.pet_name}
              href={`/clinic?id=${p.id}`}
              className={`beast room-link ${met ? '' : 'locked'}`}
            >
              <PetIcon pet={p.pet_name} emoji={p.emoji} size={56} locked={!met} />
              <p className="name">{met ? petLabel(p.pet_name) : '???'}</p>
              <p className="tag">{p.topic}</p>
              <p className="muted">{met ? pets[p.pet_name]?.hint : '治好牠就能收集'}</p>
              <p className="muted">
                治好 {curedOf(p.pet_name)} / {totalOf(p.pet_name)} 題
              </p>
            </Link>
          )
        })}
      </section>

      <div className="section-head">
        <h2>神獸圖鑑</h2>
        <span className="muted">
          {unlocked.size} / {beasts.length}
        </span>
      </div>
      <section className="dex-grid">
        {beasts.map((b) => {
          const met = unlocked.has(b.key)
          return (
            <div key={b.key} className={`beast ${met ? '' : 'locked'}`}>
              <Pixel name={b.key} size={56} alt={met ? b.name : ''} locked={!met} />
              <p className="name">{met ? b.name : '???'}</p>
              <p className="tag">
                <Rarity rank={b.rank} tier={b.tier} />
              </p>
              <p className="muted">{met ? b.story : `解鎖條件：${b.goal}`}</p>
            </div>
          )
        })}
      </section>
    </main>
  )
}
