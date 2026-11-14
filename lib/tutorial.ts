// 新手教程的步驟和判斷，畫面在 components/Tutorial.tsx
import type { ChimeraCode, EditorTab } from '@/lib/chimera'

// 第四步要放進 JS 格的範例：點一下身體，牠會往上跳再落下
// 玩家要自己把 -30px 改成別的數字，才算完成
// 零件和名字都在 .body 裡面，讓 body 跳就會整隻一起跳
export const JUMP_SAMPLE = `
// 點一下身體，牠會跳起來
const body = document.querySelector('.body')
body.addEventListener('click', () => {
  body.animate(
    [
      { transform: 'translateY(0)' },
      { transform: 'translateY(-30px)' },
      { transform: 'translateY(0)' },
    ],
    { duration: 400 },
  )
})
`

// 用瀏覽器自己的規則判斷是不是合法的顏色，像只打了 # 或打錯字都不算
// CSS.supports 只有瀏覽器有，在伺服器上跑的時候一律當成不是
export function isColor(value: string) {
  return typeof CSS !== 'undefined' && CSS.supports('color', value)
}

// 找出 .body { ... } 大括號裡面的文字，找不到回空字串
export function bodyBlock(css: string) {
  return css.match(/\.body\s*\{([^}]*)\}/)?.[1] ?? ''
}

export type Step = {
  title: string
  tab: EditorTab
  hint: string
  // 看玩家現在的程式碼，判斷這一步做完了沒
  done: (code: ChimeraCode) => boolean
}

// 教程的四個步驟：CSS 換顏色 → CSS 改大小 → HTML 加名字 → JS 讓牠跳
// 每一步都是「改一個地方，右邊馬上看到變化」
export const steps: Step[] = [
  {
    title: '幫牠換毛色',
    tab: 'css',
    hint: '在 CSS 烤漆找到 --fur-color: #b4b2a9，把色碼改掉。也可以點色碼旁邊的小色塊直接選顏色',
    // 要改成別的顏色，而且是瀏覽器看得懂的顏色才算
    done: (code) =>
      [...code.css.matchAll(/--fur-color:\s*([^;]+);/g)].some((m) => {
        const value = m[1].trim()
        return value.toLowerCase() !== '#b4b2a9' && isColor(value)
      }),
  },
  {
    title: '讓牠長大一點',
    tab: 'css',
    hint: '在 .body 裡面，把 width: 120px 或 height: 100px 改成別的數字',
    done: (code) => {
      const block = bodyBlock(code.css)
      const width = block.match(/(?:^|[\s;])width:\s*(\d+)px/)?.[1]
      const height = block.match(/(?:^|[\s;])height:\s*(\d+)px/)?.[1]
      return (!!width && width !== '120') || (!!height && height !== '100')
    },
  },
  {
    title: '幫牠取名字',
    tab: 'html',
    hint: '在 HTML 骨架的「零件裝在這裡」上面加一行 <p>小咪</p>，名字會寫在牠的身體上，名字自己取',
    done: (code) => /<p[^>]*>\s*[^<\s][^<]*<\/p>/.test(code.html),
  },
  {
    title: '點一下讓牠跳',
    tab: 'js',
    hint: '先按「放入範例」，再把 translateY(-30px) 的 30 改成別的數字，改完點右邊的身體試試看',
    done: (code) =>
      code.js.includes('addEventListener') &&
      [...code.js.matchAll(/translateY\(-(\d+)px\)/g)].some((m) => m[1] !== '30'),
  },
]
