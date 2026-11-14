"""合成獸零件資料：9 個部位 × 9 種造型

執行後輸出 server/db/seed-parts-v2.sql：
  python3 scripts/parts/parts.py

加上 --preview 會另外輸出一張預覽頁，用瀏覽器打開就能一次看全部零件：
  python3 scripts/parts/parts.py --preview /tmp/parts-preview.html

加上 --check 會輸出檢查頁：8 種身體 × 每一個零件全部排出來，看零件有沒有貼好身體：
  python3 scripts/parts/parts.py --check /tmp/parts-check.html

座標規則：
- 零件裝在 .body 裡，用 position: absolute 跟著身體定位
- 上下位置讀身體定義的變數，百分比是身體高度的幾成，沒定義就用預設身體（120×100）的位置：
  --horn-y 0%（上緣）、--eye-y 30%、--mouth-y 60%、--neck-y 80%、--wing-y 10%、--tail-y 60%、--leg-y 100%（下緣）
  矮的或下面比較窄的身體（圓滾滾、蛋形、麵包、扁扁胖胖）會把 --neck-y 往上調
- 翅膀、尾巴、背包、雨傘、氣球接在身體左右邊緣（0 或 100%），身體變寬變窄會跟著走
- 圓形的身體左右邊會往內縮，用 --wing-x 讓翅膀往內靠
- 眼睛、嘴巴、角左右照中線 calc(50% ± Npx) 擺
- 寬度跟身體有關的零件用百分比：項鍊、領結、勳章、墨鏡、圍巾、披風、章魚觸手、輪軸，腳和鬍鬚的左右位置也是
- 預設合成獸沒有對話框，動作參考第 11、14 招會用 JS 生一個放在 .chimera 裡
  身體變高變矮時在 .chimera 定義 --speech-y（中心到對話框底部多遠），那個對話框會跟著調整
- 線條 #4a3426、奶油色 #f3ead8
"""

import html as html_lib
import json
import sys
from pathlib import Path
from textwrap import dedent

ROOT = Path(__file__).resolve().parents[2]
SQL_PATH = ROOT / 'server' / 'db' / 'seed-parts-v2.sql'

# 商店分頁的順序
SLOTS = [
    ('body', '身體'),
    ('horn', '角'),
    ('eyes', '眼睛'),
    ('mouth', '嘴巴'),
    ('pattern', '花紋'),
    ('wings', '翅膀'),
    ('tail', '尾巴'),
    ('feet', '腳'),
    ('accessory', '配件'),
]


def code(text):
    """把多行字串的共同縮排拿掉，頭尾空行也去掉"""
    return dedent(text).strip('\n')


def part(slot, name, category, price, html='', css='', js=''):
    return {
        'slot': slot,
        'name': name,
        'category': category,
        'price': price,
        'html': code(html),
        'css': code(css),
        'js': code(js),
    }


PARTS = []

# 身體：只改形狀，不設 background
PARTS += [
    part('body', '圓滾滾', 'css', 20, css='''
        /* 圓的上下比較窄：角往下、腳往上，翅膀往內靠，才不會跟身體分開 */
        .body {
          --horn-y: 7%;
          --leg-y: 93%;
          --neck-y: 72%;
          --wing-x: 5px;
          border-radius: 50%;
        }
    '''),
    part('body', '蛋形', 'css', 20, css='''
        /* 上窄下寬：上面的垂直半徑比較大 */
        .body {
          --horn-y: 9%;
          --leg-y: 93%;
          --neck-y: 76%;
          --wing-x: 9px;
          width: 110px;
          height: 120px;
          border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
        }

        /* 身體比較高，對話框跟著往上移：身體高度的一半 + 50px */
        .chimera {
          --speech-y: 110px;
        }
    '''),
    part('body', '麵包', 'css', 20, css='''
        /* 上面圓、下面平 */
        .body {
          --horn-y: 8%;
          --neck-y: 74%;
          --wing-x: 8px;
          border-radius: 60px 60px 8px 8px;
        }
    '''),
    part('body', '高高瘦瘦', 'css', 25, css='''
        .body {
          width: 90px;
          height: 126px;
          border-radius: 16px;
        }

        /* 身體比較高，對話框跟著往上移：身體高度的一半 + 50px */
        .chimera {
          --speech-y: 113px;
        }
    '''),
    part('body', '扁扁胖胖', 'css', 25, css='''
        /* 身體比較矮：眼睛、嘴巴、脖子往上挪一點，領結才不會掉到身體外面 */
        .body {
          --eye-y: 25%;
          --mouth-y: 48%;
          --neck-y: 70%;
          --wing-x: 4px;
          width: 150px;
          height: 80px;
          border-radius: 40px;
        }

        /* 身體比較矮，對話框跟著往下移：身體高度的一半 + 50px */
        .chimera {
          --speech-y: 90px;
        }
    '''),
    part('body', '布丁', 'css', 30, css='''
        /* 上面那層焦糖用 inset 陰影畫，改 22px 調焦糖厚度 */
        /* 眼睛往下一點，才不會壓到焦糖 */
        .body {
          --eye-y: 34%;
          border-radius: 30px 30px 10px 10px;
          box-shadow: inset 0 22px 0 #8a4f1d;
        }
    '''),
    part('body', '雲朵', 'css', 40, css='''
        /* 頭上兩顆圓凸起，下緣不畫框、壓在身體的上框上，看起來就跟身體連在一起 */
        /* 角往上移到凸起上面，對話框也抬高到凸起上面 */
        .body {
          --horn-y: -56%;
          --wing-x: 4px;
          border-radius: 50px;
        }

        .chimera {
          --speech-y: 122px;
        }

        .body::before,
        .body::after {
          content: '';
          position: absolute;
          background: var(--fur-color);
          border: 4px solid #4a3426;
          border-bottom-color: transparent;
          border-radius: 50%;
        }

        .body::before {
          top: -54px;
          left: 16px;
          width: 50px;
          height: 50px;
        }

        .body::after {
          top: -64px;
          right: 14px;
          width: 60px;
          height: 60px;
        }
    '''),
    part('body', '會呼吸的身體', 'css', 40, css='''
        /* 待機的時候一直慢慢呼吸，不用 JS 觸發 */
        /* 放在外層的 .chimera：點一下跳是放在 .body，兩個動畫在不同元素上，不會互相蓋掉 */
        /* 用 scale 不用 transform，商店小預覽縮小 .chimera 用的是 transform，兩個會疊在一起 */
        /* 改 2.4s 調呼吸快慢，改 1.06 調放大多少 */
        .chimera {
          animation: body-breathe 2.4s ease-in-out infinite;
        }

        @keyframes body-breathe {
          50% {
            scale: 1.06;
          }
        }
    '''),
    part('body', '會變形的身體', 'js', 60, css='''
        .body {
          cursor: pointer;
          transition: border-radius 0.3s;
        }

        /* 每個形狀一個 class，想加形狀就多寫一個 .shape-4，JS 那邊的 4 也要改成 5 */
        /* 每個形狀也調整角、腳、翅膀的位置，零件才會貼著身體 */
        .body.shape-1 {
          --horn-y: 7%;
          --leg-y: 93%;
          --wing-x: 5px;
          border-radius: 50%;
        }

        .body.shape-2 {
          --horn-y: 8%;
          --wing-x: 8px;
          border-radius: 60px 60px 8px 8px;
        }

        .body.shape-3 {
          --horn-y: 8%;
          --leg-y: 94%;
          --wing-x: 8px;
          border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
        }
    ''', js='''
        // 點身體輪流換形狀：形狀寫在 CSS 的 .shape-1 ~ .shape-3，JS 只負責換 class
        const morphBody = document.querySelector('.body')
        let morphIndex = 0
        morphBody.addEventListener('click', () => {
          morphBody.classList.remove(`shape-${morphIndex}`)
          morphIndex = (morphIndex + 1) % 4
          if (morphIndex) morphBody.classList.add(`shape-${morphIndex}`)
        })
    '''),
]

# 角：底部對到 --horn-y（預設 0%，身體上緣）
# z-index: 1 讓角畫在身體偽元素（例如雲朵頭上的凸起）上面，不會被蓋住
PARTS += [
    part('horn', '小角', 'html', 10, html='''
        <div class="horn"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn {
          --horn-color: #fbf8f1;
          top: calc(var(--horn-y, 0%) - 16px);
          left: calc(50% - 14px);
        }

        /* 角分三層，由下往上寬 5 格、3 格、1 格，疊起來就是一階一階的尖角 */
        /* 一格是 4px，外框也是一格；上面兩層沒有下框，往下蓋住下一層的上框，三層才會連在一起 */
        .horn {
          position: absolute;
          z-index: 1;
          width: 20px;
          height: 8px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 20%);
        }

        /* 中間那層 */
        .horn::before {
          content: '';
          position: absolute;
          top: -12px;
          left: 0;
          width: 12px;
          height: 12px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 20%);
        }

        /* 最上面的尖端 */
        .horn::after {
          content: '';
          position: absolute;
          top: -20px;
          left: 4px;
          width: 4px;
          height: 8px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }
    '''),
    part('horn', '雙角', 'html', 15, html='''
        <div class="horn-twin left"></div>
        <div class="horn-twin right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-twin {
          --horn-color: #fbf8f1;
          top: calc(var(--horn-y, 0%) - 16px);
        }

        .horn-twin.left {
          left: calc(50% - 40px);
        }

        .horn-twin.right {
          left: calc(50% + 20px);
        }

        /* 每支角兩層：下層 3 × 2 格，上層 1 格寬的尖端 */
        .horn-twin {
          position: absolute;
          z-index: 1;
          width: 12px;
          height: 8px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 20%);
        }

        /* 尖端：沒有下框，往下蓋住下層的上框，兩層才會連在一起 */
        .horn-twin::before {
          content: '';
          position: absolute;
          top: -12px;
          left: 0;
          width: 4px;
          height: 8px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }
    '''),
    part('horn', '獨角獸角', 'css', 20, html='''
        <div class="horn-unicorn"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-unicorn {
          --horn-color: #fbf8f1;
          --stripe-color: #e8a0a0;
          top: calc(var(--horn-y, 0%) - 20px);
          left: calc(50% - 10px);
        }

        /* 下層 3 × 3 格，上面接一根 1 格寬、4 格高的尖端 */
        /* 條紋是一格白、一格粉紅一直重複，邊緣是直的，跟像素圖一樣 */
        .horn-unicorn,
        .horn-unicorn::before {
          background: repeating-linear-gradient(
            var(--horn-color) 0 4px,
            var(--stripe-color) 4px 8px
          );
          border: 4px solid #4a3426;
        }

        .horn-unicorn {
          position: absolute;
          z-index: 1;
          width: 12px;
          height: 12px;
        }

        /* 尖端：沒有下框，往下蓋住下層的上框 */
        .horn-unicorn::before {
          content: '';
          position: absolute;
          top: -20px;
          left: 0;
          width: 4px;
          height: 16px;
          border-bottom: 0;
        }
    '''),
    part('horn', '鹿角', 'html', 25, html='''
        <div class="horn-deer left">
          <span class="horn-deer-branch"></span>
        </div>
        <div class="horn-deer right">
          <span class="horn-deer-branch"></span>
        </div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-deer {
          --antler-color: #9a6440;
          top: calc(var(--horn-y, 0%) - 36px);
        }

        .horn-deer.left {
          left: calc(50% - 32px);
        }

        .horn-deer.right {
          left: calc(50% + 24px);
        }

        /* 一根 2 格寬的主幹，旁邊伸出一根分岔，分岔尾端再往上長一段，全部都是方塊 */
        /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著整支鹿角的形狀走 */
        .horn-deer {
          position: absolute;
          z-index: 1;
          width: 8px;
          height: 36px;
          background: var(--antler-color);
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .horn-deer-branch {
          position: absolute;
          top: 12px;
          width: 12px;
          height: 8px;
          background: var(--antler-color);
        }

        /* 分岔往外長：左邊的往左、右邊的往右 */
        .horn-deer.left .horn-deer-branch {
          left: -12px;
        }

        .horn-deer.right .horn-deer-branch {
          left: 8px;
        }

        .horn-deer-branch::after {
          content: '';
          position: absolute;
          top: -12px;
          width: 8px;
          height: 12px;
          background: var(--antler-color);
        }

        .horn-deer.left .horn-deer-branch::after {
          left: 0;
        }

        .horn-deer.right .horn-deer-branch::after {
          right: 0;
        }
    '''),
    part('horn', '牛角', 'css', 20, html='''
        <div class="horn-ox left"></div>
        <div class="horn-ox right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-ox {
          --horn-color: #fbf8f1;
          top: calc(var(--horn-y, 0%) - 16px);
        }

        .horn-ox.left {
          left: calc(50% - 72px);
        }

        .horn-ox.right {
          left: calc(50% + 40px);
        }

        /* 一條往外長的橫條，末端往上翹兩格，看起來就是彎彎的牛角 */
        .horn-ox {
          position: absolute;
          z-index: 1;
          width: 24px;
          height: 8px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 -4px 0 rgb(46 34 26 / 20%);
        }

        /* 往上翹的那段：沒有下框，往下蓋住橫條的上框，兩塊才會連在一起 */
        .horn-ox::before {
          content: '';
          position: absolute;
          top: -16px;
          width: 8px;
          height: 12px;
          background: var(--horn-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }

        .horn-ox.left::before {
          left: -4px;
        }

        .horn-ox.right::before {
          right: -4px;
        }
    '''),
    part('horn', '天線', 'html', 15, html='''
        <div class="horn-antenna"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-antenna {
          --ball-color: #e8a33d;
          top: calc(var(--horn-y, 0%) - 28px);
          left: calc(50% - 2px);
        }

        /* 一根 1 格寬的細桿，頂端一顆 3 × 3 格的方球 */
        .horn-antenna {
          position: absolute;
          z-index: 1;
          width: 4px;
          height: 28px;
          background: #4a3426;
        }

        .horn-antenna::after {
          content: '';
          position: absolute;
          top: -16px;
          left: -8px;
          width: 12px;
          height: 12px;
          background: var(--ball-color);
          border: 4px solid #4a3426;
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 45%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
        }
    '''),
    part('horn', '貓耳', 'html', 20, html='''
        <div class="horn-cat left"></div>
        <div class="horn-cat right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-cat {
          --ear-color: #9a6440;
          --ear-inner: #e8a0a0;
          top: calc(var(--horn-y, 0%) - 16px);
        }

        .horn-cat.left {
          left: calc(50% - 50px);
        }

        .horn-cat.right {
          left: calc(50% + 22px);
        }

        /* 耳朵三層，由下往上寬 5 格、3 格、1 格；中間那層是粉紅色的耳朵內側 */
        .horn-cat {
          position: absolute;
          z-index: 1;
          width: 20px;
          height: 8px;
          background: var(--ear-color);
          border: 4px solid #4a3426;
        }

        /* 上面兩層沒有下框，往下蓋住下一層的上框，三層才會連在一起 */
        .horn-cat::before {
          content: '';
          position: absolute;
          top: -12px;
          left: 0;
          width: 12px;
          height: 12px;
          background: var(--ear-inner);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }

        .horn-cat::after {
          content: '';
          position: absolute;
          top: -20px;
          left: 4px;
          width: 4px;
          height: 8px;
          background: var(--ear-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }
    '''),
    part('horn', '兔耳', 'html', 20, html='''
        <div class="horn-bunny left"></div>
        <div class="horn-bunny right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .horn-bunny {
          --ear-color: #fbf8f1;
          --ear-inner: #e8a0a0;
          top: calc(var(--horn-y, 0%) - 48px);
        }

        .horn-bunny.left {
          left: calc(50% - 34px);
        }

        .horn-bunny.right {
          left: calc(50% + 14px);
        }

        /* 一隻耳朵 3 格寬、10 格高，頂端多一格收尖 */
        .horn-bunny {
          position: absolute;
          z-index: 1;
          width: 12px;
          height: 40px;
          background: var(--ear-color);
          border: 4px solid #4a3426;
        }

        /* 頂端：沒有下框，往下蓋住耳朵的上框 */
        .horn-bunny::before {
          content: '';
          position: absolute;
          top: -12px;
          left: 0;
          width: 4px;
          height: 8px;
          background: var(--ear-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }

        /* 中間一條粉紅色的耳朵內側，1 格寬 */
        .horn-bunny::after {
          content: '';
          position: absolute;
          top: 4px;
          left: 4px;
          width: 4px;
          height: 32px;
          background: var(--ear-inner);
        }
    '''),
    part('horn', '會變色的角', 'js', 50, html='''
        <div class="horn-color"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好；點角的時候 JS 會改 --horn-color */
        .horn-color {
          --horn-color: #fbf8f1;
          top: calc(var(--horn-y, 0%) - 16px);
          left: calc(50% - 14px);
        }

        /* 角分三層，由下往上寬 5 格、3 格、1 格；三層都用 --horn-color，換色時一起變 */
        .horn-color,
        .horn-color::before,
        .horn-color::after {
          background: var(--horn-color);
          border: 4px solid #4a3426;
          transition: background-color 0.3s;
        }

        .horn-color {
          position: absolute;
          z-index: 1;
          width: 20px;
          height: 8px;
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 20%);
          cursor: pointer;
        }

        /* 上面兩層沒有下框，往下蓋住下一層的上框，三層才會連在一起 */
        .horn-color::before {
          content: '';
          position: absolute;
          top: -12px;
          left: 0;
          width: 12px;
          height: 12px;
          border-bottom: 0;
        }

        .horn-color::after {
          content: '';
          position: absolute;
          top: -20px;
          left: 4px;
          width: 4px;
          height: 8px;
          border-bottom: 0;
        }
    ''', js='''
        // 點角換一個隨機顏色
        const colorHorn = document.querySelector('.horn-color')
        colorHorn.addEventListener('click', (event) => {
          // 角長在身體裡，不擋住的話也會觸發身體的點擊
          event.stopPropagation()
          const hue = Math.floor(Math.random() * 360)
          colorHorn.style.setProperty('--horn-color', `hsl(${hue}, 70%, 65%)`)
        })
    '''),
]

# 眼睛：上緣大約在 --eye-y（預設 30%），左右眼各離中線 25px 左右
PARTS += [
    part('eyes', '眼睛', 'html', 15, html='''
        <div class="eye left"></div>
        <div class="eye right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye {
          --eye-color: #2e221a;
          top: var(--eye-y, 30%);
        }

        .eye.left {
          left: calc(50% - 32px);
        }

        .eye.right {
          left: calc(50% + 20px);
        }

        /* 一隻眼睛 3 × 3 格 */
        .eye {
          position: absolute;
          width: 12px;
          height: 12px;
          background: var(--eye-color);
        }

        /* 右上角一格白色反光，眼睛看起來亮亮的 */
        .eye::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '圓圓大眼', 'html', 15, html='''
        <div class="eye-round left"><span class="eye-round-pupil"></span></div>
        <div class="eye-round right"><span class="eye-round-pupil"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-round {
          --eye-white: #fbf8f1;
          --pupil-color: #2e221a;
          top: calc(var(--eye-y, 30%) - 4px);
        }

        .eye-round.left {
          left: calc(50% - 32px);
        }

        .eye-round.right {
          left: calc(50% + 16px);
        }

        /* 白色的眼睛 4 × 4 格 */
        .eye-round {
          position: absolute;
          width: 16px;
          height: 16px;
          background: var(--eye-white);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角會空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 眼珠 2 × 2 格，右上角一格白色反光 */
        .eye-round-pupil {
          position: absolute;
          top: 4px;
          left: 4px;
          width: 8px;
          height: 8px;
          background: var(--pupil-color);
        }

        .eye-round-pupil::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '瞇瞇眼', 'css', 15, html='''
        <div class="eye-squint left"></div>
        <div class="eye-squint right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-squint {
          --eye-color: #2e221a;
          top: calc(var(--eye-y, 30%) + 2px);
        }

        .eye-squint.left {
          left: calc(50% - 26px);
        }

        .eye-squint.right {
          left: calc(50% + 18px);
        }

        /* 瞇起來的眼睛是 4 格排成一個彎彎的倒 V：上面兩格、下面左右各一格 */
        /* 元素本身是上排左邊那一格，另外 3 格用 box-shadow 複製出來 */
        .eye-squint {
          position: absolute;
          width: 4px;
          height: 4px;
          background: var(--eye-color);
          box-shadow:
            4px 0 0 var(--eye-color),
            -4px 4px 0 var(--eye-color),
            8px 4px 0 var(--eye-color);
        }
    '''),
    part('eyes', '獨眼', 'html', 20, html='''
        <div class="eye-cyclops"><span class="eye-cyclops-pupil"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-cyclops {
          --eye-white: #fbf8f1;
          --pupil-color: #2e221a;
          top: calc(var(--eye-y, 30%) - 10px);
          left: calc(50% - 12px);
        }

        /* 一隻大眼睛 6 × 6 格 */
        .eye-cyclops {
          position: absolute;
          width: 24px;
          height: 24px;
          background: var(--eye-white);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角會空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 眼珠 3 × 3 格，右上角一格白色反光 */
        .eye-cyclops-pupil {
          position: absolute;
          top: 6px;
          left: 6px;
          width: 12px;
          height: 12px;
          background: var(--pupil-color);
        }

        .eye-cyclops-pupil::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '星星眼', 'html', 20, html='''
        <div class="eye-star left"></div>
        <div class="eye-star right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-star {
          --star-color: #f2d16b;
          top: calc(var(--eye-y, 30%) - 2px);
        }

        .eye-star.left {
          left: calc(50% - 30px);
        }

        .eye-star.right {
          left: calc(50% + 22px);
        }

        /* 星星是 5 塊排成十字：元素本身是中間那塊，上下左右 4 塊用 box-shadow 複製出來 */
        /* 每一塊 2 × 2 格（8px），所以 box-shadow 往旁邊移 8px */
        .eye-star {
          position: absolute;
          width: 8px;
          height: 8px;
          background: var(--star-color);
          box-shadow:
            0 -8px 0 var(--star-color),
            0 8px 0 var(--star-color),
            -8px 0 0 var(--star-color),
            8px 0 0 var(--star-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        /* 中間一格白色反光 */
        .eye-star::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '愛心眼', 'html', 20, html='''
        <div class="eye-heart left"></div>
        <div class="eye-heart right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-heart {
          --heart-color: #c8553d;
          top: calc(var(--eye-y, 30%) - 6px);
        }

        .eye-heart.left {
          left: calc(50% - 38px);
        }

        .eye-heart.right {
          left: calc(50% + 14px);
        }

        /* 愛心是 6 塊：上排左右各一塊、中間一排三塊、最下面一塊尖尖的 */
        /* 元素本身是左上那一塊，另外 5 塊用 box-shadow 複製出來；每一塊 2 × 2 格（8px） */
        .eye-heart {
          position: absolute;
          width: 8px;
          height: 8px;
          background: var(--heart-color);
          box-shadow:
            16px 0 0 var(--heart-color),
            0 8px 0 var(--heart-color),
            8px 8px 0 var(--heart-color),
            16px 8px 0 var(--heart-color),
            8px 16px 0 var(--heart-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        /* 左上那塊放一格白色反光 */
        .eye-heart::after {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '墨鏡', 'html', 25, html='''
        <div class="eye-shades">
          <span class="eye-shades-lens left"></span>
          <span class="eye-shades-lens right"></span>
        </div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-shades {
          --lens-color: #2e221a;
          top: calc(var(--eye-y, 30%) - 6px);
        }

        /* 寬度是身體的 67%，鏡片和鼻樑也用百分比，跟著身體變寬變窄 */
        .eye-shades {
          position: absolute;
          left: 16.5%;
          width: 67%;
          height: 20px;
        }

        /* 鼻樑 */
        .eye-shades::before {
          content: '';
          position: absolute;
          top: 4px;
          left: 32%;
          width: 36%;
          height: 4px;
          background: var(--lens-color);
        }

        /* 鏡片 3 格高，下面再接一排左右各縮一格的，鏡片底部就一階一階收窄 */
        .eye-shades-lens {
          position: absolute;
          top: 0;
          width: 38%;
          height: 12px;
          background: var(--lens-color);
        }

        .eye-shades-lens.left {
          left: 0;
        }

        .eye-shades-lens.right {
          right: 0;
        }

        .eye-shades-lens::before {
          content: '';
          position: absolute;
          top: 12px;
          left: 4px;
          right: 4px;
          height: 4px;
          background: var(--lens-color);
        }

        /* 鏡片上一格白色反光 */
        .eye-shades-lens::after {
          content: '';
          position: absolute;
          top: 4px;
          left: 4px;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('eyes', '會眨眼', 'css', 30, html='''
        <div class="eye-blink left"></div>
        <div class="eye-blink right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-blink {
          --eye-color: #2e221a;
          top: var(--eye-y, 30%);
        }

        .eye-blink.left {
          left: calc(50% - 32px);
        }

        .eye-blink.right {
          left: calc(50% + 20px);
        }

        /* 一隻眼睛 3 × 3 格，大部分時間睜開，96% 那一下壓扁就是眨眼 */
        .eye-blink {
          position: absolute;
          width: 12px;
          height: 12px;
          background: var(--eye-color);
          animation: eye-blink 3s infinite;
        }

        /* 右上角一格白色反光 */
        .eye-blink::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }

        @keyframes eye-blink {
          0%,
          92%,
          100% {
            transform: scaleY(1);
          }
          96% {
            transform: scaleY(0.1);
          }
        }
    '''),
    part('eyes', '跟著滑鼠的眼睛', 'js', 70, html='''
        <div class="eye-follow left"><span class="eye-follow-pupil"></span></div>
        <div class="eye-follow right"><span class="eye-follow-pupil"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .eye-follow {
          --eye-white: #fbf8f1;
          --pupil-color: #2e221a;
          top: calc(var(--eye-y, 30%) - 4px);
        }

        .eye-follow.left {
          left: calc(50% - 32px);
        }

        .eye-follow.right {
          left: calc(50% + 16px);
        }

        /* 白色的眼睛 4 × 4 格 */
        .eye-follow {
          position: absolute;
          width: 16px;
          height: 16px;
          background: var(--eye-white);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角會空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 眼珠 2 × 2 格，放在正中間；JS 會讓它往滑鼠的方向移一格 */
        .eye-follow-pupil {
          position: absolute;
          top: 4px;
          left: 4px;
          width: 8px;
          height: 8px;
          background: var(--pupil-color);
        }

        .eye-follow-pupil::after {
          content: '';
          position: absolute;
          top: 0;
          right: 0;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    ''', js='''
        // 算出滑鼠在眼睛的哪個方向，眼珠往那邊移一格（4px），一格一格動才有像素的感覺
        const followEyes = document.querySelectorAll('.eye-follow')
        document.addEventListener('mousemove', (e) => {
          followEyes.forEach((eye) => {
            const rect = eye.getBoundingClientRect()
            const angle = Math.atan2(
              e.clientY - (rect.top + rect.height / 2),
              e.clientX - (rect.left + rect.width / 2),
            )
            const x = Math.round(Math.cos(angle)) * 4
            const y = Math.round(Math.sin(angle)) * 4
            const pupil = eye.querySelector('.eye-follow-pupil')
            pupil.style.transform = `translate(${x}px, ${y}px)`
          })
        })
    '''),
]

# 嘴巴：從 --mouth-y（預設 60%）往下
PARTS += [
    part('mouth', '牙齒', 'html', 15, html='''
        <div class="tooth left"></div>
        <div class="tooth right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tooth {
          --tooth-color: #fbf8f1;
          top: calc(var(--mouth-y, 60%) + 6px);
        }

        .tooth.left {
          left: calc(50% - 18px);
        }

        .tooth.right {
          left: calc(50% + 6px);
        }

        /* 每顆牙齒是 4 格：上面一排 3 格、下面中間 1 格尖尖的 */
        /* 元素本身是左上那一格，另外 3 格用 box-shadow 複製出來 */
        /* box-shadow 的前兩個數字是往右、往下移多少，移 4px 就是旁邊那一格 */
        .tooth {
          position: absolute;
          width: 4px;
          height: 4px;
          background: var(--tooth-color);
          box-shadow:
            4px 0 0 var(--tooth-color),
            8px 0 0 var(--tooth-color),
            4px 4px 0 var(--tooth-color);
        }
    '''),
    part('mouth', '微笑', 'css', 10, html='''
        <div class="mouth-smile"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-smile {
          --mouth-color: #2e221a;
          top: var(--mouth-y, 60%);
          left: calc(50% - 12px);
        }

        /* 微笑是 6 格：左上一格、下面一排 4 格、右上一格，排起來就是 U 形 */
        /* 元素本身是左上那一格，另外 5 格用 box-shadow 複製出來 */
        .mouth-smile {
          position: absolute;
          width: 4px;
          height: 4px;
          background: var(--mouth-color);
          box-shadow:
            4px 4px 0 var(--mouth-color),
            8px 4px 0 var(--mouth-color),
            12px 4px 0 var(--mouth-color),
            16px 4px 0 var(--mouth-color),
            20px 0 0 var(--mouth-color);
        }
    '''),
    part('mouth', '大嘴巴', 'html', 15, html='''
        <div class="mouth-big"><span class="mouth-big-tongue"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-big {
          --mouth-color: #2e221a;
          --tongue-color: #e8a0a0;
          top: calc(var(--mouth-y, 60%) - 4px);
          left: calc(50% - 16px);
        }

        /* 張開的嘴 8 × 3 格，下面再接一排左右各縮一格的，嘴巴底部一階一階收圓 */
        .mouth-big {
          position: absolute;
          width: 32px;
          height: 12px;
          background: var(--mouth-color);
        }

        .mouth-big::before {
          content: '';
          position: absolute;
          top: 12px;
          left: 4px;
          right: 4px;
          height: 4px;
          background: var(--mouth-color);
        }

        /* 舌頭 4 × 2 格，放在嘴巴下半部 */
        .mouth-big-tongue {
          position: absolute;
          top: 8px;
          left: 8px;
          width: 16px;
          height: 8px;
          background: var(--tongue-color);
        }
    '''),
    part('mouth', '吐舌頭', 'html', 15, html='''
        <div class="mouth-tongue"><span class="mouth-tongue-tip"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-tongue {
          --mouth-color: #2e221a;
          --tongue-color: #e8a0a0;
          top: calc(var(--mouth-y, 60%) + 4px);
          left: calc(50% - 16px);
        }

        /* 一條 8 格長的嘴巴線 */
        .mouth-tongue {
          position: absolute;
          width: 32px;
          height: 4px;
          background: var(--mouth-color);
        }

        /* 舌頭從嘴巴中間吐出來：2 × 2 格，外框沒有上邊，跟嘴巴線連在一起 */
        .mouth-tongue-tip {
          position: absolute;
          top: 4px;
          left: 8px;
          width: 8px;
          height: 8px;
          background: var(--tongue-color);
          border: 4px solid #4a3426;
          border-top: 0;
        }
    '''),
    part('mouth', '鳥嘴', 'css', 15, html='''
        <div class="mouth-beak"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-beak {
          --beak-color: #e8a33d;
          top: calc(var(--mouth-y, 60%) - 4px);
          left: calc(50% - 12px);
        }

        /* 鳥嘴三排，由上往下寬 6 格、4 格、2 格，一階一階變尖 */
        .mouth-beak {
          position: absolute;
          width: 24px;
          height: 4px;
          background: var(--beak-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .mouth-beak::before,
        .mouth-beak::after {
          content: '';
          position: absolute;
          height: 4px;
          background: var(--beak-color);
        }

        .mouth-beak::before {
          top: 4px;
          left: 4px;
          width: 16px;
        }

        .mouth-beak::after {
          top: 8px;
          left: 8px;
          width: 8px;
        }
    '''),
    part('mouth', '吸血鬼牙', 'html', 20, html='''
        <div class="mouth-vampire"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-vampire {
          --mouth-color: #2e221a;
          --fang-color: #fbf8f1;
          top: calc(var(--mouth-y, 60%) + 2px);
          left: calc(50% - 16px);
        }

        /* 一條 8 格長的嘴巴線，兩顆尖牙用 ::before ::after 畫，每顆 1 格寬、2 格長 */
        .mouth-vampire {
          position: absolute;
          width: 32px;
          height: 4px;
          background: var(--mouth-color);
        }

        .mouth-vampire::before,
        .mouth-vampire::after {
          content: '';
          position: absolute;
          top: 4px;
          width: 4px;
          height: 8px;
          background: var(--fang-color);
        }

        .mouth-vampire::before {
          left: 4px;
        }

        .mouth-vampire::after {
          right: 4px;
        }
    '''),
    part('mouth', '鬍鬚', 'html', 20, html='''
        <div class="mouth-whisker left"><span></span><span></span><span></span></div>
        <div class="mouth-whisker right"><span></span><span></span><span></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-whisker {
          --whisker-color: #2e221a;
          top: calc(var(--mouth-y, 60%) - 8px);
        }

        /* 從身體左右邊緣往內 30px 長出來，露在外面 10px，身體變寬變窄都一樣 */
        .mouth-whisker.left {
          left: -10px;
        }

        .mouth-whisker.right {
          left: calc(100% - 30px);
        }

        /* 每邊三根鬍鬚，一根 1 格粗；上下兩根短一點，看起來有遠近 */
        .mouth-whisker {
          position: absolute;
          width: 40px;
        }

        .mouth-whisker span {
          display: block;
          width: 100%;
          height: 4px;
          margin-bottom: 4px;
          background: var(--whisker-color);
        }

        .mouth-whisker span:first-child,
        .mouth-whisker span:last-child {
          width: 75%;
        }

        /* 右邊那組靠右對齊，短的鬍鬚才會在外側 */
        .mouth-whisker.right span {
          margin-left: auto;
        }
    '''),
    part('mouth', 'O 型嘴', 'css', 10, html='''
        <div class="mouth-o"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-o {
          --mouth-inside: #c8553d;
          top: calc(var(--mouth-y, 60%) + 4px);
          left: calc(50% - 4px);
        }

        /* 嘴巴裡面 2 × 2 格，外框用 box-shadow 往上下左右各複製一次，四個角空出來就是圓圓的 O */
        .mouth-o {
          position: absolute;
          width: 8px;
          height: 8px;
          background: var(--mouth-inside);
          box-shadow:
            0 -4px 0 #2e221a,
            0 4px 0 #2e221a,
            -4px 0 0 #2e221a,
            4px 0 0 #2e221a;
        }
    '''),
    part('mouth', '會說話的嘴', 'js', 60, html='''
        <div class="mouth-talk"></div>
        <div class="mouth-bubble"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .mouth-talk {
          --mouth-color: #2e221a;
          top: calc(var(--mouth-y, 60%) + 4px);
          left: calc(50% - 12px);
        }

        .mouth-bubble {
          top: calc(var(--horn-y, 0%) - 50px);
          left: calc(50% + 30px);
        }

        .body {
          cursor: pointer;
        }

        /* 嘴巴 6 格長、1 格高；說話的時候在 1 格和 3 格之間一格一格跳 */
        .mouth-talk {
          position: absolute;
          width: 24px;
          height: 4px;
          background: var(--mouth-color);
        }

        .mouth-talk.talking {
          animation: mouth-talk 0.3s steps(2) infinite alternate;
        }

        @keyframes mouth-talk {
          to {
            height: 12px;
          }
        }

        /* 說話泡泡：直角、4px 外框，跟像素圖一樣 */
        .mouth-bubble {
          position: absolute;
          padding: 4px 8px;
          background: #fbf8f1;
          border: 4px solid #4a3426;
          font-size: 14px;
          white-space: nowrap;
          opacity: 0;
          transition: opacity 0.2s;
        }

        .mouth-bubble.show {
          opacity: 1;
        }
    ''', js='''
        // 點身體隨機說一句話，兩秒後收起來
        const talkBody = document.querySelector('.body')
        const talkMouth = document.querySelector('.mouth-talk')
        const talkBubble = document.querySelector('.mouth-bubble')
        const talkLines = ['你好！', '肚子餓了', '我是合成獸', '再點我一下', '今天也要寫程式']
        let talkTimer
        talkBody.addEventListener('click', () => {
          talkBubble.textContent = talkLines[Math.floor(Math.random() * talkLines.length)]
          talkBubble.classList.add('show')
          talkMouth.classList.add('talking')
          clearTimeout(talkTimer)
          talkTimer = setTimeout(() => {
            talkBubble.classList.remove('show')
            talkMouth.classList.remove('talking')
          }, 2000)
        })
    '''),
]

# 花紋：只改 .body 的 background-image，底色還是玩家選的 --fur-color
PARTS += [
    part('pattern', '毛色', 'css', 20, css='''
        /* 想換顏色，改這裡就好：--fur-color 是底色，最後的 15% 是條紋的深淺 */
        .body {
          --fur-color: #e8a33d;
          --stripe-color: rgb(46 34 26 / 15%);
        }

        /* 直的條紋：每 6 格一個循環，前 4 格空白、後 2 格是條紋，邊緣是直的，跟像素圖一樣 */
        .body {
          background-image: repeating-linear-gradient(
            90deg,
            transparent 0 16px,
            var(--stripe-color) 16px 24px
          );
        }
    '''),
    part('pattern', '點點', 'css', 20, css='''
        /* 改 background-size 調點點的間距 */
        .body {
          background-image: radial-gradient(rgba(255, 255, 255, 0.5) 22%, transparent 26%);
          background-size: 20px 20px;
        }
    '''),
    part('pattern', '格子', 'css', 20, css='''
        /* 直的、橫的半透明條紋疊在一起，交叉的地方比較深 */
        .body {
          background-image:
            linear-gradient(90deg, rgba(0, 0, 0, 0.12) 50%, transparent 50%),
            linear-gradient(rgba(0, 0, 0, 0.12) 50%, transparent 50%);
          background-size: 24px 24px;
        }
    '''),
    part('pattern', '漸層', 'css', 25, css='''
        /* 上面疊白、下面疊黑，看起來像有光從上面照下來 */
        .body {
          background-image: linear-gradient(rgba(255, 255, 255, 0.45), rgba(0, 0, 0, 0.25));
        }
    '''),
    part('pattern', '彩虹', 'css', 30, css='''
        .body {
          background-image: linear-gradient(
            rgba(230, 102, 102, 0.6) 0 17%,
            rgba(242, 165, 65, 0.6) 17% 33%,
            rgba(245, 213, 71, 0.6) 33% 50%,
            rgba(124, 195, 107, 0.6) 50% 67%,
            rgba(90, 169, 230, 0.6) 67% 83%,
            rgba(155, 127, 209, 0.6) 83%
          );
        }
    '''),
    part('pattern', '斑馬紋', 'css', 25, css='''
        .body {
          background-image: repeating-linear-gradient(
            100deg,
            transparent 0 10px,
            rgba(43, 29, 20, 0.8) 10px 16px
          );
        }
    '''),
    part('pattern', '星空', 'css', 30, css='''
        /* 兩層大小不同的白點錯開放，最下面一層是深藍色 */
        .body {
          background-image:
            radial-gradient(#ffffff 1.5px, transparent 2px),
            radial-gradient(#ffffff 1px, transparent 1.5px),
            linear-gradient(#1d2b53, #3b3f7a);
          background-size:
            26px 26px,
            17px 17px,
            100% 100%;
          background-position:
            0 0,
            8px 11px,
            0 0;
        }
    '''),
    part('pattern', '白肚子', 'css', 20, css='''
        .body {
          background-image: radial-gradient(
            ellipse 36% 30% at 50% 68%,
            #f3ead8 96%,
            transparent 100%
          );
        }
    '''),
    part('pattern', '點一下換毛色', 'js', 50, css='''
        .body {
          cursor: pointer;
          transition: background-color 0.3s;
        }
    ''', js='''
        // 點身體把 --fur-color 換成隨機顏色
        const furBody = document.querySelector('.body')
        furBody.addEventListener('click', () => {
          const hue = Math.floor(Math.random() * 360)
          furBody.style.setProperty('--fur-color', `hsl(${hue}, 55%, 65%)`)
        })
    '''),
]

# 翅膀：上緣在 --wing-y（預設 10%），接在身體左右邊緣外側
# 右邊那片多半是左邊那片用 scaleX(-1) 翻過來
PARTS += [
    part('wings', '翅膀', 'css', 30, html='''
        <div class="wing"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing {
          --wing-color: #6b8fb0;
          top: calc(var(--wing-y, 10%) + 4px);
          left: calc(-66px + var(--wing-x, 0px));
        }

        /* 翅膀 16 × 10 格；外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
        .wing {
          position: absolute;
          width: 64px;
          height: 40px;
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角：左上和右下一階一階剪成圓弧，右上和左下保持直角 */
        .wing {
          --wing-shape: polygon(
            24px 0,
            64px 0,
            64px 24px,
            60px 24px,
            60px 28px,
            56px 28px,
            56px 32px,
            48px 32px,
            48px 36px,
            40px 36px,
            40px 40px,
            0 40px,
            0 20px,
            4px 20px,
            4px 16px,
            8px 16px,
            8px 12px,
            12px 12px,
            12px 8px,
            16px 8px,
            16px 4px,
            24px 4px
          );
        }
    '''),
    part('wings', '一對小翅膀', 'html', 30, html='''
        <div class="wing-pair left"></div>
        <div class="wing-pair right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-pair {
          --wing-color: #6b8fb0;
          top: calc(var(--wing-y, 10%) + 6px);
        }

        .wing-pair.left {
          left: calc(-44px + var(--wing-x, 0px));
        }

        .wing-pair.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
        }

        /* 每片翅膀 10 × 7 格 */
        .wing-pair {
          position: absolute;
          width: 40px;
          height: 28px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing-pair::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角；右邊那片是左邊左右翻過來 */
        .wing-pair.left {
          --wing-shape: polygon(
            12px 0,
            40px 0,
            40px 20px,
            36px 20px,
            36px 24px,
            24px 24px,
            24px 28px,
            0 28px,
            0 8px,
            4px 8px,
            4px 4px,
            12px 4px
          );
        }

        .wing-pair.right {
          --wing-shape: polygon(
            0 0,
            28px 0,
            28px 4px,
            36px 4px,
            36px 8px,
            40px 8px,
            40px 28px,
            16px 28px,
            16px 24px,
            4px 24px,
            4px 20px,
            0 20px
          );
        }
    '''),
    part('wings', '天使翅膀', 'html', 35, html='''
        <div class="wing-angel left"><span></span><span></span><span></span></div>
        <div class="wing-angel right"><span></span><span></span><span></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-angel {
          --feather-color: #fbf8f1;
          top: calc(var(--wing-y, 10%) - 8px);
        }

        .wing-angel.left {
          left: calc(-60px + var(--wing-x, 0px));
        }

        .wing-angel.right {
          left: calc(100% - var(--wing-x, 0px));
        }

        /* 三片羽毛由長到短往下疊，長度 13、10、7 格；上下兩片共用一條外框，疊起來就是一階一階的翅膀 */
        .wing-angel {
          position: absolute;
          width: 60px;
          height: 40px;
        }

        .wing-angel span {
          position: absolute;
          height: 8px;
          background: var(--feather-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 -4px 0 rgb(46 34 26 / 15%);
        }

        .wing-angel span:nth-child(1) {
          top: 0;
          width: 52px;
        }

        .wing-angel span:nth-child(2) {
          top: 12px;
          width: 40px;
        }

        .wing-angel span:nth-child(3) {
          top: 24px;
          width: 28px;
        }

        /* 羽毛貼著身體那一側對齊：左邊的翅膀靠右、右邊的翅膀靠左 */
        .wing-angel.left span {
          right: 0;
        }

        .wing-angel.right span {
          left: 0;
        }
    '''),
    part('wings', '蝙蝠翅膀', 'css', 35, html='''
        <div class="wing-bat left"></div>
        <div class="wing-bat right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-bat {
          --wing-color: #6f6a64;
          top: calc(var(--wing-y, 10%) - 4px);
        }

        .wing-bat.left {
          left: calc(-70px + var(--wing-x, 0px));
        }

        .wing-bat.right {
          left: calc(100% - 2px - var(--wing-x, 0px));
        }

        /* 每片翅膀 18 × 11 格：上緣往外斜到翼尖，下緣三個尖角 */
        .wing-bat {
          position: absolute;
          width: 72px;
          height: 44px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing-bat::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角；右邊那片是左邊左右翻過來 */
        .wing-bat.left {
          --wing-shape: polygon(
            0 0,
            8px 0,
            8px 4px,
            16px 4px,
            16px 8px,
            28px 8px,
            28px 12px,
            40px 12px,
            40px 16px,
            64px 16px,
            64px 12px,
            72px 12px,
            72px 44px,
            56px 44px,
            56px 40px,
            52px 40px,
            52px 36px,
            48px 36px,
            48px 32px,
            44px 32px,
            44px 36px,
            40px 36px,
            40px 40px,
            36px 40px,
            36px 44px,
            32px 44px,
            32px 40px,
            28px 40px,
            28px 36px,
            24px 36px,
            24px 32px,
            20px 32px,
            20px 36px,
            16px 36px,
            16px 40px,
            12px 40px,
            12px 44px,
            8px 44px,
            8px 36px,
            4px 36px,
            4px 28px,
            0 28px
          );
        }

        .wing-bat.right {
          --wing-shape: polygon(
            64px 0,
            72px 0,
            72px 28px,
            68px 28px,
            68px 36px,
            64px 36px,
            64px 44px,
            60px 44px,
            60px 40px,
            56px 40px,
            56px 36px,
            52px 36px,
            52px 32px,
            48px 32px,
            48px 36px,
            44px 36px,
            44px 40px,
            40px 40px,
            40px 44px,
            36px 44px,
            36px 40px,
            32px 40px,
            32px 36px,
            28px 36px,
            28px 32px,
            24px 32px,
            24px 36px,
            20px 36px,
            20px 40px,
            16px 40px,
            16px 44px,
            0 44px,
            0 12px,
            8px 12px,
            8px 16px,
            32px 16px,
            32px 12px,
            44px 12px,
            44px 8px,
            56px 8px,
            56px 4px,
            64px 4px
          );
        }
    '''),
    part('wings', '蝴蝶翅膀', 'html', 35, html='''
        <div class="wing-butterfly left">
          <span class="wing-butterfly-top"></span>
          <span class="wing-butterfly-bottom"></span>
        </div>
        <div class="wing-butterfly right">
          <span class="wing-butterfly-top"></span>
          <span class="wing-butterfly-bottom"></span>
        </div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-butterfly {
          --top-color: #e8a33d;
          --bottom-color: #e8a0a0;
          top: calc(var(--wing-y, 10%) - 12px);
        }

        .wing-butterfly.left {
          left: calc(-48px + var(--wing-x, 0px));
        }

        .wing-butterfly.right {
          left: calc(100% - var(--wing-x, 0px));
        }

        /* 上下兩片，上面大 10 × 8 格、下面小 7 × 6 格 */
        .wing-butterfly {
          position: absolute;
          width: 48px;
          height: 72px;
        }

        .wing-butterfly span {
          position: absolute;
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        .wing-butterfly-top {
          top: 4px;
          width: 40px;
          height: 32px;
          background: var(--top-color);
        }

        .wing-butterfly-bottom {
          top: 40px;
          width: 28px;
          height: 24px;
          background: var(--bottom-color);
        }

        /* 上翅膀中間一個 2 × 2 格的白點 */
        .wing-butterfly-top::after {
          content: '';
          position: absolute;
          top: 12px;
          left: 16px;
          width: 8px;
          height: 8px;
          background: #fbf8f1;
        }

        /* 兩片翅膀都貼著身體那一側：左邊的靠右、右邊的靠左 */
        .wing-butterfly.left span {
          right: 4px;
        }

        .wing-butterfly.right span {
          left: 4px;
        }
    '''),
    part('wings', '蜻蜓翅膀', 'css', 30, html='''
        <div class="wing-dragonfly left"></div>
        <div class="wing-dragonfly right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好；最後的 60% 是透明度 */
        .wing-dragonfly {
          --wing-color: rgb(156 196 190 / 60%);
          top: var(--wing-y, 10%);
        }

        .wing-dragonfly.left {
          left: calc(-84px + var(--wing-x, 0px));
        }

        .wing-dragonfly.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
        }

        /* 前翅 19 × 2 格，後翅用 ::after 畫在下面、短一點；半透明看得到後面 */
        .wing-dragonfly,
        .wing-dragonfly::after {
          position: absolute;
          height: 8px;
          background: var(--wing-color);
          border: 4px solid rgb(74 52 38 / 60%);
        }

        .wing-dragonfly {
          width: 76px;
        }

        .wing-dragonfly::after {
          content: '';
          top: 16px;
          width: 60px;
        }

        /* 後翅貼著身體那一側：左邊的靠右、右邊的靠左 */
        .wing-dragonfly.left::after {
          right: -4px;
        }

        .wing-dragonfly.right::after {
          left: -4px;
        }
    '''),
    part('wings', '龍翼', 'css', 40, html='''
        <div class="wing-dragon left"><span></span></div>
        <div class="wing-dragon right"><span></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-dragon {
          --wing-color: #5a9a4a;
          top: calc(var(--wing-y, 10%) - 24px);
        }

        .wing-dragon.left {
          left: calc(-104px + var(--wing-x, 0px));
        }

        .wing-dragon.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
        }

        /* 每片翅膀 25 × 20 格：上緣是骨架往外伸，下緣三個大尖角 */
        .wing-dragon {
          position: absolute;
          width: 100px;
          height: 80px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing-dragon span {
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角；右邊那片是左邊左右翻過來 */
        .wing-dragon.left {
          --wing-shape: polygon(
            4px 0,
            16px 0,
            16px 4px,
            28px 4px,
            28px 8px,
            44px 8px,
            44px 12px,
            64px 12px,
            64px 16px,
            80px 16px,
            80px 20px,
            100px 20px,
            100px 80px,
            92px 80px,
            92px 76px,
            88px 76px,
            88px 72px,
            84px 72px,
            84px 68px,
            80px 68px,
            80px 72px,
            76px 72px,
            76px 76px,
            72px 76px,
            72px 80px,
            64px 80px,
            64px 76px,
            60px 76px,
            60px 72px,
            56px 72px,
            56px 68px,
            52px 68px,
            52px 64px,
            48px 64px,
            48px 60px,
            44px 60px,
            44px 56px,
            40px 56px,
            40px 52px,
            36px 52px,
            36px 56px,
            32px 56px,
            32px 60px,
            28px 60px,
            28px 64px,
            24px 64px,
            24px 68px,
            20px 68px,
            20px 72px,
            16px 72px,
            16px 76px,
            12px 76px,
            12px 80px,
            0 80px,
            0 48px,
            4px 48px,
            4px 40px,
            8px 40px,
            8px 32px,
            12px 32px,
            12px 24px,
            16px 24px,
            16px 16px,
            12px 16px,
            12px 8px,
            8px 8px,
            8px 4px,
            4px 4px
          );
        }

        .wing-dragon.right {
          --wing-shape: polygon(
            84px 0,
            96px 0,
            96px 4px,
            92px 4px,
            92px 8px,
            88px 8px,
            88px 16px,
            84px 16px,
            84px 24px,
            88px 24px,
            88px 32px,
            92px 32px,
            92px 40px,
            96px 40px,
            96px 48px,
            100px 48px,
            100px 80px,
            88px 80px,
            88px 76px,
            84px 76px,
            84px 72px,
            80px 72px,
            80px 68px,
            76px 68px,
            76px 64px,
            72px 64px,
            72px 60px,
            68px 60px,
            68px 56px,
            64px 56px,
            64px 52px,
            60px 52px,
            60px 56px,
            56px 56px,
            56px 60px,
            52px 60px,
            52px 64px,
            48px 64px,
            48px 68px,
            44px 68px,
            44px 72px,
            40px 72px,
            40px 76px,
            36px 76px,
            36px 80px,
            28px 80px,
            28px 76px,
            24px 76px,
            24px 72px,
            20px 72px,
            20px 68px,
            16px 68px,
            16px 72px,
            12px 72px,
            12px 76px,
            8px 76px,
            8px 80px,
            0 80px,
            0 20px,
            20px 20px,
            20px 16px,
            36px 16px,
            36px 12px,
            56px 12px,
            56px 8px,
            72px 8px,
            72px 4px,
            84px 4px
          );
        }
    '''),
    part('wings', '拍拍翅膀', 'css', 45, html='''
        <div class="wing-flap left"></div>
        <div class="wing-flap right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-flap {
          --wing-color: #6b8fb0;
          top: calc(var(--wing-y, 10%) + 4px);
        }

        .wing-flap.left {
          left: calc(-56px + var(--wing-x, 0px));
        }

        .wing-flap.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
        }

        /* 每片翅膀 12 × 8 格；transform-origin 設在靠身體那一側，旋轉起來才像在拍 */
        .wing-flap {
          position: absolute;
          width: 48px;
          height: 32px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing-flap::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        .wing-flap.left {
          transform-origin: right center;
          animation: wing-flap-left 0.5s ease-in-out infinite alternate;
        }

        .wing-flap.right {
          transform-origin: left center;
          animation: wing-flap-right 0.5s ease-in-out infinite alternate;
        }

        @keyframes wing-flap-left {
          to {
            transform: rotate(25deg);
          }
        }

        @keyframes wing-flap-right {
          to {
            transform: rotate(-25deg);
          }
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角；右邊那片是左邊左右翻過來 */
        .wing-flap.left {
          --wing-shape: polygon(
            16px 0,
            48px 0,
            48px 20px,
            44px 20px,
            44px 24px,
            40px 24px,
            40px 28px,
            32px 28px,
            32px 32px,
            0 32px,
            0 12px,
            4px 12px,
            4px 8px,
            8px 8px,
            8px 4px,
            16px 4px
          );
        }

        .wing-flap.right {
          --wing-shape: polygon(
            0 0,
            32px 0,
            32px 4px,
            40px 4px,
            40px 8px,
            44px 8px,
            44px 12px,
            48px 12px,
            48px 32px,
            16px 32px,
            16px 28px,
            8px 28px,
            8px 24px,
            4px 24px,
            4px 20px,
            0 20px
          );
        }
    '''),
    part('wings', '會飛的翅膀', 'js', 70, html='''
        <div class="wing-fly left"></div>
        <div class="wing-fly right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .wing-fly {
          --wing-color: #fbf8f1;
          top: calc(var(--wing-y, 10%) + 4px);
        }

        .wing-fly.left {
          left: calc(-56px + var(--wing-x, 0px));
        }

        .wing-fly.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
        }

        /* 每片翅膀 12 × 8 格 */
        .wing-fly {
          position: absolute;
          width: 48px;
          height: 32px;
          cursor: pointer;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，外框就會跟著剪出來的形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .wing-fly::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--wing-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--wing-shape);
        }

        .wing-fly.left {
          transform-origin: right center;
        }

        .wing-fly.right {
          transform-origin: left center;
        }

        /* 飛的時候整隻上下飄、翅膀一直拍；JS 只負責加上、拿掉 flying */
        .body.flying {
          animation: wing-float 1.2s ease-in-out infinite alternate;
        }

        /* 飛的時候點身體還是要能跳：兩個動畫一起放，跳的時候疊在飄浮上面，跳完繼續飄 */
        .body.flying.jump {
          animation:
            wing-float 1.2s ease-in-out infinite alternate,
            jump 0.4s ease-out;
        }

        .body.flying .wing-fly {
          animation: wing-fly 0.3s ease-in-out infinite alternate;
        }

        @keyframes wing-float {
          to {
            translate: 0 -16px;
          }
        }

        @keyframes wing-fly {
          to {
            scale: 1 0.6;
          }
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角；右邊那片是左邊左右翻過來 */
        .wing-fly.left {
          --wing-shape: polygon(
            16px 0,
            48px 0,
            48px 20px,
            44px 20px,
            44px 24px,
            40px 24px,
            40px 28px,
            32px 28px,
            32px 32px,
            0 32px,
            0 12px,
            4px 12px,
            4px 8px,
            8px 8px,
            8px 4px,
            16px 4px
          );
        }

        .wing-fly.right {
          --wing-shape: polygon(
            0 0,
            32px 0,
            32px 4px,
            40px 4px,
            40px 8px,
            44px 8px,
            44px 12px,
            48px 12px,
            48px 32px,
            16px 32px,
            16px 28px,
            8px 28px,
            8px 24px,
            4px 24px,
            4px 20px,
            0 20px
          );
        }
    ''', js='''
        // 點翅膀讓整隻飄起來，再點一下停下來；飄和拍翅膀的動作寫在 CSS 的 .flying
        const flyBody = document.querySelector('.body')
        document.querySelectorAll('.wing-fly').forEach((wing) => {
          wing.addEventListener('click', (event) => {
            // 翅膀長在身體裡，不擋住的話也會觸發身體的點擊
            event.stopPropagation()
            flyBody.classList.toggle('flying')
          })
        })
    '''),
]

# 尾巴：從身體右邊緣（100%）接出去，高度在 --tail-y（預設 60%）附近
PARTS += [
    part('tail', '會擺動的尾巴', 'js', 60, html='''
        <div class="tail"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail {
          --tail-color: #9a6440;
          top: var(--tail-y, 60%);
          left: 100%;
        }

        /* 尾巴是一條 10 × 2 格的長條，尾巴尖往上翹一格 */
        .tail {
          position: absolute;
          width: 40px;
          height: 8px;
          background: var(--tail-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 4px 0 rgb(255 255 255 / 35%);
          transform-origin: left center;
          cursor: pointer;
        }

        /* 尾巴尖：沒有下框，往下蓋住長條的上框，兩塊才會連在一起 */
        .tail::after {
          content: '';
          position: absolute;
          top: -12px;
          right: -4px;
          width: 8px;
          height: 8px;
          background: var(--tail-color);
          border: 4px solid #4a3426;
          border-bottom: 0;
        }

        .tail.wag {
          animation: wag 0.4s ease-in-out infinite alternate;
        }

        @keyframes wag {
          from {
            transform: rotate(-20deg);
          }
          to {
            transform: rotate(20deg);
          }
        }
    ''', js='''
        // 點一下尾巴開始擺動，再點一下停下來
        const tail = document.querySelector(".tail");
        tail.addEventListener("click", (event) => {
          // 尾巴長在身體裡，不擋住的話也會觸發身體的點擊
          event.stopPropagation();
          tail.classList.toggle("wag");
        });
    '''),
    part('tail', '毛球尾巴', 'html', 15, html='''
        <div class="tail-pompom"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-pompom {
          --tail-color: #fbf8f1;
          top: calc(var(--tail-y, 60%) - 4px);
          left: calc(100% + 4px);
        }

        /* 毛球 4 × 4 格；外框用 box-shadow 往上下左右各複製一次，四個角空出來就是圓圓的 */
        .tail-pompom {
          position: absolute;
          width: 16px;
          height: 16px;
          background: var(--tail-color);
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 右下角一格陰影，看起來有立體感 */
        .tail-pompom::after {
          content: '';
          position: absolute;
          right: 0;
          bottom: 0;
          width: 4px;
          height: 4px;
          background: rgb(46 34 26 / 20%);
        }
    '''),
    part('tail', '捲捲尾巴', 'css', 15, html='''
        <div class="tail-curly"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-curly {
          --tail-color: #e8a0a0;
          top: var(--tail-y, 60%);
          left: calc(100% + 4px);
        }

        /* 豬尾巴是 4 塊一上一下排成鋸齒，看起來就是捲捲的；每一塊 2 × 2 格（8px） */
        /* 元素本身是第一塊，另外 3 塊用 box-shadow 複製出來 */
        .tail-curly {
          position: absolute;
          width: 8px;
          height: 8px;
          background: var(--tail-color);
          box-shadow:
            8px -8px 0 var(--tail-color),
            16px 0 0 var(--tail-color),
            24px -8px 0 var(--tail-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }
    '''),
    part('tail', '狐狸尾巴', 'css', 25, html='''
        <div class="tail-fox"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-fox {
          --tail-color: #e8a33d;
          --tip-color: #fbf8f1;
          top: calc(var(--tail-y, 60%) - 24px);
          left: 100%;
        }

        /* 尾巴 20 × 9 格，往右上翹；尾端白色是背景在 75% 的地方直接換顏色 */
        .tail-fox {
          position: absolute;
          width: 80px;
          height: 36px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .tail-fox::before {
          content: '';
          position: absolute;
          inset: 0;
          background: linear-gradient(90deg, var(--tail-color) 75%, var(--tip-color) 75%);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--tail-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角 */
        .tail-fox {
          --tail-shape: polygon(
            48px 0,
            64px 0,
            64px 4px,
            72px 4px,
            72px 20px,
            80px 20px,
            80px 24px,
            76px 24px,
            76px 28px,
            68px 28px,
            68px 32px,
            56px 32px,
            56px 36px,
            20px 36px,
            20px 32px,
            12px 32px,
            12px 28px,
            4px 28px,
            4px 24px,
            0 24px,
            0 20px,
            8px 20px,
            8px 16px,
            16px 16px,
            16px 12px,
            24px 12px,
            24px 8px,
            36px 8px,
            36px 4px,
            48px 4px
          );
        }
    '''),
    part('tail', '惡魔尾巴', 'html', 20, html='''
        <div class="tail-devil"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-devil {
          --line-color: #4a3426;
          --arrow-color: #c8553d;
          top: calc(var(--tail-y, 60%) + 6px);
          left: calc(100% + 4px);
        }

        /* 細細的尾巴一階一階往上：元素本身是第一段，另外 3 段用 box-shadow 複製出來 */
        .tail-devil {
          position: absolute;
          width: 12px;
          height: 4px;
          background: var(--line-color);
          box-shadow:
            12px -4px 0 var(--line-color),
            24px -8px 0 var(--line-color),
            36px -12px 0 var(--line-color);
        }

        /* 尾端的箭頭：直的 3 格加上往右一格尖端 */
        .tail-devil::after {
          content: '';
          position: absolute;
          top: -16px;
          left: 48px;
          width: 4px;
          height: 4px;
          background: var(--arrow-color);
          box-shadow:
            0 4px 0 var(--arrow-color),
            0 8px 0 var(--arrow-color),
            4px 4px 0 var(--arrow-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }
    '''),
    part('tail', '魚尾巴', 'css', 20, html='''
        <div class="tail-fish"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-fish {
          --tail-color: #6b8fb0;
          top: var(--tail-y, 60%);
          left: calc(100% + 4px);
        }

        /* 魚尾巴 6 塊：接身體的一塊、中間直的三塊、上下兩塊分岔；每一塊 2 × 2 格（8px） */
        /* 元素本身是接身體那塊，另外 5 塊用 box-shadow 複製出來 */
        .tail-fish {
          position: absolute;
          width: 8px;
          height: 8px;
          background: var(--tail-color);
          box-shadow:
            8px -8px 0 var(--tail-color),
            8px 0 0 var(--tail-color),
            8px 8px 0 var(--tail-color),
            16px -16px 0 var(--tail-color),
            16px 16px 0 var(--tail-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }
    '''),
    part('tail', '閃電尾巴', 'css', 25, html='''
        <div class="tail-bolt"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-bolt {
          --tail-color: #f2d16b;
          top: calc(var(--tail-y, 60%) - 30px);
          left: calc(100% + 2px);
        }

        /* 閃電 16 × 10 格，從身體往右上一折一折 */
        .tail-bolt {
          position: absolute;
          width: 64px;
          height: 40px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .tail-bolt::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--tail-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--tail-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角 */
        .tail-bolt {
          --tail-shape: polygon(
            48px 0,
            64px 0,
            64px 4px,
            56px 4px,
            56px 8px,
            48px 8px,
            48px 12px,
            56px 12px,
            56px 20px,
            48px 20px,
            48px 24px,
            40px 24px,
            40px 28px,
            32px 28px,
            32px 32px,
            24px 32px,
            24px 36px,
            16px 36px,
            16px 40px,
            0 40px,
            0 36px,
            8px 36px,
            8px 32px,
            16px 32px,
            16px 28px,
            24px 28px,
            24px 24px,
            32px 24px,
            32px 20px,
            40px 20px,
            40px 16px,
            24px 16px,
            24px 12px,
            32px 12px,
            32px 8px,
            40px 8px,
            40px 4px,
            48px 4px
          );
        }
    '''),
    part('tail', '恐龍尾巴', 'css', 25, html='''
        <div class="tail-dino"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-dino {
          --tail-color: #5a9a4a;
          top: calc(var(--tail-y, 60%) - 18px);
          left: 100%;
        }

        /* 尾巴 22 × 9 格，往外越來越細，上面三根背刺 */
        .tail-dino {
          position: absolute;
          width: 88px;
          height: 36px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .tail-dino::before {
          content: '';
          position: absolute;
          inset: 0;
          background: var(--tail-color);
          box-shadow:
            inset 4px 4px 0 rgb(255 255 255 / 35%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          clip-path: var(--tail-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角 */
        .tail-dino {
          --tail-shape: polygon(
            12px 0,
            16px 0,
            16px 4px,
            20px 4px,
            20px 8px,
            32px 8px,
            32px 4px,
            36px 4px,
            36px 0,
            40px 0,
            40px 4px,
            44px 4px,
            44px 8px,
            56px 8px,
            56px 4px,
            60px 4px,
            60px 0,
            64px 0,
            64px 4px,
            68px 4px,
            68px 8px,
            88px 8px,
            88px 16px,
            80px 16px,
            80px 20px,
            68px 20px,
            68px 24px,
            52px 24px,
            52px 28px,
            32px 28px,
            32px 32px,
            16px 32px,
            16px 36px,
            0 36px,
            0 8px,
            8px 8px,
            8px 4px,
            12px 4px
          );
        }
    '''),
    part('tail', '會長大的尾巴', 'js', 50, html='''
        <div class="tail-grow"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .tail-grow {
          --tail-color: #9a6440;
          top: var(--tail-y, 60%);
          left: 100%;
        }

        /* 尾巴 2 格高，一開始 8 格長，JS 每點一下加 4 格 */
        .tail-grow {
          position: absolute;
          width: 32px;
          height: 8px;
          background: var(--tail-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 4px 0 rgb(255 255 255 / 35%);
          cursor: pointer;
          transition: width 0.3s steps(4);
        }
    ''', js='''
        // 每點一下變長 4 格（16px），超過 32 格（128px）就變回原本的 8 格（32px）
        const growTail = document.querySelector('.tail-grow')
        let growLength = 32
        growTail.addEventListener('click', (event) => {
          // 尾巴長在身體裡，不擋住的話也會觸發身體的點擊
          event.stopPropagation()
          growLength = growLength >= 128 ? 32 : growLength + 16
          growTail.style.width = `${growLength}px`
        })
    '''),
]

# 腳：從 --leg-y（預設 100%，身體下緣）往下長，左腳用 left、右腳用 right，兩邊同一個百分比，一定左右對稱；身體變寬腳也會分開
# z-index: 1 讓腳畫在披風上面，不管哪個先裝，披風下襬都不會蓋住腳
PARTS += [
    part('feet', '小短腳', 'html', 10, html='''
        <div class="feet-short left"></div>
        <div class="feet-short right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-short {
          --foot-color: #9a6440;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-short.left {
          left: 16.67%;
        }

        .feet-short.right {
          right: 16.67%;
        }

        /* 一隻腳 3 × 2 格，加上 4px 的深棕外框 */
        .feet-short {
          position: absolute;
          z-index: 1;
          width: 12px;
          height: 8px;
          background: var(--foot-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 -4px 0 rgb(46 34 26 / 25%);
        }
    '''),
    part('feet', '肉球腳掌', 'html', 15, html='''
        <div class="feet-paw left"></div>
        <div class="feet-paw right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-paw {
          --paw-color: #fbf8f1;
          --pad-color: #e8a0a0;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-paw.left {
          left: 11.67%;
        }

        .feet-paw.right {
          right: 11.67%;
        }

        /* 腳掌 5 × 3 格 */
        .feet-paw {
          position: absolute;
          z-index: 1;
          width: 20px;
          height: 12px;
          background: var(--paw-color);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 底下的粉紅肉球 2 × 1 格 */
        .feet-paw::after {
          content: '';
          position: absolute;
          bottom: 0;
          left: 6px;
          width: 8px;
          height: 4px;
          background: var(--pad-color);
        }
    '''),
    part('feet', '長腿', 'html', 20, html='''
        <div class="feet-long left"></div>
        <div class="feet-long right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-long {
          --leg-color: #4a3426;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-long.left {
          left: 21.67%;
        }

        .feet-long.right {
          right: 21.67%;
        }

        /* 腿 2 格寬、9 格長 */
        .feet-long {
          position: absolute;
          z-index: 1;
          width: 8px;
          height: 36px;
          background: var(--leg-color);
        }

        /* 腳掌 4 × 2 格，往外側伸出去 */
        .feet-long::after {
          content: '';
          position: absolute;
          bottom: 0;
          width: 16px;
          height: 8px;
          background: var(--leg-color);
        }

        .feet-long.left::after {
          right: 0;
        }

        .feet-long.right::after {
          left: 0;
        }
    '''),
    part('feet', '鴨蹼', 'css', 15, html='''
        <div class="feet-duck left"></div>
        <div class="feet-duck right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-duck {
          --foot-color: #e8a33d;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-duck.left {
          left: 22.5%;
        }

        .feet-duck.right {
          right: 22.5%;
        }

        /* 細細的腿 1 格寬、2 格長 */
        .feet-duck {
          position: absolute;
          z-index: 1;
          width: 4px;
          height: 8px;
          background: var(--foot-color);
        }

        /* 蹼是 6 格：一排 4 格，最左、最右再往下各一格，看起來是張開的腳掌 */
        /* 元素本身是左上那一格，另外 5 格用 box-shadow 複製出來 */
        .feet-duck::after {
          content: '';
          position: absolute;
          top: 8px;
          left: -6px;
          width: 4px;
          height: 4px;
          background: var(--foot-color);
          box-shadow:
            4px 0 0 var(--foot-color),
            8px 0 0 var(--foot-color),
            12px 0 0 var(--foot-color),
            0 4px 0 var(--foot-color),
            12px 4px 0 var(--foot-color);
        }
    '''),
    part('feet', '馬蹄', 'html', 20, html='''
        <div class="feet-hoof left"><span class="feet-hoof-tip"></span></div>
        <div class="feet-hoof right"><span class="feet-hoof-tip"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-hoof {
          --leg-color: #c99a6b;
          --hoof-color: #2e221a;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-hoof.left {
          left: 18.33%;
        }

        .feet-hoof.right {
          right: 18.33%;
        }

        /* 腿 4 格寬、5 格長 */
        .feet-hoof {
          position: absolute;
          z-index: 1;
          width: 16px;
          height: 20px;
          background: var(--leg-color);
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 20%);
        }

        /* 蹄比腿左右各寬一格，2 格高 */
        .feet-hoof-tip {
          position: absolute;
          bottom: -8px;
          left: -4px;
          width: 24px;
          height: 8px;
          background: var(--hoof-color);
        }
    '''),
    part('feet', '章魚觸手', 'css', 25, html='''
        <div class="feet-octopus"><span></span><span></span><span></span><span></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-octopus {
          --tentacle-color: #e8a0a0;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        /* 四條觸手平均排開，整排寬度是身體的 83%，身體變寬觸手會分開一點 */
        .feet-octopus {
          position: absolute;
          z-index: 1;
          left: 8.5%;
          width: 83%;
          display: flex;
          justify-content: space-between;
        }

        /* 每條觸手 2 格寬、5 格長，最底下往外勾一格 */
        .feet-octopus span {
          position: relative;
          width: 8px;
          height: 20px;
          background: var(--tentacle-color);
          box-shadow: inset -4px 0 0 rgb(46 34 26 / 15%);
        }

        .feet-octopus span::after {
          content: '';
          position: absolute;
          bottom: 0;
          width: 4px;
          height: 4px;
          background: var(--tentacle-color);
        }

        /* 左邊兩條往左勾、右邊兩條往右勾 */
        .feet-octopus span:nth-child(-n + 2)::after {
          left: -4px;
        }

        .feet-octopus span:nth-child(n + 3)::after {
          right: -4px;
        }
    '''),
    part('feet', '輪子', 'html', 25, html='''
        <div class="feet-wheel-axle"></div>
        <div class="feet-wheel left"></div>
        <div class="feet-wheel right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-wheel {
          --tire-color: #2e221a;
          --hub-color: #a8a29a;
          top: calc(var(--leg-y, 100%) + 8px);
        }

        .feet-wheel-axle {
          top: calc(var(--leg-y, 100%) + 16px);
        }

        /* 輪軸是身體寬度的一半，兩個輪子裝在輪軸兩端 */
        .feet-wheel-axle {
          position: absolute;
          z-index: 1;
          left: 25%;
          width: 50%;
          height: 4px;
          background: #4a3426;
        }

        .feet-wheel.left {
          left: calc(25% - 10px);
        }

        .feet-wheel.right {
          right: calc(25% - 10px);
        }

        /* 輪子 5 × 5 格 */
        .feet-wheel {
          position: absolute;
          z-index: 1;
          width: 20px;
          height: 20px;
          background: var(--tire-color);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 輪子中間的輪框 2 × 2 格 */
        .feet-wheel::after {
          content: '';
          position: absolute;
          top: 6px;
          left: 6px;
          width: 8px;
          height: 8px;
          background: var(--hub-color);
        }
    '''),
    part('feet', '彈簧腳', 'css', 30, html='''
        <div class="feet-spring left"></div>
        <div class="feet-spring right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-spring {
          --spring-color: #6f6a64;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-spring.left {
          left: 18.33%;
        }

        .feet-spring.right {
          right: 18.33%;
        }

        /* 彈簧 4 格寬、7 格長：一格線、一格空一直重複，像一圈一圈的彈簧 */
        .feet-spring {
          position: absolute;
          z-index: 1;
          width: 16px;
          height: 28px;
          background: repeating-linear-gradient(
            var(--spring-color) 0 4px,
            transparent 4px 8px
          );
        }

        /* 底下的腳墊，比彈簧左右各寬一格 */
        .feet-spring::after {
          content: '';
          position: absolute;
          bottom: -4px;
          left: -4px;
          width: 24px;
          height: 4px;
          background: #4a3426;
        }
    '''),
    part('feet', '會走路的腳', 'js', 60, html='''
        <div class="feet-walk left"></div>
        <div class="feet-walk right"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .feet-walk {
          --foot-color: #9a6440;
          top: calc(var(--leg-y, 100%) + 4px);
        }

        .feet-walk.left {
          left: 18.33%;
        }

        .feet-walk.right {
          right: 18.33%;
        }

        /* 一隻腳 3 × 4 格，加上 4px 的深棕外框 */
        .feet-walk {
          position: absolute;
          z-index: 1;
          width: 12px;
          height: 16px;
          background: var(--foot-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 -4px 0 rgb(46 34 26 / 25%);
          cursor: pointer;
        }

        /* 走路時兩隻腳輪流抬起來，右腳晚半拍；一次抬兩格，一格一格動；JS 只負責加上、拿掉 walking */
        .body.walking .feet-walk {
          animation: feet-step 0.6s steps(2) infinite;
        }

        .body.walking .feet-walk.right {
          animation-delay: 0.3s;
        }

        @keyframes feet-step {
          50% {
            translate: 0 -8px;
          }
        }
    ''', js='''
        // 點腳開始左右交替踏步，再點一下停下來；踏步的動作寫在 CSS 的 .walking
        const walkBody = document.querySelector('.body')
        document.querySelectorAll('.feet-walk').forEach((foot) => {
          foot.addEventListener('click', (event) => {
            // 腳長在身體裡，不擋住的話也會觸發身體的點擊
            event.stopPropagation()
            walkBody.classList.toggle('walking')
          })
        })
    '''),
]

# 配件：多半放在身體下半部前面，不要擋到眼睛和嘴巴；領結、圍巾、項鍊、勳章對到 --neck-y（預設 80%）
# 零件在 .body 裡面，身體做動畫時 z-index: -1 會跑到身體前面，所以「在後面」的配件改成不跟身體重疊
PARTS += [
    part('accessory', '領結', 'html', 10, html='''
        <div class="accessory-bowtie"><span></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-bowtie {
          --bow-color: #c8553d;
          top: calc(var(--neck-y, 80%) - 8px);
        }

        /* 領結寬度是身體的 40%，身體變寬也跟著變寬；左右兩塊是蝴蝶結的兩邊，中間的 span 是結 */
        .accessory-bowtie {
          position: absolute;
          left: 30%;
          width: 40%;
          height: 24px;
        }

        /* box-sizing: border-box 讓寬度把外框也算進去，兩塊各占一半剛好排滿 */
        .accessory-bowtie::before,
        .accessory-bowtie::after {
          content: '';
          position: absolute;
          top: 0;
          box-sizing: border-box;
          width: 50%;
          height: 24px;
          background: var(--bow-color);
          border: 4px solid #4a3426;
          box-shadow: inset 0 -4px 0 rgb(46 34 26 / 20%);
        }

        .accessory-bowtie::before {
          left: 0;
        }

        .accessory-bowtie::after {
          right: 0;
        }

        /* 中間的結 2 × 2 格，疊在兩塊上面；兩邊比中間高，看起來就是蝴蝶結 */
        .accessory-bowtie span {
          position: absolute;
          z-index: 1;
          top: 4px;
          left: calc(50% - 8px);
          width: 8px;
          height: 8px;
          background: var(--bow-color);
          border: 4px solid #4a3426;
        }
    '''),
    part('accessory', '圍巾', 'css', 15, html='''
        <div class="accessory-scarf"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-scarf {
          --scarf-color: #5a9a4a;
          --stripe-color: #fbf8f1;
          top: calc(var(--neck-y, 80%) + 4px);
        }

        /* 橫的一條繞在身體上，寬度是身體加一圈；條紋是 2 格綠、1 格白一直重複 */
        .accessory-scarf {
          position: absolute;
          left: -4px;
          width: calc(100% + 8px);
          height: 8px;
          background: repeating-linear-gradient(
            90deg,
            var(--scarf-color) 0 8px,
            var(--stripe-color) 8px 12px
          );
          border-top: 4px solid #4a3426;
          border-bottom: 4px solid #4a3426;
        }

        /* 垂下來的那一端：3 格寬、8 格長，條紋改成橫的 */
        .accessory-scarf::after {
          content: '';
          position: absolute;
          top: 8px;
          right: 16px;
          width: 12px;
          height: 32px;
          background: repeating-linear-gradient(
            var(--scarf-color) 0 8px,
            var(--stripe-color) 8px 12px
          );
          border: 4px solid #4a3426;
        }
    '''),
    part('accessory', '項鍊', 'html', 15, html='''
        <div class="accessory-necklace"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-necklace {
          --bead-color: #fbf8f1;
          --pendant-color: #e8a33d;
          top: calc(var(--neck-y, 80%) - 16px);
        }

        /* 虛線邊框剛好是一顆一顆方方的珠子，寬度是身體的 53%，跟著身體變寬 */
        .accessory-necklace {
          position: absolute;
          left: calc(23.5% - 4px);
          width: 53%;
          height: 12px;
          border: 4px dashed var(--bead-color);
          border-top: none;
        }

        /* 墜子 2 × 2 格，掛在正中間 */
        .accessory-necklace::after {
          content: '';
          position: absolute;
          bottom: -12px;
          left: calc(50% - 8px);
          width: 8px;
          height: 8px;
          background: var(--pendant-color);
          border: 4px solid #4a3426;
        }
    '''),
    part('accessory', '小花', 'html', 15, html='''
        <div class="accessory-flower"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-flower {
          --center-color: #f2d16b;
          --petal-color: #e8a0a0;
          top: calc(var(--horn-y, 0%) + 6px);
          left: calc(50% + 34px);
        }

        /* 中間是花心，上下左右四片花瓣用 box-shadow 複製出來；每一塊 2 × 2 格（8px） */
        .accessory-flower {
          position: absolute;
          z-index: 1;
          width: 8px;
          height: 8px;
          background: var(--center-color);
          box-shadow:
            0 -8px 0 var(--petal-color),
            8px 0 0 var(--petal-color),
            0 8px 0 var(--petal-color),
            -8px 0 0 var(--petal-color);
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }
    '''),
    part('accessory', '勳章', 'html', 20, html='''
        <div class="accessory-medal"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-medal {
          --medal-color: #f2d16b;
          --ribbon-color: #6b8fb0;
          top: calc(var(--neck-y, 80%) - 14px);
          left: 5%;
        }

        /* 掛在胸口左邊，大小是身體寬度的 17%，用 aspect-ratio 保持方方正正 */
        .accessory-medal {
          position: absolute;
          width: 17%;
          aspect-ratio: 1;
          background: var(--medal-color);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
        }

        /* 上面的緞帶 2 × 3 格 */
        .accessory-medal::before {
          content: '';
          position: absolute;
          top: -16px;
          left: calc(50% - 4px);
          width: 8px;
          height: 12px;
          background: var(--ribbon-color);
        }

        /* 左上角一格白色反光 */
        .accessory-medal::after {
          content: '';
          position: absolute;
          top: 4px;
          left: 4px;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }
    '''),
    part('accessory', '背包', 'html', 20, html='''
        <div class="accessory-backpack"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-backpack {
          --bag-color: #6b8fb0;
          top: calc(var(--wing-y, 10%) + 10px);
          left: calc(-28px + var(--wing-x, 0px));
        }

        /* 只畫露在身體左邊的那一截 6 × 13 格，右邊貼著身體的框 */
        .accessory-backpack {
          position: absolute;
          width: 24px;
          height: 52px;
          background: var(--bag-color);
          border: 4px solid #4a3426;
          border-right: none;
          box-shadow: inset 4px 4px 0 rgb(255 255 255 / 30%);
        }

        /* 外面的口袋 3 × 3 格 */
        .accessory-backpack::after {
          content: '';
          position: absolute;
          top: 24px;
          left: 4px;
          width: 12px;
          height: 12px;
          background: rgb(46 34 26 / 20%);
          border: 4px solid #4a3426;
        }
    '''),
    part('accessory', '披風', 'css', 25, html='''
        <div class="accessory-cape"></div>
    ''', css='''
        /* 想換顏色，改這裡就好 */
        .accessory-cape {
          --cape-color: #c8553d;
        }

        /* 披風疊在身體外框上，border-radius: inherit 讓它跟身體同一個形狀 */
        /* 紅色用 box-shadow 畫：影子只畫在外框外面，身體那一塊永遠是空的，圓的、蛋形的身體也不會露白 */
        /* 不用 z-index: -1，身體做動畫的時候會變成自己一層，披風就會跑到身體前面 */
        .accessory-cape {
          position: absolute;
          top: -4px;
          left: -4px;
          width: calc(100% + 8px);
          height: calc(100% + 8px);
          border-radius: inherit;
          box-shadow: 0 0 0 40px var(--cape-color);
          clip-path: var(--cape-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從肩膀（身體 63% 的高度）開始，左右兩邊每往下一段就往外一格，一階一階張開 */
        .accessory-cape {
          --cape-shape: polygon(
            0 63%,
            0 72%,
            -4px 72%,
            -4px 81%,
            -8px 81%,
            -8px 90%,
            -12px 90%,
            -12px 100%,
            -16px 100%,
            -16px calc(100% + 12px),
            calc(100% + 16px) calc(100% + 12px),
            calc(100% + 16px) 100%,
            calc(100% + 12px) 100%,
            calc(100% + 12px) 90%,
            calc(100% + 8px) 90%,
            calc(100% + 8px) 81%,
            calc(100% + 4px) 81%,
            calc(100% + 4px) 72%,
            100% 72%,
            100% 63%
          );
        }
    '''),
    part('accessory', '小雨傘', 'html', 25, html='''
        <div class="accessory-umbrella"><span class="accessory-umbrella-top"></span></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-umbrella {
          --canopy-color: #c8553d;
          --stripe-color: #fbf8f1;
          top: calc(var(--wing-y, 10%) - 32px);
          left: calc(100% + 14px);
        }

        /* 本體是 1 格寬、14 格長的傘柄，最下面往左勾一格 */
        .accessory-umbrella {
          position: absolute;
          width: 4px;
          height: 56px;
          background: #4a3426;
        }

        .accessory-umbrella::after {
          content: '';
          position: absolute;
          bottom: 0;
          left: -4px;
          width: 4px;
          height: 4px;
          background: #4a3426;
        }

        /* 傘面 14 × 5 格，紅白直條紋；外框跟著剪出來的圓頂走 */
        .accessory-umbrella-top {
          position: absolute;
          top: -20px;
          left: -26px;
          width: 56px;
          height: 20px;
          /* 外框用 drop-shadow 往上下左右各畫一次 4px，會沿著形狀走 */
          filter:
            drop-shadow(4px 0 0 #4a3426)
            drop-shadow(-4px 0 0 #4a3426)
            drop-shadow(0 4px 0 #4a3426)
            drop-shadow(0 -4px 0 #4a3426);
        }

        .accessory-umbrella-top::before {
          content: '';
          position: absolute;
          inset: 0;
          background: repeating-linear-gradient(
            90deg,
            var(--canopy-color) 0 8px,
            var(--stripe-color) 8px 16px
          );
          clip-path: var(--canopy-shape);
        }

        /* 下面是剪出形狀的程式，想改形狀再研究 */
        /* 從左上開始順時針走一圈，每一行是一個轉角，左右兩邊一階一階收成圓頂 */
        .accessory-umbrella-top {
          --canopy-shape: polygon(
            16px 0,
            40px 0,
            40px 4px,
            48px 4px,
            48px 8px,
            52px 8px,
            52px 12px,
            56px 12px,
            56px 20px,
            0 20px,
            0 12px,
            4px 12px,
            4px 8px,
            8px 8px,
            8px 4px,
            16px 4px
          );
        }
    '''),
    part('accessory', '會飄的氣球', 'js', 60, html='''
        <div class="accessory-balloon"></div>
    ''', css='''
        /* 想換顏色、移位置，改這裡就好 */
        .accessory-balloon {
          --balloon-color: #c8553d;
          top: calc(var(--wing-y, 10%) - 60px);
          left: calc(100% + 4px);
        }

        /* 氣球 6 × 7 格 */
        .accessory-balloon {
          position: absolute;
          width: 24px;
          height: 28px;
          background: var(--balloon-color);
          /* 外框用 box-shadow 往上下左右各複製一次深棕色，四個角空出來，看起來就是像素風的圓 */
          box-shadow:
            0 -4px 0 #4a3426,
            0 4px 0 #4a3426,
            -4px 0 0 #4a3426,
            4px 0 0 #4a3426;
          cursor: pointer;
        }

        /* 左上角一格白色反光 */
        .accessory-balloon::before {
          content: '';
          position: absolute;
          top: 4px;
          left: 4px;
          width: 4px;
          height: 4px;
          background: #fbf8f1;
        }

        /* 綁在身體上的線，1 格寬 */
        .accessory-balloon::after {
          content: '';
          position: absolute;
          top: 32px;
          left: 10px;
          width: 4px;
          height: 60px;
          background: #4a3426;
        }

        /* 飄上去再慢慢回來；JS 只負責加上 rising */
        .accessory-balloon.rising {
          animation: balloon-rise 2.4s ease-in-out;
        }

        @keyframes balloon-rise {
          30% {
            translate: 0 -60px;
          }
        }
    ''', js='''
        // 點氣球讓它飄上去，再慢慢回到原本的位置；飄的動作寫在 CSS 的 .rising
        const balloon = document.querySelector('.accessory-balloon')
        balloon.addEventListener('click', (event) => {
          // 氣球長在身體裡，不擋住的話也會觸發身體的點擊
          event.stopPropagation()
          balloon.classList.add('rising')
        })

        // 動畫播完把 class 拿掉，下次才能再飄
        // 擋住不往上傳，不然身體收到 animationend 會把自己的 jump 也拿掉
        balloon.addEventListener('animationend', (event) => {
          event.stopPropagation()
          balloon.classList.remove('rising')
        })
    '''),
]


def check(parts):
    names = [p['name'] for p in parts]
    dupes = {n for n in names if names.count(n) > 1}
    assert not dupes, f'零件名稱重複：{dupes}'
    for p in parts:
        assert p['slot'] in dict(SLOTS), f'{p["name"]} 的部位不對'
        assert p['category'] in ('html', 'css', 'js'), f'{p["name"]} 的類別不對'
    for slot, label in SLOTS:
        count = sum(1 for p in parts if p['slot'] == slot)
        assert count == 9, f'{label}有 {count} 個零件，應該是 9 個'


def sql_str(text):
    """轉成 MySQL 字串：反斜線和單引號要跳脫"""
    return "'" + text.replace('\\', '\\\\').replace("'", "\\'") + "'"


def starter_code(p):
    return json.dumps({'html': p['html'], 'css': p['css'], 'js': p['js']}, ensure_ascii=False)


def build_sql(parts):
    lines = [
        '-- 合成獸零件 v2：9 個部位 × 9 種造型，共 81 個',
        '-- 要改零件請改 scripts/parts/parts.py，再執行一次輸出這個檔',
        '-- 可以重複執行：先依 name UPDATE，沒有這個名字才 INSERT，不會 DELETE（user_parts 有外鍵）',
        '-- 要先跑過 add-part-slots.sql',
        'SET NAMES utf8mb4;',
        'USE bug_clinic;',
        '',
    ]
    for p in parts:
        name = sql_str(p['name'])
        values = {
            'category': sql_str(p['category']),
            'slot': sql_str(p['slot']),
            'price': str(p['price']),
            'starter_code': sql_str(starter_code(p)),
        }
        sets = ', '.join(f'{k} = {v}' for k, v in values.items())
        lines.append(f'-- {p["slot"]}：{p["name"]}')
        lines.append(f'UPDATE parts SET {sets} WHERE name = {name};')
        lines.append(
            'INSERT INTO parts (name, category, slot, price, sprite, starter_code)\n'
            f'SELECT {name}, {values["category"]}, {values["slot"]}, {values["price"]}, '
            f'{sql_str(p["slot"] + ".svg")}, {values["starter_code"]}\n'
            f'FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM parts WHERE name = {name});'
        )
        lines.append('')
    lines.append('SELECT slot, COUNT(*) AS parts FROM parts GROUP BY slot;')
    return '\n'.join(lines) + '\n'


# 預覽頁：照前端 installPart、buildPage 的做法組出來

# 跟 components/ChimeraEditor.tsx 的 starterChimera 一樣
STARTER = {
    'html': '<div class="chimera">\n  <div class="body">\n    <!-- 零件裝在這裡 -->\n  </div>\n</div>',
    'css': code('''
        .chimera {
          position: relative;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
        }

        .body {
          --fur-color: #b4b2a9;
          position: relative;
          width: 120px;
          height: 100px;
          background: var(--fur-color);
          border: 4px solid #4a3426;
        }

        /* 立體感：左上亮一格、右下暗一格，畫在 .body::before，換毛色也一樣有效 */
        /* 不畫在 .body 的 box-shadow，留給玩家自己加影子；border-radius: inherit 讓身體改成圓的時候也跟著圓 */
        .body::before {
          content: '';
          position: absolute;
          inset: 0;
          border-radius: inherit;
          box-shadow:
            inset 4px 4px 0 rgb(251 248 241 / 45%),
            inset -4px -4px 0 rgb(46 34 26 / 25%);
          pointer-events: none;
        }

        /* 點一下往上跳再落下，改 -30px 調跳多高、改 0.4s 調多快 */
        .body.jump {
          animation: jump 0.4s ease-out;
        }

        @keyframes jump {
          50% {
            translate: 0 -30px;
          }
        }
    '''),
    'js': code('''
        // 點一下合成獸，牠會跳起來
        const body = document.querySelector('.body');

        body.addEventListener('click', () => {
          body.classList.add('jump');
        });

        // 動畫播完就把 class 拿掉，下次才能再跳
        body.addEventListener('animationend', () => {
          body.classList.remove('jump');
        });
    ''') + '\n',
}

PART_MARKER = '<!-- 零件裝在這裡 -->'


def install(chimera, p, part_id):
    tag = f'[{p["slot"]}:{part_id}]'
    result = dict(chimera)
    if p['html']:
        html = result['html']
        at = html.index(PART_MARKER)
        spaces = html[html.rindex('\n', 0, at) + 1:at]
        block = f'<!-- {tag} {p["name"]} 開始 -->\n{p["html"]}\n<!-- {tag} 結束 -->'
        block = block.replace('\n', '\n' + spaces)
        result['html'] = f'{html[:at]}{block}\n{spaces}{html[at:]}'
    if p['css']:
        result['css'] += f'\n\n/* {tag} {p["name"]} 開始 */\n{p["css"]}\n/* {tag} 結束 */'
    if p['js']:
        result['js'] += f'\n// {tag} {p["name"]} 開始\n{p["js"]}\n// {tag} 結束'
    return result


def build_page(chimera, extra_css=''):
    return (
        '<!doctype html>\n<html>\n<head>\n'
        f'<style>body {{ margin: 0; }} {chimera["css"]}{extra_css}</style>\n'
        f'</head>\n<body>\n{chimera["html"]}\n<script>{chimera["js"]}</script>\n</body>\n</html>'
    )


PREVIEW_CSS = '\n.chimera { transform: scale(0.55); }\nbody { overflow: hidden; }'

# 加上 --big 會用原本大小顯示，看細節比較清楚
if '--big' in sys.argv:
    PREVIEW_CSS = '\nbody { overflow: hidden; }'


def frame(page, title):
    return (
        f'<figure><iframe sandbox="allow-scripts" srcdoc="{html_lib.escape(page)}"></iframe>'
        f'<figcaption>{html_lib.escape(title)}</figcaption></figure>'
    )


def build_preview(parts):
    sections = []
    for slot, label in SLOTS:
        cards = [
            frame(build_page(install(STARTER, p, i), PREVIEW_CSS), p['name'])
            for i, p in enumerate(parts, 1)
            if p['slot'] == slot
        ]
        if cards:
            sections.append(f'<h2 id="{slot}">{label}</h2><div class="grid">{"".join(cards)}</div>')

    # 最後一排：每個部位挑一個一起裝，看會不會互相蓋到
    combos = []
    for pick in range(10):
        chimera = STARTER
        for slot, _ in SLOTS:
            same = [(i, p) for i, p in enumerate(parts, 1) if p['slot'] == slot]
            if same:
                i, p = same[pick % len(same)]
                chimera = install(chimera, p, i)
        combos.append(frame(build_page(chimera, PREVIEW_CSS), f'全部第 {pick + 1} 個'))
    sections.append(f'<h2 id="all">全部一起裝</h2><div class="grid">{"".join(combos)}</div>')

    # 指定幾個零件一起裝，用來檢查特定組合
    by_name = {p['name']: (i, p) for i, p in enumerate(parts, 1)}

    def combo(names):
        chimera = STARTER
        for name in names:
            i, p = by_name[name]
            chimera = install(chimera, p, i)
        return frame(build_page(chimera, PREVIEW_CSS), '＋'.join(names))

    behind = ['雲朵', '兔耳', '龍翼', '狐狸尾巴', '背包', '披風']
    moving = [combo(['會呼吸的身體', name]) for name in behind[1:]] + [combo(['雲朵', '會飛的翅膀'])]
    sections.append(f'<h2 id="moving">身體在動的時候</h2><div class="grid">{"".join(moving)}</div>')

    sizes = []
    for body in ['高高瘦瘦', '扁扁胖胖']:
        for pick in range(9):
            names = [body] + [
                [p['name'] for p in parts if p['slot'] == slot][pick]
                for slot, _ in SLOTS
                if slot not in ('body',)
            ]
            sizes.append(combo(names))
    sections.append(f'<h2 id="sizes">高高瘦瘦、扁扁胖胖</h2><div class="grid">{"".join(sizes)}</div>')

    width, height = (340, 260) if '--big' in sys.argv else (200, 150)
    style = (
        'body{font-family:sans-serif;background:#efe9dd;color:#4a3426;padding:16px}'
        f'.grid{{display:grid;grid-template-columns:repeat(auto-fill,{width}px);gap:12px}}'
        'figure{margin:0;background:#fbf8f1;border:3px solid #4a3426}'
        f'iframe{{display:block;width:{width}px;height:{height}px;border:0;background:#fff}}'
        'figcaption{padding:4px 8px;font-size:14px}'
    )
    return f'<!doctype html><meta charset="utf-8"><style>{style}</style>{"".join(sections)}'


# 檢查頁：每個部位一張表，橫的是 8 種身體，直的是這個部位的每一個零件
# 改了零件位置之後打開看一遍，哪個組合沒貼好身體一眼就看得出來
CHECK_BODIES = [None, '圓滾滾', '蛋形', '麵包', '高高瘦瘦', '扁扁胖胖', '布丁', '雲朵']


def build_check(parts):
    by_name = {p['name']: (i, p) for i, p in enumerate(parts, 1)}
    small = '\n.chimera { transform: scale(0.55); }\nbody { overflow: hidden; }'

    def cell(names):
        chimera = STARTER
        for name in names:
            i, p = by_name[name]
            chimera = install(chimera, p, i)
        page = build_page(chimera, small)
        # 576 格一次全部載入很慢，loading="lazy" 讓捲到附近才載入
        return f'<td><iframe loading="lazy" sandbox="allow-scripts" srcdoc="{html_lib.escape(page)}"></iframe></td>'

    head = '<tr><th></th>' + ''.join(f'<th>{body or "預設"}</th>' for body in CHECK_BODIES) + '</tr>'
    sections = []
    for slot, label in SLOTS:
        if slot == 'body':
            continue
        rows = [
            f'<tr><th>{p["name"]}</th>'
            + ''.join(cell(([body] if body else []) + [p['name']]) for body in CHECK_BODIES)
            + '</tr>'
            for p in parts
            if p['slot'] == slot
        ]
        sections.append(f'<h2 id="{slot}">{label}</h2><table>{head}{"".join(rows)}</table>')

    style = (
        'body{font-family:sans-serif;background:#efe9dd;color:#4a3426;padding:16px}'
        'table{border-collapse:collapse}th,td{padding:2px;font-size:13px}th{white-space:nowrap}'
        'iframe{display:block;width:150px;height:190px;border:1px solid #4a3426;background:#fff}'
    )
    return f'<!doctype html><meta charset="utf-8"><style>{style}</style>{"".join(sections)}'


def main():
    check(PARTS)
    SQL_PATH.write_text(build_sql(PARTS), encoding='utf-8')
    print(f'寫好 {SQL_PATH.relative_to(ROOT)}，共 {len(PARTS)} 個零件')

    if '--preview' in sys.argv:
        out = Path(sys.argv[sys.argv.index('--preview') + 1])
        out.write_text(build_preview(PARTS), encoding='utf-8')
        print(f'預覽頁：{out}')

    if '--check' in sys.argv:
        out = Path(sys.argv[sys.argv.index('--check') + 1])
        out.write_text(build_check(PARTS), encoding='utf-8')
        print(f'檢查頁：{out}')


if __name__ == '__main__':
    main()
