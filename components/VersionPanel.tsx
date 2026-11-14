'use client'

import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import { buildPage, type ChimeraCode } from '@/lib/chimera'
import { formatSavedAt } from '@/lib/time'

type Version = { id: number; createdAt: string }

// 小預覽縮小一點，翅膀和尾巴才放得進框框
const PREVIEW_CSS = `
.chimera { transform: scale(0.6); }
body { overflow: hidden; }`

type VersionPanelProps = {
  // 存檔次數，存完一次就重新拿一次列表
  savedCount: number
  onRestore: (code: ChimeraCode, label: string) => void
}

// 版本紀錄：列出最近 20 次存檔，點一筆看預覽，可以還原到那個版本
export function VersionPanel({ savedCount, onRestore }: VersionPanelProps) {
  const [versions, setVersions] = useState<Version[] | null>(null)
  const [selected, setSelected] = useState<{ id: number; code: ChimeraCode } | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    api('/api/chimera/versions').then((res) => {
      if (res.error) setError(res.message)
      else setVersions(res.data)
    })
  }, [savedCount])

  async function pick(id: number) {
    setError('')
    const res = await api(`/api/chimera/versions/${id}`)
    if (res.error) {
      setError(res.message)
      return
    }
    setSelected({ id, code: res.data.code })
  }

  const selectedVersion = versions?.find((v) => v.id === selected?.id)

  return (
    <section className="versions">
      <p className="versions-title">版本紀錄（最近 20 次存檔）</p>
      {versions === null && !error && <p className="muted">讀取中…</p>}
      {versions?.length === 0 && <p className="muted">還沒有存檔紀錄，按存檔就會留下一個版本</p>}
      {error && <p className="error">{error}</p>}

      {!!versions?.length && (
        <div className="versions-body">
          <ul className="versions-list">
            {versions.map((v) => (
              <li key={v.id}>
                <button
                  className={`versions-item ${selected?.id === v.id ? 'active' : ''}`}
                  onClick={() => pick(v.id)}
                >
                  {formatSavedAt(v.createdAt)}
                </button>
              </li>
            ))}
          </ul>

          <div className="versions-preview">
            {selected && selectedVersion ? (
              <>
                <iframe
                  title={`${formatSavedAt(selectedVersion.createdAt)} 的版本預覽`}
                  sandbox="allow-scripts"
                  srcDoc={buildPage({
                    ...selected.code,
                    css: selected.code.css + PREVIEW_CSS,
                  })}
                />
                <button
                  className="btn"
                  onClick={() => onRestore(selected.code, formatSavedAt(selectedVersion.createdAt))}
                >
                  還原這個版本
                </button>
              </>
            ) : (
              <p className="muted">點左邊的時間，這裡會顯示那個版本的樣子</p>
            )}
          </div>
        </div>
      )}
    </section>
  )
}
