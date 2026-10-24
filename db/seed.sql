-- 題庫：10 題，涵蓋 TypeScript、非同步、模組、React、陣列、型別轉換、fetch、SQL、Express
-- 會清空舊的練習紀錄和題目，重新放入；測試帳號的金幣經驗也歸零，demo 從乾淨的狀態開始
-- 執行：mysql bug_clinic < db/seed.sql

ALTER TABLE problems MODIFY explanation TEXT NOT NULL;

DELETE FROM attempts;
DELETE FROM problem_options;
DELETE FROM problems;
ALTER TABLE attempts AUTO_INCREMENT = 1;
ALTER TABLE problem_options AUTO_INCREMENT = 1;
ALTER TABLE problems AUTO_INCREMENT = 1;
UPDATE users SET coins = 0, exp = 0;

-- 1. 小橘：TypeScript 型別
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(1, '小橘', '��', 'TypeScript 型別', 'Type ''string'' is not assignable to type ''number''.',
 'type Item = {\n  id: number\n  title: string\n}\n\nconst ref = await addDoc(collection(db, ''items''), data)\nconst item: Item = { id: ref.id, title }',
 2,
 '【為什麼錯】Firestore 自動產生的文件 id 是字串（例如 "a8Kx3f..."），但型別寫成 number，兩邊對不上，TypeScript 就擋下來。\n【基本概念】型別是對資料長相的約定。TypeScript 會在程式執行前先檢查「實際的資料」和「約定」是否一致，提早抓出錯誤。改成 any 雖然不會報錯，但等於把檢查關掉。\n【名詞解釋】type：定義資料長相的語法。number／string：數字／字串型別。any：什麼都接受的型別，會失去保護。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(1, 'id: string', TRUE, 1),
(1, 'id: any', FALSE, 2),
(1, 'id?: number', FALSE, 3);

-- 2. 阿福：非同步 await
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(2, '阿福', '🐶', '非同步 await', '畫面一直顯示載入中，清單永遠是空的。',
 'async function load() {\n  const snap = getDocs(collection(db, ''items''))\n  const list = snap.docs.map((d) => d.data())\n  setItems(list)\n}',
 2,
 '【為什麼錯】getDocs 要去資料庫拿資料，需要時間，它先回傳一個 Promise（之後才會有結果的承諾）。沒有 await 就直接往下跑，snap 拿到的是 Promise 而不是資料。\n【基本概念】非同步就像點餐拿號碼牌：號碼牌（Promise）不是餐點本身，要等叫號（await）才拿得到東西。\n【名詞解釋】async：宣告這個函式裡面會等待。await：等 Promise 完成、取出結果。Promise：代表「未來會有的結果」的物件。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(2, 'const snap = getDoc(collection(db, ''items''))', FALSE, 1),
(2, 'const snap = await getDocs(collection(db, ''items''))', TRUE, 2),
(2, 'let snap = getDocs(collection(db, ''items''))', FALSE, 3);

-- 3. 跳跳：模組路徑
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(3, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''@/lib/firebse''',
 'import { useState } from ''react''\nimport { db } from ''@/lib/firebse''\nimport List from ''@/components/List''',
 2,
 '【為什麼錯】檔名是 firebase，路徑打成 firebse，少了一個 a，打包工具找不到檔案。\n【基本概念】import 是去別的檔案拿東西，路徑必須跟真實的檔名一模一樣。看到 Module not found，先比對錯誤訊息裡的路徑和實際檔名。\n【名詞解釋】import：從其他檔案載入程式。@/：專案根目錄的捷徑，在 tsconfig 設定。Module：一個可以被 import 的檔案。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(3, 'import db from ''@/lib/firebse''', FALSE, 1),
(3, 'import { db } from ''lib/firebse''', FALSE, 2),
(3, 'import { db } from ''@/lib/firebase''', TRUE, 3);

-- 4. 嚕嚕：React 列表 key
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(4, '嚕嚕', '🐹', 'React 列表 key', 'Warning: Each child in a list should have a unique "key" prop.',
 'function TodoList({ todos }) {\n  return (\n    <ul>\n      {todos.map((todo) => (\n        <li>{todo.title}</li>\n      ))}\n    </ul>\n  )\n}',
 5,
 '【為什麼錯】用 map 產生一排元素時，React 需要每一個都有獨一無二的 key，才能分辨誰新增、誰刪掉。寫成固定的 "item" 等於大家都同一個名字，一樣分不出來。\n【基本概念】key 像是座號。資料更新時，React 用座號對照前後兩次的畫面，只重畫有變的那一個，效率比較好也比較不會出錯。\n【名詞解釋】map：把陣列每一筆轉成新的東西。key：React 列表項目的身分證。props：父元件傳給子元件的資料。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(4, '<li id={todo.id}>{todo.title}</li>', FALSE, 1),
(4, '<li key={todo.id}>{todo.title}</li>', TRUE, 2),
(4, '<li key="item">{todo.title}</li>', FALSE, 3);

-- 5. 慢慢：React 狀態
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(5, '慢慢', '🐢', 'React 狀態', 'TypeError: Assignment to constant variable.',
 'function Counter() {\n  const [count, setCount] = useState(0)\n\n  function add() {\n    count = count + 1\n  }\n\n  return <button onClick={add}>{count}</button>\n}',
 5,
 '【為什麼錯】count 是用 const 宣告的，不能直接重新指定。更重要的是，就算改得動，React 也不會知道資料變了，畫面不會更新。\n【基本概念】React 的原則是「只改資料，畫面照著資料長」。想改狀態一定要透過 setCount，React 收到通知才會重新渲染畫面。\n【名詞解釋】useState：建立一個會被 React 追蹤的狀態，回傳 [目前的值, 修改用的函式]。const：宣告後不能重新指定的變數。渲染：把資料變成畫面的過程。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(5, 'count++', FALSE, 1),
(5, 'let count = count + 1', FALSE, 2),
(5, 'setCount(count + 1)', TRUE, 3);

-- 6. 企企：迴圈邊界
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(6, '企企', '🐧', '迴圈邊界', '印出 Amy、Ben、Cat 之後，多印了一個 undefined。',
 'const names = [''Amy'', ''Ben'', ''Cat'']\n\nfor (let i = 0; i <= names.length; i++) {\n  console.log(names[i])\n}',
 3,
 '【為什麼錯】陣列有 3 個，索引是 0、1、2。條件寫 i <= 3，會多跑一次 i = 3，names[3] 不存在，就印出 undefined。\n【基本概念】陣列從 0 開始數，最後一個的索引是「長度減 1」。這種多一次或少一次的錯誤叫 off-by-one，是最常見的 bug 之一。\n【名詞解釋】索引：元素在陣列裡的位置編號。length：陣列的長度。undefined：JavaScript 表示「沒有這個值」。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(6, 'for (let i = 0; i < names.length; i++) {', TRUE, 1),
(6, 'for (let i = 1; i <= names.length; i++) {', FALSE, 2),
(6, 'for (let i = 0; i <= names.length - 2; i++) {', FALSE, 3);

-- 7. 狐狐：型別轉換
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(7, '狐狐', '🦊', '型別轉換', '購物車總金額顯示 1005，應該是 105。',
 'const price = 100\nconst qty = document.querySelector(''#qty'').value\nconst total = price + qty\nshowTotal(total)',
 3,
 '【為什麼錯】從輸入框拿到的 value 永遠是字串 "5"。數字加字串時，JavaScript 會把數字也當字串，變成字串相接 "100" + "5" = "1005"。\n【基本概念】+ 在 JavaScript 有兩種意思：兩邊都是數字就相加，只要有一邊是字串就變成接起來。從畫面拿到的資料要先轉成數字再計算。\n【名詞解釋】value：輸入框裡的內容，型別是字串。Number()：把字串轉成數字。型別轉換：把一種型別的資料變成另一種。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(7, 'const total = String(price) + qty', FALSE, 1),
(7, 'const total = price + Number(qty)', TRUE, 2),
(7, 'const total = price + qty.length', FALSE, 3);

-- 8. 圓圓：fetch 與 JSON
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(8, '圓圓', '🐼', 'fetch 與 JSON', '使用者資料一直是 undefined，畫面顯示不出名字。',
 'async function getUser() {\n  const res = await fetch(''/api/user/auth'')\n  const data = res.json()\n  return data.data\n}',
 3,
 '【為什麼錯】res.json() 也是非同步的，它回傳 Promise。沒有 await，data 是 Promise，Promise 身上沒有 data 這個屬性，所以得到 undefined。\n【基本概念】fetch 分兩段等待：第一段等伺服器回應（拿到 res），第二段等把回應內容讀完並轉成 JavaScript 物件（res.json()）。兩段都要 await。\n【名詞解釋】fetch：瀏覽器發出 HTTP 請求的函式。Response（res）：伺服器的回應。JSON：前後端交換資料最常用的文字格式。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(8, 'const data = await res.json()', TRUE, 1),
(8, 'const data = res.body', FALSE, 2),
(8, 'const data = JSON.parse(res)', FALSE, 3);

-- 9. 熊熊：SQL 語法
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(9, '熊熊', '🐻', 'SQL 語法', '所有玩家都多了 20 金幣，接著又跳出 SQL 語法錯誤。',
 'UPDATE users\nSET coins = coins + 20;\nWHERE id = 2;',
 2,
 '【為什麼錯】分號代表「這句指令結束」。SET 後面多了分號，資料庫就執行了沒有 WHERE 的 UPDATE，把所有人的金幣都改了；下一行 WHERE 單獨存在，就變成語法錯誤。\n【基本概念】UPDATE 和 DELETE 一定要確認 WHERE 有寫對，不然會影響整張表。正式環境改資料前，可以先用 SELECT 加同樣的 WHERE 看會影響哪些資料。\n【名詞解釋】UPDATE：修改資料。SET：要改成什麼。WHERE：篩選要改哪幾筆。分號：SQL 指令的結尾。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(9, 'SET coins = 20;', FALSE, 1),
(9, 'SET coins += 20;', FALSE, 2),
(9, 'SET coins = coins + 20', TRUE, 3);

-- 10. 咕咕：Express 回應
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(10, '咕咕', '🦉', 'Express 回應', '前端 fetch 一直轉圈圈，永遠等不到回應。',
 'app.get(''/api/problems'', async (req, res) => {\n  const [rows] = await pool.query(''SELECT * FROM problems'')\n  console.log(rows)\n})',
 3,
 '【為什麼錯】資料有查出來，但只印在後端的終端機，沒有回傳給前端。前端的請求就一直等，直到逾時。\n【基本概念】每一個 HTTP 請求都要有一個回應。在 Express 裡，必須呼叫 res.json() 或 res.send() 才會把結果送回去；單純 return 不會送出任何東西。\n【名詞解釋】req（request）：前端送來的請求。res（response）：要回給前端的回應。res.json()：把資料轉成 JSON 送回去。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(10, 'return rows', FALSE, 1),
(10, 'res.json(rows)', TRUE, 2),
(10, 'console.log(res.json)', FALSE, 3);
