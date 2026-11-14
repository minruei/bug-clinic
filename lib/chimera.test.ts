import { describe, expect, it } from 'vitest'
import {
  SHAPE_MARKER,
  hasChimeraWrapper,
  installPart,
  SPEECH_CSS,
  installedPartId,
  buildPage,
  partPreviewPage,
  practiceChimera,
  removePart,
  splitPartCss,
  starterChimera,
  toJsLine,
  withShapes,
  type ChimeraCode,
  type InstallablePart,
} from '@/lib/chimera'

const deerHorn: InstallablePart = {
  id: 7,
  slot: 'horn',
  name: '鹿角',
  code: { html: '<div class="horn-deer"></div>', css: '.horn-deer {}', js: '' },
}

const colorHorn: InstallablePart = {
  id: 9,
  slot: 'horn',
  name: '會變色的角',
  code: {
    html: '<div class="horn-color"></div>',
    css: '.horn-color {}',
    js: "const colorHorn = document.querySelector('.horn-color')",
  },
}

const wagTail: InstallablePart = {
  id: 6,
  slot: 'tail',
  name: '會擺動的尾巴',
  code: { html: '<div class="tail"></div>', css: '.tail {}', js: 'const tail = 1' },
}

const roundBody: InstallablePart = {
  id: 11,
  slot: 'body',
  name: '圓滾滾',
  code: { html: '', css: '.body {\n  border-radius: 50%;\n}', js: '' },
}

describe('installPart', () => {
  it('空的部位裝上零件，三格都多了帶標記的段落', () => {
    const code = installPart(starterChimera, colorHorn)

    expect(code.html).toContain('<!-- [horn:9] 會變色的角 開始 -->')
    expect(code.html).toContain('<!-- [horn:9] 結束 -->')
    expect(code.css).toContain(
      '/* [horn:9] 會變色的角 開始 */\n.horn-color {}\n/* [horn:9] 結束 */',
    )
    expect(code.js).toContain('// [horn:9] 會變色的角 開始')
    expect(code.js).toContain('// [horn:9] 結束')
  })

  it('HTML 插在 .body 裡面、「零件裝在這裡」前面，縮排跟那一行對齊', () => {
    const code = installPart(starterChimera, deerHorn)

    expect(code.html).toBe(
      [
        '<div class="chimera">',
        '  <div class="body">',
        '    <!-- [horn:7] 鹿角 開始 -->',
        '    <div class="horn-deer"></div>',
        '    <!-- [horn:7] 結束 -->',
        '    <!-- 零件裝在這裡 -->',
        '  </div>',
        '</div>',
      ].join('\n'),
    )
  })

  it('11/14 以前存的合成獸「零件裝在這裡」在 .body 外面：搬進 .body，CSS 補上 position: relative', () => {
    const oldStarter: ChimeraCode = {
      html: '<div class="chimera">\n  <div class="body"></div>\n  <!-- 零件裝在這裡 -->\n</div>',
      css: '.body {\n  width: 120px;\n}',
      js: '',
      shapes: '',
    }

    const code = installPart(oldStarter, deerHorn)

    expect(code.html).toBe(
      [
        '<div class="chimera">',
        '  <div class="body">',
        '    <!-- [horn:7] 鹿角 開始 -->',
        '    <div class="horn-deer"></div>',
        '    <!-- [horn:7] 結束 -->',
        '    <!-- 零件裝在這裡 -->',
        '  </div>',
        '</div>',
      ].join('\n'),
    )
    expect(code.css).toContain('.body {\n  position: relative;\n}')
  })

  it('舊結構裡已經裝在 .body 外面的同部位零件，換新的時候改裝到 .body 裡', () => {
    const oldWithHorn: ChimeraCode = {
      html: '<div class="chimera">\n  <div class="body"></div>\n  <!-- [horn:7] 鹿角 開始 -->\n  <div class="horn-deer"></div>\n  <!-- [horn:7] 結束 -->\n  <!-- 零件裝在這裡 -->\n</div>',
      css: '.body {\n  position: relative;\n}',
      js: '',
      shapes: '',
    }

    const code = installPart(oldWithHorn, colorHorn)

    expect(code.html.match(/horn-/g)).toHaveLength(1)
    expect(code.html).toContain('<div class="body">\n    <!-- [horn:9] 會變色的角 開始 -->')
    // 已經有 position: relative 就不重複加
    expect(code.css.match(/position: relative/g)).toHaveLength(1)
  })

  it('新結構不會被搬動', () => {
    expect(installPart(starterChimera, roundBody).html).toBe(starterChimera.html)
  })

  it('零件哪一格是空的，那一格就不加標記', () => {
    const code = installPart(starterChimera, roundBody)

    expect(code.html).toBe(starterChimera.html)
    expect(code.js).toBe(starterChimera.js)
    expect(code.css).toContain('[body:11]')
  })

  it('同部位換另一個零件：舊段落整段不見，新段落在原本的位置', () => {
    const before = installPart(installPart(starterChimera, deerHorn), wagTail)
    const after = installPart(before, colorHorn)

    for (const text of [after.html, after.css, after.js]) {
      expect(text).not.toContain('horn-deer')
      expect(text).not.toContain('[horn:7]')
    }
    // 鹿角原本在尾巴前面，換成會變色的角之後還是在尾巴前面
    expect(after.html.indexOf('horn-color')).toBeLessThan(after.html.indexOf('class="tail"'))
    expect(after.html.match(/\[horn:\d+\] [^\n]*開始/g)).toHaveLength(1)
  })

  it('同一個零件重複裝上，結果跟裝一次一樣', () => {
    const once = installPart(starterChimera, deerHorn)
    expect(installPart(once, deerHorn)).toEqual(once)
  })

  it('玩家在段落裡自己改過的程式碼，換零件時整段被換掉', () => {
    const installed = installPart(starterChimera, deerHorn)
    const edited: ChimeraCode = {
      ...installed,
      css: installed.css.replace('.horn-deer {}', '.horn-deer {\n  background: hotpink;\n}'),
    }

    const swapped = installPart(edited, colorHorn)

    expect(swapped.css).not.toContain('hotpink')
    expect(swapped.css).toContain('.horn-color {}')
  })

  it('沒有標記的舊零件程式碼不會被誤刪', () => {
    // 11/14 以前裝的小角沒有標記，直接寫在程式碼裡
    const oldSave: ChimeraCode = {
      html: starterChimera.html.replace(
        '<!-- 零件裝在這裡 -->',
        '<div class="horn"></div>\n    <!-- 零件裝在這裡 -->',
      ),
      css: `${starterChimera.css}\n\n.horn {\n  top: 10px;\n}`,
      js: starterChimera.js,
      shapes: starterChimera.shapes,
    }

    const code = installPart(oldSave, deerHorn)

    expect(code.html).toContain('<div class="horn"></div>')
    expect(code.css).toContain('.horn {\n  top: 10px;\n}')
    expect(removePart(code, 'horn')).toEqual(oldSave)
  })
})

describe('removePart', () => {
  it('不同部位可以同時存在，卸下一個不會影響另一個', () => {
    const both = installPart(installPart(starterChimera, colorHorn), wagTail)
    const code = removePart(both, 'horn')

    expect(installedPartId(code, 'horn')).toBeNull()
    expect(installedPartId(code, 'tail')).toBe(6)
    expect(code.html).toContain('class="tail"')
    expect(code.js).toContain('const tail = 1')
    expect(code.js).not.toContain('colorHorn')
  })

  it('只刪指定部位，全部卸下後跟預設一模一樣', () => {
    const all = installPart(installPart(installPart(starterChimera, deerHorn), wagTail), roundBody)

    expect(removePart(all, 'eyes')).toEqual(all)
    expect(removePart(removePart(removePart(all, 'tail'), 'horn'), 'body')).toEqual(starterChimera)
  })

  it('玩家自己加在段落外面的程式碼會留著', () => {
    const installed = installPart(starterChimera, deerHorn)
    const named = {
      ...installed,
      html: installed.html.replace('<!-- 零件裝在這裡 -->', '<p>小咪</p>\n  <!-- 零件裝在這裡 -->'),
    }

    expect(removePart(named, 'horn').html).toContain('<p>小咪</p>')
  })
})

describe('installedPartId', () => {
  it('裝了回零件 id，沒裝回 null', () => {
    const code = installPart(installPart(starterChimera, colorHorn), roundBody)

    expect(installedPartId(code, 'horn')).toBe(9)
    expect(installedPartId(code, 'body')).toBe(11)
    expect(installedPartId(code, 'tail')).toBeNull()
    expect(installedPartId(starterChimera, 'horn')).toBeNull()
  })
})

describe('預設合成獸', () => {
  it('新的合成獸點一下會跳：JS 有 click 和 animationend，CSS 有 .jump 動畫', () => {
    expect(starterChimera.js).toContain("body.classList.add('jump')")
    expect(starterChimera.js).toContain("addEventListener('animationend'")
    expect(starterChimera.css).toContain('.body.jump')
    expect(starterChimera.css).toContain('@keyframes jump')
  })

  it('練習用的合成獸跟正式版長一樣，只多了對話框，JS 喊跳的那一行留給玩家補', () => {
    expect(practiceChimera.html.replace('\n  <div class="speech">……</div>', '')).toBe(
      starterChimera.html,
    )
    // 對話框的樣子放在零件形狀，教程中不顯示那一格，CSS 烤漆跟正式版一模一樣
    expect(practiceChimera.css).toBe(starterChimera.css)
    expect(practiceChimera.shapes).toBe(`${starterChimera.shapes}\n\n${SPEECH_CSS}`)
    expect(practiceChimera.js).not.toContain("classList.add('jump')")
    expect(practiceChimera.js).toContain('在這裡加上一行')
  })
})

describe('商店預覽不顯示對話框', () => {
  // 從預覽頁的 <style> 裡拿出 CSS，看最後一條管 .speech 的規則是不是 display: none
  function lastSpeechRule(page: string) {
    const css = page.slice(page.indexOf('<style>'), page.indexOf('</style>'))
    const rules = [...css.matchAll(/\.speech\s*\{([^}]*)\}/g)].map((m) => m[1].trim())
    return rules.at(-1)
  }

  it('商店卡片和詳情框的預覽，最後一條 .speech 規則是 display: none', () => {
    const page = partPreviewPage(deerHorn, '\n.chimera { transform: scale(0.55); }')
    expect(lastSpeechRule(page)).toBe('display: none !important;')
  })

  it('只是在預覽頁加 CSS 蓋過去，零件的 HTML 都還在', () => {
    const page = partPreviewPage(deerHorn)
    expect(page).toContain('horn-deer')
  })

  it('編輯器和一般的預覽照常顯示對話框', () => {
    expect(lastSpeechRule(buildPage(practiceChimera))).not.toBe('display: none !important;')
    expect(lastSpeechRule(buildPage(practiceChimera, { catchErrors: true }))).not.toBe(
      'display: none !important;',
    )
  })
})

describe('對話框', () => {
  it('正式版的預設合成獸沒有對話框', () => {
    expect(starterChimera.html).not.toContain('speech')
    expect(starterChimera.css).not.toContain('speech')
  })

  it('教程怪物的對話框在 .chimera 裡、跟 .body 同一層，不在身體裡', () => {
    const speechAt = practiceChimera.html.indexOf('<div class="speech">')
    expect(speechAt).toBeGreaterThan(practiceChimera.html.indexOf('<div class="chimera">'))
    expect(speechAt).toBeLessThan(practiceChimera.html.indexOf('<div class="body">'))
  })

  it('對話框的高度跟著身體的 --speech-y，只管 .chimera 底下那一層', () => {
    expect(SPEECH_CSS).toContain('.chimera > .speech {')
    expect(SPEECH_CSS).toContain('bottom: calc(50% + var(--speech-y, 100px))')
  })

  it('舊存檔對話框在 .body 裡，裝零件也不會搬動它', () => {
    const old = {
      ...starterChimera,
      html: '<div class="chimera">\n  <div class="body">\n    <div class="speech">嗨</div>\n    <!-- 零件裝在這裡 -->\n  </div>\n</div>',
    }
    const next = installPart(old, deerHorn)
    expect(next.html).toContain('<div class="body">\n    <div class="speech">嗨</div>')
  })
})

describe('寫在 .chimera 上的零件', () => {
  const breathing: InstallablePart = {
    id: 8,
    slot: 'body',
    name: '會呼吸的身體',
    code: { html: '', css: '.chimera {\n  animation: body-breathe 2.4s infinite;\n}', js: '' },
  }

  it('有外框的合成獸照原樣裝上，HTML 不變', () => {
    const next = installPart(starterChimera, breathing)
    expect(next.html).toBe(starterChimera.html)
  })

  it('外框被刪掉的話，裝上時整段包一層 .chimera', () => {
    const noWrapper = {
      ...starterChimera,
      html: '<div class="body">\n  <div class="speech">嗨</div>\n</div>',
    }
    const next = installPart(noWrapper, breathing)
    expect(hasChimeraWrapper(noWrapper.html)).toBe(false)
    expect(next.html).toBe(
      '<div class="chimera">\n  <div class="body">\n    <div class="speech">嗨</div>\n  </div>\n</div>',
    )
  })

  it('不是寫在 .chimera 上的零件不會加外框', () => {
    const noWrapper = { ...starterChimera, html: '<div class="body"></div>' }
    expect(installPart(noWrapper, deerHorn).html).not.toContain('chimera')
  })

  it('class 裡有其他名字也認得出外框', () => {
    expect(hasChimeraWrapper('<div class="pet chimera big">')).toBe(true)
    expect(hasChimeraWrapper('<div class="chimera-like">')).toBe(false)
    expect(hasChimeraWrapper('<div class="body">')).toBe(false)
  })
})

describe('身體是透明的容器', () => {
  // 從 CSS 裡拿出某個選擇器的規則內容
  function rule(css: string, selector: string) {
    const start = css.indexOf(`${selector} {`)
    return start === -1 ? '' : css.slice(start, css.indexOf('}', start))
  }

  it('預設合成獸和教程怪物的 .body 不畫自己的底色和外框，這段放在零件形狀', () => {
    for (const code of [starterChimera, practiceChimera]) {
      const body = rule(code.shapes, '.body')
      expect(body).toContain('border: 4px solid transparent')
      expect(body).toContain('background-clip: text')
      expect(body).toContain('background: var(--fur-color)')
    }
  })

  it('CSS 烤漆只留毛色和尺寸，換毛色、教程第一步都照舊改這裡', () => {
    for (const code of [starterChimera, practiceChimera]) {
      const body = rule(code.css, '.body')
      expect(body).toContain('--fur-color: #b4b2a9')
      expect(body).toContain('width: 120px')
      expect(body).toContain('height: 100px')
      // 不寫 background：CSS 烤漆排在零件形狀後面，寫了會把 background-clip 和花紋一起蓋掉
      expect(body).not.toContain('background')
      expect(code.css).not.toContain('::before')
      expect(code.css).not.toContain('::after')
    }
  })

  it('看得到的身體畫在 ::before，立體感畫在 ::after，兩層都在零件後面', () => {
    const before = rule(starterChimera.shapes, '.body::before')
    const after = rule(starterChimera.shapes, '.body::after')
    expect(before).toContain('background: inherit')
    expect(before).toContain('border: 4px solid #4a3426')
    expect(before).toContain('z-index: -1')
    // 教程第三步、每日任務「圓滾滾」改的是 .body 的 border-radius，兩層都要跟著圓
    expect(before).toContain('border-radius: inherit')
    expect(after).toContain('border-radius: inherit')
    expect(after).toContain('z-index: -1')
  })
})

describe('像素模式', () => {
  const plain = buildPage(starterChimera, { catchErrors: true })
  const pixel = buildPage(starterChimera, { catchErrors: true, pixel: true })

  it('預設關閉，沒有濾鏡', () => {
    expect(plain).not.toContain('pixel-mode')
  })

  it('打開時 .body 加上濾鏡，寫在玩家的 CSS 前面，玩家自己寫的 filter 以玩家的為準', () => {
    const rule = pixel.indexOf('.body { filter: url(#pixel-mode); }')
    expect(rule).toBeGreaterThan(-1)
    expect(rule).toBeLessThan(pixel.indexOf(starterChimera.css))
    expect(pixel).toContain('<filter id="pixel-mode"')
  })

  it('濾鏡每 4px 取一個點，格子從 .body 的左上角算起', () => {
    expect(pixel).toContain('filterUnits="userSpaceOnUse"')
    expect(pixel).toContain('<feOffset x="0" y="0" width="4" height="4"/>')
  })

  it('玩家的三格程式碼原封不動，濾鏡放在玩家的 HTML 後面、JS 前面', () => {
    expect(pixel).toContain(starterChimera.css)
    expect(pixel).toContain(starterChimera.html)
    expect(pixel).toContain(starterChimera.js)
    expect(pixel.indexOf('<svg')).toBeGreaterThan(pixel.indexOf(starterChimera.html))
    expect(pixel.indexOf('<svg')).toBeLessThan(pixel.indexOf(starterChimera.js))
  })

  it('濾鏡只加在 .body，對話框在 .body 外面不會被打馬賽克', () => {
    const page = buildPage(practiceChimera, { pixel: true })
    expect(page).not.toMatch(/\.speech[^{]*\{[^}]*pixel-mode/)
    expect(page.match(/url\(#pixel-mode\)/g)).toHaveLength(1)
  })
})

describe('零件形狀', () => {
  const wing: InstallablePart = {
    id: 12,
    slot: 'wings',
    name: '翅膀',
    code: {
      html: '<div class="wing"></div>',
      css: `.wing {\n  --wing-color: green;\n}\n\n${SHAPE_MARKER}\n\n.wing {\n  clip-path: polygon(0 0, 4px 0);\n}`,
      js: '',
    },
  }

  it('零件的 CSS 用分隔線拆成兩段，沒有分隔線就整段算 CSS 烤漆', () => {
    expect(splitPartCss(wing.code.css)).toEqual({
      css: '.wing {\n  --wing-color: green;\n}',
      shapes: '.wing {\n  clip-path: polygon(0 0, 4px 0);\n}',
    })
    expect(splitPartCss('.horn {}')).toEqual({ css: '.horn {}', shapes: '' })
  })

  it('裝上時顏色放進 CSS 烤漆、形狀放進零件形狀，兩邊用同一個標記，分隔線不會出現在玩家的程式碼裡', () => {
    const code = installPart(starterChimera, wing)
    expect(code.css).toContain(
      '/* [wings:12] 翅膀 開始 */\n.wing {\n  --wing-color: green;\n}\n/* [wings:12] 結束 */',
    )
    expect(code.shapes).toContain(
      '/* [wings:12] 翅膀 開始 */\n.wing {\n  clip-path: polygon(0 0, 4px 0);\n}\n/* [wings:12] 結束 */',
    )
    expect(code.shapes.startsWith(starterChimera.shapes)).toBe(true)
    expect(`${code.css}${code.shapes}`).not.toContain(SHAPE_MARKER)
    expect(installedPartId(code, 'wings')).toBe(12)
  })

  it('換零件、卸下零件時兩邊一起動，卸下後跟原本一模一樣', () => {
    const code = installPart(starterChimera, wing)
    const other = {
      ...wing,
      id: 13,
      name: '天使翅膀',
      code: { ...wing.code, css: `.wing-angel {}\n${SHAPE_MARKER}\n.wing-angel { width: 4px; }` },
    }
    const swapped = installPart(code, other)
    expect(swapped.css).not.toContain('[wings:12]')
    expect(swapped.shapes).not.toContain('[wings:12]')
    expect(swapped.shapes).toContain('[wings:13]')
    expect(removePart(code, 'wings')).toEqual(starterChimera)
  })

  it('只寫在零件形狀的零件也認得出來裝了哪一個', () => {
    const pattern: InstallablePart = {
      id: 40,
      slot: 'pattern',
      name: '點點',
      code: { html: '', css: `${SHAPE_MARKER}\n.body { background-size: 16px; }`, js: '' },
    }
    const code = installPart(starterChimera, pattern)
    expect(code.css).toBe(starterChimera.css)
    expect(installedPartId(code, 'pattern')).toBe(40)
  })

  it('舊存檔沒有零件形狀：裝零件時形狀前面不多空行，原本的 CSS 不動', () => {
    const old = withShapes({ html: starterChimera.html, css: '.body { width: 120px; }', js: '' })
    expect(old.shapes).toBe('')
    const code = installPart(old, wing)
    expect(code.shapes.startsWith('/* [wings:12] 翅膀 開始 */')).toBe(true)
    expect(code.css.startsWith('.body { width: 120px; }')).toBe(true)
  })

  it('組預覽頁時零件形狀排在 CSS 烤漆前面，CSS 烤漆寫的會蓋過形狀', () => {
    const page = buildPage(starterChimera)
    expect(page.indexOf(starterChimera.shapes)).toBeGreaterThan(-1)
    expect(page.indexOf(starterChimera.shapes)).toBeLessThan(page.indexOf(starterChimera.css))
  })

  it('零件形狀變長，主控台的行號換算還是對的', () => {
    const code = {
      ...starterChimera,
      shapes: `${starterChimera.shapes}\n\n\n.a {}\n.b {}`,
      js: 'x\nboom()',
    }
    const page = buildPage(code, { catchErrors: true })
    const line = page.slice(0, page.indexOf('boom()')).split('\n').length
    expect(toJsLine(code, line, { catchErrors: true })).toBe(2)
  })

  it('舊存檔、舊版本沒有零件形狀，補成空字串；有的話原樣保留', () => {
    expect(withShapes({ html: 'h', css: 'c', js: 'j' })).toEqual({
      html: 'h',
      css: 'c',
      js: 'j',
      shapes: '',
    })
    expect(withShapes({ html: 'h', css: 'c', js: 'j', shapes: 's' }).shapes).toBe('s')
    expect(withShapes({ html: 'h', css: 'c', js: 'j', shapes: 3 }).shapes).toBe('')
  })
})
