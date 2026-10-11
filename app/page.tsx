import Link from 'next/link'
import { player, daily, week, beasts, rooms, records } from '@/lib/clinic'
import { cases } from '@/lib/cases'

export default function Home() {
  const percent = Math.round((player.exp / player.nextExp) * 100)
  const today = cases[daily.caseIndex]
  const nextBeast = beasts.find((b) => b.days > player.streak)

  return (
    <main className="wrap">
      <header className="top">
        <div>
          <p className="eyebrow">Bug Clinic</p>
          <h1>除蟲動物診所</h1>
        </div>
        <div className="stats">
          <span>🪙 {player.coins}</span>
          <span>💉 已治癒 {player.cured}</span>
        </div>
      </header>

      <section className="card daily">
        <div className="pet">{today.emoji}</div>
        <div className="grow">
          <p className="muted">📅 今日病患 #{daily.no}</p>
          <p className="big">
            {today.pet} 身體不舒服，正在等你
            <span className="tag">{today.topic}</span>
          </p>
          <p className="muted">全世界的醫生今天都在救同一隻</p>
        </div>
        <Link href="/clinic" className="btn">
          開始看診
        </Link>
      </section>

      <section className="two">
        <div className="card">
          <p className="name">🔥 連續打卡 {player.streak} 天</p>
          <div className="week">
            {week.map((d) => (
              <div key={d.day} className={`dot ${d.done ? 'done' : ''}`}>
                <span>{d.done ? '✓' : ''}</span>
                <small>{d.day}</small>
              </div>
            ))}
          </div>
          <p className="muted">🎫 請假券 {player.leaveTickets} 張，斷一天也不會歸零</p>
        </div>

        <div className="card doctor">
          <div className="avatar">👨‍⚕️</div>
          <div className="grow">
            <p className="name">
              {player.name}
              <span className="tag">診所 Lv.{player.level}</span>
            </p>
            <div className="bar">
              <div className="fill exp" style={{ width: `${percent}%` }} />
            </div>
            <p className="muted">
              經驗值 {player.exp} / {player.nextExp}
            </p>
          </div>
        </div>
      </section>

      <h2>神獸來訪</h2>
      {nextBeast && (
        <p className="muted">
          再打卡 {nextBeast.days - player.streak} 天，{nextBeast.icon} {nextBeast.name}
          就會來診所求診
        </p>
      )}
      <section className="beasts">
        {beasts.map((b) => {
          const met = player.streak >= b.days
          return (
            <div key={b.name} className={`beast ${met ? '' : 'locked'}`}>
              <span className="icon">{met ? b.icon : '❔'}</span>
              <p className="name">{met ? b.name : '???'}</p>
              <p className="muted">{met ? b.desc : `連續 ${b.days} 天`}</p>
            </div>
          )
        })}
      </section>

      <h2>我的診所</h2>
      <section className="rooms">
        {rooms.map((room) => {
          const locked = room.unlock > player.level
          return (
            <div key={room.name} className={`room ${locked ? 'locked' : ''}`}>
              <span className="icon">{locked ? '🔒' : room.icon}</span>
              <p className="name">{room.name}</p>
              <p className="muted">{locked ? `Lv.${room.unlock} 解鎖` : room.desc}</p>
            </div>
          )
        })}
      </section>

      <h2>病歷本</h2>
      <section className="card">
        {records.map((r) => (
          <div key={r.pet} className="record">
            <span>{r.pet}</span>
            <span className="tag">{r.topic}</span>
            <span className="grow muted">{r.note}</span>
            <span className="muted">{r.date}</span>
          </div>
        ))}
      </section>

      <p className="footnote">Demo 版本，資料皆為假資料，插畫繪製中</p>
    </main>
  )
}
