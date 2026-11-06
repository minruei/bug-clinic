-- 合成獸實驗室的零件：HTML 三個、CSS 兩個、JS 一個
-- starter_code 存成 JSON 文字，分成 html、css、js 三段，裝上時各自加進編輯器對應的格子
-- 像素圖檔名先佔位，之後用 sprites.py 畫好再放進 public/pixel/
SET NAMES utf8mb4;
USE bug_clinic;

-- 先清空再放，重複執行也只會有這幾筆
-- 已經有人買過零件的話會刪不掉，那時候改用 update-parts.sql
DELETE FROM parts;
ALTER TABLE parts AUTO_INCREMENT = 1;

INSERT INTO parts (name, category, price, sprite, starter_code) VALUES
(
  '小角',
  'html',
  10,
  'horn.svg',
  '{"html": "<div class=\\"horn\\"></div>", "css": ".horn {\\n  position: absolute;\\n  top: calc(50% - 74px);\\n  left: calc(50% - 10px);\\n  border-left: 10px solid transparent;\\n  border-right: 10px solid transparent;\\n  border-bottom: 24px solid #f3ead8;\\n}", "js": ""}'
),
(
  '眼睛',
  'html',
  15,
  'eye.svg',
  '{"html": "<div class=\\"eye left\\"></div>\\n  <div class=\\"eye right\\"></div>", "css": ".eye {\\n  position: absolute;\\n  top: calc(50% - 20px);\\n  width: 14px;\\n  height: 14px;\\n  background: #2b1d14;\\n}\\n\\n.eye.left {\\n  left: calc(50% - 32px);\\n}\\n\\n.eye.right {\\n  left: calc(50% + 18px);\\n}", "js": ""}'
),
(
  '牙齒',
  'html',
  15,
  'tooth.svg',
  '{"html": "<div class=\\"tooth left\\"></div>\\n  <div class=\\"tooth right\\"></div>", "css": ".tooth {\\n  position: absolute;\\n  top: calc(50% + 16px);\\n  border-left: 6px solid transparent;\\n  border-right: 6px solid transparent;\\n  border-top: 12px solid #ffffff;\\n}\\n\\n.tooth.left {\\n  left: calc(50% - 18px);\\n}\\n\\n.tooth.right {\\n  left: calc(50% + 6px);\\n}", "js": ""}'
),
(
  '毛色',
  'css',
  20,
  'fur.svg',
  '{"html": "", "css": "/* 斑紋：改 --fur-color 換底色，改 rgba 的透明度調斑紋深淺 */\\n.body {\\n  --fur-color: #e8a33d;\\n  background-image: repeating-linear-gradient(\\n    45deg,\\n    transparent 0 10px,\\n    rgba(0, 0, 0, 0.15) 10px 20px\\n  );\\n}", "js": ""}'
),
(
  '翅膀',
  'css',
  30,
  'wing.svg',
  '{"html": "<div class=\\"wing\\"></div>", "css": ".wing {\\n  --wing-color: #85b7eb;\\n  position: absolute;\\n  top: calc(50% - 40px);\\n  left: calc(50% - 130px);\\n  width: 64px;\\n  height: 40px;\\n  background: var(--wing-color);\\n  border: 4px solid #4a3426;\\n  border-radius: 40px 4px 40px 4px;\\n}", "js": ""}'
),
(
  '會擺動的尾巴',
  'js',
  60,
  'tail.svg',
  '{"html": "<div class=\\"tail\\"></div>", "css": ".tail {\\n  position: absolute;\\n  top: calc(50% + 10px);\\n  left: calc(50% + 64px);\\n  width: 50px;\\n  height: 12px;\\n  background: #4a3426;\\n  transform-origin: left center;\\n  cursor: pointer;\\n}\\n\\n.tail.wag {\\n  animation: wag 0.4s ease-in-out infinite alternate;\\n}\\n\\n@keyframes wag {\\n  from {\\n    transform: rotate(-20deg);\\n  }\\n  to {\\n    transform: rotate(20deg);\\n  }\\n}", "js": "// 點一下尾巴開始擺動，再點一下停下來\\nconst tail = document.querySelector(\\".tail\\");\\ntail.addEventListener(\\"click\\", () => {\\n  tail.classList.toggle(\\"wag\\");\\n});"}'
);

SELECT id, name, category, price, sprite FROM parts;
