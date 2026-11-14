import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import {
  JUMP_CSS,
  JUMP_LINE,
  JUMP_PLACEHOLDER,
  SPEECH_PLACEHOLDER,
  practiceChimera,
  type ChimeraCode,
} from '@/lib/chimera'
import { isColor, steps, type Progress } from '@/lib/tutorial'

// 測試跑在 Node 裡沒有 CSS.supports，換成一個簡單版：只認色碼和幾個顏色名稱
beforeEach(() => {
  vi.stubGlobal('CSS', {
    supports: (_property: string, value: string) =>
      /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(value) || ['red', 'pink'].includes(value),
  })
})

afterEach(() => {
  vi.unstubAllGlobals()
})

// 預覽裡還沒跳過、已經跳過
const notJumped: Progress = { jumped: false, speech: SPEECH_PLACEHOLDER, shape: '0px' }
const jumped: Progress = { jumped: true, speech: SPEECH_PLACEHOLDER, shape: '0px' }

function doneList(code: ChimeraCode, progress = notJumped) {
  return steps.map((step) => step.done(code, progress))
}

function editCss(from: string, to: string): ChimeraCode {
  return { ...practiceChimera, css: practiceChimera.css.replace(from, to) }
}

describe('新手教程', () => {
  it('練習用合成獸四步都還沒完成', () => {
    expect(doneList(practiceChimera)).toEqual([false, false, false, false])
  })

  describe('第一步：換毛色', () => {
    it('改成合法的顏色算完成', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#e8a33d'), notJumped)).toBe(true)
      expect(steps[0].done(editCss('#b4b2a9', 'pink'), notJumped)).toBe(true)
    })

    it('只打 # 或亂打不算', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#'), notJumped)).toBe(false)
      expect(steps[0].done(editCss('#b4b2a9', 'abcde'), notJumped)).toBe(false)
    })

    it('改成跟原本一樣的顏色不算，大小寫不同也一樣', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#B4B2A9'), notJumped)).toBe(false)
    })

    it('沒有 CSS.supports 的環境一律不算', () => {
      vi.unstubAllGlobals()
      expect(isColor('#e8a33d')).toBe(false)
    })
  })

  describe('第三步：改變形狀', () => {
    const shaped = (shape: string | null) => steps[2].done(practiceChimera, { ...notJumped, shape })

    it('預覽裡 .body 算出來的圓角跟一開始的 0px 不一樣才算', () => {
      expect(shaped('20px')).toBe(true)
      expect(shaped('50%')).toBe(true)
      expect(shaped('50% 50% 10% 10%')).toBe(true)
    })

    it('還是 0px、還沒收到預覽的回報，都不算', () => {
      expect(shaped('0px')).toBe(false)
      expect(shaped(null)).toBe(false)
    })

    it('做完時合成獸會說話', () => {
      expect(steps[2].doneVoice).toBe('哇！我變成新的樣子了！')
    })
  })

  describe('第二步：幫牠說話', () => {
    const said = (speech: string | null) => steps[1].done(practiceChimera, { ...notJumped, speech })

    it('預覽裡對話框的字換成自己的話才算', () => {
      expect(said('你好！')).toBe(true)
    })

    it('還是「……」、空的、只有空白、還沒收到預覽的回報，都不算', () => {
      expect(said(SPEECH_PLACEHOLDER)).toBe(false)
      expect(said('')).toBe(false)
      expect(said('   ')).toBe(false)
      expect(said(null)).toBe(false)
    })

    it('練習用合成獸的 HTML 有對話框，裡面是「……」', () => {
      expect(practiceChimera.html).toContain(`<div class="speech">${SPEECH_PLACEHOLDER}</div>`)
    })
  })

  describe('第四步：喊一聲讓牠跳', () => {
    it('練習用合成獸的 CSS 已經編好舞步，JS 留了一行空格給玩家補', () => {
      expect(practiceChimera.css).toContain(JUMP_CSS)
      expect(practiceChimera.js).toContain(JUMP_PLACEHOLDER)
      expect(practiceChimera.js).not.toContain(JUMP_LINE)
      // 動畫播完拿掉 class 的部分已經寫好了
      expect(practiceChimera.js).toContain("classList.remove('jump')")
    })

    it('只寫對程式碼、還沒點合成獸讓牠跳，不算', () => {
      const code = {
        ...practiceChimera,
        js: practiceChimera.js.replace(JUMP_PLACEHOLDER, JUMP_LINE),
      }
      expect(steps[3].done(code, notJumped)).toBe(false)
    })

    it('預覽裡真的跳起來了才算', () => {
      expect(steps[3].done(practiceChimera, jumped)).toBe(true)
    })

    it('前三步不看有沒有跳過', () => {
      expect(doneList(practiceChimera, jumped)).toEqual([false, false, false, true])
    })
  })
})
