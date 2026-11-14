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
        .horn {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 24px);
          left: calc(50% - 10px);
          border-left: 10px solid transparent;
          border-right: 10px solid transparent;
          border-bottom: 24px solid #f3ead8;
        }
    '''),
    part('horn', '雙角', 'html', 15, html='''
        <div class="horn-twin left"></div>
        <div class="horn-twin right"></div>
    ''', css='''
        .horn-twin {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 22px);
          border-left: 9px solid transparent;
          border-right: 9px solid transparent;
          border-bottom: 22px solid #f3ead8;
        }

        .horn-twin.left {
          left: calc(50% - 42px);
        }

        .horn-twin.right {
          left: calc(50% + 24px);
        }
    '''),
    part('horn', '獨角獸角', 'css', 20, html='''
        <div class="horn-unicorn"></div>
    ''', css='''
        /* 用 clip-path 切成細長三角形，斜條紋是 repeating-linear-gradient */
        .horn-unicorn {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 50px);
          left: calc(50% - 8px);
          width: 16px;
          height: 50px;
          background: repeating-linear-gradient(160deg, #f3ead8 0 6px, #f2b8c6 6px 10px);
          clip-path: polygon(50% 0, 100% 100%, 0 100%);
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
        /* 一根直的主幹，加一根橫的分岔，分岔尾端再往上長一小段 */
        .horn-deer {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 42px);
          width: 6px;
          height: 40px;
          background: #8a5a3b;
        }

        .horn-deer.left {
          left: calc(50% - 34px);
        }

        .horn-deer.right {
          left: calc(50% + 28px);
        }

        .horn-deer-branch {
          position: absolute;
          top: 12px;
          width: 16px;
          height: 6px;
          background: #8a5a3b;
        }

        .horn-deer.left .horn-deer-branch {
          left: -16px;
        }

        .horn-deer.right .horn-deer-branch {
          left: 6px;
        }

        .horn-deer-branch::after {
          content: '';
          position: absolute;
          top: -12px;
          width: 6px;
          height: 12px;
          background: #8a5a3b;
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
        /* 圓圈只畫兩邊的邊框，就是一段彎月形 */
        .horn-ox {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 40px);
          width: 24px;
          height: 24px;
          border: 8px solid transparent;
          border-bottom-color: #f3ead8;
          border-radius: 50%;
        }

        .horn-ox.left {
          left: calc(50% - 74px);
          border-left-color: #f3ead8;
        }

        .horn-ox.right {
          left: calc(50% + 34px);
          border-right-color: #f3ead8;
        }
    '''),
    part('horn', '天線', 'html', 15, html='''
        <div class="horn-antenna"></div>
    ''', css='''
        .horn-antenna {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 34px);
          left: calc(50% - 2px);
          width: 4px;
          height: 30px;
          background: #4a3426;
        }

        .horn-antenna::after {
          content: '';
          position: absolute;
          top: -16px;
          left: -8px;
          width: 14px;
          height: 14px;
          background: #e8a33d;
          border: 3px solid #4a3426;
          border-radius: 50%;
        }
    '''),
    part('horn', '貓耳', 'html', 20, html='''
        <div class="horn-cat left"></div>
        <div class="horn-cat right"></div>
    ''', css='''
        /* 外面深棕色大三角，::after 疊一個粉紅小三角 */
        .horn-cat {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 30px);
          border-left: 18px solid transparent;
          border-right: 18px solid transparent;
          border-bottom: 28px solid #4a3426;
        }

        .horn-cat.left {
          left: calc(50% - 54px);
        }

        .horn-cat.right {
          left: calc(50% + 18px);
        }

        .horn-cat::after {
          content: '';
          position: absolute;
          top: 9px;
          left: -10px;
          border-left: 10px solid transparent;
          border-right: 10px solid transparent;
          border-bottom: 16px solid #f2b8c6;
        }
    '''),
    part('horn', '兔耳', 'html', 20, html='''
        <div class="horn-bunny left"></div>
        <div class="horn-bunny right"></div>
    ''', css='''
        .horn-bunny {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 66px);
          width: 22px;
          height: 60px;
          background: #f3ead8;
          border: 4px solid #4a3426;
          border-radius: 50%;
        }

        .horn-bunny.left {
          left: calc(50% - 42px);
          transform: rotate(-10deg);
        }

        .horn-bunny.right {
          left: calc(50% + 12px);
          transform: rotate(10deg);
        }

        .horn-bunny::after {
          content: '';
          position: absolute;
          top: 10px;
          left: 7px;
          width: 8px;
          height: 38px;
          background: #f2b8c6;
          border-radius: 50%;
        }
    '''),
    part('horn', '會變色的角', 'js', 50, html='''
        <div class="horn-color"></div>
    ''', css='''
        .horn-color {
          --horn-color: #f3ead8;
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) - 32px);
          left: calc(50% - 14px);
          border-left: 14px solid transparent;
          border-right: 14px solid transparent;
          border-bottom: 32px solid var(--horn-color);
          cursor: pointer;
          transition: border-color 0.3s;
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
        .eye {
          position: absolute;
          top: var(--eye-y, 30%);
          width: 14px;
          height: 14px;
          background: #2b1d14;
        }

        .eye.left {
          left: calc(50% - 32px);
        }

        .eye.right {
          left: calc(50% + 18px);
        }
    '''),
    part('eyes', '圓圓大眼', 'html', 15, html='''
        <div class="eye-round left"><span class="eye-round-pupil"></span></div>
        <div class="eye-round right"><span class="eye-round-pupil"></span></div>
    ''', css='''
        .eye-round {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 7px);
          width: 22px;
          height: 22px;
          background: #ffffff;
          border: 3px solid #4a3426;
          border-radius: 50%;
        }

        .eye-round.left {
          left: calc(50% - 38px);
        }

        .eye-round.right {
          left: calc(50% + 10px);
        }

        .eye-round-pupil {
          position: absolute;
          top: 7px;
          left: 7px;
          width: 10px;
          height: 10px;
          background: #2b1d14;
          border-radius: 50%;
        }
    '''),
    part('eyes', '瞇瞇眼', 'css', 15, html='''
        <div class="eye-squint left"></div>
        <div class="eye-squint right"></div>
    ''', css='''
        /* 圓角框拿掉下邊，剩一個彎弧 */
        .eye-squint {
          position: absolute;
          top: calc(var(--eye-y, 30%) + 2px);
          width: 16px;
          height: 8px;
          border: 4px solid #2b1d14;
          border-bottom: none;
          border-radius: 12px 12px 0 0;
        }

        .eye-squint.left {
          left: calc(50% - 34px);
        }

        .eye-squint.right {
          left: calc(50% + 10px);
        }
    '''),
    part('eyes', '獨眼', 'html', 20, html='''
        <div class="eye-cyclops"><span class="eye-cyclops-pupil"></span></div>
    ''', css='''
        .eye-cyclops {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 14px);
          left: calc(50% - 18px);
          width: 28px;
          height: 28px;
          background: #ffffff;
          border: 4px solid #4a3426;
          border-radius: 50%;
        }

        .eye-cyclops-pupil {
          position: absolute;
          top: 7px;
          left: 7px;
          width: 14px;
          height: 14px;
          background: #2b1d14;
          border-radius: 50%;
        }
    '''),
    part('eyes', '星星眼', 'html', 20, html='''
        <div class="eye-star left">★</div>
        <div class="eye-star right">★</div>
    ''', css='''
        .eye-star {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 10px);
          font-size: 24px;
          line-height: 1;
          color: #f5c542;
          -webkit-text-stroke: 1.5px #4a3426;
        }

        .eye-star.left {
          left: calc(50% - 38px);
        }

        .eye-star.right {
          left: calc(50% + 14px);
        }
    '''),
    part('eyes', '愛心眼', 'html', 20, html='''
        <div class="eye-heart left">♥</div>
        <div class="eye-heart right">♥</div>
    ''', css='''
        .eye-heart {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 10px);
          font-size: 24px;
          line-height: 1;
          color: #e0526b;
          -webkit-text-stroke: 1.5px #4a3426;
        }

        .eye-heart.left {
          left: calc(50% - 38px);
        }

        .eye-heart.right {
          left: calc(50% + 14px);
        }
    '''),
    part('eyes', '墨鏡', 'html', 25, html='''
        <div class="eye-shades">
          <span class="eye-shades-lens left"></span>
          <span class="eye-shades-lens right"></span>
        </div>
    ''', css='''
        /* 寬度是身體的 67%，鏡片和鼻樑也用百分比，跟著身體變寬變窄 */
        .eye-shades {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 6px);
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
          background: #2b1d14;
        }

        .eye-shades-lens {
          position: absolute;
          top: 0;
          width: 38%;
          height: 20px;
          background: #2b1d14;
          border-radius: 2px 2px 14px 14px;
        }

        .eye-shades-lens.left {
          left: 0;
        }

        .eye-shades-lens.right {
          right: 0;
        }

        /* 鏡片上的反光 */
        .eye-shades-lens::after {
          content: '';
          position: absolute;
          top: 4px;
          left: 5px;
          width: 8px;
          height: 3px;
          background: #ffffff;
        }
    '''),
    part('eyes', '會眨眼', 'css', 30, html='''
        <div class="eye-blink left"></div>
        <div class="eye-blink right"></div>
    ''', css='''
        /* 大部分時間睜開，96% 那一下壓扁就是眨眼 */
        .eye-blink {
          position: absolute;
          top: var(--eye-y, 30%);
          width: 14px;
          height: 14px;
          background: #2b1d14;
          animation: eye-blink 3s infinite;
        }

        .eye-blink.left {
          left: calc(50% - 32px);
        }

        .eye-blink.right {
          left: calc(50% + 18px);
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
        .eye-follow {
          position: absolute;
          top: calc(var(--eye-y, 30%) - 8px);
          width: 24px;
          height: 24px;
          background: #ffffff;
          border: 3px solid #4a3426;
          border-radius: 50%;
        }

        .eye-follow.left {
          left: calc(50% - 38px);
        }

        .eye-follow.right {
          left: calc(50% + 8px);
        }

        .eye-follow-pupil {
          position: absolute;
          top: 7px;
          left: 7px;
          width: 10px;
          height: 10px;
          background: #2b1d14;
          border-radius: 50%;
        }
    ''', js='''
        // 算出滑鼠在眼睛的哪個方向，眼珠往那邊移 6px
        const followEyes = document.querySelectorAll('.eye-follow')
        document.addEventListener('mousemove', (e) => {
          followEyes.forEach((eye) => {
            const rect = eye.getBoundingClientRect()
            const angle = Math.atan2(
              e.clientY - (rect.top + rect.height / 2),
              e.clientX - (rect.left + rect.width / 2),
            )
            const pupil = eye.querySelector('.eye-follow-pupil')
            pupil.style.transform = `translate(${Math.cos(angle) * 6}px, ${Math.sin(angle) * 6}px)`
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
        .tooth {
          position: absolute;
          top: calc(var(--mouth-y, 60%) + 6px);
          border-left: 6px solid transparent;
          border-right: 6px solid transparent;
          border-top: 12px solid #ffffff;
        }

        .tooth.left {
          left: calc(50% - 18px);
        }

        .tooth.right {
          left: calc(50% + 6px);
        }
    '''),
    part('mouth', '微笑', 'css', 10, html='''
        <div class="mouth-smile"></div>
    ''', css='''
        /* 框拿掉上邊、下面兩角變圓，就是微笑的弧 */
        .mouth-smile {
          position: absolute;
          top: var(--mouth-y, 60%);
          left: calc(50% - 19px);
          width: 30px;
          height: 12px;
          border: 4px solid #2b1d14;
          border-top: none;
          border-radius: 0 0 20px 20px;
        }
    '''),
    part('mouth', '大嘴巴', 'html', 15, html='''
        <div class="mouth-big"><span class="mouth-big-tongue"></span></div>
    ''', css='''
        .mouth-big {
          position: absolute;
          top: calc(var(--mouth-y, 60%) - 4px);
          left: calc(50% - 25px);
          width: 44px;
          height: 22px;
          background: #4a1f1a;
          border: 3px solid #2b1d14;
          border-radius: 0 0 24px 24px;
          overflow: hidden;
        }

        .mouth-big-tongue {
          position: absolute;
          bottom: -6px;
          left: 11px;
          width: 22px;
          height: 14px;
          background: #e0526b;
          border-radius: 50%;
        }
    '''),
    part('mouth', '吐舌頭', 'html', 15, html='''
        <div class="mouth-tongue"><span class="mouth-tongue-tip"></span></div>
    ''', css='''
        .mouth-tongue {
          position: absolute;
          top: calc(var(--mouth-y, 60%) + 4px);
          left: calc(50% - 16px);
          width: 32px;
          height: 4px;
          background: #2b1d14;
        }

        .mouth-tongue-tip {
          position: absolute;
          top: 4px;
          left: 12px;
          width: 12px;
          height: 14px;
          background: #e0526b;
          border: 3px solid #4a3426;
          border-top: none;
          border-radius: 0 0 10px 10px;
        }
    '''),
    part('mouth', '鳥嘴', 'css', 15, html='''
        <div class="mouth-beak"></div>
    ''', css='''
        .mouth-beak {
          position: absolute;
          top: calc(var(--mouth-y, 60%) - 4px);
          left: calc(50% - 18px);
          border-left: 18px solid transparent;
          border-right: 18px solid transparent;
          border-top: 26px solid #e8a33d;
        }
    '''),
    part('mouth', '吸血鬼牙', 'html', 20, html='''
        <div class="mouth-vampire"></div>
    ''', css='''
        /* 一條嘴巴線，兩顆尖牙用 ::before ::after 畫 */
        .mouth-vampire {
          position: absolute;
          top: calc(var(--mouth-y, 60%) + 2px);
          left: calc(50% - 18px);
          width: 36px;
          height: 4px;
          background: #2b1d14;
        }

        .mouth-vampire::before,
        .mouth-vampire::after {
          content: '';
          position: absolute;
          top: 4px;
          border-left: 5px solid transparent;
          border-right: 5px solid transparent;
          border-top: 18px solid #ffffff;
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
        .mouth-whisker {
          position: absolute;
          top: calc(var(--mouth-y, 60%) - 8px);
          width: 40px;
        }

        /* 從身體左右邊緣往內 30px 長出來，露在外面 10px，身體變寬變窄都一樣 */
        .mouth-whisker.left {
          left: -10px;
        }

        .mouth-whisker.right {
          left: calc(100% - 30px);
        }

        .mouth-whisker span {
          display: block;
          height: 2px;
          margin: 6px 0;
          background: #2b1d14;
        }

        .mouth-whisker.left span:first-child,
        .mouth-whisker.right span:last-child {
          transform: rotate(10deg);
        }

        .mouth-whisker.left span:last-child,
        .mouth-whisker.right span:first-child {
          transform: rotate(-10deg);
        }
    '''),
    part('mouth', 'O 型嘴', 'css', 10, html='''
        <div class="mouth-o"></div>
    ''', css='''
        .mouth-o {
          position: absolute;
          top: var(--mouth-y, 60%);
          left: calc(50% - 11px);
          width: 14px;
          height: 14px;
          border: 4px solid #2b1d14;
          border-radius: 50%;
        }
    '''),
    part('mouth', '會說話的嘴', 'js', 60, html='''
        <div class="mouth-talk"></div>
        <div class="mouth-bubble"></div>
    ''', css='''
        .body {
          cursor: pointer;
        }

        .mouth-talk {
          position: absolute;
          top: calc(var(--mouth-y, 60%) + 4px);
          left: calc(50% - 12px);
          width: 24px;
          height: 6px;
          background: #2b1d14;
          border-radius: 0 0 12px 12px;
        }

        .mouth-talk.talking {
          animation: mouth-talk 0.15s infinite alternate;
        }

        @keyframes mouth-talk {
          to {
            height: 14px;
          }
        }

        .mouth-bubble {
          position: absolute;
          top: calc(var(--horn-y, 0%) - 50px);
          left: calc(50% + 30px);
          padding: 6px 10px;
          background: #ffffff;
          border: 3px solid #4a3426;
          border-radius: 10px;
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
        /* 斑紋：改 --fur-color 換底色，改 rgba 的透明度調斑紋深淺 */
        .body {
          --fur-color: #e8a33d;
          background-image: repeating-linear-gradient(
            45deg,
            transparent 0 10px,
            rgba(0, 0, 0, 0.15) 10px 20px
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
        .wing {
          --wing-color: #85b7eb;
          position: absolute;
          top: var(--wing-y, 10%);
          left: calc(-70px + var(--wing-x, 0px));
          width: 64px;
          height: 40px;
          background: var(--wing-color);
          border: 4px solid #4a3426;
          border-radius: 40px 4px 40px 4px;
        }
    '''),
    part('wings', '一對小翅膀', 'html', 30, html='''
        <div class="wing-pair left"></div>
        <div class="wing-pair right"></div>
    ''', css='''
        .wing-pair {
          position: absolute;
          top: calc(var(--wing-y, 10%) + 2px);
          width: 40px;
          height: 28px;
          background: #85b7eb;
          border: 4px solid #4a3426;
        }

        .wing-pair.left {
          left: calc(-48px + var(--wing-x, 0px));
          border-radius: 30px 4px 30px 4px;
        }

        .wing-pair.right {
          left: calc(100% - var(--wing-x, 0px));
          border-radius: 4px 30px 4px 30px;
        }
    '''),
    part('wings', '天使翅膀', 'html', 35, html='''
        <div class="wing-angel left"><span></span><span></span><span></span></div>
        <div class="wing-angel right"><span></span><span></span><span></span></div>
    ''', css='''
        /* 三片白色羽毛由長到短往下疊 */
        .wing-angel {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 10px);
          width: 62px;
          height: 60px;
        }

        .wing-angel.left {
          left: calc(-62px + var(--wing-x, 0px));
        }

        .wing-angel.right {
          left: calc(100% - var(--wing-x, 0px));
          transform: scaleX(-1);
        }

        .wing-angel span {
          position: absolute;
          right: 0;
          height: 14px;
          background: #ffffff;
          border: 3px solid #4a3426;
          border-radius: 14px 4px 4px 14px;
        }

        .wing-angel span:nth-child(1) {
          top: 0;
          width: 54px;
        }

        .wing-angel span:nth-child(2) {
          top: 17px;
          width: 44px;
        }

        .wing-angel span:nth-child(3) {
          top: 34px;
          width: 32px;
        }
    '''),
    part('wings', '蝙蝠翅膀', 'css', 35, html='''
        <div class="wing-bat left"></div>
        <div class="wing-bat right"></div>
    ''', css='''
        /* clip-path 的點從身體那側開始，繞一圈切出下緣的鋸齒 */
        .wing-bat {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 4px);
          width: 72px;
          height: 46px;
          background: #3b2a3f;
          clip-path: polygon(
            100% 20%,
            35% 0,
            0 30%,
            12% 100%,
            26% 72%,
            42% 100%,
            56% 72%,
            72% 100%,
            86% 72%,
            100% 82%
          );
        }

        .wing-bat.left {
          left: calc(-70px + var(--wing-x, 0px));
        }

        .wing-bat.right {
          left: calc(100% - 2px - var(--wing-x, 0px));
          transform: scaleX(-1);
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
        .wing-butterfly {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 12px);
          width: 56px;
          height: 80px;
        }

        .wing-butterfly.left {
          left: calc(-56px + var(--wing-x, 0px));
        }

        .wing-butterfly.right {
          left: calc(100% - var(--wing-x, 0px));
          transform: scaleX(-1);
        }

        .wing-butterfly span {
          position: absolute;
          border: 3px solid #4a3426;
          border-radius: 50%;
        }

        .wing-butterfly-top {
          top: 0;
          left: 0;
          width: 48px;
          height: 42px;
          background: radial-gradient(circle at 40% 45%, #ffffff 0 6px, transparent 7px), #f2a541;
        }

        .wing-butterfly-bottom {
          top: 40px;
          left: 14px;
          width: 34px;
          height: 32px;
          background: #9b7fd1;
        }
    '''),
    part('wings', '蜻蜓翅膀', 'css', 30, html='''
        <div class="wing-dragonfly left"></div>
        <div class="wing-dragonfly right"></div>
    ''', css='''
        /* 前翅是本體，後翅用 ::after 畫在下面 */
        .wing-dragonfly,
        .wing-dragonfly::after {
          position: absolute;
          height: 14px;
          background: rgba(180, 220, 240, 0.6);
          border: 2px solid rgba(74, 52, 38, 0.6);
          border-radius: 50%;
        }

        .wing-dragonfly {
          top: var(--wing-y, 10%);
          width: 84px;
          transform-origin: right center;
          transform: rotate(12deg);
        }

        .wing-dragonfly.left {
          left: calc(-86px + var(--wing-x, 0px));
        }

        .wing-dragonfly.right {
          left: calc(100% - 2px - var(--wing-x, 0px));
          transform-origin: left center;
          transform: rotate(-12deg);
        }

        .wing-dragonfly::after {
          content: '';
          top: 18px;
          width: 72px;
          transform: rotate(-18deg);
        }

        .wing-dragonfly.left::after {
          right: 0;
          transform-origin: right center;
        }

        .wing-dragonfly.right::after {
          left: 0;
          transform-origin: left center;
          transform: rotate(18deg);
        }
    '''),
    part('wings', '龍翼', 'css', 40, html='''
        <div class="wing-dragon left"><span></span></div>
        <div class="wing-dragon right"><span></span></div>
    ''', css='''
        /* clip-path 切掉的地方畫不出邊框，所以外層深色、裡面縮 4px 疊淺色，看起來像有框 */
        .wing-dragon,
        .wing-dragon span {
          clip-path: polygon(
            100% 30%,
            60% 0,
            0 8%,
            16% 42%,
            4% 100%,
            34% 74%,
            50% 100%,
            64% 72%,
            80% 94%,
            100% 70%
          );
        }

        .wing-dragon {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 24px);
          width: 100px;
          height: 82px;
          background: #4a3426;
        }

        .wing-dragon.left {
          left: calc(-104px + var(--wing-x, 0px));
        }

        .wing-dragon.right {
          left: calc(100% + 4px - var(--wing-x, 0px));
          transform: scaleX(-1);
        }

        .wing-dragon span {
          position: absolute;
          inset: 4px;
          background: #5a9a4a;
        }
    '''),
    part('wings', '拍拍翅膀', 'css', 45, html='''
        <div class="wing-flap left"></div>
        <div class="wing-flap right"></div>
    ''', css='''
        /* transform-origin 設在靠身體那一側，旋轉起來才像在拍 */
        .wing-flap {
          position: absolute;
          top: var(--wing-y, 10%);
          width: 50px;
          height: 32px;
          background: #85b7eb;
          border: 4px solid #4a3426;
        }

        .wing-flap.left {
          left: calc(-60px + var(--wing-x, 0px));
          border-radius: 32px 4px 32px 4px;
          transform-origin: right center;
          animation: wing-flap-left 0.5s ease-in-out infinite alternate;
        }

        .wing-flap.right {
          left: calc(100% + 2px - var(--wing-x, 0px));
          border-radius: 4px 32px 4px 32px;
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
    '''),
    part('wings', '會飛的翅膀', 'js', 70, html='''
        <div class="wing-fly left"></div>
        <div class="wing-fly right"></div>
    ''', css='''
        .wing-fly {
          position: absolute;
          top: var(--wing-y, 10%);
          width: 50px;
          height: 32px;
          background: #f3ead8;
          border: 4px solid #4a3426;
          cursor: pointer;
        }

        .wing-fly.left {
          left: calc(-60px + var(--wing-x, 0px));
          border-radius: 32px 4px 32px 4px;
          transform-origin: right center;
        }

        .wing-fly.right {
          left: calc(100% + 2px - var(--wing-x, 0px));
          border-radius: 4px 32px 4px 32px;
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
        .tail {
          position: absolute;
          top: var(--tail-y, 60%);
          left: calc(100% + 4px);
          width: 50px;
          height: 12px;
          background: #4a3426;
          transform-origin: left center;
          cursor: pointer;
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
        .tail-pompom {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 6px);
          left: calc(100% - 4px);
          width: 24px;
          height: 24px;
          background: #f3ead8;
          border: 4px solid #4a3426;
          border-radius: 50%;
        }
    '''),
    part('tail', '捲捲尾巴', 'css', 15, html='''
        <div class="tail-curly"></div>
    ''', css='''
        /* 圓圈少畫一邊，看起來就是捲起來的豬尾巴 */
        .tail-curly {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 12px);
          left: calc(100% + 12px);
          width: 18px;
          height: 18px;
          border: 5px solid #e89aa8;
          border-left-color: transparent;
          border-radius: 50%;
        }

        /* 接回身體的那一小段 */
        .tail-curly::before {
          content: '';
          position: absolute;
          top: 13px;
          left: -13px;
          width: 12px;
          height: 5px;
          background: #e89aa8;
        }
    '''),
    part('tail', '狐狸尾巴', 'css', 25, html='''
        <div class="tail-fox"></div>
    ''', css='''
        /* 尾端白色是漸層硬切出來的 */
        .tail-fox {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 16px);
          left: 100%;
          width: 72px;
          height: 34px;
          background: linear-gradient(90deg, #e07b39 70%, #ffffff 70%);
          border: 4px solid #4a3426;
          border-radius: 10px 40px 40px 10px / 10px 30px 30px 10px;
          transform-origin: left center;
          transform: rotate(-25deg);
        }
    '''),
    part('tail', '惡魔尾巴', 'html', 20, html='''
        <div class="tail-devil"></div>
    ''', css='''
        .tail-devil {
          position: absolute;
          top: calc(var(--tail-y, 60%) + 6px);
          left: calc(100% + 4px);
          width: 56px;
          height: 4px;
          background: #4a3426;
          transform-origin: left center;
          transform: rotate(-20deg);
        }

        /* 尾端的箭頭 */
        .tail-devil::after {
          content: '';
          position: absolute;
          top: -7px;
          right: -14px;
          border-top: 9px solid transparent;
          border-bottom: 9px solid transparent;
          border-left: 16px solid #c8553d;
        }
    '''),
    part('tail', '魚尾巴', 'css', 20, html='''
        <div class="tail-fish"></div>
    ''', css='''
        .tail-fish {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 18px);
          left: calc(100% + 2px);
          width: 40px;
          height: 46px;
          background: #5aa9e6;
          clip-path: polygon(0 40%, 100% 0, 72% 50%, 100% 100%, 0 60%);
        }
    '''),
    part('tail', '閃電尾巴', 'css', 25, html='''
        <div class="tail-bolt"></div>
    ''', css='''
        /* 照 clip-path 的點連起來就是閃電的形狀 */
        .tail-bolt {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 30px);
          left: calc(100% + 2px);
          width: 66px;
          height: 52px;
          background: #f5c542;
          clip-path: polygon(0 45%, 48% 20%, 42% 45%, 100% 5%, 60% 85%, 66% 58%, 0 80%);
        }
    '''),
    part('tail', '恐龍尾巴', 'css', 25, html='''
        <div class="tail-dino"></div>
    ''', css='''
        /* 下緣是一條斜線，上緣的點一高一低就是背刺 */
        .tail-dino {
          position: absolute;
          top: calc(var(--tail-y, 60%) - 18px);
          left: 100%;
          width: 88px;
          height: 40px;
          background: #5a9a4a;
          clip-path: polygon(
            0 40%,
            14% 40%,
            20% 10%,
            28% 44%,
            40% 52%,
            46% 26%,
            54% 58%,
            66% 64%,
            71% 46%,
            77% 72%,
            100% 88%,
            0 100%
          );
        }
    '''),
    part('tail', '會長大的尾巴', 'js', 50, html='''
        <div class="tail-grow"></div>
    ''', css='''
        .tail-grow {
          position: absolute;
          top: var(--tail-y, 60%);
          left: calc(100% + 4px);
          width: 30px;
          height: 12px;
          background: #4a3426;
          border-radius: 0 6px 6px 0;
          cursor: pointer;
          transition: width 0.3s;
        }
    ''', js='''
        // 每點一下變長 20px，超過 130px 就變回原本的 30px
        const growTail = document.querySelector('.tail-grow')
        let growLength = 30
        growTail.addEventListener('click', (event) => {
          // 尾巴長在身體裡，不擋住的話也會觸發身體的點擊
          event.stopPropagation()
          growLength = growLength >= 130 ? 30 : growLength + 20
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
        .feet-short {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 20px;
          height: 16px;
          background: #4a3426;
        }

        .feet-short.left {
          left: 16.67%;
        }

        .feet-short.right {
          right: 16.67%;
        }
    '''),
    part('feet', '肉球腳掌', 'html', 15, html='''
        <div class="feet-paw left"></div>
        <div class="feet-paw right"></div>
    ''', css='''
        .feet-paw {
          position: absolute;
          z-index: 1;
          top: var(--leg-y, 100%);
          width: 26px;
          height: 18px;
          background: #f3ead8;
          border: 3px solid #4a3426;
          border-radius: 50% 50% 40% 40%;
        }

        .feet-paw.left {
          left: 11.67%;
        }

        .feet-paw.right {
          right: 11.67%;
        }

        /* 底下的粉紅肉球 */
        .feet-paw::after {
          content: '';
          position: absolute;
          bottom: 2px;
          left: 7px;
          width: 12px;
          height: 7px;
          background: #f2b8c6;
          border-radius: 50%;
        }
    '''),
    part('feet', '長腿', 'html', 20, html='''
        <div class="feet-long left"></div>
        <div class="feet-long right"></div>
    ''', css='''
        .feet-long {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 8px;
          height: 38px;
          background: #4a3426;
        }

        .feet-long.left {
          left: 21.67%;
        }

        .feet-long.right {
          right: 21.67%;
        }

        /* 腳掌往外側伸出去 */
        .feet-long::after {
          content: '';
          position: absolute;
          bottom: 0;
          width: 16px;
          height: 6px;
          background: #4a3426;
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
        .feet-duck {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 6px;
          height: 10px;
          background: #e8a33d;
        }

        .feet-duck.left {
          left: 22.5%;
        }

        .feet-duck.right {
          right: 22.5%;
        }

        /* 扇形的蹼，下緣切成三個尖 */
        .feet-duck::after {
          content: '';
          position: absolute;
          top: 8px;
          left: -12px;
          width: 30px;
          height: 14px;
          background: #e8a33d;
          clip-path: polygon(50% 0, 100% 100%, 75% 80%, 50% 100%, 25% 80%, 0 100%);
        }
    '''),
    part('feet', '馬蹄', 'html', 20, html='''
        <div class="feet-hoof left"><span class="feet-hoof-tip"></span></div>
        <div class="feet-hoof right"><span class="feet-hoof-tip"></span></div>
    ''', css='''
        .feet-hoof {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 16px;
          height: 22px;
          background: #b98b62;
        }

        .feet-hoof.left {
          left: 18.33%;
        }

        .feet-hoof.right {
          right: 18.33%;
        }

        .feet-hoof-tip {
          position: absolute;
          bottom: -8px;
          left: -2px;
          width: 20px;
          height: 8px;
          background: #2b1d14;
        }
    '''),
    part('feet', '章魚觸手', 'css', 25, html='''
        <div class="feet-octopus"><span></span><span></span><span></span><span></span></div>
    ''', css='''
        /* 每條觸手只畫兩個邊再把角弄圓，就是一條彎彎的線；左右兩邊往外彎 */
        /* 整排寬度是身體的 83%，身體變寬觸手會分開一點 */
        .feet-octopus {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 2px);
          left: 8.5%;
          width: 83%;
          display: flex;
          justify-content: space-between;
        }

        .feet-octopus span {
          width: 14px;
          height: 26px;
          border-bottom: 6px solid #c97ca0;
        }

        .feet-octopus span:nth-child(-n + 2) {
          border-left: 6px solid #c97ca0;
          border-radius: 0 0 0 16px;
        }

        .feet-octopus span:nth-child(n + 3) {
          border-right: 6px solid #c97ca0;
          border-radius: 0 0 16px 0;
        }
    '''),
    part('feet', '輪子', 'html', 25, html='''
        <div class="feet-wheel-axle"></div>
        <div class="feet-wheel left"></div>
        <div class="feet-wheel right"></div>
    ''', css='''
        /* 輪軸是身體寬度的一半，兩個輪子裝在輪軸兩端 */
        .feet-wheel-axle {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 18px);
          left: 25%;
          width: 50%;
          height: 4px;
          background: #4a3426;
        }

        .feet-wheel {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 26px;
          height: 26px;
          background: #2b1d14;
          border: 3px solid #4a3426;
          border-radius: 50%;
        }

        .feet-wheel.left {
          left: calc(25% - 16px);
        }

        .feet-wheel.right {
          right: calc(25% - 16px);
        }

        /* 輪子中間的輪框 */
        .feet-wheel::after {
          content: '';
          position: absolute;
          top: 8px;
          left: 8px;
          width: 10px;
          height: 10px;
          background: #b4b2a9;
          border-radius: 50%;
        }
    '''),
    part('feet', '彈簧腳', 'css', 30, html='''
        <div class="feet-spring left"></div>
        <div class="feet-spring right"></div>
    ''', css='''
        /* 斜斜的條紋疊起來像一圈一圈的彈簧，::after 是底下的腳墊 */
        .feet-spring {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 16px;
          height: 30px;
          background: repeating-linear-gradient(
            160deg,
            transparent 0 3px,
            #6f6a64 3px 6px
          );
        }

        .feet-spring.left {
          left: 18.33%;
        }

        .feet-spring.right {
          right: 18.33%;
        }

        .feet-spring::after {
          content: '';
          position: absolute;
          bottom: -6px;
          left: -4px;
          width: 24px;
          height: 6px;
          background: #4a3426;
        }
    '''),
    part('feet', '會走路的腳', 'js', 60, html='''
        <div class="feet-walk left"></div>
        <div class="feet-walk right"></div>
    ''', css='''
        .feet-walk {
          position: absolute;
          z-index: 1;
          top: calc(var(--leg-y, 100%) + 4px);
          width: 16px;
          height: 22px;
          background: #4a3426;
          cursor: pointer;
        }

        .feet-walk.left {
          left: 18.33%;
        }

        .feet-walk.right {
          right: 18.33%;
        }

        /* 走路時兩隻腳輪流抬起來，右腳晚半拍；JS 只負責加上、拿掉 walking */
        .body.walking .feet-walk {
          animation: feet-step 0.6s ease-in-out infinite;
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
        /* 左右兩個三角形對在一起，中間的 span 是結；寬度是身體的 28%，身體變寬領結也跟著變寬 */
        .accessory-bowtie {
          position: absolute;
          top: calc(var(--neck-y, 80%) - 4px);
          left: 36%;
          width: 28%;
          height: 18px;
        }

        /* 三角形用 clip-path 切，寬度用百分比才會跟著領結變寬 */
        .accessory-bowtie::before,
        .accessory-bowtie::after {
          content: '';
          position: absolute;
          top: 0;
          width: 50%;
          height: 100%;
          background: #c8553d;
        }

        .accessory-bowtie::before {
          left: 0;
          clip-path: polygon(0 0, 100% 50%, 0 100%);
        }

        .accessory-bowtie::after {
          right: 0;
          clip-path: polygon(100% 0, 0 50%, 100% 100%);
        }

        .accessory-bowtie span {
          position: absolute;
          top: 4px;
          left: calc(50% - 5px);
          width: 10px;
          height: 10px;
          background: #9c3f2c;
        }
    '''),
    part('accessory', '圍巾', 'css', 15, html='''
        <div class="accessory-scarf"></div>
    ''', css='''
        /* 橫的一條繞在身體上，::after 是垂下來的那一端 */
        .accessory-scarf {
          position: absolute;
          top: calc(var(--neck-y, 80%) + 4px);
          left: -4px;
          width: calc(100% + 8px);
          height: 12px;
          background: repeating-linear-gradient(90deg, #5a9a4a 0 10px, #f3ead8 10px 14px);
          border-top: 3px solid #4a3426;
          border-bottom: 3px solid #4a3426;
        }

        .accessory-scarf::after {
          content: '';
          position: absolute;
          top: 8px;
          right: 14px;
          width: 14px;
          height: 34px;
          background: repeating-linear-gradient(#5a9a4a 0 10px, #f3ead8 10px 14px);
          border: 3px solid #4a3426;
          transform: rotate(8deg);
        }
    '''),
    part('accessory', '項鍊', 'html', 15, html='''
        <div class="accessory-necklace"></div>
    ''', css='''
        /* dotted 邊框剛好是一顆一顆的珠子，::after 是墜子；寬度是身體的 53%，跟著身體變寬 */
        .accessory-necklace {
          position: absolute;
          top: calc(var(--neck-y, 80%) - 16px);
          left: calc(23.5% - 4px);
          width: 53%;
          height: 16px;
          border: 4px dotted #f3ead8;
          border-top: none;
          border-radius: 0 0 40px 40px;
        }

        .accessory-necklace::after {
          content: '';
          position: absolute;
          bottom: -11px;
          left: calc(50% - 8px);
          width: 12px;
          height: 12px;
          background: #e8a33d;
          border: 2px solid #4a3426;
          border-radius: 50%;
        }
    '''),
    part('accessory', '小花', 'html', 15, html='''
        <div class="accessory-flower"></div>
    ''', css='''
        /* 中間是花心，四片花瓣用 box-shadow 複製出來 */
        .accessory-flower {
          position: absolute;
          z-index: 1;
          top: calc(var(--horn-y, 0%) + 6px);
          left: calc(50% + 38px);
          width: 10px;
          height: 10px;
          background: #f5c542;
          border-radius: 50%;
          box-shadow:
            0 -9px 0 #f2b8c6,
            9px 0 0 #f2b8c6,
            0 9px 0 #f2b8c6,
            -9px 0 0 #f2b8c6;
        }
    '''),
    part('accessory', '勳章', 'html', 20, html='''
        <div class="accessory-medal">★</div>
    ''', css='''
        /* 掛在胸口左邊，大小是身體寬度的 17%，用 aspect-ratio 保持圓形 */
        .accessory-medal {
          position: absolute;
          top: calc(var(--neck-y, 80%) - 14px);
          left: 5%;
          display: flex;
          justify-content: center;
          align-items: center;
          width: 17%;
          aspect-ratio: 1;
          background: #f5c542;
          border: 3px solid #4a3426;
          border-radius: 50%;
          color: #c8553d;
          font-size: 14px;
        }

        /* 上面的緞帶 */
        .accessory-medal::before {
          content: '';
          position: absolute;
          top: -14px;
          left: calc(50% - 6px);
          width: 12px;
          height: 12px;
          background: #5aa9e6;
        }
    '''),
    part('accessory', '背包', 'html', 20, html='''
        <div class="accessory-backpack"></div>
    ''', css='''
        /* 只畫露在身體左邊的那一截，右邊貼著身體的框 */
        .accessory-backpack {
          position: absolute;
          top: calc(var(--wing-y, 10%) + 10px);
          left: calc(-32px + var(--wing-x, 0px));
          width: 25px;
          height: 54px;
          background: #6b8fb0;
          border: 3px solid #4a3426;
          border-right: none;
          border-radius: 10px 0 0 10px;
        }

        /* 外面的口袋 */
        .accessory-backpack::after {
          content: '';
          position: absolute;
          top: 24px;
          left: 3px;
          width: 14px;
          height: 16px;
          background: #4f7091;
          border: 2px solid #4a3426;
          border-radius: 4px;
        }
    '''),
    part('accessory', '披風', 'css', 25, html='''
        <div class="accessory-cape"></div>
    ''', css='''
        /* 披風疊在身體外框上，border-radius: inherit 讓它跟身體同一個形狀 */
        /* 紅色用 box-shadow 畫：影子只畫在外框外面，身體那一塊永遠是空的，圓的、蛋形的身體也不會露白 */
        /* 再用 clip-path 切成從肩膀往下張開的梯形 */
        /* 不用 z-index: -1，身體做動畫的時候會變成自己一層，披風就會跑到身體前面 */
        .accessory-cape {
          position: absolute;
          top: -4px;
          left: -4px;
          width: calc(100% + 8px);
          height: calc(100% + 8px);
          border-radius: inherit;
          box-shadow: 0 0 0 40px #c8553d;
          clip-path: polygon(0 63%, -16px calc(100% + 12px), calc(100% + 16px) calc(100% + 12px), 100% 63%);
        }
    '''),
    part('accessory', '小雨傘', 'html', 25, html='''
        <div class="accessory-umbrella"></div>
    ''', css='''
        /* 上半圓是傘面，::after 是傘柄 */
        .accessory-umbrella {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 52px);
          left: calc(100% - 12px);
          width: 56px;
          height: 28px;
          background: repeating-linear-gradient(90deg, #e0526b 0 14px, #ffffff 14px 28px);
          border: 3px solid #4a3426;
          border-bottom: none;
          border-radius: 56px 56px 0 0;
        }

        .accessory-umbrella::after {
          content: '';
          position: absolute;
          top: 28px;
          left: 26px;
          width: 4px;
          height: 56px;
          background: #4a3426;
        }
    '''),
    part('accessory', '會飄的氣球', 'js', 60, html='''
        <div class="accessory-balloon"></div>
    ''', css='''
        .accessory-balloon {
          position: absolute;
          top: calc(var(--wing-y, 10%) - 60px);
          left: calc(100% + 2px);
          width: 30px;
          height: 36px;
          background: #e0526b;
          border: 3px solid #4a3426;
          border-radius: 50%;
          cursor: pointer;
        }

        /* 綁在身體上的線 */
        .accessory-balloon::after {
          content: '';
          position: absolute;
          top: 36px;
          left: 14px;
          width: 2px;
          height: 62px;
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
        return f'<td><iframe sandbox="allow-scripts" srcdoc="{html_lib.escape(page)}"></iframe></td>'

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
