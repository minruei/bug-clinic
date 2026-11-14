import { describe, expect, it } from 'vitest'
import { MIN_COINS, MISTAKE_PENALTY, TIME_LIMIT, coinsFor, remainingLife } from './game'

describe('remainingLife', () => {
  it('沒花時間也沒點錯，生命值是滿的', () => {
    expect(remainingLife(0, 0)).toBe(TIME_LIMIT)
  })

  it('每過一秒扣 1，每點錯一次扣 MISTAKE_PENALTY', () => {
    expect(remainingLife(10, 0)).toBe(TIME_LIMIT - 10)
    expect(remainingLife(10, 2)).toBe(TIME_LIMIT - 10 - 2 * MISTAKE_PENALTY)
  })

  it('超時或點錯太多會變成負的', () => {
    expect(remainingLife(TIME_LIMIT + 5, 0)).toBeLessThan(0)
  })
})

describe('coinsFor', () => {
  it('金幣是剩餘生命值的一半，無條件捨去', () => {
    expect(coinsFor(60)).toBe(30)
    expect(coinsFor(41)).toBe(20)
  })

  it('生命值很低時至少拿到 MIN_COINS', () => {
    expect(coinsFor(1)).toBe(MIN_COINS)
    expect(coinsFor(0)).toBe(MIN_COINS)
    expect(coinsFor(-20)).toBe(MIN_COINS)
  })
})
