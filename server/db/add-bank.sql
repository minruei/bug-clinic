-- 題庫擴充：每隻動物再加 9 題，總共 100 題
-- 只新增不刪除，不會影響練習紀錄，可以直接對線上資料庫執行（只能執行一次）
SET NAMES utf8mb4;

-- 真實的錯誤訊息有些很長（超過 255 字），欄位改成 TEXT
ALTER TABLE problems MODIFY error_message TEXT NOT NULL;

-- 原本 6 題中文症狀：中文搬到 symptom_zh，error_message 改成英文，所有題目都是英文加中文
-- 同一句 SET 裡由左到右執行，所以 symptom_zh 先拿到原本的中文，error_message 才換成英文
UPDATE problems SET symptom_zh = error_message, error_message = 'The page keeps showing loading and the list is always empty.' WHERE id = 2 AND symptom_zh IS NULL;
UPDATE problems SET symptom_zh = error_message, error_message = 'After printing Amy, Ben, Cat, an extra undefined is printed.' WHERE id = 6 AND symptom_zh IS NULL;
UPDATE problems SET symptom_zh = error_message, error_message = 'The cart total shows 1005 instead of 105.' WHERE id = 7 AND symptom_zh IS NULL;
UPDATE problems SET symptom_zh = error_message, error_message = 'The user data is always undefined, so the name never shows.' WHERE id = 8 AND symptom_zh IS NULL;
UPDATE problems SET symptom_zh = error_message, error_message = 'Every player gains 20 coins, then a SQL syntax error appears.' WHERE id = 9 AND symptom_zh IS NULL;
UPDATE problems SET symptom_zh = error_message, error_message = 'The frontend fetch keeps spinning and never gets a response.' WHERE id = 10 AND symptom_zh IS NULL;

-- 小橘：TypeScript 型別
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(11, '小橘', '🐱', 'TypeScript 型別', 'Argument of type ''string'' is not assignable to parameter of type ''number''.', '參數型別不合：這個函式要收數字，你卻傳了文字進去', 'function double(n: number) {\n  return n * 2;\n}\nconst input = "21";\nconsole.log(double(input));', 5, '【哪裡出錯】double 規定參數 n 要是 number，但 input 是用雙引號包起來的 "21"，是文字不是數字，所以 TypeScript 不讓你傳進去。要先用 Number() 把文字轉成數字再傳。\n【用生活例子想】自動販賣機只收硬幣，你塞一張寫著「21 元」的紙條進去，機器不會收。要先去換成真的硬幣。\n【一句話記住】參數型別寫什麼，就要傳什麼；文字要變數字，先用 Number() 轉。\n【小字典】參數：函式括號裡用來接收資料的變數。型別：資料的種類，例如 number 數字、string 文字。Number()：把文字轉成數字的工具。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(11, 'console.log(double(Number(input)));', TRUE, 1),
(11, 'console.log(double("21"));', FALSE, 2),
(11, 'console.log(double(input * 1));', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(12, '小橘', '🐱', 'TypeScript 型別', 'Property ''age'' is missing in type ''{ name: string; }'' but required in type ''User''.', '物件少了屬性：User 規定要有 age，你的物件卻沒有', 'type User = {\n  name: string;\n  age: number;\n};\nconst user: User = { name: "Amy" };\nconsole.log(user.name, user.age);', 5, '【哪裡出錯】type User 規定一定要有 name 和 age 兩個屬性，但建立 user 時只給了 name，少了 age，所以 TypeScript 報錯。補上 age 而且要是數字才對。\n【用生活例子想】報名表上姓名和年齡都是必填欄位，你只寫了名字就交出去，櫃台會退件請你補上年齡。\n【一句話記住】型別裡沒加問號的屬性都是必填，一個都不能少。\n【小字典】type：用來描述資料長什麼樣子的設計圖。屬性：物件裡的一個欄位，例如 name。必填：沒有加 ? 的屬性，一定要給值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(12, 'const user: User = { name: "Amy", age };', FALSE, 1),
(12, 'const user: User = { name: "Amy", age: 20 };', TRUE, 2),
(12, 'const user: User = { name: "Amy", age: "20" };', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(13, '小橘', '🐱', 'TypeScript 型別', 'Type ''"XL"'' is not assignable to type ''Size''.', '值不在清單裡：Size 只能是 S、M、L，你卻給了 XL', 'type Size = "S" | "M" | "L";\nlet size: Size = "M";\nsize = "XL";\nconsole.log(size);', 3, '【哪裡出錯】Size 用 | 列出只能是 "S"、"M"、"L" 三個值其中一個，"XL" 不在清單裡，所以不能放進 size。要改成清單裡有的值，而且大小寫要完全一樣。\n【用生活例子想】飲料店的杯子只有小、中、大三種，你說要「特大杯」，店員只能說沒有這個選項。\n【一句話記住】union 型別像選單，只能從上面列出來的選項挑。\n【小字典】union：用 | 把幾種可能接起來，表示「其中一個」。字面值型別：把某個固定的值當成型別，例如 "S"。type：替型別取名字的方法。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(13, 'size = XL;', FALSE, 1),
(13, 'size = "m";', FALSE, 2),
(13, 'size = "L";', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(14, '小橘', '🐱', 'TypeScript 型別', '''p.price'' is possibly ''undefined''.', '可能是空的：price 是可選屬性，有可能根本沒有值', 'type Product = {\n  name: string;\n  price?: number;\n};\nconst p: Product = { name: "Pen" };\nconst total: number = p.price * 2;\nconsole.log(total);', 6, '【哪裡出錯】price 後面有 ?，代表它可以不存在。這裡的 p 就真的沒有 price，拿 undefined 去乘 2 會變成 NaN，所以 TypeScript 先提醒你。用 ?? 0 讓它沒值時改用 0。寫 p.price! 只是叫 TypeScript 別管，算出來還是 NaN。\n【用生活例子想】商品標籤上的價格欄可能是空白的，收銀員不能直接拿空白去算錢，要先決定空白就當作 0 元。\n【一句話記住】看到 ? 的屬性，用之前先想好「沒有值時怎麼辦」。\n【小字典】可選屬性：名稱後面加 ?，可以有也可以沒有。undefined：代表「沒有值」。??：左邊是 null 或 undefined 時，就改用右邊的值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(14, 'const total: number = (p.price ?? 0) * 2;', TRUE, 1),
(14, 'const total: number = p.price! * 2;', FALSE, 2),
(14, 'const total: string = p.price * 2;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(15, '小橘', '🐱', 'TypeScript 型別', '''btn'' is possibly ''null''.', '可能找不到：getElementById 有可能找不到元素而回傳 null', 'const btn = document.getElementById("save");\nbtn.addEventListener("click", () => {\n  console.log("saved");\n});', 2, '【哪裡出錯】getElementById 如果在網頁上找不到 id 是 save 的元素，就會回傳 null。對 null 呼叫 addEventListener 會讓程式當掉，所以要用 btn?. 先確認 btn 存在再用。\n【用生活例子想】你請朋友去教室找小明，小明可能今天請假。你要先確認他在，才能叫他幫忙，不然是在對空氣說話。\n【一句話記住】從網頁抓元素可能抓到 null，用 ?. 先問「在不在」。\n【小字典】null：代表「找不到、空的」。?.：可選串連，前面是 null 或 undefined 就停下來不往下執行。getElementById：用 id 從網頁找元素的方法。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(15, 'btn.addEventListener?.("click", () => {', FALSE, 1),
(15, 'btn?.addEventListener("click", () => {', TRUE, 2),
(15, '(btn as string).addEventListener("click", () => {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(16, '小橘', '🐱', 'TypeScript 型別', 'Object literal may only specify known properties, but ''colour'' does not exist in type ''Pet''. Did you mean to write ''color''?', '多了不認識的屬性：Pet 裡沒有 colour，你是不是想寫 color', 'interface Pet {\n  name: string;\n  color?: string;\n}\nfunction showPet(pet: Pet) {\n  console.log(pet.name, pet.color);\n}\nshowPet({ name: "Momo", colour: "white" });', 8, '【哪裡出錯】interface Pet 裡的屬性叫 color（美式拼法），呼叫時卻寫成 colour（英式拼法）。TypeScript 發現多了一個不認識的屬性就報錯，而且 pet.color 也拿不到顏色。把拼字改成 color 就對了；如果乾脆刪掉這個屬性，錯誤是消失了，但顏色也跟著不見。\n【用生活例子想】表格上的欄位叫「電話」，你卻在旁邊多寫一格「手機」，承辦人員看不懂那格要放哪，資料也沒填進正確的欄位。\n【一句話記住】屬性名稱要跟 interface 一字不差，拼錯就等於多塞一個不存在的欄位。\n【小字典】interface：描述物件該有哪些屬性的規格書。物件字面值：直接用 { } 寫出來的物件。可選屬性：名稱後面加 ?，可以不給。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(16, 'showPet({ name: "Momo" });', FALSE, 1),
(16, 'showPet({ name: Momo, color: white });', FALSE, 2),
(16, 'showPet({ name: "Momo", color: "white" });', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(17, '小橘', '🐱', 'TypeScript 型別', 'The return type of an async function or method must be the global Promise<T> type. Did you mean to write ''Promise<number>''?', '回傳型別不對：async 函式一定回傳 Promise，要寫成 Promise<number>', 'async function getCount(): number {\n  const res = await fetch("/api/count");\n  const data = await res.json();\n  return data.count;\n}\ngetCount().then((n) => console.log(n));', 1, '【哪裡出錯】加了 async 的函式不會馬上給你數字，而是先給你一個 Promise，等資料回來才裝進數字。所以回傳型別要寫 Promise<number>，不能只寫 number。\n【用生活例子想】你在餐廳點餐，店員先給你一張取餐號碼牌，餐點晚點才會好。async 函式給你的就是那張號碼牌，不是餐點本身。\n【一句話記住】async 函式的回傳型別一律寫 Promise<裡面的型別>。\n【小字典】async：讓函式可以用 await 等待的關鍵字。Promise：代表「之後才會拿到的結果」。泛型 <T>：尖括號裡寫裡面裝的是什麼型別。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(17, 'async function getCount(): Promise<number> {', TRUE, 1),
(17, 'function getCount(): number {', FALSE, 2),
(17, 'async function getCount(): Promise {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(18, '小橘', '🐱', 'TypeScript 型別', 'Property ''toUpperCase'' does not exist on type ''string | number''.', '型別不確定：id 可能是數字，數字沒有 toUpperCase 可以用', 'function formatId(id: string | number) {\n  return id.toUpperCase();\n}\nconsole.log(formatId("ab12"));\nconsole.log(formatId(7));', 2, '【哪裡出錯】id 可能是文字也可能是數字。toUpperCase 只有文字能用，數字沒有，所以 TypeScript 不讓你直接呼叫。先用 String(id) 把它統一變成文字再轉大寫。用 as string 只是騙過檢查，傳 7 進去執行時還是會當掉。\n【用生活例子想】箱子裡可能是衣服也可能是書，你不能直接拿去洗衣機洗。要先確定、或先處理成能洗的東西才行。\n【一句話記住】union 型別要先統一或先判斷種類，才能用只屬於某一種的方法。\n【小字典】union：用 | 表示可能是好幾種型別之一。toUpperCase：把英文字母變大寫，只有字串能用。as：型別斷言，告訴 TypeScript「相信我」，但不會真的轉換資料。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(18, '  return (id as string).toUpperCase();', FALSE, 1),
(18, '  return String(id).toUpperCase();', TRUE, 2),
(18, '  return id.toString.toUpperCase();', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(19, '小橘', '🐱', 'TypeScript 型別', 'Type ''string'' is not assignable to type ''boolean''.', '型別不合：done 要放 true 或 false，你卻放了文字', 'interface Todo {\n  id: number;\n  title: string;\n  done: boolean;\n}\nfunction toggle(todo: Todo): Todo {\n  return { ...todo, done: "true" };\n}\nconsole.log(toggle({ id: 1, title: "買牛奶", done: true }));', 7, '【哪裡出錯】Todo 規定 done 是 boolean，但這行放了 "true"，有引號就是文字，不是布林值。而且 toggle 的意思是「切換」，應該把原本的 done 反過來，所以要寫 !todo.done。寫死 true 或直接照抄 todo.done 的話，已完成的事項按了也不會變回未完成。\n【用生活例子想】電燈開關每按一次就要從開變關、從關變開。如果你做的開關不管按幾次都是「開」，那就不是切換了。\n【一句話記住】boolean 不加引號；要切換就用 ! 把原本的值反過來。\n【小字典】boolean：只有 true 和 false 兩種值的型別。!：把 true 變 false、false 變 true。...（展開運算子）：把物件原本的屬性全部複製過來。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(19, '  return { ...todo, done: todo.done };', FALSE, 1),
(19, '  return { ...todo, done: true };', FALSE, 2),
(19, '  return { ...todo, done: !todo.done };', TRUE, 3);

-- 慢慢：非同步 await
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(20, '慢慢', '🐢', '非同步 await', 'SyntaxError: await is only valid in async functions and the top level bodies of modules', '語法錯誤：await 只能用在 async 函式裡面', 'function loadUser() {\n  const res = await fetch("/api/user");\n  const data = await res.json();\n  console.log(data.name);\n}\nloadUser();', 1, '【哪裡出錯】函式裡面用了 await，但函式前面沒有加 async，JavaScript 不允許在一般函式裡等待，所以直接報語法錯誤。\n【用生活例子想】只有拿到「排隊號碼牌」的人才能在櫃台前等叫號，沒拿號碼牌就站著等，店員會請你離開。\n【一句話記住】用了 await，外面那層函式就要寫 async function。\n【小字典】async：放在函式前面，表示這個函式裡可以等待。await：等一件需要時間的事做完再往下。SyntaxError：程式寫法不符合規則的錯誤。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(20, 'async function loadUser() {', TRUE, 1),
(20, 'function async loadUser() {', FALSE, 2),
(20, 'function loadUser() async {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(21, '慢慢', '🐢', '非同步 await', 'The console prints undefined instead of the price 120.', '主控台印出 undefined，應該要印出價格 120。', 'async function showPrice() {\n  const res = await fetch("/api/price");\n  const data = res.json();\n  console.log(data.price);\n}\nshowPrice();', 3, '【哪裡出錯】res.json() 也需要時間把資料讀完，它先回傳一個 Promise。沒有 await，data 只是一張「還沒好的單子」，裡面沒有 price。\n【用生活例子想】在飲料店拿到取餐號碼就急著喝，手上只有號碼牌，沒有飲料。\n【一句話記住】fetch 要 await，res.json() 也要 await，兩次都不能少。\n【小字典】Promise：一個「之後才會有結果」的承諾。res.json()：把回傳內容轉成 JavaScript 物件。undefined：找不到值時拿到的空結果。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(21, '  const data = res.json;', FALSE, 1),
(21, '  const data = await res.json();', TRUE, 2),
(21, '  const data = await res;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(22, '慢慢', '🐢', '非同步 await', '"Order placed" and "Order ready" print at the same time, with no 1 second wait.', '「點餐」和「出餐」同時印出來，中間沒有等 1 秒。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nasync function order() {\n  console.log("點餐");\n  wait(1000);\n  console.log("出餐");\n}\norder();', 4, '【哪裡出錯】wait(1000) 只是「開始計時」，沒有加 await，程式不會停下來等，馬上就跑去印「出餐」。\n【用生活例子想】你按下微波爐開始鍵，卻沒等它叮一聲就把便當拿出來，便當還是冷的。\n【一句話記住】想要「等一下再做」，就在那件事前面加 await。\n【小字典】setTimeout：過一段時間後再執行某件事。resolve：告訴 Promise「我完成了」。await：讓程式停在這裡，等完成再往下。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(22, '  wait(1000).then();', FALSE, 1),
(22, '  setTimeout(wait, 1000);', FALSE, 2),
(22, '  await wait(1000);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(23, '慢慢', '🐢', '非同步 await', 'TypeError: Cannot read properties of undefined (reading ''name'')', '型別錯誤：你想從 undefined 裡面拿 name，但 undefined 裡什麼都沒有', 'fetch("/api/user")\n  .then((res) => {\n    res.json();\n  })\n  .then((data) => {\n    console.log(data.name);\n  });', 3, '【哪裡出錯】第一個 then 用了大括號，裡面沒有寫 return，所以什麼都沒交給下一個 then，下一個 then 拿到的 data 是 undefined。\n【用生活例子想】接力賽跑完了卻沒把棒子交出去，下一棒的人手上是空的。\n【一句話記住】then 有大括號，就要自己寫 return 把結果傳下去。\n【小字典】then：Promise 完成後要做的下一步。return：把結果交出去。接力：上一個 then 回傳什麼，下一個 then 就拿到什麼。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(23, '    return res.json();', TRUE, 1),
(23, '    await res.json();', FALSE, 2),
(23, '    res.json().name;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(24, '慢慢', '🐢', '非同步 await', 'TypeError: fetch(...).json is not a function', '型別錯誤：fetch(...) 身上沒有 json 這個功能可以用', 'async function loadWeather() {\n  const data = await fetch("/api/weather").json();\n  console.log(data.temp);\n}\nloadWeather();', 2, '【哪裡出錯】程式會先算 fetch(...).json()，再做 await。可是 fetch 剛回傳的是 Promise，不是回應，Promise 身上沒有 json()。要先用括號把 fetch 等完，拿到回應後再呼叫 json()。\n【用生活例子想】包裹還在運送中，你就想拆箱拿東西，手上只有物流單號，拆不了。\n【一句話記住】先等到回應，再對回應呼叫 json()，括號決定誰先做。\n【小字典】Promise：之後才會有結果的東西。Response：伺服器真正送回來的回應。括號：讓裡面的事情先做完。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(24, '  const data = (await fetch("/api/weather").json());', FALSE, 1),
(24, '  const data = await (await fetch("/api/weather")).json();', TRUE, 2),
(24, '  const data = await fetch("/api/weather").json;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(25, '慢慢', '🐢', '非同步 await', 'The frontend receives {"total":0} instead of 350, the total of three items.', '前端收到 {"total":0}，應該是三樣商品的總價 350。', 'app.get("/api/total", async (req, res) => {\n  let total = 0;\n  const addPrice = async (id) => {\n    const [rows] = await pool.query("SELECT price FROM items WHERE id = ?", [id]);\n    total += rows[0].price;\n  };\n  [1, 2, 3].forEach(addPrice);\n  res.json({ total });\n});', 7, '【哪裡出錯】forEach 不會等裡面的 async 函式做完，三個查詢才剛送出，程式就跑到下一行把 total（還是 0）回傳了。在 forEach 前面加 await 也沒用，因為 forEach 什麼都不回傳。\n【用生活例子想】你請三個朋友去買東西，人才剛出門你就開始算花了多少錢，當然是 0 元。\n【一句話記住】陣列裡每個都要等，用 map 收集 Promise，再用 await Promise.all 一起等。\n【小字典】forEach：對每個元素做一件事，但不會等。map：對每個元素做事並收集結果成新陣列。Promise.all：等一整組 Promise 全部完成。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(25, '  await [1, 2, 3].forEach(addPrice);', FALSE, 1),
(25, '  [1, 2, 3].map(addPrice);', FALSE, 2),
(25, '  await Promise.all([1, 2, 3].map(addPrice));', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(26, '慢慢', '🐢', '非同步 await', 'Uncaught (in promise) SyntaxError: Unexpected token ''<'', "<!DOCTYPE "... is not valid JSON', '沒被接住的錯誤：伺服器回傳的是網頁不是 JSON，而且 catch 沒有接到這個錯誤', 'async function loadPosts() {\n  try {\n    const res = await fetch("/api/posts");\n    return res.json();\n  } catch (err) {\n    console.log("讀取失敗");\n  }\n}\nloadPosts();', 4, '【哪裡出錯】return res.json() 沒有 await，函式直接把「還沒好的 Promise」交出去，就離開 try 了。之後 JSON 解析失敗，錯誤發生在 try 外面，catch 接不到。\n【用生活例子想】守門員站在球門前，但球是在他下班離開後才踢過來，他根本來不及擋。\n【一句話記住】在 try 裡面 return 一個 Promise，要寫 return await，錯誤才會被 catch 接住。\n【小字典】try/catch：把可能出錯的程式包起來，出錯時改做 catch 裡的事。JSON：一種用文字表示資料的格式。Uncaught：錯誤沒有被任何人處理。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(26, '    return await res.json();', TRUE, 1),
(26, '    res.json();', FALSE, 2),
(26, '    return res.json().then();', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(27, '慢慢', '🐢', '非同步 await', 'Uncaught (in promise) TypeError: object is not iterable (cannot read property Symbol(Symbol.iterator))', '型別錯誤：這個東西不是陣列，沒辦法一個一個拿出來', 'async function loadPage() {\n  const userReq = fetch("/api/user").then((r) => r.json());\n  const postsReq = fetch("/api/posts").then((r) => r.json());\n  const [user, posts] = await Promise.all(userReq, postsReq);\n  console.log(user.name, posts.length);\n}\nloadPage();', 4, '【哪裡出錯】Promise.all 只收「一個陣列」，這裡卻把兩個 Promise 分開傳進去，它只拿到第一個，發現不是陣列就報錯。\n【用生活例子想】外送員說「請把要送的東西全部裝進一個袋子給我」，你卻一手塞一個便當，他接不住。\n【一句話記住】Promise.all 要用中括號包成陣列，前面還要記得 await。\n【小字典】Promise.all：同時等好幾個 Promise，全部完成後一起給結果。iterable：可以一個一個拿出來的東西，例如陣列。解構：用 [a, b] 一次拿出陣列裡的值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(27, '  const [user, posts] = Promise.all([userReq, postsReq]);', FALSE, 1),
(27, '  const [user, posts] = await Promise.all([userReq, postsReq]);', TRUE, 2),
(27, '  const { user, posts } = await Promise.all(userReq, postsReq);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(28, '慢慢', '🐢', '非同步 await', 'Regular members can delete posts. "Permission denied" never shows up.', '一般會員也能刪除文章，從來沒有出現「沒有權限」。', 'async function isAdmin(userId) {\n  const [rows] = await pool.query("SELECT role FROM users WHERE id = ?", [userId]);\n  return rows[0].role === "admin";\n}\napp.delete("/api/posts/:id", async (req, res) => {\n  if (!isAdmin(req.body.userId)) return res.status(403).json({ error: "沒有權限" });\n  await pool.query("DELETE FROM posts WHERE id = ?", [req.params.id]);\n  res.json({ ok: true });\n});', 6, '【哪裡出錯】isAdmin 是 async 函式，沒有 await 時拿到的是一個 Promise。Promise 永遠算「有東西」，加上 ! 就永遠是 false，所以權限檢查從來不會擋人。\n【用生活例子想】警衛只看到你手上有「審核中」的信封，沒打開看結果就放行，誰都進得去。\n【一句話記住】async 函式的結果要先 await 拿到真正的值，再拿去判斷。\n【小字典】async 函式：一定回傳 Promise 的函式。truthy：在 if 裡被當成「真」的值，物件和 Promise 都算。403：伺服器說「你沒有權限」的狀態碼。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(28, '  if (await !isAdmin(req.body.userId)) return res.status(403).json({ error: "沒有權限" });', FALSE, 1),
(28, '  if (isAdmin(req.body.userId) === false) return res.status(403).json({ error: "沒有權限" });', FALSE, 2),
(28, '  if (!(await isAdmin(req.body.userId))) return res.status(403).json({ error: "沒有權限" });', TRUE, 3);

-- 跳跳：模組路徑
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(29, '跳跳', '🐰', '模組路徑', 'SyntaxError: The requested module ''./math.js'' does not provide an export named ''add''', '語法錯誤：math.js 這個檔案沒有對外提供叫做 add 的東西', '// math.js\nfunction add(a, b) {\n  return a + b\n}\n// app.js\nimport { add } from ''./math.js''\nconsole.log(add(2, 3))', 2, '【哪裡出錯】math.js 裡寫了 add 函式，但前面沒有加 export，這個函式只能在 math.js 自己用，別的檔案 import 不到。改成 export default 也不行，因為 app.js 用的是大括號 { add } 的寫法，要的是具名匯出。\n【用生活例子想】你在家裡煮了一鍋湯，但沒有端上桌，客人在餐桌上怎麼找都找不到。\n【一句話記住】想給別的檔案用，就要先 export 出去。\n【小字典】export：把東西開放給別的檔案使用。import：從別的檔案拿東西進來。模組：一個 JS 檔案就是一個模組。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(29, 'export function add(a, b) {', TRUE, 1),
(29, 'export default function add(a, b) {', FALSE, 2),
(29, 'function export add(a, b) {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(30, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''axois''', '找不到模組：找不到叫做 axois 的套件', 'import axios from ''axois''\n\nasync function loadPosts() {\n  const res = await axios.get(''/api/posts'')\n  console.log(res.data)\n}\nloadPosts()', 1, '【哪裡出錯】套件名稱是 axios，這裡拼成 axois，o 和 i 的順序顛倒了，系統去 node_modules 裡找不到這個套件。改成 ''./axios'' 會變成去找自己資料夾裡的檔案；改成大寫 ''Axios'' 也不對，套件名稱大小寫要完全一樣。\n【用生活例子想】你去圖書館借書，書名寫錯一個字，館員翻遍書架也找不到。\n【一句話記住】套件名稱要跟 npm install 時打的一字不差。\n【小字典】套件：別人寫好、可以下載來用的程式碼。node_modules：專門放下載套件的資料夾。npm install：下載套件的指令。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(30, 'import axios from ''./axios''', FALSE, 1),
(30, 'import axios from ''axios''', TRUE, 2),
(30, 'import axios from ''Axios''', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(31, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''../components/Card''', '找不到模組：照這個路徑找不到 Card 元件', '// 這個檔案在 app/dashboard/page.js\n// Card 在專案最外層的 components/Card.js\nimport Card from ''../components/Card''\n\nexport default function Dashboard() {\n  return <Card title="今日營收" />\n}', 3, '【哪裡出錯】page.js 在 app/dashboard 裡面，一個 ../ 只會退到 app 資料夾，結果去找 app/components/Card，當然找不到。要退兩層 ../../ 才會回到專案最外層，再進 components。退三層又會跑出專案外面。\n【用生活例子想】你在三樓的某個房間，要去一樓大廳，只下一層樓會停在二樓，下三層又跑到地下室了。\n【一句話記住】從自己的資料夾開始數，一個 ../ 退一層，數清楚再寫。\n【小字典】./：目前這個資料夾。../：上一層資料夾。相對路徑：從目前檔案的位置出發去找別的檔案。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(31, 'import Card from ''./components/Card''', FALSE, 1),
(31, 'import Card from ''../../../components/Card''', FALSE, 2),
(31, 'import Card from ''../../components/Card''', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(32, '跳跳', '🐰', '模組路徑', 'Error [ERR_MODULE_NOT_FOUND]: Cannot find module ''/app/db'' imported from /app/server.js', '找不到模組：server.js 要載入 /app/db，但找不到這個檔案', '// package.json 裡有 "type": "module"\n// server.js\nimport express from ''express''\nimport { getUsers } from ''./db''\n\nconst app = express()\napp.get(''/users'', async (req, res) => res.json(await getUsers()))\napp.listen(3000)', 4, '【哪裡出錯】Node.js 用 ES 模組（type: module）的時候，不會自動幫你補 .js，所以 ''./db'' 會被當成一個叫 db、沒有副檔名的檔案，找不到。要寫完整的 ''./db.js''。拿掉 ./ 會被當成套件名稱去 node_modules 找；開頭只寫 / 會變成從電腦最根部的資料夾找。\n【用生活例子想】寄信只寫「中山路」沒寫門牌號碼，郵差不會幫你猜是哪一戶。\n【一句話記住】Node 的 ES 模組，自己的檔案要寫完整副檔名 .js。\n【小字典】副檔名：檔名最後的 .js、.json 這類標示。ES 模組：用 import 和 export 的寫法。type: module：在 package.json 告訴 Node 這個專案用 ES 模組。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(32, 'import { getUsers } from ''./db.js''', TRUE, 1),
(32, 'import { getUsers } from ''db.js''', FALSE, 2),
(32, 'import { getUsers } from ''/db.js''', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(33, '跳跳', '🐰', '模組路徑', 'TypeError: (0 , _lib_api__WEBPACK_IMPORTED_MODULE_1__.fetchPosts) is not a function', '型別錯誤：從 lib/api 拿到的 fetchPosts 不是函式，沒辦法呼叫', '// lib/api.js\nexport const fetchPots = () => fetch(''https://api.example.com/posts'').then((res) => res.json())\n// app/page.js\nimport { fetchPosts } from ''@/lib/api''\nexport default async function Page() {\n  const posts = await fetchPosts()\n  return <p>共 {posts.length} 篇</p>\n}', 2, '【哪裡出錯】lib/api.js 匯出的名字拼成 fetchPots，少了一個 s，但 page.js 要的是 fetchPosts。名字對不上，拿到的就是 undefined，一呼叫就說它不是函式。把 export 拿掉一樣拿不到；export default 後面不能直接接 const，會變成語法錯誤。\n【用生活例子想】你在門口貼的名牌是「王小名」，朋友來找「王小明」，管理員就說查無此人。\n【一句話記住】export 的名字和 import 大括號裡的名字，要一字不差。\n【小字典】具名匯出：用 export 加名字匯出，import 時要用一樣的名字放在大括號裡。undefined：沒有東西、還沒有值。TypeError：拿某個東西去做它不能做的事時出現的錯誤。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(33, 'export default const fetchPosts = () => fetch(''https://api.example.com/posts'').then((res) => res.json())', FALSE, 1),
(33, 'export const fetchPosts = () => fetch(''https://api.example.com/posts'').then((res) => res.json())', TRUE, 2),
(33, 'const fetchPosts = () => fetch(''https://api.example.com/posts'').then((res) => res.json())', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(34, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''../components/Navbar''', '找不到模組：在自己的 Mac 上跑得好好的，部署到 Vercel 才出現找不到 Navbar', '// 檔案實際名稱：components/NavBar.js\n// app/layout.js\nimport NavBar from ''../components/Navbar''\n\nexport default function RootLayout({ children }) {\n  return (\n    <html><body><NavBar />{children}</body></html>\n  )\n}', 3, '【哪裡出錯】檔案叫 NavBar.js（B 是大寫），路徑卻寫 Navbar（b 小寫）。Mac 預設不分大小寫，所以本機剛好找得到；Vercel 的主機是 Linux，大小寫不同就是不同檔案，所以部署才壞掉。改變數名稱沒用，要改的是引號裡的路徑。\n【用生活例子想】密碼 Abc123 打成 abc123，有些舊系統放你進去，嚴格的系統就不讓你登入。\n【一句話記住】路徑的大小寫，要跟檔名完全一樣。\n【小字典】大小寫敏感：A 和 a 被當成不同的字。部署：把程式放到網路主機上讓大家使用。Linux：很多伺服器使用的作業系統。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(34, 'import NavBar from ''../components/navbar''', FALSE, 1),
(34, 'import Navbar from ''../components/Navbar''', FALSE, 2),
(34, 'import NavBar from ''../components/NavBar''', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(35, '跳跳', '🐰', '模組路徑', 'ReferenceError: module is not defined in ES module scope', '參考錯誤：在 ES 模組裡面沒有 module 這個東西可以用', '// package.json 裡有 "type": "module"\n// routes/users.js\nimport express from ''express''\nconst router = express.Router()\nrouter.get(''/'', (req, res) => res.json([{ id: 1, name: ''Ruei'' }]))\nmodule.exports = router\n// server.js\nimport usersRouter from ''./routes/users.js''\napp.use(''/users'', usersRouter)', 6, '【哪裡出錯】這個專案用 ES 模組（import / export），可是匯出時用了舊的 CommonJS 寫法 module.exports，ES 模組裡沒有 module 這個東西。server.js 用 import usersRouter 沒加大括號，代表要的是預設匯出，所以要寫 export default router。exports 一樣是舊寫法會出錯；export router 少了 default，是語法錯誤。\n【用生活例子想】全班都改用 LINE 傳訊息了，你還在用傳紙條，紙條沒有人收。\n【一句話記住】用 import 就配 export，用 require 就配 module.exports，不要混著用。\n【小字典】CommonJS：Node 早期的模組寫法，用 require 和 module.exports。ES 模組：新的標準寫法，用 import 和 export。export default：一個檔案最主要的那一個匯出，import 時不用大括號。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(35, 'export default router', TRUE, 1),
(35, 'exports.default = router', FALSE, 2),
(35, 'export router', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(36, '跳跳', '🐰', '模組路徑', 'Error: Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: undefined. You likely forgot to export your component from the file it''s defined in, or you might have mixed up default and named imports.', '元素型別無效：要畫的元件拿到的是 undefined，可能忘了 export，或把預設匯入和具名匯入搞混了', '// components/Button.js\nexport default function Button({ label }) {\n  return <button>{label}</button>\n}\n// app/page.js\nimport { Button } from ''@/components/Button''\nexport default function Page() {\n  return <Button label="送出" />\n}', 6, '【哪裡出錯】Button.js 用的是 export default（預設匯出），import 時就不能加大括號。加了大括號是在找「名字叫 Button 的具名匯出」，可是檔案裡沒有，拿到 undefined，React 不知道要畫什麼。補副檔名沒用；用 * as Button 會拿到整個模組物件，React 一樣畫不出來。\n【用生活例子想】店家說「招牌菜直接說要招牌就好」，你卻翻菜單找一道叫「招牌」的菜名，當然找不到。\n【一句話記住】export default 配沒大括號，export 加名字配有大括號。\n【小字典】預設匯出：export default，一個檔案只能有一個，import 時名字可以自己取。具名匯出：export 加名字，import 時要用大括號和同樣的名字。元件：React 裡可以重複使用的畫面積木。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(36, 'import { Button } from ''@/components/Button.js''', FALSE, 1),
(36, 'import Button from ''@/components/Button''', TRUE, 2),
(36, 'import * as Button from ''@/components/Button''', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(37, '跳跳', '🐰', '模組路徑', 'Module not found: Can''t resolve ''@/src/components/Card''', '找不到模組：照 @/src/components/Card 這個路徑找不到 Card', '// tsconfig.json 設定："paths": { "@/*": ["./src/*"] }\n// 檔案位置：src/components/Card.tsx\n// src/app/page.tsx\nimport Card from ''@/src/components/Card''\n\nexport default function Page() {\n  return <Card title="本週任務" />\n}', 4, '【哪裡出錯】tsconfig 已經設定 @/ 就等於 ./src/，所以 ''@/src/components/Card'' 其實會變成 src/src/components/Card，多了一層 src。直接寫 ''@/components/Card'' 就好。少了斜線的 ''@components'' 會被當成套件名稱；開頭只寫 / 會從電腦最根部找。\n【用生活例子想】捷徑「回家」已經代表「台北市中山區你家」，你卻說「回家的台北市中山區」，地址就重複了。\n【一句話記住】@/ 已經包含 src，後面不要再寫一次 src。\n【小字典】路徑別名：用短短的符號代替一長串路徑。tsconfig.json：設定 TypeScript 和路徑別名的檔案。@/：Next.js 專案常見的別名，通常代表專案根目錄或 src 資料夾。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(37, 'import Card from ''@components/Card''', FALSE, 1),
(37, 'import Card from ''/src/components/Card''', FALSE, 2),
(37, 'import Card from ''@/components/Card''', TRUE, 3);

-- 嚕嚕：React 列表 key
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(38, '嚕嚕', '🐹', 'React 列表 key', 'The list is empty. None of the three fruits appear, and there is no error.', '畫面上的清單是空的，三種水果一個都沒有出現，也沒有任何錯誤訊息。', 'function FruitList() {\n  const fruits = ["蘋果", "香蕉", "芭樂"];\n  return (\n    <ul>\n      {fruits.map((fruit) => { <li key={fruit}>{fruit}</li> })}\n    </ul>\n  );\n}', 5, '【哪裡出錯】箭頭函式後面用了大括號 { }，就變成一段要自己寫 return 的程式區塊。裡面只寫了 <li> 卻沒有 return，所以 map 每次都拿到 undefined，畫面什麼都沒有。\n【用生活例子想】你請同學幫你包三份禮物，他包好了卻全部放在自己桌上，沒有交給你，你手上還是空的。\n【一句話記住】箭頭函式用大括號就要寫 return，想省略 return 就改用小括號或直接接 JSX。\n【小字典】map：把陣列每一項加工後，收集回傳值變成新陣列。return：把結果交出去。箭頭函式：用 => 寫的簡短函式。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(38, '      {fruits.map((fruit) => <li key={fruit}>{fruit}</li>)}', TRUE, 1),
(38, '      {fruits.forEach((fruit) => { <li key={fruit}>{fruit}</li> })}', FALSE, 2),
(38, '      {fruits.map((fruit) => { <li key={fruit}>{fruit}</li>; })}', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(39, '嚕嚕', '🐹', 'React 列表 key', 'The cart is empty, but a stray 0 appears under the "Cart" heading.', '購物車明明是空的，「購物車」標題下面卻多出一個 0。', 'function CartBadge() {\n  const items = [];\n  return (\n    <div>\n      <h2>購物車</h2>\n      {items.length && <p>你有 {items.length} 件商品</p>}\n    </div>\n  );\n}', 6, '【哪裡出錯】A && B 在 A 是假值時會直接回傳 A。items.length 是 0，所以整段的結果就是數字 0，而 React 會把數字 0 印在畫面上（false 和 null 才不會印）。\n【用生活例子想】你問店員「有貨的話幫我拿來」，店員沒貨，結果沒說「沒有」，反而遞給你一張寫著 0 的紙條。\n【一句話記住】條件渲染的左邊要放真正的 true 或 false，用 length > 0，不要直接放 length。\n【小字典】條件渲染：符合條件才顯示某段畫面。&&：左邊成立才看右邊，不成立就回傳左邊。假值：會被當成 false 的值，例如 0、空字串、null。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(39, '      {items && <p>你有 {items.length} 件商品</p>}', FALSE, 1),
(39, '      {items.length > 0 && <p>你有 {items.length} 件商品</p>}', TRUE, 2),
(39, '      {items.length || <p>你有 {items.length} 件商品</p>}', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(40, '嚕嚕', '🐹', 'React 列表 key', 'TypeError: Cannot read properties of undefined (reading ''map'')', '讀不到屬性：你想對 undefined 使用 map，但它根本不是陣列', 'function UserList() {\n  const [users, setUsers] = useState();\n  useEffect(() => {\n    fetch("/api/users").then((res) => res.json()).then((data) => setUsers(data));\n  }, []);\n  return <ul>{users.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;\n}', 2, '【哪裡出錯】useState() 沒給初始值，users 一開始是 undefined。畫面第一次渲染時資料還沒抓回來，就先執行了 users.map，undefined 沒有 map 可以用，於是當掉。\n【用生活例子想】外送還沒到，你就急著打開便當盒，但手上根本沒有盒子。先放一個空盒子，至少打開不會出事。\n【一句話記住】之後要 map 的 state，初始值就給空陣列 []。\n【小字典】useState：讓元件記住一個會變動的值。初始值：state 一開始的內容。undefined：還沒有被給值的狀態。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(40, '  const [users, setUsers] = useState({});', FALSE, 1),
(40, '  const [users, setUsers] = useState(null);', FALSE, 2),
(40, '  const [users, setUsers] = useState([]);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(41, '嚕嚕', '🐹', 'React 列表 key', 'After checking "Buy milk" and deleting it, "Do homework" becomes checked instead.', '勾選「買牛奶」之後按刪除，買牛奶不見了，結果變成「寫作業」被打勾。', 'function TodoList() {\n  const [todos, setTodos] = useState([{ id: 1, text: "買牛奶" }, { id: 2, text: "寫作業" }, { id: 3, text: "游泳" }]);\n  const remove = (id) => setTodos(todos.filter((t) => t.id !== id));\n  return todos.map((t, index) => (\n    <div key={index}>\n      <input type="checkbox" /> {t.text} <button onClick={() => remove(t.id)}>刪除</button>\n    </div>\n  ));\n}', 5, '【哪裡出錯】用 index 當 key，刪掉第一項後，寫作業的 index 從 1 變成 0。React 看到 key 0 還在，就以為是同一個項目，把原本打勾的那個框留下來，只換掉文字，勾勾就跑到寫作業身上。\n【用生活例子想】教室用座位號碼認人，1 號同學轉學後大家往前坐，老師看 1 號座位還在，就把原本 1 號的獎狀發給新坐上來的人。\n【一句話記住】key 要用資料本身不會變的 id，不要用 index，更不要用亂數。\n【小字典】key：React 用來認出清單中每一項是誰的名牌。index：項目在陣列中的位置編號，會隨刪除而改變。Math.random()：每次產生不同的亂數，每次渲染名牌都換掉，狀態也會全部消失。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(41, '    <div key={t.id}>', TRUE, 1),
(41, '    <div key={Math.random()}>', FALSE, 2),
(41, '    <div>', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(42, '嚕嚕', '🐹', 'React 列表 key', 'Warning: Encountered two children with the same key, `React`. Keys should be unique so that components maintain their identity across updates.', '名牌撞號：有兩個項目的 key 都是 React，key 必須每個都不一樣', 'function TagList() {\n  const tags = [\n    { id: 1, name: "React" },\n    { id: 2, name: "JavaScript" },\n    { id: 3, name: "React" },\n  ];\n  return <ul>{tags.map((tag) => <li key={tag.name}>{tag.name}</li>)}</ul>;\n}', 7, '【哪裡出錯】用 name 當 key，但資料裡有兩個都叫 React，key 重複了。React 分不出誰是誰，更新時可能少畫或多畫項目。資料本來就有獨一無二的 id，應該用 id。\n【用生活例子想】班上有兩個人都叫小明，老師只喊「小明」，兩個人都不知道是不是在叫自己，用學號就不會搞錯。\n【一句話記住】key 要選「保證不會重複」的欄位，通常就是 id。\n【小字典】key：清單每一項的專屬名牌。unique：獨一無二、不重複。id：資料的編號，每筆都不一樣。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(42, '  return <ul>{tags.map((tag) => <li key="tag">{tag.name}</li>)}</ul>;', FALSE, 1),
(42, '  return <ul>{tags.map((tag) => <li key={tag.name.toLowerCase()}>{tag.name}</li>)}</ul>;', FALSE, 2),
(42, '  return <ul>{tags.map((tag) => <li key={tag.id}>{tag.name}</li>)}</ul>;', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(43, '嚕嚕', '🐹', 'React 列表 key', 'The list shows 3 blank items instead of just two names.', '清單出現 3 個空白的項目，應該只顯示「阿華」和「美美」兩個名字。', 'function AdultList() {\n  const people = [\n    { id: 1, name: "小明", age: 12 },\n    { id: 2, name: "阿華", age: 25 },\n    { id: 3, name: "美美", age: 30 },\n  ];\n  const adults = people.map((p) => p.age >= 18);\n  return <ul>{adults.map((p) => <li key={p.id}>{p.name}</li>)}</ul>;\n}', 7, '【哪裡出錯】這裡想「挑出」成年人，卻用了 map。map 會把每個人都換成判斷結果，得到 [false, true, true]，三個都不是人物資料，所以 p.name 都是空的。挑選要用 filter。\n【用生活例子想】老師要你從全班挑出戴眼鏡的人，你卻交回一張寫著「否、是、是」的紙，人名一個都沒有。\n【一句話記住】要挑選留下用 filter，要每個都加工轉換用 map。\n【小字典】filter：留下符合條件的項目，數量可能變少。map：每一項都轉換，數量不變。find：只找第一個符合的項目，回傳的是一筆資料不是陣列。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(43, '  const adults = people.find((p) => p.age >= 18);', FALSE, 1),
(43, '  const adults = people.filter((p) => p.age >= 18);', TRUE, 2),
(43, '  const adults = people.map((p) => p.age >= 18 && p);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(44, '嚕嚕', '🐹', 'React 列表 key', 'SyntaxError: Adjacent JSX elements must be wrapped in an enclosing tag. Did you want a JSX fragment <>...</>?', '語法錯誤：相鄰的兩個 JSX 標籤必須用一個外層包起來，要不要用 <>...</> 包？', 'function Glossary() {\n  const words = [{ id: 1, term: "key", desc: "清單的名牌" }, { id: 2, term: "map", desc: "陣列加工廠" }];\n  return (\n    <dl>\n      {words.map((w) => (\n        <dt key={w.id}>{w.term}</dt><dd>{w.desc}</dd>\n      ))}</dl>\n  );\n}', 6, '【哪裡出錯】map 每一次只能回傳一個東西，這裡卻並排回傳 <dt> 和 <dd> 兩個標籤。要用一個外層把它們包起來，而且 key 要放在最外層。簡寫的 <></> 不能放 key，所以要用 React.Fragment。\n【用生活例子想】寄包裹時一次只能交一個箱子，你有兩樣東西，就要先裝進同一個大箱子，地址標籤也要貼在大箱子外面。\n【一句話記住】map 一次回傳多個標籤要用 Fragment 包起來，key 貼在最外層。\n【小字典】Fragment：看不見的外包裝，不會多產生 HTML 標籤。<></>：Fragment 的簡寫，但不能加 key。dl、dt、dd：名詞清單、名詞、名詞說明的 HTML 標籤。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(44, '        <><dt key={w.id}>{w.term}</dt><dd>{w.desc}</dd></>', FALSE, 1),
(44, '        [<dt key={w.id}>{w.term}</dt>, <dd>{w.desc}</dd>]', FALSE, 2),
(44, '        <React.Fragment key={w.id}><dt>{w.term}</dt><dd>{w.desc}</dd></React.Fragment>', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(45, '嚕嚕', '🐹', 'React 列表 key', 'Error: Objects are not valid as a React child (found: object with keys {id, text}). If you meant to render a collection of children, use an array instead.', '物件不能直接顯示：你把整個物件放進畫面，React 不知道要印哪個欄位', 'function NoteList() {\n  const notes = [\n    { id: 1, text: "記得繳電費" },\n    { id: 2, text: "週五交作業" },\n  ];\n  return <ul>{notes.map((note) => <li key={note.id}>{note}</li>)}</ul>;\n}', 6, '【哪裡出錯】{note} 是整個物件 { id, text }，React 只會顯示文字、數字或 JSX，不知道物件要怎麼印，所以報錯。要指定印出 note.text 這個欄位。\n【用生活例子想】你請朋友念出便條紙上的字，卻把整個資料夾塞給他，他不知道要念哪一張的哪一行。\n【一句話記住】畫面上要放物件裡的欄位，例如 note.text，不能放整個物件。\n【小字典】物件：用大括號裝很多欄位的資料。欄位：物件裡的一項資料，例如 text。JSON.stringify：把物件變成一串原始文字，通常只拿來除錯，不適合直接給使用者看。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(45, '  return <ul>{notes.map((note) => <li key={note.id}>{note.text}</li>)}</ul>;', TRUE, 1),
(45, '  return <ul>{notes.map((note) => <li key={note.id}>{notes.text}</li>)}</ul>;', FALSE, 2),
(45, '  return <ul>{notes.map((note) => <li key={note.id}>{JSON.stringify(note)}</li>)}</ul>;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(46, '嚕嚕', '🐹', 'React 列表 key', 'TypeError: movies.map is not a function', '不是函式：movies 不是陣列，所以沒有 map 可以用', '// API 回傳格式：{ total: 2, results: [{ id: 1, title: "龍貓" }, { id: 2, title: "神隱少女" }] }\nfunction MovieList() {\n  const [movies, setMovies] = useState([]);\n  useEffect(() => {\n    fetch("/api/movies").then((res) => res.json())\n      .then((data) => setMovies(data));\n  }, []);\n  return <ul>{movies.map((m) => <li key={m.id}>{m.title}</li>)}</ul>;\n}', 6, '【哪裡出錯】API 回傳的是一個物件，電影陣列藏在 results 裡面。把整個物件存進 movies，畫面一更新，movies 就不是陣列了，物件沒有 map 可以用。要存 data.results。\n【用生活例子想】你訂了一盒餅乾，收到的是外面的紙箱，直接往紙箱咬當然不行，要先打開拿出裡面的餅乾盒。\n【一句話記住】拿到 API 資料先看清楚格式，陣列在哪一層就取哪一層。\n【小字典】API：前後端溝通的窗口。res.json()：把回應內容轉成 JavaScript 資料。results：這支 API 用來裝資料陣列的欄位名稱。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(46, '      .then((data) => setMovies([data]));', FALSE, 1),
(46, '      .then((data) => setMovies(data.results));', TRUE, 2),
(46, '      .then((data) => setMovies(data.total));', FALSE, 3);

-- 阿福：React 狀態
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(47, '阿福', '🐶', 'React 狀態', 'Error: Too many re-renders. React limits the number of renders to prevent an infinite loop.', '重新渲染太多次：React 為了避免無限迴圈，把畫面停下來了', 'function Counter() {\n  const [count, setCount] = useState(0);\n  const add = () => setCount(count + 1);\n  return (\n    <button onClick={add()}>點我 {count}</button>\n  );\n}', 5, '【哪裡出錯】onClick={add()} 多了小括號，等於畫面一畫出來就立刻執行 add，add 改了 state 又讓畫面重畫，重畫又再執行 add，就停不下來了。\n【用生活例子想】你想把門鈴交給客人按，結果自己一直狂按門鈴，鈴聲響個不停。\n【一句話記住】onClick 裡放函式的名字，不要加小括號去呼叫它。\n【小字典】onClick：按下去時才要做的事。呼叫函式：在名字後面加 () 讓它馬上執行。重新渲染：state 改變後 React 把畫面重畫一次。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(47, '    <button onClick={add}>點我 {count}</button>', TRUE, 1),
(47, '    <button onClick="add()">點我 {count}</button>', FALSE, 2),
(47, '    <button onClick={add(count)}>點我 {count}</button>', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(48, '阿福', '🐶', 'React 狀態', 'Warning: You provided a `value` prop to a form field without an `onChange` handler. This will render a read-only field. If the field should be mutable use `defaultValue`. Otherwise, set either `onChange` or `readOnly`.', '警告：輸入框有綁 value 卻沒有 onChange，所以它變成只能看、不能打字的欄位', 'function NameInput() {\n  const [name, setName] = useState("");\n  return (\n    <div>\n      <input value={name} />\n      <p>你好，{name}</p>\n    </div>\n  );\n}', 5, '【哪裡出錯】輸入框的內容被 value={name} 綁住了，但沒有 onChange 去更新 name，所以不管怎麼打字，name 永遠是空字串，框框也就打不進字。\n【用生活例子想】白板上的字只有老師能改，你拿筆去寫，老師沒有幫你抄上去，白板就永遠不變。\n【一句話記住】有 value 就要配 onChange，把 e.target.value 存回 state。\n【小字典】value：輸入框要顯示的內容。onChange：使用者打字時會觸發的事件。e.target.value：使用者剛剛打進去的文字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(48, '      <input value={name} onChange={setName} />', FALSE, 1),
(48, '      <input value={name} onChange={(e) => setName(e.target.value)} />', TRUE, 2),
(48, '      <input value="name" onChange={(e) => setName(e.target.value)} />', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(49, '阿福', '🐶', 'React 狀態', 'After clicking the button, the new item does not appear in the list.', '按下按鈕後，畫面上的清單沒有多出「寫作業」，還是只有「買牛奶」。', 'function TodoList() {\n  const [todos, setTodos] = useState(["買牛奶"]);\n  const addTodo = () => {\n    todos.push("寫作業");\n  };\n  return <button onClick={addTodo}>{todos.join("、")}</button>;\n}', 4, '【哪裡出錯】todos.push 是偷偷改掉原本的陣列，沒有呼叫 setTodos，React 根本不知道資料變了，所以不會重畫畫面。\n【用生活例子想】你在班級名單上偷偷加了一個名字，卻沒有跟老師說，老師點名時還是照舊的名單點。\n【一句話記住】改陣列 state 要用 setXxx 給一個新陣列，常用 [...舊陣列, 新東西]。\n【小字典】push：把東西塞進原本陣列的最後面，並回傳新的長度。展開運算子 ...：把陣列裡的東西一個一個倒出來。setTodos：通知 React 資料變了的唯一方法。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(49, '    todos = [...todos, "寫作業"];', FALSE, 1),
(49, '    setTodos(todos.push("寫作業"));', FALSE, 2),
(49, '    setTodos([...todos, "寫作業"]);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(50, '阿福', '🐶', 'React 狀態', 'Clicking "+3" once only changes the count from 0 to 1 instead of 3.', '按一次「加 3」按鈕，畫面只從 0 變成 1，應該要變成 3。', 'function Counter() {\n  const [count, setCount] = useState(0);\n  const addThree = () => {\n    for (let i = 0; i < 3; i++) {\n      setCount(count + 1);\n    }\n  };\n  return <button onClick={addThree}>加 3：{count}</button>;\n}', 5, '【哪裡出錯】同一次點擊裡，count 一直都是舊的 0，三次都是 setCount(0 + 1)，最後結果還是 1。要用函式寫法，讓每次都拿「上一次算完的值」再加 1。\n【用生活例子想】三個人照著同一張舊的成績單各自加 1 分，交上去都是 1 分；如果是一個接一個傳下去加，才會加到 3 分。\n【一句話記住】新值要靠舊值算，就寫 setCount((prev) => prev + 1)。\n【小字典】函式寫法：把一個函式交給 setCount，React 會把最新的值傳進來。prev：上一個狀態的值，名字可以自己取。批次更新：React 會把同一次事件裡的多個 setState 合在一起處理。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(50, '      setCount(count + i);', FALSE, 1),
(50, '      setCount((prev) => prev + 1);', TRUE, 2),
(50, '      setCount(count++);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(51, '阿福', '🐶', 'React 狀態', 'After clicking the button, the dog''s age stays at 10 instead of becoming 11.', '按下按鈕後，小黑的年齡一直停在 10 歲，沒有變成 11 歲。', 'function Pet() {\n  const [dog, setDog] = useState({ name: "小黑", age: 10 });\n  const grow = () => {\n    dog.age = dog.age + 1;\n  };\n  return <button onClick={grow}>{dog.name}：{dog.age} 歲</button>;\n}', 4, '【哪裡出錯】dog.age = ... 是直接去改物件裡的屬性，沒有呼叫 setDog，React 不知道要重畫，所以畫面還是 10 歲。\n【用生活例子想】寵物的健康手冊要拿去櫃台重新登記才算數，你自己在家用鉛筆改，醫院系統還是舊資料。\n【一句話記住】物件 state 要用 setXxx({ ...舊物件, 要改的屬性: 新值 })。\n【小字典】物件：用大括號裝很多「名字: 值」的資料。...dog：把 dog 原本所有屬性複製過來。不可變更新：不去改舊資料，而是做一份新的交給 React。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(51, '    setDog({ ...dog, age: dog.age + 1 });', TRUE, 1),
(51, '    setDog({ age: dog.age + 1 });', FALSE, 2),
(51, '    setDog(dog.age + 1);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(52, '阿福', '🐶', 'React 狀態', 'After the first click the screen shows 1, but the console logs "now 0".', '按第一次按鈕，畫面變成 1，但 console 卻印出「現在是 0」。', 'function Counter() {\n  const [count, setCount] = useState(0);\n  const add = () => {\n    const next = count + 1;\n    setCount(next);\n    console.log("現在是", count);\n  };\n  return <button onClick={add}>{count}</button>;\n}', 6, '【哪裡出錯】setCount 不會馬上改掉這一輪的 count，它是「預約」下一次畫面更新時才換成新值，所以緊接著印出來的 count 還是舊的 0。\n【用生活例子想】你在餐廳點了換一杯飲料，服務生還沒端來之前，你手上拿的還是原本那杯。\n【一句話記住】setState 之後馬上要用新值，就用自己算好的那個變數，不要再讀 state。\n【小字典】setCount：預約更新 state，不是立刻改。console.log：把東西印在開發者工具裡看。await：等待非同步的結果，只能用在 async 函式裡。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(52, '    await console.log("現在是", count);', FALSE, 1),
(52, '    console.log("現在是", setCount(next));', FALSE, 2),
(52, '    console.log("現在是", next);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(53, '阿福', '🐶', 'React 狀態', 'TypeError: Cannot read properties of undefined (reading ''map'')', '型別錯誤：users 是 undefined（還沒有東西），沒辦法對它用 map', 'function UserList() {\n  const [users, setUsers] = useState();\n  useEffect(() => {\n    fetch("/api/users").then((res) => res.json()).then((data) => setUsers(data));\n  }, []);\n  return <ul>{users.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;\n}', 2, '【哪裡出錯】useState() 沒給初始值，第一次畫面出現時資料還沒抓回來，users 是 undefined，對 undefined 呼叫 map 就壞掉了。之後要放的是陣列，所以初始值就要先給空陣列。\n【用生活例子想】餐廳還沒進貨，但你要先擺好一個空盤子，客人看到的是空盤，而不是連盤子都沒有就直接把菜倒在桌上。\n【一句話記住】state 之後會放陣列，初始值就給 []。\n【小字典】初始值：useState 括號裡的值，第一次畫面用它。undefined：還沒有給任何值。map：陣列專用的方法，把每個元素變成畫面上的東西。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(53, '  const [users, setUsers] = useState({});', FALSE, 1),
(53, '  const [users, setUsers] = useState(null);', FALSE, 2),
(53, '  const [users, setUsers] = useState([]);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(54, '阿福', '🐶', 'React 狀態', 'Clicking delete on one item removes the other two and leaves only that item.', '按下「洗碗」想把它刪掉，結果清單只剩下「洗碗」，其他兩項都不見了。', 'function TodoList() {\n  const [todos, setTodos] = useState(["買菜", "洗碗", "倒垃圾"]);\n  const remove = (index) => {\n    setTodos(todos.splice(index, 1));\n  };\n  return todos.map((t, i) => <button key={t} onClick={() => remove(i)}>{t}</button>);\n}', 4, '【哪裡出錯】splice 會偷偷改掉原本的陣列，而且它回傳的是「被刪掉的那些東西」，所以 setTodos 收到的是 ["洗碗"]，清單就只剩它了。\n【用生活例子想】你請人把垃圾從房間拿走，結果他把房間清空，只把垃圾留下來給你。\n【一句話記住】刪除陣列 state 用 filter 留下「不是它的」，不要用 splice。\n【小字典】splice：直接改原陣列，回傳被刪掉的元素。filter：照條件挑出要留下的元素，做出一個新陣列。!==：不等於。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(54, '    setTodos(todos.filter((t, i) => i !== index));', TRUE, 1),
(54, '    setTodos(todos.filter((t, i) => i === index));', FALSE, 2),
(54, '    setTodos(todos.slice(index, 1));', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(55, '阿福', '🐶', 'React 狀態', 'Warning: A component is changing a controlled input to be uncontrolled. This is likely caused by the value changing from a defined to undefined, which should not happen.', '警告：輸入框原本由 state 控制，後來 value 變成 undefined，失去控制了', 'function SignUp() {\n  const [form, setForm] = useState({ email: "", password: "" });\n  const handleChange = (e) => setForm({ [e.target.name]: e.target.value });\n  return (<form>\n    <input name="email" value={form.email} onChange={handleChange} />\n    <input name="password" value={form.password} onChange={handleChange} />\n  </form>);\n}', 3, '【哪裡出錯】setForm 給的新物件只有剛剛打字的那一個欄位，另一個欄位就不見了，變成 undefined，輸入框就從「被控制」變成「沒人管」。要先用 ...form 把舊的欄位複製過來。\n【用生活例子想】你只想改報名表上的電話，結果交了一張只寫電話的新表，名字和地址全都消失了。\n【一句話記住】物件 state 更新一定先寫 ...舊物件，再蓋上要改的欄位。\n【小字典】受控元件：輸入框的內容由 state 決定。[e.target.name]：用變數當作物件屬性的名字。...form：把 form 裡原本所有欄位複製過來。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(55, '  const handleChange = (e) => setForm({ ...form, name: e.target.value });', FALSE, 1),
(55, '  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });', TRUE, 2),
(55, '  const handleChange = (e) => setForm({ form, [e.target.name]: e.target.value });', FALSE, 3);

-- 企企：迴圈邊界
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(56, '企企', '🐧', '迴圈邊界', 'The screen shows NaN instead of the total 60.', '畫面顯示 NaN，總金額應該是 60。', 'const prices = [10, 20, 30];\nlet total;\nfor (const p of prices) {\n  total += p;\n}\nconsole.log(total);', 2, '【哪裡出錯】total 只有宣告，沒有給初始值，所以它一開始是 undefined。undefined 加上數字會變成 NaN，之後不管再加什麼都還是 NaN。\n【用生活例子想】要開始存錢之前，要先確定存錢筒裡是 0 元；連存錢筒都沒準備好，投進去的錢就不知道算到哪裡。\n【一句話記住】要累加的變數，一開始就先設成 0。\n【小字典】undefined：變數有名字但還沒放東西。NaN：Not a Number，算出來不是正常的數字。累加：一次一次把數字加進同一個變數。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(56, 'let total = 0;', TRUE, 1),
(56, 'let total = "";', FALSE, 2),
(56, 'let total = 1;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(57, '企企', '🐧', '迴圈邊界', 'Only the second and third fruits print. The first one is skipped.', '只印出香蕉和芒果，排第一個的蘋果不見了。', 'const fruits = ["蘋果", "香蕉", "芒果"];\nfor (let i = 1; i < fruits.length; i++) {\n  console.log(fruits[i]);\n}', 2, '【哪裡出錯】陣列的第一個位置是索引 0，迴圈卻從 i = 1 開始，直接跳過了 fruits[0] 的蘋果。\n【用生活例子想】排隊叫號從 0 號開始，你卻從 1 號開始叫，站在最前面的人就永遠沒被叫到。\n【一句話記住】跑陣列的迴圈，從 0 開始，用 < length 結束。\n【小字典】索引：東西在陣列裡的位置編號，從 0 開始。length：陣列裡總共有幾個東西。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(57, 'for (let i = 0; i <= fruits.length; i++) {', FALSE, 1),
(57, 'for (let i = 0; i < fruits.length; i++) {', TRUE, 2),
(57, 'for (let i = 1; i <= fruits.length; i++) {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(58, '企企', '🐧', '迴圈邊界', 'The last score shows undefined instead of 92.', '畫面顯示「最後一次成績：undefined」，應該是 92。', 'const scores = [70, 85, 92];\nconst last = scores[scores.length];\nconsole.log("最後一次成績：" + last);', 2, '【哪裡出錯】scores 有 3 個成績，索引是 0、1、2。scores.length 是 3，但 scores[3] 沒有東西，所以拿到 undefined。最後一個要用 length 減 1。另外 JavaScript 不像 Python，scores[-1] 也是 undefined。\n【用生活例子想】一排 3 間教室編號 0、1、2，你跑去找 3 號教室，當然空無一物。\n【一句話記住】最後一個索引永遠是 length - 1。\n【小字典】索引：從 0 開始的位置編號。length：陣列的總數量。undefined：拿不到東西時得到的值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(58, 'const last = scores[-1];', FALSE, 1),
(58, 'const last = scores[scores.length - 2];', FALSE, 2),
(58, 'const last = scores[scores.length - 1];', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(59, '企企', '🐧', '迴圈邊界', 'Printing the steps in reverse shows undefined first.', '想把步驟倒過來印，第一行卻先出現 undefined，接著才是盛飯、煮飯、洗米。', 'const steps = ["洗米", "煮飯", "盛飯"];\nfor (let i = steps.length; i >= 0; i--) {\n  console.log(steps[i]);\n}', 2, '【哪裡出錯】倒著跑的起點設成 steps.length，也就是 3，但最後一個東西在索引 2。所以第一圈拿的是 steps[3]，印出 undefined。\n【用生活例子想】要從最後一節車廂往前走，你卻從火車後面的空地開始走，第一步踩到的什麼都沒有。\n【一句話記住】倒數迴圈從 length - 1 開始，跑到 i >= 0 為止。\n【小字典】i--：每跑一圈就把 i 減 1。>=：大於或等於，這樣 0 也會跑到。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(59, 'for (let i = steps.length - 1; i >= 0; i--) {', TRUE, 1),
(59, 'for (let i = steps.length - 1; i > 0; i--) {', FALSE, 2),
(59, 'for (let i = steps.length; i > 0; i--) {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(60, '企企', '🐧', '迴圈邊界', 'The top 3 ranking only shows 2 names.', '想拿排行榜前三名，畫面卻只顯示 ["小明", "小華"]。', 'const ranking = ["小明", "小華", "小美", "阿強", "阿德"];\nconst top3 = ranking.slice(0, 2);\nconsole.log(top3);', 2, '【哪裡出錯】slice(開始, 結束) 不包含結束那一格。slice(0, 2) 只拿索引 0 和 1，也就是兩個人。要拿三個人，結束要寫 3。\n【用生活例子想】切蛋糕說「從第 0 刀切到第 2 刀」，中間只有兩塊；想要三塊，就要切到第 3 刀。\n【一句話記住】slice 包頭不包尾，要拿幾個，結尾就是開始加幾個。\n【小字典】slice：從陣列切一段出來，不會改到原本的陣列。包頭不包尾：開始那格有算，結束那格不算。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(60, 'const top3 = ranking.slice(1, 4);', FALSE, 1),
(60, 'const top3 = ranking.slice(0, 3);', TRUE, 2),
(60, 'const top3 = ranking.slice(3);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(61, '企企', '🐧', '迴圈邊界', 'The loop never stops printing and the browser tab freezes.', '畫面一直狂印「第 1 次」停不下來，瀏覽器分頁卡住，「結束」永遠沒出現。', 'let count = 1;\nwhile (count <= 3) {\n  console.log("第 " + count + " 次");\n  count + 1;\n}\nconsole.log("結束");', 4, '【哪裡出錯】count + 1 只是算出一個答案，卻沒有存回 count，所以 count 永遠是 1。條件 count <= 3 一直成立，迴圈就停不下來。\n【用生活例子想】教練說跑完一圈就在本子上記一筆，你只在心裡算，本子上永遠寫著 1 圈，教練就一直叫你繼續跑。\n【一句話記住】while 迴圈裡一定要真的更新變數，用 = 或 += 存回去。\n【小字典】無窮迴圈：條件永遠成立，迴圈永遠不會結束。+=：把原本的值加上一個數，再存回去。==：比較兩邊是否相等，不會改變任何值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(61, '  count == count + 1;', FALSE, 1),
(61, '  let count = count + 1;', FALSE, 2),
(61, '  count += 1;', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(62, '企企', '🐧', '迴圈邊界', 'The name is in the list, but the result shows -1 (not found).', '名單裡明明有 bob，畫面卻顯示 -1（找不到）。', 'const users = ["amy", "bob", "cat"];\nlet index = -1;\nfor (let i = 0; i < users.length; i++) {\n  if (users[i] === "bob") index = i;\n  break;\n}\nconsole.log(index);', 5, '【哪裡出錯】break 沒有放在條件裡，第一圈檢查完 amy 就直接跳出迴圈，根本還沒輪到 bob。要等真的找到了（index 不是 -1）才 break。\n【用生活例子想】在書架上找一本書，看了第一本不是，你就直接走人，後面的書都沒看。\n【一句話記住】break 要放在「找到了」的條件裡，不然第一圈就結束。\n【小字典】break：立刻跳出整個迴圈。-1：常用來代表「還沒找到」。!==：不相等。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(62, '  if (index === -1) break;', FALSE, 1),
(62, '  if (index !== -1) break;', TRUE, 2),
(62, '  i++;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(63, '企企', '🐧', '迴圈邊界', 'Uncaught TypeError: Cannot read properties of undefined (reading ''length'')', '讀不到屬性：你想讀 undefined 的 length，但那裡根本沒有東西', 'const grid = [[1, 2], [3, 4], [5, 6]];\nlet sum = 0;\nfor (let i = 0; i < grid.length; i++) {\n  for (let j = 0; j < grid[i].length; i++) {\n    sum += grid[i][j];\n  }\n}\nconsole.log(sum);', 4, '【哪裡出錯】內層迴圈本來要讓 j 往上加，卻寫成 i++。結果 j 一直是 0，i 卻被加到 3，grid[3] 不存在，去讀它的 length 就出錯了。\n【用生活例子想】你應該在同一層樓一間一間房間走（j），卻一直按電梯換樓層（i），最後按到一個不存在的樓層。\n【一句話記住】內層迴圈的開始、條件、更新，三個地方都要用自己的變數 j。\n【小字典】巢狀迴圈：迴圈裡面再放一個迴圈。二維陣列：陣列裡面裝的是陣列，像一張有行有列的表格。TypeError：對某個值做了它不能做的事。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(63, '  for (let j = 0; j < grid.length; j++) {', FALSE, 1),
(63, '  for (let i = 0; i < grid[i].length; i++) {', FALSE, 2),
(63, '  for (let j = 0; j < grid[i].length; j++) {', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(64, '企企', '🐧', '迴圈邊界', 'Page 1 should show ["a", "b"] but shows ["c", "d"].', '第 1 頁應該顯示 ["a", "b"]，畫面卻顯示 ["c", "d"]。', 'const items = ["a", "b", "c", "d", "e", "f"];\nconst size = 2;\nfunction getPage(page) {\n  return items.slice(page * size, page * size + size);\n}\nconsole.log(getPage(1));', 4, '【哪裡出錯】頁數是從 1 開始算的，但 slice 的位置是從 0 開始算的。第 1 頁直接用 1 * 2 當起點，就跳過了 a、b，拿到第 2 頁的資料。要先把頁數減 1 再乘。\n【用生活例子想】書的第 1 頁就是最前面那張，不是先翻過一張才叫第 1 頁。\n【一句話記住】人說的頁數從 1 開始，程式的索引從 0 開始，換算時記得減 1。\n【小字典】分頁：把很多資料分成一頁一頁顯示。slice：切出陣列的一段，包頭不包尾。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(64, '  return items.slice((page - 1) * size, page * size);', TRUE, 1),
(64, '  return items.slice((page - 1) * size, page * size - 1);', FALSE, 2),
(64, '  return items.slice(page * size - 1, page * size + size - 1);', FALSE, 3);

-- 狐狐：型別轉換
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(65, '狐狐', '🦊', '型別轉換', 'The visit counter shows "visit 11" instead of "visit 2".', '畫面顯示「第 11 次來訪」，應該是「第 2 次來訪」。', 'localStorage.setItem(''visits'', 1);\nconst visits = localStorage.getItem(''visits'');\nconst next = visits + 1;\nconsole.log(`第 ${next} 次來訪`);', 2, '【哪裡出錯】localStorage 不管你存什麼進去，拿出來一律都是字串，所以 visits 是 ''1'' 不是 1。字串加 1 會變成把兩段文字接在一起，得到 ''11''。\n【用生活例子想】你把一張寫著「1」的紙條放進抽屜，拿出來的還是一張紙條，不是一顆可以拿來數的球；要先把紙條上的字看成數字才能加。\n【一句話記住】從 localStorage 拿出來的東西都是字串，要算數學先用 Number() 轉。\n【小字典】localStorage：瀏覽器裡可以長期存小資料的抽屜。getItem：從抽屜拿出資料。Number()：把字串轉成數字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(65, 'const visits = Number(localStorage.getItem(''visits''));', TRUE, 1),
(65, 'const visits = localStorage.getItem(''visits'').toString();', FALSE, 2),
(65, 'const visits = JSON.stringify(localStorage.getItem(''visits''));', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(66, '狐狐', '🦊', '型別轉換', 'Stock is 0, but the page says the item is in stock.', '庫存明明是 0，畫面卻顯示「有貨，可以下單」。', 'const stock = ''0''; // 從後端拿到的是字串\nif (stock) {\n  console.log(''有貨，可以下單'');\n} else {\n  console.log(''已售完'');\n}', 2, '【哪裡出錯】if 只看值是「有東西」還是「沒東西」。數字 0 會被當成沒東西，但字串 ''0'' 裡面有一個字，會被當成有東西，所以一律走進「有貨」。\n【用生活例子想】一個盒子裡放了一張寫著「0」的紙條，盒子不是空的，可是紙條的意思是「沒有貨」；只看盒子空不空就會判斷錯。\n【一句話記住】字串 ''0'' 是 true，要判斷數量就先轉成數字再比大小。\n【小字典】truthy：if 會當成「有」的值。falsy：if 會當成「沒有」的值，例如 0、''''、null、undefined、NaN。Number()：把字串轉成數字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(66, 'if (stock !== '''') {', FALSE, 1),
(66, 'if (Number(stock) > 0) {', TRUE, 2),
(66, 'if (stock.length) {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(67, '狐狐', '🦊', '型別轉換', 'Typing abc as the quantity shows "Added NaN items" instead of a format error.', '輸入 abc 當數量，畫面卻顯示「已加入 NaN 件」，應該顯示「數量格式錯誤」。', 'const input = ''abc''; // 使用者在數量欄輸入的字\nconst qty = parseInt(input, 10);\nif (qty === NaN) {\n  console.log(''數量格式錯誤'');\n} else {\n  console.log(`已加入 ${qty} 件`);\n}', 3, '【哪裡出錯】parseInt(''abc'') 會得到 NaN，但 NaN 很特別，它跟任何東西比都不相等，連跟自己比也不相等，所以 qty === NaN 永遠是 false。\n【用生活例子想】NaN 像一個戴著面具的人，你問他「你是不是你？」他永遠回答「不是」，所以只能用專門的檢查機器去認他。\n【一句話記住】檢查 NaN 不能用等號，要用 Number.isNaN()。\n【小字典】NaN：Not a Number，算不出數字時的結果。parseInt：把字串轉成整數。Number.isNaN()：專門檢查是不是 NaN 的函式。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(67, 'if (qty == NaN) {', FALSE, 1),
(67, 'if (typeof qty !== ''number'') {', FALSE, 2),
(67, 'if (Number.isNaN(qty)) {', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(68, '狐狐', '🦊', '型別轉換', 'The ranking shows [100, 25, 3, 9] instead of [3, 9, 25, 100].', '排行榜顯示 [100, 25, 3, 9]，應該是由小到大 [3, 9, 25, 100]。', 'const scores = [100, 25, 9, 3];\nconst sorted = scores.sort();\nconsole.log(sorted);', 2, '【哪裡出錯】sort() 什麼都不給的時候，會先把每個數字當成字串，再一個字一個字比。''100'' 的第一個字是 ''1''，比 ''3'' 小，所以 100 會被排在最前面。\n【用生活例子想】像查字典一樣排順序，「10」會排在「9」前面，因為字典只看第一個字，不管數字到底多大。\n【一句話記住】數字排序一定要寫 sort((a, b) => a - b)。\n【小字典】sort：把陣列重新排順序。比較函式：告訴 sort 誰該排前面的小規則。a - b：結果是負的，a 就排前面。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(68, 'const sorted = scores.sort().reverse();', FALSE, 1),
(68, 'const sorted = scores.sort((a, b) => a - b);', TRUE, 2),
(68, 'const sorted = scores.sort((a, b) => b - a);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(69, '狐狐', '🦊', '型別轉換', 'Comparing ages 10 and 9 says the second person is older.', '輸入 10 歲和 9 歲，畫面卻顯示「第二位比較大」。', 'function isOlder(ageA, ageB) {\n  return ageA > ageB;\n}\n// 兩個年齡都是從輸入框拿到的字串\nconst result = isOlder(''10'', ''9'');\nconsole.log(result ? ''第一位比較大'' : ''第二位比較大'');', 2, '【哪裡出錯】兩邊都是字串時，大於小於是照字典順序一個字一個字比。''10'' 的第一個字 ''1'' 比 ''9'' 小，所以 ''10'' > ''9'' 是 false。\n【用生活例子想】點名簿照字典排，「10 號」會排在「9 號」前面，但這不代表 10 比 9 小，只是第一個字比較前面。\n【一句話記住】兩個字串比大小是比字典順序，要比數字就先轉成 Number。\n【小字典】字串比較：從第一個字開始逐字比的規則。Number()：把字串轉成數字。輸入框的 value：拿出來一定是字串。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(69, '  return Number(ageA) > Number(ageB);', TRUE, 1),
(69, '  return ageA >= ageB;', FALSE, 2),
(69, '  return String(ageA) > String(ageB);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(70, '狐狐', '🦊', '型別轉換', 'The cart total shows 24.00 instead of 25.49.', '購物車總計顯示 24.00，應該是 25.49。', 'const prices = [''19.99'', ''5.50''];\nlet total = 0;\nprices.forEach((p) => {\n  total += parseInt(p);\n});\nconsole.log(total.toFixed(2));', 4, '【哪裡出錯】parseInt 只會讀整數，看到小數點就停下來，所以 ''19.99'' 變成 19，''5.50'' 變成 5，小數點後面全部被丟掉。\n【用生活例子想】收銀員只收紙鈔不收零錢，19.99 元只記 19 元，算到最後當然少了一截。\n【一句話記住】有小數就用 parseFloat 或 Number，不要用 parseInt。\n【小字典】parseInt：把字串轉成整數，遇到不是數字的字就停。parseFloat：把字串轉成可以有小數的數字。toFixed(2)：把數字顯示到小數點後兩位。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(70, '  total += p;', FALSE, 1),
(70, '  total += parseInt(p, 10);', FALSE, 2),
(70, '  total += parseFloat(p);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(71, '狐狐', '🦊', '型別轉換', 'TypeError: Cannot read properties of undefined (reading ''name'')', '讀不到屬性：你想拿 name，可是前面那個東西是 undefined，也就是根本沒找到。', 'const users = [{ id: 1, name: ''Amy'' }, { id: 2, name: ''Ben'' }];\nconst params = new URLSearchParams(''?id=2'');\nconst id = params.get(''id'');\nconst user = users.find((u) => u.id === id);\nconsole.log(user.name);', 4, '【哪裡出錯】網址參數拿出來一定是字串，所以 id 是 ''2''。=== 會連型別一起比，數字 2 和字串 ''2'' 型別不同，永遠不相等，find 找不到就回傳 undefined，下一行讀 name 就壞掉。\n【用生活例子想】你拿一張寫著「2」的紙條去找 2 號櫃子，管理員很嚴格，說紙條和櫃子號碼牌不是同一種東西，不讓你開。\n【一句話記住】=== 會比型別，從網址或表單拿到的值要先轉成數字再比。\n【小字典】===：值和型別都要一樣才算相等。URLSearchParams：讀取網址 ? 後面參數的工具。find：找出第一個符合條件的項目，找不到就給 undefined。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(71, 'const user = users.find((u) => u.id = id);', FALSE, 1),
(71, 'const user = users.find((u) => u.id === ''id'');', FALSE, 2),
(71, 'const user = users.find((u) => u.id === Number(id));', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(72, '狐狐', '🦊', '型別轉換', 'Submitting an empty amount shows "Transferred 0 successfully" instead of asking for an amount.', '使用者沒有填金額就按送出，畫面卻顯示「轉帳 0 元成功」，應該顯示「請輸入金額」。', 'const input = { value: '''' }; // 使用者沒有填\nconst amount = Number(input.value);\nif (isNaN(amount)) {\n  console.log(''請輸入金額'');\n} else {\n  console.log(`轉帳 ${amount} 元成功`);\n}', 3, '【哪裡出錯】Number('''') 不是 NaN，而是 0。所以空白的輸入會順利變成 0，isNaN 檢查不出來，程式就以為使用者想轉 0 元。\n【用生活例子想】點餐單上數量那格空白，店員卻自動當成「點 0 份」直接送單，其實應該先問客人「你還沒填喔」。\n【一句話記住】Number('''') 是 0，檢查空白要另外看原本的字串是不是空的。\n【小字典】Number('''')：空字串轉數字會變成 0。isNaN()：檢查是不是 NaN。trim()：去掉字串前後的空白。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(72, 'if (input.value.trim() === '''' || isNaN(amount)) {', TRUE, 1),
(72, 'if (amount === NaN) {', FALSE, 2),
(72, 'if (amount === undefined) {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(73, '狐狐', '🦊', '型別轉換', 'The level shows "Unknown" instead of "Intermediate".', '畫面顯示「未知」，應該顯示「中級」。', 'function getLevelName(level) {\n  switch (level) {\n    case 1: return ''初級'';\n    case 2: return ''中級'';\n    default: return ''未知'';\n  }\n}\nlocalStorage.setItem(''level'', 2);\nconsole.log(getLevelName(localStorage.getItem(''level'')));', 2, '【哪裡出錯】localStorage 拿出來的是字串 ''2''，而 switch 比對 case 時用的是 ===，字串 ''2'' 和數字 2 不相等，所以一路掉到 default。\n【用生活例子想】門口的感應器只認「2 號卡」，你拿的是一張手寫「2」的紙，看起來一樣，機器就是不放行。\n【一句話記住】switch 用 === 比對，丟進去之前先把型別轉對。\n【小字典】switch：依照值跳到對應 case 的寫法。case：switch 裡的每一個選項。parseInt 第二個參數：進位制，寫 2 是二進位，寫 10 才是平常用的十進位。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(73, '  switch (String(level)) {', FALSE, 1),
(73, '  switch (Number(level)) {', TRUE, 2),
(73, '  switch (parseInt(level, 2)) {', FALSE, 3);

-- 圓圓：fetch 與 JSON
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(74, '圓圓', '🐼', 'fetch 與 JSON', 'GET http://localhost:3000/api/user 404 (Not Found)', '找不到：你要的網址在伺服器上不存在', 'app.get("/api/users", (req, res) => {\n  res.json([{ name: "Amy" }]);\n});\nasync function load() {\n  const res = await fetch("/api/user");\n  const data = await res.json();\n  console.log(data);\n}\nload();', 5, '【哪裡出錯】後端開的路線是 /api/users（有 s），前端卻去敲 /api/user（少了 s），伺服器找不到這條路，只好回 404。\n【用生活例子想】朋友住在「中山路 12 號」，你卻跑去「中山路 1 號」按門鈴，當然沒人應門。\n【一句話記住】看到 404，先把前端網址和後端路線一個字一個字對一遍。\n【小字典】404：伺服器說「找不到這個網址」。路由：後端設定好的網址入口。fetch：前端向伺服器要資料的指令。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(74, '  const res = await fetch("/api/users");', TRUE, 1),
(74, '  const res = await fetch("/api/user/");', FALSE, 2),
(74, '  const res = await fetch("api/user");', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(75, '圓圓', '🐼', 'fetch 與 JSON', 'SyntaxError: Unexpected token ''o'', "[object Object]" is not valid JSON', '語法錯誤：後端收到的是 "[object Object]" 這串字，不是 JSON', 'async function addTodo() {\n  const res = await fetch("/api/todos", {\n    method: "POST",\n    headers: { "Content-Type": "application/json" },\n    body: { title: "買牛奶" }\n  });\n  console.log(res.status);\n}\naddTodo();', 5, '【哪裡出錯】body 只能放文字，直接塞物件進去，瀏覽器會把它變成 "[object Object]" 這串沒意義的字，後端拿去解析就出錯。\n【用生活例子想】寄包裹要先把東西打包裝箱，你把一張沙發直接丟進郵筒，郵局只會收到一張寫著「沙發」的紙條。\n【一句話記住】POST 送物件，一定要先 JSON.stringify 變成文字。\n【小字典】body：請求裡要送出去的內容。JSON.stringify：把物件變成 JSON 文字。JSON.parse：把 JSON 文字變回物件，方向剛好相反。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(75, '    body: JSON.parse({ title: "買牛奶" })', FALSE, 1),
(75, '    body: JSON.stringify({ title: "買牛奶" })', TRUE, 2),
(75, '    body: { title: "買牛奶" }.toString()', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(76, '圓圓', '🐼', 'fetch 與 JSON', 'The console shows 404, but the backend does have app.post("/api/todos").', '主控台印出 404，但後端明明有寫 app.post("/api/todos")。', 'app.post("/api/todos", (req, res) => res.json({ ok: true }));\nfetch("/api/todos", {\n  method: "POTS",\n  headers: { "Content-Type": "application/json" },\n  body: JSON.stringify({ title: "買牛奶" })\n}).then((res) => console.log(res.status));', 3, '【哪裡出錯】method 寫成 POTS，字母順序打反了。後端只有開 POST 這個門，收到 POTS 不認得，就回 404。\n【用生活例子想】餐廳只接受「內用」和「外帶」，你跟店員說要「外內」，店員只能說沒有這個選項。\n【一句話記住】method 要和後端的 app.get、app.post 一模一樣，拼字不能錯。\n【小字典】method：這次請求的動作種類，例如 GET 拿資料、POST 新增資料。app.post：後端只接 POST 請求的路線。404：找不到對應的路線。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(76, '  method: "PUT",', FALSE, 1),
(76, '  methods: "POST",', FALSE, 2),
(76, '  method: "POST",', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(77, '圓圓', '🐼', 'fetch 與 JSON', 'The backend''s req.body is empty ({}), so it cannot read title.', '主控台印出 {}，後端的 req.body 是空的，拿不到 title。', 'app.use(express.json());\napp.post("/api/todos", (req, res) => {\n  res.json({ saved: req.body.title });\n});\nfetch("/api/todos", {\n  method: "POST",\n  headers: { "Accept": "application/json" },\n  body: JSON.stringify({ title: "買牛奶" })\n}).then((res) => res.json()).then((data) => console.log(data));', 7, '【哪裡出錯】這裡只寫了 Accept，沒寫 Content-Type。express.json() 只會拆開標明 application/json 的包裹，沒標示的就不理它，所以 req.body 變成空物件。\n【用生活例子想】寄冷凍食品卻沒貼「冷凍」標籤，物流就當一般包裹處理，冷凍庫那邊根本收不到。\n【一句話記住】送 JSON 給後端，headers 要寫 "Content-Type": "application/json"。\n【小字典】headers：請求附帶的說明標籤。Content-Type：告訴對方「我送的是什麼格式」。Accept：告訴對方「我希望收到什麼格式」，跟送出去的內容無關。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(77, '  headers: { "Content-Type": "json" },', FALSE, 1),
(77, '  headers: { "Content-Type": "application/json" },', TRUE, 2),
(77, '  headers: { "Content-Type": "text/plain" },', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(78, '圓圓', '🐼', 'fetch 與 JSON', 'The backend returns 404 for a missing product, but no error shows and the name is blank.', '商品 999 不存在，後端回 404，但畫面沒有跳出錯誤訊息，名稱欄位變成一片空白。', 'app.get("/api/products/:id", (req, res) => res.status(404).json({ error: "找不到商品" }));\nasync function showProduct(id) {\n  const res = await fetch(`/api/products/${id}`);\n  const data = await res.json();\n  if (!res) throw new Error(data.error);\n  document.querySelector("#name").textContent = data.name;\n}\nshowProduct(999).catch((err) => alert(err.message));', 5, '【哪裡出錯】fetch 就算拿到 404 也不會自己報錯，res 永遠是一個物件，所以 !res 永遠是 false，這行檢查等於沒寫。要看的是 res.ok，它在 404、500 時才會是 false。\n【用生活例子想】你問店員有沒有貨，店員有回話（res 存在），不代表他說的是「有」，要聽清楚回答的內容（res.ok）。\n【一句話記住】fetch 不會因為 404 報錯，要自己檢查 res.ok。\n【小字典】res.ok：狀態碼在 200 到 299 之間時是 true。狀態碼：伺服器回覆的結果代號，例如 200 成功、404 找不到。throw：主動丟出錯誤，讓 catch 接住。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(78, '  if (res.ok) throw new Error(data.error);', FALSE, 1),
(78, '  if (!data) throw new Error(data.error);', FALSE, 2),
(78, '  if (!res.ok) throw new Error(data.error);', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(79, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: result.map is not a function', '型別錯誤：result 不是陣列，沒有 map 可以用', 'async function loadUsers() {\n  const res = await fetch("/api/users");\n  const result = await res.json();\n  // 後端回傳格式：{ data: [{ name: "Amy" }, { name: "Ben" }] }\n  const names = result.map((user) => user.name);\n  console.log(names);\n}\nloadUsers();', 5, '【哪裡出錯】後端回傳的是一個物件，陣列被包在 data 這個欄位裡面。result 本身是物件，物件沒有 map，要先打開 result.data 才拿得到陣列。\n【用生活例子想】便當盒裡裝著一排壽司，你要先打開盒蓋（.data），才能一個一個拿壽司（map），不能直接對盒子用筷子。\n【一句話記住】先 console.log 看清楚資料長怎樣，再決定要走到哪一層。\n【小字典】map：把陣列每一項都處理一次，變出新陣列。物件：用 { } 包起來、有欄位名稱的資料。資料層級：資料一層包一層的結構，要用 . 一層一層往下走。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(79, '  const names = result.data.map((user) => user.name);', TRUE, 1),
(79, '  const names = result.data.name;', FALSE, 2),
(79, '  const names = result[0].map((user) => user.name);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(80, '圓圓', '🐼', 'fetch 與 JSON', 'SyntaxError: Unexpected token ''o'', "[object Object]" is not valid JSON', '語法錯誤：你拿去解析的東西不是 JSON 文字', 'async function loadWeather() {\n  const res = await fetch("/api/weather?city=Taipei");\n  const data = JSON.parse(await res.json());\n  document.querySelector("#temp").textContent = data.temp + "°C";\n}\nloadWeather();', 3, '【哪裡出錯】res.json() 已經幫你把 JSON 文字變成物件了，再丟給 JSON.parse，它會先把物件變成 "[object Object]" 這串字再去解析，當然失敗。\n【用生活例子想】泡麵已經泡好了，你又把它丟回熱水壺裡想再泡一次，只會弄得一團亂。\n【一句話記住】用了 res.json()，就不用再 JSON.parse。\n【小字典】res.json()：讀取回覆內容並轉成物件，要搭配 await。JSON.parse：把 JSON 文字轉成物件。JSON.stringify：把物件轉成 JSON 文字。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(80, '  const data = JSON.parse(res.json());', FALSE, 1),
(80, '  const data = JSON.stringify(await res.json());', FALSE, 2),
(80, '  const data = await res.json();', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(81, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: Failed to execute ''fetch'' on ''Window'': Request with GET/HEAD method cannot have body.', '型別錯誤：GET 請求不能帶 body', 'app.get("/api/search", (req, res) => res.json({ results: [req.query.q] }));\nasync function search(keyword) {\n  const res = await fetch("/api/search", { method: "GET", body: JSON.stringify({ q: keyword }) });\n  const data = await res.json();\n  console.log(data.results);\n}\nsearch("貓咪");', 3, '【哪裡出錯】GET 請求規定不能有 body，瀏覽器直接拒絕送出。GET 要帶資料，得寫在網址後面的 ?q=...，後端才用 req.query.q 讀得到。\n【用生活例子想】寄明信片沒有信封可以裝東西，要說的話只能直接寫在卡片正面（網址）上。\n【一句話記住】GET 的資料放網址，POST 的資料放 body。\n【小字典】query string：網址 ? 後面的資料，例如 ?q=貓咪。req.query：後端讀取網址參數的地方。body：POST、PUT 用來裝資料的請求內容。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(81, '  const res = await fetch(`/api/search?q=${keyword}`);', TRUE, 1),
(81, '  const res = await fetch("/api/search", { method: "POST", body: JSON.stringify({ q: keyword }) });', FALSE, 2),
(81, '  const res = await fetch("/api/search", { body: JSON.stringify({ q: keyword }) });', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(82, '圓圓', '🐼', 'fetch 與 JSON', 'GET http://localhost:3000/api/me 401 (Unauthorized)', '未授權：伺服器不知道你是誰，拒絕給資料', 'const token = localStorage.getItem("token");\nasync function loadProfile() {\n  const res = await fetch("/api/me", {\n    headers: { "Content-Type": "application/json" }\n  });\n  if (!res.ok) throw new Error(`錯誤代碼 ${res.status}`);\n  console.log((await res.json()).name);\n}\nloadProfile();', 4, '【哪裡出錯】/api/me 要登入才能看，後端會去 Authorization 這個 header 找通行證。這裡只寫了 Content-Type，token 拿出來了卻沒帶上，後端就回 401。\n【用生活例子想】你有買電影票，但放在家裡沒帶，到了驗票口還是進不去。\n【一句話記住】要登入的 API，記得在 headers 帶上 Authorization: Bearer 加上 token。\n【小字典】token：登入後拿到的通行證字串。Authorization：放通行證的 header 欄位。401：伺服器說「你沒登入或通行證無效」。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(82, '    headers: { "Content-Type": "application/json", "token": token }', FALSE, 1),
(82, '    headers: { "Authorization": `Bearer ${token}` }', TRUE, 2),
(82, '    headers: { "Authorization": "Bearer token" }', FALSE, 3);

-- 熊熊：SQL 語法
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(83, '熊熊', '🐻', 'SQL 語法', 'The query returns nothing, even though 3 users have no phone number.', '查詢結果是空的，但 users 資料表裡明明有 3 位玩家沒有填電話。', 'SELECT username, email\nFROM users\nWHERE phone = NULL;', 3, '【哪裡出錯】NULL 代表「不知道、沒有值」，它不能用 = 來比較，任何東西 = NULL 的結果都是「不知道」，所以一筆都查不到。要判斷是不是空的，必須用 IS NULL。\n【用生活例子想】問卷上有人「沒填年齡」，你不能說他的年齡「等於空白」，只能說他「沒有填」。\n【一句話記住】找空值用 IS NULL，找有值用 IS NOT NULL，永遠不要寫 = NULL。\n【小字典】NULL：資料庫裡「沒有值」的意思，不是 0 也不是空字串。IS NULL：專門用來檢查欄位是不是 NULL 的寫法。WHERE：篩選資料的條件。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(83, 'WHERE phone IS NULL;', TRUE, 1),
(83, 'WHERE phone = ''NULL'';', FALSE, 2),
(83, 'WHERE phone == NULL;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(84, '熊熊', '🐻', 'SQL 語法', 'ERROR 1054 (42S22): Unknown column ''Mochi'' in ''where clause''', '找不到欄位：WHERE 裡面有一個叫 Mochi 的欄位，但資料表沒有這個欄位', 'SELECT id, name, level\nFROM pets\nWHERE name = Mochi;', 3, '【哪裡出錯】Mochi 是寵物的名字，屬於「文字資料」，要用單引號包起來。沒加引號的話，MySQL 會以為 Mochi 是一個欄位名稱，結果找不到這個欄位就報錯。\n【用生活例子想】你跟店員說「我要找 可樂」，店員以為「可樂」是一個貨架的名字；你說「我要找『可樂』這瓶飲料」，他才知道你要的是商品。\n【一句話記住】欄位名稱不加引號，文字資料一定要加單引號。\n【小字典】字串：一段文字資料，例如 ''Mochi''。欄位：資料表裡的一直排，例如 name。Unknown column：MySQL 找不到你說的那個欄位。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(84, 'WHERE name = (Mochi);', FALSE, 1),
(84, 'WHERE name = ''Mochi'';', TRUE, 2),
(84, 'WHERE ''name'' = Mochi;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(85, '熊熊', '🐻', 'SQL 語法', 'ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''DESC coins LIMIT 3'' at line 3', '語法錯誤：第 3 行 DESC coins LIMIT 3 這附近的寫法 MySQL 看不懂', 'SELECT username, coins\nFROM users\nORDER BY DESC coins LIMIT 3;', 3, '【哪裡出錯】DESC 是用來說明「這個欄位要從大排到小」，所以要寫在欄位名稱的後面。寫在 coins 前面，MySQL 不知道你要排哪個欄位，就看不懂了。\n【用生活例子想】你跟老師說「請把成績，從高到低排」，要先說排什麼，再說怎麼排；只說「從高到低排成績」在 SQL 的世界裡是行不通的。\n【一句話記住】ORDER BY 欄位 DESC，先寫欄位再寫方向，LIMIT 放最後。\n【小字典】ORDER BY：把查詢結果排序。DESC：由大到小排列。ASC：由小到大排列，不寫的話預設就是 ASC。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(85, 'ORDER BY coins LIMIT 3 DESC;', FALSE, 1),
(85, 'ORDER BY coins ASC LIMIT 3;', FALSE, 2),
(85, 'ORDER BY coins DESC LIMIT 3;', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(86, '熊熊', '🐻', 'SQL 語法', 'ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''WHERE COUNT(*) >= 3'' at line 4', '語法錯誤：第 4 行 WHERE COUNT(*) >= 3 這附近的寫法 MySQL 看不懂', 'SELECT user_id, COUNT(*) AS order_count\nFROM orders\nGROUP BY user_id\nWHERE COUNT(*) >= 3;', 4, '【哪裡出錯】WHERE 是在「分組之前」一筆一筆篩資料，不能放在 GROUP BY 後面，也不能拿 COUNT 這種要分組後才算得出來的結果來比。分組之後再篩選，要用 HAVING。\n【用生活例子想】老師要找「交了 3 份以上作業的同學」，一定要先把作業依照同學分好堆、數完每堆有幾份，才能挑出來，這個「數完再挑」就是 HAVING。\n【一句話記住】篩原始資料用 WHERE，篩分組後的統計結果用 HAVING。\n【小字典】GROUP BY：把相同值的資料分成一組。HAVING：對分組後的結果加條件。COUNT(*)：計算有幾筆資料。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(86, 'WHERE order_count >= 3;', FALSE, 1),
(86, 'HAVING COUNT(*) >= 3;', TRUE, 2),
(86, 'AND COUNT(*) >= 3;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(87, '熊熊', '🐻', 'SQL 語法', '3 pets and 3 owners, but the query returns 9 rows matching every pet to every owner.', '寵物只有 3 隻、主人只有 3 位，查詢結果卻跑出 9 筆，每隻寵物都配上了每一位主人。', 'SELECT pets.name, users.username\nFROM pets\nJOIN users;', 3, '【哪裡出錯】JOIN 沒有寫 ON，MySQL 不知道兩張表要怎麼對應，就把每一隻寵物跟每一位主人全部配對一次，3 乘 3 變成 9 筆。要用 ON 告訴它「寵物的 owner_id 對到使用者的 id」。\n【用生活例子想】要把學生跟家長配對，卻沒給聯絡簿，只好讓每個學生跟每個家長都握一次手，結果亂成一團。\n【一句話記住】JOIN 一定要配 ON，寫清楚兩張表是靠哪個欄位連起來的。\n【小字典】JOIN：把兩張表的資料接在一起。ON：說明兩張表要用哪些欄位對應。外鍵：像 owner_id 這種指向另一張表 id 的欄位。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(87, 'JOIN users ON pets.id = users.id;', FALSE, 1),
(87, 'LEFT JOIN users;', FALSE, 2),
(87, 'JOIN users ON pets.owner_id = users.id;', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(88, '熊熊', '🐻', 'SQL 語法', 'ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column ''game.users.gender'' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by', '分組不完整：SELECT 裡的 gender 沒有放進 GROUP BY，MySQL 不知道每一組要顯示哪個 gender', 'SELECT city, gender, COUNT(*) AS total\nFROM users\nGROUP BY city;', 3, '【哪裡出錯】只用 city 分組的話，同一個城市裡會有男生也有女生，MySQL 不知道那一組的 gender 要顯示哪一個，所以拒絕執行。SELECT 裡沒有被聚合函式包住的欄位，都要放進 GROUP BY。\n【用生活例子想】你把全班依「住哪個城市」分組，然後問「台北組的性別是什麼？」，答案有男有女，根本回答不出來；要依「城市加性別」一起分組才說得清楚。\n【一句話記住】SELECT 裡沒被 COUNT、SUM 包起來的欄位，全部都要寫進 GROUP BY。\n【小字典】聚合函式：COUNT、SUM、AVG 這類把多筆資料算成一個值的函式。GROUP BY：把相同值的資料分成一組。only_full_group_by：MySQL 預設開啟的嚴格分組規則。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(88, 'GROUP BY city, gender;', TRUE, 1),
(88, 'GROUP BY gender;', FALSE, 2),
(88, 'GROUP BY city, total;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(89, '熊熊', '🐻', 'SQL 語法', 'Column count doesn''t match value count at row 1', '數量不合：你列了 3 個欄位，卻只給了 2 個值', 'app.post("/api/pets", async (req, res) => {\n  const { name, species, ownerId } = req.body;\n  await pool.query(\n    "INSERT INTO pets (name, species, owner_id) VALUES (?, ?)",\n    [name, species, ownerId]\n  );\n  res.json({ ok: true });\n});', 4, '【哪裡出錯】前面列了 name、species、owner_id 三個欄位，VALUES 裡卻只有兩個問號，多出來的 ownerId 沒有位置放，最後送出的 SQL 只有兩個值，欄位數和值數對不起來。\n【用生活例子想】你準備了 3 個便當要放進便當盒，但只拿了 2 個盒子，最後一個便當就沒地方裝。\n【一句話記住】INSERT 時欄位有幾個，VALUES 的值（或問號）就要有幾個，順序也要一樣。\n【小字典】INSERT INTO：新增一筆資料。佔位符 ?：先佔位置，之後由陣列裡的值依序填進去。req.body：前端送來的資料內容。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(89, '    "INSERT INTO pets (name, species) VALUES (?, ?, ?)",', FALSE, 1),
(89, '    "INSERT INTO pets (name, species, owner_id) VALUES (?)",', FALSE, 2),
(89, '    "INSERT INTO pets (name, species, owner_id) VALUES (?, ?, ?)",', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(90, '熊熊', '🐻', 'SQL 語法', 'Deleting the pet with id 5 wipes out every row in the pets table.', '只想刪掉 id 為 5 的寵物，按下刪除後，pets 資料表裡的寵物全部消失了。', 'app.delete("/api/pets/:id", async (req, res) => {\n  const id = req.params.id;\n  await pool.query("DELETE FROM pets", [id]);\n  res.json({ ok: true });\n});', 3, '【哪裡出錯】DELETE FROM pets 沒有加 WHERE，意思就是「刪掉 pets 裡的每一筆」。雖然後面有傳 [id]，但 SQL 裡沒有問號可以放，所以 id 根本沒被用到。\n【用生活例子想】你跟清潔人員說「把教室的東西清掉」，卻忘了說「只清 5 號桌」，結果整間教室都被清空。\n【一句話記住】寫 DELETE 和 UPDATE 前，先確認 WHERE 有沒有寫、條件對不對。\n【小字典】DELETE：刪除資料。WHERE：指定只對哪些資料動作。req.params：網址裡冒號那段的值，例如 /api/pets/5 裡的 5。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(90, '  await pool.query("DELETE FROM pets WHERE id = ?", [id]);', TRUE, 1),
(90, '  await pool.query("DELETE FROM pets WHERE id = id", [id]);', FALSE, 2),
(90, '  await pool.query("DELETE id FROM pets", [id]);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(91, '熊熊', '🐻', 'SQL 語法', 'There are 10 users, but the stats API returns total 7.', 'users 資料表裡有 10 位玩家，統計 API 回傳的 total 卻是 7。', 'app.get("/api/stats", async (req, res) => {\n  const [rows] = await pool.query(\n    "SELECT COUNT(nickname) AS total FROM users"\n  );\n  res.json({ total: rows[0].total });\n});', 3, '【哪裡出錯】COUNT(nickname) 只會數「nickname 有填值」的資料，有 3 位玩家沒取暱稱（是 NULL），就被跳過了。想數全部有幾筆，要用 COUNT(*)。\n【用生活例子想】老師想知道班上有幾個人，卻去數「有交作業的人」，沒交作業的同學就被漏掉了。\n【一句話記住】數全部筆數用 COUNT(*)，COUNT(欄位) 會跳過 NULL。\n【小字典】COUNT(*)：計算總共有幾筆資料。COUNT(欄位)：只計算那個欄位不是 NULL 的筆數。DISTINCT：去掉重複的值。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(91, '    "SELECT COUNT(DISTINCT nickname) AS total FROM users"', FALSE, 1),
(91, '    "SELECT COUNT(*) AS total FROM users"', TRUE, 2),
(91, '    "SELECT SUM(nickname) AS total FROM users"', FALSE, 3);

-- 咕咕：Express 回應
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(92, '咕咕', '🦉', 'Express 回應', 'TypeError: Cannot read properties of undefined (reading ''name'')', '讀不到東西：req.body 是 undefined，所以拿不到裡面的 name', 'const app = express();\napp.use(express.urlencoded({ extended: true }));\napp.post("/api/pets", (req, res) => {\n  const name = req.body.name;\n  res.json({ ok: true, name });\n});\napp.listen(3000);', 2, '【哪裡出錯】前端用 fetch 送來的是 JSON，可是後端只裝了拆「表單格式」的 express.urlencoded()，沒有裝「拆 JSON 包裹」的 express.json()，所以 req.body 是 undefined，讀 .name 就壞掉。\n【用生活例子想】快遞送來一個包裹，可是你手上沒有美工刀，包裹打不開，當然拿不到裡面的東西。\n【一句話記住】要讀 req.body，先寫 app.use(express.json())，而且括號不能少。\n【小字典】req.body：前端放在請求裡一起送來的資料。middleware：請求進到路由前先經過的關卡。express.json()：把 JSON 文字拆成物件的工具。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(92, 'app.use(express.json());', TRUE, 1),
(92, 'app.use(express.json);', FALSE, 2),
(92, 'app.use(express.text());', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(93, '咕咕', '🦉', 'Express 回應', 'Cannot POST /api/messages', '找不到路：後端沒有可以接 POST /api/messages 的路由', 'app.use(express.json());\napp.get("/api/messages", (req, res) => {\n  const text = req.body.text;\n  res.status(201).json({ ok: true, text });\n});', 2, '【哪裡出錯】前端用 POST 送出新留言，後端卻用 app.get 開路由，只接 GET。網址一樣但方法不同，Express 就說找不到 POST 這條路。\n【用生活例子想】你去郵局要寄包裹，可是櫃台只開了「領包裹」窗口，櫃員只能跟你說這裡不收件。\n【一句話記住】前端用什麼 method，後端就要用同一個 app.方法 來接。\n【小字典】GET：拿資料用的請求方法。POST：新增資料用的請求方法。路由：網址加上方法，決定由哪段程式處理。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(93, 'app.put("/api/messages", (req, res) => {', FALSE, 1),
(93, 'app.post("/api/messages", (req, res) => {', TRUE, 2),
(93, 'app.get("/api/messages/post", (req, res) => {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(94, '咕咕', '🦉', 'Express 回應', 'The terminal says the server runs on localhost:3000, but the browser cannot connect.', '終端機顯示「伺服器啟動：http://localhost:3000」，但用瀏覽器打開這個網址卻顯示「無法連上這個網站」。', 'const PORT = 3000;\napp.get("/api/hello", (req, res) => {\n  res.json({ msg: "hi" });\n});\napp.listen(5000, () => {\n  console.log(`伺服器啟動：http://localhost:${PORT}`);\n});', 5, '【哪裡出錯】伺服器實際開在 5000 號門，可是印出來的訊息用的是 PORT（3000），你照著訊息去敲 3000 號門，裡面根本沒人。\n【用生活例子想】店家招牌寫「3 號攤位」，老闆卻跑去 5 號攤位擺攤，客人照招牌找當然找不到。\n【一句話記住】port 只寫一次在變數裡，listen 和印出來的訊息都用同一個變數。\n【小字典】port：電腦上的門牌號碼，一個程式守一個門。app.listen()：讓伺服器開始在某個 port 等請求。localhost：指自己這台電腦。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(94, 'app.listen("PORT", () => {', FALSE, 1),
(94, 'app.listen(localhost:3000, () => {', FALSE, 2),
(94, 'app.listen(PORT, () => {', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(95, '咕咕', '🦉', 'Express 回應', 'Opening /api/pets/3 shows a blank page, though pet 3 exists in the database.', '打開 /api/pets/3，畫面一片空白，可是資料庫裡明明有 id 為 3 的寵物。', 'app.get("/api/pets/:id", async (req, res) => {\n  const id = req.query.id;\n  const [rows] = await pool.query("SELECT * FROM pets WHERE id = ?", [id]);\n  res.json(rows[0]);\n});', 2, '【哪裡出錯】3 是寫在網址路徑裡（/pets/3），要從 req.params 拿；req.query 是讀問號後面的東西（?id=3），這裡沒有，所以拿到 undefined，查不到資料。\n【用生活例子想】地址寫在信封正面，你卻去翻信封背面的備註欄找，當然什麼都沒有。\n【一句話記住】路徑裡的 :名字 用 req.params，問號後面的用 req.query。\n【小字典】req.params：網址路徑中用冒號標記的參數。req.query：網址問號後面的參數。undefined：代表「沒有這個值」。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(95, '  const id = req.params.id;', TRUE, 1),
(95, '  const id = req.body.id;', FALSE, 2),
(95, '  const id = req.params;', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(96, '咕咕', '🦉', 'Express 回應', 'Error [ERR_HTTP_HEADERS_SENT]: Cannot set headers after they are sent to the client', '回覆已經送出去了，不能再送一次：同一個請求被回覆了兩次', 'app.get("/api/users/:id", async (req, res) => {\n  const [rows] = await pool.query("SELECT * FROM users WHERE id = ?", [req.params.id]);\n  if (rows.length === 0) {\n    res.status(404).json({ error: "找不到使用者" });\n  }\n  res.json(rows[0]);\n});', 4, '【哪裡出錯】找不到使用者時已經回了 404，可是沒有 return，程式繼續往下跑到 res.json(rows[0]) 又回一次，同一個請求只能回覆一次，所以報錯。\n【用生活例子想】你已經把信寄出去了，又想在同一封信上補寫字，信早就不在你手上了。\n【一句話記住】回覆完要提早結束，就寫 return res.json()。\n【小字典】headers：回覆最前面的說明資料，例如狀態碼。return：讓函式在這裡停下來不再往下跑。404：找不到資料的狀態碼。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(96, '    res.status(404).send({ error: "找不到使用者" });', FALSE, 1),
(96, '    return res.status(404).json({ error: "找不到使用者" });', TRUE, 2),
(96, '    res.status(404);', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(97, '咕咕', '🦉', 'Express 回應', 'A wrong password still shows "Login successful" because the status is always 200.', '密碼打錯也顯示「登入成功」。前端是用 if (response.ok) 判斷，結果收到的狀態碼一直是 200。', 'app.post("/api/login", async (req, res) => {\n  const { email, password } = req.body;\n  const sql = "SELECT * FROM users WHERE email = ? AND password = ?";\n  const [rows] = await pool.query(sql, [email, password]);\n  if (rows.length === 0) {\n    return res.json({ error: "帳號或密碼錯誤" });\n  }\n  res.json({ ok: true, name: rows[0].name });\n});', 6, '【哪裡出錯】登入失敗時只回了錯誤文字，沒有設定狀態碼，Express 預設就是 200（成功），前端看 response.ok 是 true，就以為登入成功。\n【用生活例子想】考卷上寫滿錯，老師卻在分數欄打了一百分，家長只看分數就以為你考很好。\n【一句話記住】失敗就要用 res.status(錯誤碼) 說清楚，不要只寫在內容裡。\n【小字典】狀態碼：回覆附上的三位數代號，表示成功或失敗。200：成功。401：沒通過身分驗證。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(97, '    return res.json({ error: "帳號或密碼錯誤", status: 401 });', FALSE, 1),
(97, '    return res.sendStatus(401).json({ error: "帳號或密碼錯誤" });', FALSE, 2),
(97, '    return res.status(401).json({ error: "帳號或密碼錯誤" });', TRUE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(98, '咕咕', '🦉', 'Express 回應', 'After deleting, the page shows "Deleted post undefined" and the post is still there.', '按刪除後畫面顯示「已刪除第 undefined 篇」，重新整理後文章還在。', 'app.delete("/api/posts/:postid", async (req, res) => {\n  const postId = req.params.postId;\n  await pool.query("DELETE FROM posts WHERE id = ?", [postId]);\n  res.json({ ok: true, message: `已刪除第 ${req.params.postId} 篇` });\n});', 1, '【哪裡出錯】路由寫 :postid（小寫 i），下面卻都讀 req.params.postId（大寫 I）。名字大小寫不同就是兩個不同的名字，所以讀到 undefined，什麼都沒刪掉。\n【用生活例子想】置物櫃的名牌寫「小明」，你卻喊「小名」來拿東西，管理員說沒有這個人。\n【一句話記住】路由的 :名字 和 req.params.名字 要一字不差，大小寫也算。\n【小字典】路由參數：網址中用冒號開頭的位置，會變成 req.params 的屬性。大小寫敏感：大寫和小寫被當成不同的字。DELETE：刪除資料的請求方法。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(98, 'app.delete("/api/posts/:id", async (req, res) => {', FALSE, 1),
(98, 'app.delete("/api/posts/:postId", async (req, res) => {', TRUE, 2),
(98, 'app.delete("/api/posts/postId", async (req, res) => {', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(99, '咕咕', '🦉', 'Express 回應', 'TypeError: object is not iterable (cannot read property Symbol(Symbol.iterator))', '不能拆開：你想從這個東西裡拆出陣列，但它不是陣列', 'app.get("/api/products", async (req, res) => {\n  const [rows] = pool.query("SELECT * FROM products");\n  res.json(rows);\n});', 2, '【哪裡出錯】pool.query 要花時間查資料庫，它會先給你一個 Promise（還沒到的結果）。沒寫 await 就馬上拿 Promise 來拆成 [rows]，Promise 不是陣列，所以拆不開。\n【用生活例子想】你在飲料店拿到號碼牌，還沒等叫號就把號碼牌當成飲料往嘴裡倒。\n【一句話記住】查資料庫的那一行前面要加 await，等結果真的回來再用。\n【小字典】Promise：代表「之後才會拿到的結果」的東西。await：在這裡等 Promise 完成再往下走。async：寫在函式前面，函式裡才可以用 await。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(99, '  const [rows] = await pool.query("SELECT * FROM products");', TRUE, 1),
(99, '  const rows = pool.query("SELECT * FROM products");', FALSE, 2),
(99, '  const [rows] = async pool.query("SELECT * FROM products");', FALSE, 3);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation) VALUES
(100, '咕咕', '🦉', 'Express 回應', 'The terminal logs GET /api/todos, but the frontend never gets a response and times out.', '終端機有印出 GET /api/todos，但前端一直等不到回應，最後顯示請求逾時。', 'app.use(express.json());\napp.use((req, res, next) => {\n  console.log(`${req.method} ${req.url}`);\n  next;\n});\napp.get("/api/todos", (req, res) => {\n  res.json([{ id: 1, title: "買牛奶" }]);\n});', 4, '【哪裡出錯】這個 middleware 印完紀錄後只寫了 next 沒有加括號，等於只是提到它卻沒有呼叫。請求被卡在這一關，永遠到不了下面的 /api/todos 路由。\n【用生活例子想】排隊過安檢，安檢員看完你的包包卻忘了揮手讓你過，你就一直站在原地。\n【一句話記住】middleware 做完事，記得呼叫 next() 把請求交給下一關。\n【小字典】middleware：請求進到路由前會先經過的處理函式。next()：叫下一個關卡接手的函式。呼叫：在函式名稱後面加括號，讓它真的執行。');
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(100, '  res.next();', FALSE, 1),
(100, '  return;', FALSE, 2),
(100, '  next();', TRUE, 3);

SELECT pet_name, COUNT(*) AS 題數 FROM problems GROUP BY pet_name;
