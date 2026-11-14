import { describe, expect, it } from 'vitest'
import {
  hasChimeraWrapper,
  installPart,
  installedPartId,
  buildPage,
  partPreviewPage,
  practiceChimera,
  removePart,
  starterChimera,
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
        '  <div class="speech">……</div>',
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

  it('11/14 以前存的合成獸「零件裝在這裡」在 .body 外面，就照原本的位置插，不改結構', () => {
    const oldStarter: ChimeraCode = {
      ...starterChimera,
      html: '<div class="chimera">\n  <div class="body"></div>\n  <!-- 零件裝在這裡 -->\n</div>',
    }

    const code = installPart(oldStarter, deerHorn)

    expect(code.html).toContain('<div class="body"></div>')
    expect(code.html).toContain('\n  <div class="horn-deer"></div>\n  <!-- [horn:7] 結束 -->\n')
    expect(removePart(code, 'horn').html).toBe(oldStarter.html)
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

  it('練習用的合成獸跟正式版長一樣，只差 JS 喊跳的那一行留給玩家補', () => {
    expect(practiceChimera.html).toBe(starterChimera.html)
    expect(practiceChimera.css).toBe(starterChimera.css)
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
    expect(lastSpeechRule(page)).toBe('display: none;')
  })

  it('只是在預覽頁加 CSS 蓋過去，對話框和零件的 HTML 都還在', () => {
    const page = partPreviewPage(deerHorn)
    expect(page).toContain('<div class="speech">')
    expect(page).toContain('horn-deer')
  })

  it('編輯器和一般的預覽照常顯示對話框', () => {
    expect(lastSpeechRule(buildPage(starterChimera))).not.toBe('display: none;')
    expect(lastSpeechRule(buildPage(starterChimera, { catchErrors: true }))).not.toBe(
      'display: none;',
    )
  })
})

describe('對話框', () => {
  it('預設合成獸和練習用合成獸的對話框在 .chimera 裡、跟 .body 同一層，不在身體裡', () => {
    for (const code of [starterChimera, practiceChimera]) {
      const speechAt = code.html.indexOf('<div class="speech">')
      const bodyAt = code.html.indexOf('<div class="body">')
      expect(speechAt).toBeGreaterThan(code.html.indexOf('<div class="chimera">'))
      expect(speechAt).toBeLessThan(bodyAt)
    }
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
