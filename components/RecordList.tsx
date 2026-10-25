import { Pixel, PetIcon } from '@/components/Pixel'
import { petLabel } from '@/lib/pets'

export type AttemptRecord = {
  id: number
  problem_id: number
  pet_name: string
  emoji: string
  topic: string
  is_correct: number
  mistakes: number
  seconds_used: number
  finished_at: string
}

// 看診紀錄列表：首頁顯示最近幾筆，住院部顯示全部
export function RecordList({ records }: { records: AttemptRecord[] }) {
  return (
    <>
      {records.map((a) => (
        <div key={a.id} className="record">
          <span className="pet-name">
            <PetIcon pet={a.pet_name} emoji={a.emoji} size={32} /> {petLabel(a.pet_name)}
          </span>
          <span className="tag">{a.topic}</span>
          <span className="grow">
            {a.is_correct ? (
              <>
                <Pixel name="check" size={18} /> 治好了
              </>
            ) : (
              <>
                <Pixel name="cross" size={18} /> 沒治好，再複習一次
              </>
            )}
            <br />
            <small className="muted">
              花了 {a.seconds_used} 秒，點錯 {a.mistakes} 次
            </small>
          </span>
          <span className="muted">
            {new Date(a.finished_at).toLocaleString('zh-TW', {
              month: '2-digit',
              day: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
              hour12: false,
            })}
          </span>
        </div>
      ))}
    </>
  )
}
