// 新手教程的步驟和判斷，畫面在 components/Tutorial.tsx
import { SPEECH_PLACEHOLDER, type ChimeraCode, type EditorTab } from '@/lib/chimera'

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
  // 說明欄用怪物的口吻開頭
  voice: string
  // 要在哪一格做什麼
  todo: string
  // 為什麼是這一格：HTML 決定有什麼，CSS 決定長什麼樣子和怎麼動，JS 決定什麼時候動
  why: string
  // 卡住的時候看這句
  stuck: string
  // 看玩家現在的程式碼和預覽裡發生的事，判斷這一步做完了沒
  done: (code: ChimeraCode, progress: Progress) => boolean
}

// 預覽裡發生的事，只看程式碼判斷不出來的
export type Progress = {
  // 玩家點了預覽裡的合成獸，而且 jump 動畫真的播了
  jumped: boolean
  // 預覽裡對話框實際顯示的文字，還沒收到回報是 null
  speech: string | null
}

// 全部做完時怪物說的話
export const FINISH_VOICE = '我現在是完整的合成獸了！去零件商店幫我打扮吧！'

// 教程的四個步驟：CSS 換顏色 → HTML 說話 → CSS 長大 → JS 喊跳，三格都會用到
// 每一步都是「改一個地方，右邊馬上看到變化」
export const steps: Step[] = [
  {
    title: '幫牠換毛色',
    tab: 'css',
    voice: '我全身灰灰的好無聊，可以幫我換個顏色嗎？',
    todo: '在 CSS 烤漆找到 --fur-color: #b4b2a9，把色碼改掉。也可以點色碼旁邊的小色塊直接選顏色。',
    why: '顏色是「長什麼樣子」，樣子歸 CSS 管。',
    stuck: '色碼是 # 加上 6 個 0～9 或 a～f，例如 #e8a33d；打錯的話毛色不會變。',
    // 要改成別的顏色，而且是瀏覽器看得懂的顏色才算
    done: (code) =>
      [...code.css.matchAll(/--fur-color:\s*([^;]+);/g)].some((m) => {
        const value = m[1].trim()
        return value.toLowerCase() !== '#b4b2a9' && isColor(value)
      }),
  },
  {
    title: '幫牠說話',
    tab: 'html',
    voice: '我想跟你說話，可是不知道要說什麼……幫我在 HTML 寫一句話吧！',
    todo: `在 HTML 骨架找到 <div class="speech">${SPEECH_PLACEHOLDER}</div>，把中間的「${SPEECH_PLACEHOLDER}」換成你想讓牠說的話。`,
    why: '頁面上有什麼東西、寫了什麼字，歸 HTML 管；對話框的白底和小尾巴已經用 CSS 畫好了。',
    stuck: '只改兩個標籤中間的字，<div class="speech"> 和 </div> 不要刪到，不然對話框會不見。',
    // 看預覽裡對話框實際顯示的字，不是「……」也不是空的才算
    done: (_code, progress) => {
      const text = progress.speech?.trim()
      return !!text && text !== SPEECH_PLACEHOLDER
    },
  },
  {
    title: '讓牠長大一點',
    tab: 'css',
    voice: '我覺得自己有點小隻，可以讓我長大一點嗎？',
    todo: '在 CSS 烤漆的 .body 裡，把 width: 120px 或 height: 100px 改成別的數字。',
    why: '大小也是「長什麼樣子」，所以還是 CSS。',
    stuck: '數字後面的 px 要留著，例如 160px。',
    done: (code) => {
      const block = bodyBlock(code.css)
      const width = block.match(/(?:^|[\s;])width:\s*(\d+)px/)?.[1]
      const height = block.match(/(?:^|[\s;])height:\s*(\d+)px/)?.[1]
      return (!!width && width !== '120') || (!!height && height !== '100')
    },
  },
  {
    title: '喊一聲讓牠跳',
    tab: 'js',
    voice: '我已經學會怎麼跳了，可是要有人喊『跳』我才會跳！',
    todo: "在 JS 引擎「在這裡加上一行」的地方寫 body.classList.add('jump');，再點右邊的我。",
    why: 'CSS 已經編好舞步了（.jump 和 @keyframes jump），什麼時候跳要靠 JS 決定。',
    stuck: '點了沒反應的話，看下面主控台的紅字，會告訴你第幾行哪裡打錯。',
    // 不比對字串：要玩家真的點了合成獸、而且真的跳起來才算
    done: (_code, progress) => progress.jumped,
  },
]
