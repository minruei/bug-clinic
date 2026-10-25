-- 題庫：10 題，涵蓋 TypeScript、非同步、模組、React、陣列、型別轉換、fetch、SQL、Express
-- 會清空舊的練習紀錄和題目，重新放入；測試帳號的金幣經驗也歸零，demo 從乾淨的狀態開始
-- 執行：mysql bug_clinic < db/seed.sql

-- emoji 一個字 4 位元組，連線要用 utf8mb4 才存得進去
SET NAMES utf8mb4;

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
(1, '小橘', '🐱', 'TypeScript 型別', 'Type ''string'' is not assignable to type ''number''.',
 'type Item = {\n  id: number\n  title: string\n}\n\nconst ref = await addDoc(collection(db, ''items''), data)\nconst item: Item = { id: ref.id, title }',
 2,
 '【哪裡出錯】資料庫給的 id 是「文字」，但程式裡規定 id 要是「數字」，兩邊對不上，TypeScript 就喊停。\n【用生活例子想】就像表格寫「年齡請填數字」，你卻填了「十八歲」。TypeScript 就是幫你檢查格式有沒有填錯的老師。\n【一句話記住】型別要跟真實的資料一樣：資料是文字就寫 string，是數字才寫 number。\n【小字典】型別：資料的種類。string：文字。number：數字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(1, 'id: string', TRUE, 1),
(1, 'id: any', FALSE, 2),
(1, 'id?: number', FALSE, 3);

-- 2. 阿福：非同步 await
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(2, '慢慢', '🐢', '非同步 await', '畫面一直顯示載入中，清單永遠是空的。',
 'async function load() {\n  const snap = getDocs(collection(db, ''items''))\n  const list = snap.docs.map((d) => d.data())\n  setItems(list)\n}',
 2,
 '【哪裡出錯】去資料庫拿資料需要一點時間，程式沒有等，就拿著空空的結果往下做，所以清單永遠是空的。\n【用生活例子想】像在餐廳點餐拿到號碼牌，還沒叫號你就去拿餐，當然什麼都拿不到。await 就是「等叫號」。\n【一句話記住】需要花時間的事情（拿資料、連網路），前面要加 await 等它完成。\n【小字典】非同步：要等一下才有結果的事。await：等它做完再往下。Promise：號碼牌，代表「等一下會有結果」。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(2, 'const snap = getDoc(collection(db, ''items''))', FALSE, 1),
(2, 'const snap = await getDocs(collection(db, ''items''))', TRUE, 2),
(2, 'let snap = getDocs(collection(db, ''items''))', FALSE, 3);

-- 3. 跳跳：模組路徑
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(3, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''@/lib/firebse''',
 'import { useState } from ''react''\nimport { db } from ''@/lib/firebse''\nimport List from ''@/components/List''',
 2,
 '【哪裡出錯】檔案叫 firebase，程式裡卻打成 firebse，少了一個 a，電腦找不到這個檔案。\n【用生活例子想】寄信時把地址的路名打錯一個字，郵差就送不到。\n【一句話記住】看到 Module not found，先檢查路徑和檔名有沒有打錯字。\n【小字典】import：從別的檔案借東西來用。路徑：檔案放在哪裡的地址。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(3, 'import db from ''@/lib/firebse''', FALSE, 1),
(3, 'import { db } from ''lib/firebse''', FALSE, 2),
(3, 'import { db } from ''@/lib/firebase''', TRUE, 3);

-- 4. 嚕嚕：React 列表 key
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(4, '嚕嚕', '🐹', 'React 列表 key', 'Warning: Each child in a list should have a unique "key" prop.',
 'function TodoList({ todos }) {\n  return (\n    <ul>\n      {todos.map((todo) => (\n        <li>{todo.title}</li>\n      ))}\n    </ul>\n  )\n}',
 5,
 '【哪裡出錯】用 map 一次產生很多個項目時，React 需要每個項目都有自己的編號（key），這裡沒給，所以跳出警告。\n【用生活例子想】老師點名要靠座號。全班沒有座號，或大家都同一號，老師就分不清誰是誰。\n【一句話記住】用 map 產生清單時，每一個都要加不重複的 key，通常用資料的 id。\n【小字典】map：把清單裡每一筆都做一樣的處理。key：React 用來分辨每個項目的編號。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(4, '<li id={todo.id}>{todo.title}</li>', FALSE, 1),
(4, '<li key={todo.id}>{todo.title}</li>', TRUE, 2),
(4, '<li key="item">{todo.title}</li>', FALSE, 3);

-- 5. 慢慢：React 狀態
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(5, '阿福', '🐶', 'React 狀態', 'TypeError: Assignment to constant variable.',
 'function Counter() {\n  const [count, setCount] = useState(0)\n\n  function add() {\n    count = count + 1\n  }\n\n  return <button onClick={add}>{count}</button>\n}',
 5,
 '【哪裡出錯】count 是 React 幫你保管的數字，不能自己直接改，要請 setCount 幫忙改，畫面才會跟著更新。\n【用生活例子想】公布欄只有班長能改。你在自己的小紙條上改分數，公布欄上的分數不會變。setCount 就是請班長改公布欄。\n【一句話記住】想改 useState 的值，一定要用它給你的 set 函式。\n【小字典】useState：React 用來記住會變動的資料。setCount：專門用來改 count 的函式。const：設定好就不能直接改的變數。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(5, 'count++', FALSE, 1),
(5, 'let count = count + 1', FALSE, 2),
(5, 'setCount(count + 1)', TRUE, 3);

-- 6. 企企：迴圈邊界
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(6, '企企', '🐧', '迴圈邊界', '印出 Amy、Ben、Cat 之後，多印了一個 undefined。',
 'const names = [''Amy'', ''Ben'', ''Cat'']\n\nfor (let i = 0; i <= names.length; i++) {\n  console.log(names[i])\n}',
 3,
 '【哪裡出錯】陣列有 3 個名字，位置編號是 0、1、2。迴圈寫 i <= 3，多跑一次去拿 3 號，可是那裡沒有東西，就印出 undefined。\n【用生活例子想】3 個人排隊，編號從 0 開始是 0、1、2 號。你喊 3 號，當然沒人回答。\n【一句話記住】陣列從 0 開始數，最後一個是「長度減 1」，迴圈條件通常寫 i < 長度。\n【小字典】陣列：一排資料。索引：每個位置的編號。undefined：「這裡沒有東西」。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(6, 'for (let i = 0; i < names.length; i++) {', TRUE, 1),
(6, 'for (let i = 1; i <= names.length; i++) {', FALSE, 2),
(6, 'for (let i = 0; i <= names.length - 2; i++) {', FALSE, 3);

-- 7. 狐狐：型別轉換
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(7, '狐狐', '🦊', '型別轉換', '購物車總金額顯示 1005，應該是 105。',
 'const price = 100\nconst qty = document.querySelector(''#qty'').value\nconst total = price + qty\nshowTotal(total)',
 3,
 '【哪裡出錯】從輸入框拿到的 5 其實是文字 "5"。數字 100 加上文字 "5"，JavaScript 會把它們接在一起變成 "1005"，而不是相加。\n【用生活例子想】把兩張寫著數字的便條紙黏在一起，跟真的拿計算機做加法，是兩回事。\n【一句話記住】從畫面上拿到的資料都是文字，要計算前先用 Number() 變成數字。\n【小字典】字串：文字資料。Number()：把文字變成數字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(7, 'const total = String(price) + qty', FALSE, 1),
(7, 'const total = price + Number(qty)', TRUE, 2),
(7, 'const total = price + qty.length', FALSE, 3);

-- 8. 圓圓：fetch 與 JSON
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(8, '圓圓', '🐼', 'fetch 與 JSON', '使用者資料一直是 undefined，畫面顯示不出名字。',
 'async function getUser() {\n  const res = await fetch(''/api/user/auth'')\n  const data = res.json()\n  return data.data\n}',
 3,
 '【哪裡出錯】res.json() 也要花時間把資料整理好，前面沒加 await，data 還是一張號碼牌，不是真正的資料，所以讀不到名字。\n【用生活例子想】網購包裹送到了（fetch），但你還沒拆箱（res.json()），就想拿裡面的東西。拆箱也要等。\n【一句話記住】fetch 要 await，res.json() 也要 await，兩次都要等。\n【小字典】fetch：跟伺服器要資料。res：伺服器的回覆。JSON：前後端傳資料最常用的格式。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(8, 'const data = await res.json()', TRUE, 1),
(8, 'const data = res.body', FALSE, 2),
(8, 'const data = JSON.parse(res)', FALSE, 3);

-- 9. 熊熊：SQL 語法
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(9, '熊熊', '🐻', 'SQL 語法', '所有玩家都多了 20 金幣，接著又跳出 SQL 語法錯誤。',
 'UPDATE users\nSET coins = coins + 20;\nWHERE id = 2;',
 2,
 '【哪裡出錯】分號代表「這句話說完了」。SET 後面多了分號，資料庫以為指令結束，就把所有玩家的金幣都加了 20；下一行 WHERE 單獨出現，變成看不懂的句子。\n【用生活例子想】老師說「全班加 20 分。」停一下才說「只有 2 號。」這時候全班早就都加分了。\n【一句話記住】UPDATE 和 DELETE 一定要確認 WHERE 跟在同一句裡，不然會改到整張表。\n【小字典】UPDATE：修改資料。WHERE：指定要改哪幾筆。分號：一句 SQL 的結尾。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(9, 'SET coins = 20;', FALSE, 1),
(9, 'SET coins += 20;', FALSE, 2),
(9, 'SET coins = coins + 20', TRUE, 3);

-- 10. 咕咕：Express 回應
INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(10, '咕咕', '🦉', 'Express 回應', '前端 fetch 一直轉圈圈，永遠等不到回應。',
 'app.get(''/api/problems'', async (req, res) => {\n  const [rows] = await pool.query(''SELECT * FROM problems'')\n  console.log(rows)\n})',
 3,
 '【哪裡出錯】後端查到資料了，但只印在自己的畫面上，沒有回傳給前端，前端就一直等不到回覆。\n【用生活例子想】客人點了菜，廚師煮好卻放在廚房沒端出去，客人只能一直等。\n【一句話記住】每個 API 最後都要用 res.json() 或 res.send() 把結果送回去。\n【小字典】req：前端送來的請求。res：要回給前端的回覆。API：前後端溝通的窗口。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(10, 'return rows', FALSE, 1),
(10, 'res.json(rows)', TRUE, 2),
(10, 'console.log(res.json)', FALSE, 3);
