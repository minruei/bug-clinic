import { describe, expect, it } from 'vitest'
import { buildPage, starterChimera } from '@/lib/chimera'
import { PLAY_EXIT, playPage } from '@/lib/play'

describe('遊玩模式的預覽頁', () => {
  it('跟編輯器的預覽一樣會抓錯誤，最後多一段聽 Esc 的程式', () => {
    const page = playPage(starterChimera)
    const editor = buildPage(starterChimera, { catchErrors: true })
    expect(page.startsWith(editor.slice(0, editor.lastIndexOf('</body>')))).toBe(true)
    expect(page).toContain(`type: '${PLAY_EXIT}'`)
    expect(page).toContain("e.key === 'Escape'")
    expect(page).toContain('html, body { overflow: hidden; }')
    expect(page.trimEnd().endsWith('</body>\n</html>')).toBe(true)
  })

  it('玩家的 HTML 裡寫了 </body>，聽 Esc 的程式還是放在最後面', () => {
    const page = playPage({ ...starterChimera, html: '<p></body></p>' })
    expect(page.indexOf(PLAY_EXIT)).toBeGreaterThan(page.indexOf('<p></body></p>'))
  })
})
