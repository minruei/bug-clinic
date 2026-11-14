// 遊玩模式的預覽頁：跟編輯器的預覽一樣（會抓錯誤），最後面多一段聽 Esc 的程式，畫面也不捲動
// 玩的時候焦點在預覽裡，外面的頁面收不到鍵盤事件，所以由預覽裡面用 postMessage 告訴外面「按了 Esc」
import { buildPage, type ChimeraCode } from '@/lib/chimera'

export const PLAY_EXIT = 'chimera-play-exit'

// 遊玩的畫面不捲動：不然合成獸走到邊邊撐出捲軸，按方向鍵會變成在捲畫面
const EXIT_SCRIPT = `<style>html, body { overflow: hidden; }</style>
<script>
document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') parent.postMessage({ type: '${PLAY_EXIT}' }, '*')
})
</script>`

// 插在最後一個 </body> 前面，玩家的 HTML 裡就算寫了 </body> 也不會插錯地方
export function playPage(code: ChimeraCode) {
  const page = buildPage(code, { catchErrors: true })
  const at = page.lastIndexOf('</body>')
  return `${page.slice(0, at)}${EXIT_SCRIPT}\n${page.slice(at)}`
}
