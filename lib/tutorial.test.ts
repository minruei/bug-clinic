import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { starterChimera, type ChimeraCode } from '@/lib/chimera'
import { JUMP_SAMPLE, bodyBlock, isColor, steps } from '@/lib/tutorial'

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

function doneList(code: ChimeraCode) {
  return steps.map((step) => step.done(code))
}

function editCss(from: string, to: string): ChimeraCode {
  return { ...starterChimera, css: starterChimera.css.replace(from, to) }
}

describe('新手教程', () => {
  it('預設合成獸四步都還沒完成', () => {
    expect(doneList(starterChimera)).toEqual([false, false, false, false])
  })

  describe('第一步：換毛色', () => {
    it('改成合法的顏色算完成', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#e8a33d'))).toBe(true)
      expect(steps[0].done(editCss('#b4b2a9', 'pink'))).toBe(true)
    })

    it('只打 # 或亂打不算', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#'))).toBe(false)
      expect(steps[0].done(editCss('#b4b2a9', 'abcde'))).toBe(false)
    })

    it('改成跟原本一樣的顏色不算，大小寫不同也一樣', () => {
      expect(steps[0].done(editCss('#b4b2a9', '#B4B2A9'))).toBe(false)
    })

    it('沒有 CSS.supports 的環境一律不算', () => {
      vi.unstubAllGlobals()
      expect(isColor('#e8a33d')).toBe(false)
    })
  })

  describe('第二步：改大小', () => {
    it('改 width 或 height 算完成', () => {
      expect(steps[1].done(editCss('width: 120px', 'width: 160px'))).toBe(true)
      expect(steps[1].done(editCss('height: 100px', 'height: 80px'))).toBe(true)
    })

    it('改 .body 以外的地方不算', () => {
      expect(steps[1].done(editCss('height: 100vh', 'height: 90vh'))).toBe(false)
    })

    it('bodyBlock 找得到 .body 大括號裡的文字', () => {
      expect(bodyBlock(starterChimera.css)).toContain('width: 120px')
      expect(bodyBlock('.chimera { color: red; }')).toBe('')
    })
  })

  describe('第三步：取名字', () => {
    function addLine(line: string): ChimeraCode {
      return {
        ...starterChimera,
        html: starterChimera.html.replace(
          '<!-- 零件裝在這裡 -->',
          `${line}\n  <!-- 零件裝在這裡 -->`,
        ),
      }
    }

    it('加 <p>名字</p> 算完成', () => {
      expect(steps[2].done(addLine('<p>小咪</p>'))).toBe(true)
    })

    it('空的 <p></p> 或只有空白不算', () => {
      expect(steps[2].done(addLine('<p></p>'))).toBe(false)
      expect(steps[2].done(addLine('<p>   </p>'))).toBe(false)
    })
  })

  describe('第四步：讓牠跳', () => {
    const withSample = { ...starterChimera, js: starterChimera.js + JUMP_SAMPLE }

    it('只放範例不改數字不算', () => {
      expect(steps[3].done(withSample)).toBe(false)
    })

    it('把 30 改成別的數字才算', () => {
      const changed = { ...withSample, js: withSample.js.replace('-30px', '-60px') }
      expect(steps[3].done(changed)).toBe(true)
    })

    it('沒有 addEventListener 的話，只寫 translateY 不算', () => {
      const code = { ...starterChimera, js: "body.style.transform = 'translateY(-60px)'" }
      expect(steps[3].done(code)).toBe(false)
    })
  })
})
