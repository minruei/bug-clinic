import { describe, expect, it } from 'vitest'
import { challenges } from '@/server/src/challenges'
import { starterChimera, type ChimeraCode } from '@/lib/chimera'
import { moves } from '@/lib/moves'
import { dailyCheckPage, dailyKeys, passesDaily } from '@/lib/daily'

const withCss = (css: string): ChimeraCode => ({
  ...starterChimera,
  css: `${starterChimera.css}\n${css}`,
})

describe('每日任務的前端檢查', () => {
  it('後端的每一題，前端都有對應的效果檢查', () => {
    expect([...dailyKeys].sort()).toEqual(challenges.map((c) => c.key).sort())
  })

  it('有 moveId 的題目，動作參考裡找得到那一招', () => {
    for (const c of challenges.filter((c) => c.moveId)) {
      expect(
        moves.some((m) => m.id === c.moveId),
        c.key,
      ).toBe(true)
    }
  })

  it('寫法和效果都過了才算完成', () => {
    const code = withCss('.body { box-shadow: 4px 4px 0 #4a3426; }')
    expect(passesDaily('body-shadow', code, { shadow: 'rgb(74, 52, 38) 4px 4px 0px 0px' })).toBe(
      true,
    )
  })

  it('預覽裡看起來有效果，但寫法後端不認，也不算過（不比後端寬鬆）', () => {
    // 寫在 .body:hover 後端不算 .body
    const code = withCss('.body:hover { box-shadow: 4px 4px 0 #4a3426; }')
    expect(passesDaily('body-shadow', code, { shadow: 'rgb(74, 52, 38) 4px 4px 0px 0px' })).toBe(
      false,
    )
  })

  it('寫法對了，但預覽裡量不到效果，也不算過', () => {
    const code = withCss('.body { box-shadow: 4px 4px 0 #4a3426; }')
    expect(passesDaily('body-shadow', code, { shadow: 'none' })).toBe(false)
  })

  it('紅眼睛：預覽裡眼睛的顏色要是紅色系', () => {
    const code = withCss('.eye { background: #e53935; }')
    expect(passesDaily('red-eyes', code, { eyeColors: ['rgb(229, 57, 53)'] })).toBe(true)
    expect(passesDaily('red-eyes', code, { eyeColors: [] })).toBe(false)
  })

  it('圓滾滾：四個角都要夠圓', () => {
    const code = withCss('.body { border-radius: 50%; }')
    expect(passesDaily('round-body', code, { radius: ['50%', '50%', '50%', '50%'] })).toBe(true)
    expect(passesDaily('round-body', code, { radius: ['50%', '50%', '10px', '50%'] })).toBe(false)
  })

  it('不認得的題目一律不過', () => {
    expect(passesDaily('no-such-task', starterChimera, {})).toBe(false)
  })

  it('檢查用的預覽頁：玩家的程式碼加上量測程式，量測程式在最後面', () => {
    const page = dailyCheckPage(starterChimera, 'two-horns')
    expect(page).toContain(starterChimera.js)
    expect(page).toContain('var key = "two-horns"')
    expect(page.indexOf("type: 'daily-check'")).toBeGreaterThan(page.indexOf(starterChimera.js))
    expect(page.trimEnd().endsWith('</body>\n</html>')).toBe(true)
  })
})
