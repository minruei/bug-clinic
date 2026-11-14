import { describe, expect, it } from 'vitest'
import { coinPackages, findPackage } from './payment'

describe('findPackage', () => {
  it('找得到的方案回傳正確的金額和金幣數', () => {
    expect(findPackage(1)).toMatchObject({ amount: 30, coins: 100 })
    expect(findPackage(2)).toMatchObject({ amount: 90, coins: 350 })
  })

  it('前端送字串的編號也找得到', () => {
    expect(findPackage('2')).toBe(coinPackages[1])
  })

  // 前端偷改 packageId 只會找不到，沒辦法用別的價格買金幣
  it('不存在的編號、undefined、亂打的文字都找不到', () => {
    expect(findPackage(99)).toBeUndefined()
    expect(findPackage(-1)).toBeUndefined()
    expect(findPackage(undefined)).toBeUndefined()
    expect(findPackage('abc')).toBeUndefined()
  })
})
