-- 合成獸實驗室的測試零件：HTML 三個、CSS 兩個、JS 一個
-- 像素圖檔名先佔位，之後用 sprites.py 畫好再放進 public/pixel/
SET NAMES utf8mb4;
USE bug_clinic;

-- 先清空再放，重複執行也只會有這幾筆
-- 已經有人買過零件的話會刪不掉，那時候就不要再跑這個檔
DELETE FROM parts;
ALTER TABLE parts AUTO_INCREMENT = 1;

INSERT INTO parts (name, category, price, sprite, starter_code) VALUES
(
  '小角',
  'html',
  10,
  'horn.svg',
  '<div class="horn"></div>'
),
(
  '眼睛',
  'html',
  15,
  'eye.svg',
  '<div class="eye"></div>\n<div class="eye"></div>'
),
(
  '牙齒',
  'html',
  15,
  'tooth.svg',
  '<div class="tooth"></div>\n<div class="tooth"></div>'
),
(
  '毛色',
  'css',
  20,
  'fur.svg',
  '.body {\n  --fur-color: #b4b2a9;\n}'
),
(
  '翅膀',
  'css',
  30,
  'wing.svg',
  '.wing {\n  --wing-color: gray;\n  width: 64px;\n}'
),
(
  '會擺動的尾巴',
  'js',
  60,
  'tail.svg',
  'const tail = document.querySelector(".tail");\ntail.addEventListener("click", () => {\n  tail.classList.toggle("wag");\n});'
);

SELECT id, name, category, price, sprite FROM parts;
