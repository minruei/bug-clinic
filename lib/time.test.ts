import { describe, expect, it } from 'vitest'
import { formatSavedAt } from '@/lib/time'

// 測試固定用台灣時間，不管跑測試的電腦設在哪個時區，結果都一樣
const TW = 'Asia/Taipei'

describe('formatSavedAt', () => {
  it('顯示成「月/日 時:分:秒」', () => {
    // UTC 08:52 是台灣 16:52
    expect(formatSavedAt('2026-11-14T08:52:08.000Z', TW)).toBe('11/14 16:52:08')
  })

  it('同一分鐘內存的版本，秒數分得出來', () => {
    expect(formatSavedAt('2026-11-14T08:52:08.000Z', TW)).not.toBe(
      formatSavedAt('2026-11-14T08:52:41.000Z', TW),
    )
  })

  it('個位數補 0', () => {
    expect(formatSavedAt('2026-01-04T23:05:03.000Z', TW)).toBe('01/05 07:05:03')
  })

  it('午夜顯示 00 不是 24', () => {
    expect(formatSavedAt('2026-11-14T16:00:00.000Z', TW)).toBe('11/15 00:00:00')
  })

  it('也可以直接傳 Date', () => {
    expect(formatSavedAt(new Date('2026-11-14T08:52:08.000Z'), TW)).toBe('11/14 16:52:08')
  })

  it('換時區時間跟著換', () => {
    expect(formatSavedAt('2026-11-14T08:52:08.000Z', 'Asia/Tokyo')).toBe('11/14 17:52:08')
  })
})
