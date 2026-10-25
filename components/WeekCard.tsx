import { Pixel } from '@/components/Pixel'

type Done = { is_correct: number; finished_at: string }

const DAY_NAMES = ['一', '二', '三', '四', '五', '六', '日']

// 用當地時間把日期變成 2026-10-25 這種字串，方便比對是不是同一天
function dayKey(date: Date) {
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`
}

// 這週的練習：從看診紀錄算出哪幾天有練習、連續幾天，都是真資料
export function WeekCard({ attempts }: { attempts: Done[] }) {
  const practiced = new Set(attempts.map((a) => dayKey(new Date(a.finished_at))))

  // 這週一是哪一天（getDay() 星期日是 0，所以要換算成星期一開頭）
  const today = new Date()
  const monday = new Date(today)
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7))
  const week = DAY_NAMES.map((name, i) => {
    const day = new Date(monday)
    day.setDate(monday.getDate() + i)
    return {
      name,
      date: day.getDate(),
      done: practiced.has(dayKey(day)),
      isToday: dayKey(day) === dayKey(today),
      future: day > today,
    }
  })

  // 連續天數：從今天往回數；今天還沒練的話，從昨天開始算，不會一早就歸零
  let streak = 0
  const cursor = new Date(today)
  if (!practiced.has(dayKey(cursor))) cursor.setDate(cursor.getDate() - 1)
  while (practiced.has(dayKey(cursor))) {
    streak++
    cursor.setDate(cursor.getDate() - 1)
  }

  const thisWeek = attempts.filter(
    (a) => new Date(a.finished_at) >= new Date(monday.toDateString()),
  )
  const cured = thisWeek.filter((a) => a.is_correct).length

  return (
    <section className="card week-card">
      <div className="section-head">
        <p className="name">這週的練習</p>
        <p className="name">
          <Pixel name="flame" size={22} /> 連續 {streak} 天
        </p>
      </div>
      {/* 像撕頁日曆：上面紅色是星期，下面是日期，有練習的那天蓋上打勾章 */}
      <div className="calendar">
        {week.map((d) => (
          <div
            key={d.name}
            className={`cal-day ${d.done ? 'done' : ''} ${d.isToday ? 'today' : ''} ${d.future ? 'future' : ''}`}
          >
            <span className="cal-head">{d.name}</span>
            <span className="cal-date">{d.date}</span>
            {d.done && (
              <span className="cal-stamp">
                <Pixel name="check" size={28} />
              </span>
            )}
          </div>
        ))}
      </div>
      <p className="muted">
        這週看診 {thisWeek.length} 次，治好 {cured} 次
      </p>
    </section>
  )
}
