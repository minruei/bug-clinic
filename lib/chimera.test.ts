import { describe, expect, it } from 'vitest'
import {
  installPart,
  installedPartId,
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
