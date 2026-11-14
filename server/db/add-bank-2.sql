-- 題庫擴充第二波：每隻動物再加 20 題，總共 300 題
-- 只新增不刪除；每一筆都先檢查 id 在不在，重複執行不會重複新增
-- 執行前先確認 SELECT MAX(id) FROM problems; 是 100
SET NAMES utf8mb4;

-- 小橘：TypeScript 型別
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 101, '小橘', '🐱', 'TypeScript 型別', 'Cannot assign to ''apiUrl'' because it is a read-only property.', '唯讀屬性不能改：apiUrl 被標成 readonly，你卻想把它換成新的值', 'interface Config {\n  readonly apiUrl: string;\n}\nconst config: Config = { apiUrl: "https://a.com" };\nconfig.apiUrl = "https://b.com";\nconsole.log(config.apiUrl);', 2, '【哪裡出錯】第 2 行把 apiUrl 標成 readonly，代表只能在建立物件時給值，之後第 5 行想改它，TypeScript 就擋下來。\n【用生活例子想】就像身分證上的出生日期，印好之後不能塗改，你想改就會被櫃台拒絕。\n【一句話記住】想改的屬性就不要加 readonly，加了 readonly 就只能讀不能改。\n【容易選錯】最像答案的是 readonly apiUrl?: string; 它只是讓屬性可以不填，但 readonly 還在，第 5 行重新指定值時一樣會報同樣的錯。\n【小字典】readonly：唯讀標記，屬性只能在建立時設定一次。interface：用來描述物件長相的型別。屬性：物件裡的一個欄位，例如 apiUrl。可選屬性：名稱後面加問號，表示可以不填。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 101);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 101 AS problem_id, '  apiUrl: string;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 101 AS problem_id, '  readonly apiUrl?: string;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 101 AS problem_id, '  readonly apiUrl: string | undefined;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 101);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 102, '小橘', '🐱', 'TypeScript 型別', 'Expected 2 arguments, but got 1.', '參數個數不對：這個函式要兩個數字，你卻只給了一個', 'function add(a: number, b: number) {\n  return a + b;\n}\nconst result = add(5);\nconsole.log(result);', 4, '【哪裡出錯】add 需要兩個數字 a 和 b，第 4 行只給了 5，少一個引數，TypeScript 就報錯。\n【用生活例子想】像點套餐要選主餐和飲料，你只說主餐，店員一定會問你飲料要什麼。\n【一句話記住】函式要幾個參數，呼叫時就要給幾個，型別也要對。\n【容易選錯】add(5, "3") 看起來有給兩個引數，但第二個是文字，不是 add 要的數字，TypeScript 還是會報型別不合的錯。\n【小字典】參數：函式用來接收資料的位置。引數：呼叫時實際傳進去的值。型別：資料的種類，例如數字或文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 102);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 102 AS problem_id, 'const result = add(5, 3, 1);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 102 AS problem_id, 'const result = add(5, 3);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 102 AS problem_id, 'const result = add(5, "3");' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 102);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 103, '小橘', '🐱', 'TypeScript 型別', 'Property ''push'' does not exist on type ''readonly string[]''.', '屬性不存在：這個陣列被標成唯讀，所以沒有 push 這個修改內容的方法可以用', 'let tags: readonly string[] = ["news", "tech"];\ntags.push("sport");\nconsole.log(tags.join(", "));', 2, '【哪裡出錯】tags 的型別是 readonly string[]，代表只能讀，不能改，所以 TypeScript 找不到 push 這個方法。\n【用生活例子想】就像圖書館的書只能借來看，不能在上面亂寫字。想加新書的話，要另外做一份新的清單。\n【一句話記住】唯讀陣列不能原地修改，要加東西就產生一個新陣列再放回去。\n【容易選錯】tags[tags.length] = "sport"; 看起來像是直接在尾巴放新東西，但唯讀陣列連用索引賦值也不行，tsc 會說 Index signature in type ''readonly string[]'' only permits reading，所以還是報錯。\n【小字典】readonly：唯讀，只能看不能改。push：把新元素加到陣列尾端的方法。展開運算子：用 ... 把舊陣列的內容攤開放進新陣列。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 103);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 103 AS problem_id, 'tags[tags.length] = "sport";' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 103 AS problem_id, 'tags.unshift("sport");' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 103 AS problem_id, 'tags = [...tags, "sport"];' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 103);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 104, '小橘', '🐱', 'TypeScript 型別', 'Property ''Pending'' does not exist on type ''typeof Status''.', '屬性不存在：Status 這個列舉裡沒有叫 Pending 的成員，你卻想去拿它。', 'enum Status {\n  Active,\n  Inactive,\n}\nconst current: Status = Status.Pending;\nconsole.log(current);', 5, '【哪裡出錯】enum Status 只宣告了 Active 和 Inactive，第 5 行卻去拿不存在的 Status.Pending，TypeScript 找不到就報錯。\n【用生活例子想】就像餐廳菜單只有兩道菜，你卻點了菜單上沒有的第三道，店員會告訴你沒有這道菜。\n【一句話記住】enum 的成員要先在列舉裡寫好，才能用 名稱.成員 的方式拿來用。\n【容易選錯】改成 Status.Done 看起來像換了一個成員，但 Done 也沒有在 Status 裡宣告，一樣會報找不到屬性。直接寫 "Active" 字串也不行，因為數字列舉的型別不接受字串。\n【小字典】enum：列舉，把一組固定的選項取好名字。成員：列舉裡面宣告的每一個名字，例如 Active。typeof Status：Status 這個列舉物件本身的型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 104);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 104 AS problem_id, 'const current: Status = Status.Active;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 104 AS problem_id, 'const current: Status = Status.Done;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 104 AS problem_id, 'const current: Status = "Active";' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 104);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 105, '小橘', '🐱', 'TypeScript 型別', 'Type ''"email"'' is not assignable to type ''keyof User''.', '型別不合：keyof User 只允許 User 有的屬性名稱，你卻給了 User 裡沒有的 "email"。', 'type User = { name: string; age: number };\nconst user: User = { name: "Amy", age: 20 };\nconst key: keyof User = "email";\nconsole.log(user[key]);', 3, '【哪裡出錯】keyof User 代表 "name" 或 "age" 這兩個名字，第 3 行卻放了 User 裡沒有的 "email"。\n【用生活例子想】就像班級座號表只有小明和小華兩個名字，你卻叫了一個不在名單上的人來領獎，老師會說名單上沒有這個人。\n【一句話記住】keyof 的變數只能放那個型別真的有的屬性名稱。\n【容易選錯】改成 const key: string = "email" 看起來很合理，但 string 範圍太大，user[key] 時 TypeScript 無法確定 User 有這個屬性，還是會報錯。\n【小字典】keyof：取出一個型別所有屬性名稱組成的聯合型別。字面值型別：只允許某一個固定值的型別，例如 "name"。屬性：物件裡的欄位，例如 name 和 age。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 105);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 105 AS problem_id, 'const key: string = "email";' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 105 AS problem_id, 'const key: keyof User = "name";' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 105 AS problem_id, 'const key: keyof User = "Age";' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 105);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 106, '小橘', '🐱', 'TypeScript 型別', 'Property ''seconds'' has no initializer and is not definitely assigned in the constructor.', '屬性沒有初始值：seconds 宣告成數字，但建構子只在某些情況才給值，TypeScript 不放心。', 'class Timer {\n  seconds: number;\n  constructor(autoStart: boolean) {\n    if (autoStart) {\n      this.seconds = 1;\n    }\n  }\n  next = () => this.seconds + 1;\n}', 2, '【哪裡出錯】seconds 被宣告成 number，但建構子裡只有 autoStart 是 true 才會給值，傳 false 時 seconds 就一直是空的。\n【用生活例子想】就像發給每個人一張點數卡，說明上寫一定有點數，結果有些卡根本沒儲值，拿去刷就出事。\n【一句話記住】屬性宣告成什麼型別，就要保證每一條路都先給它一個值，最簡單的做法是宣告時直接給預設值。\n【容易選錯】選 seconds?: number; 最像答案，因為原本的錯誤會消失。但這樣 seconds 變成可能是 undefined，下面 this.seconds + 1 就會換成新的錯誤，還是編譯不過。\n【小字典】屬性：掛在物件或類別上的變數。初始化：第一次給變數一個起始值。建構子：用 new 建立物件時最先執行的函式。型別：規定變數可以放哪一種資料的標籤。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 106);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 106 AS problem_id, '  seconds?: number;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 106 AS problem_id, '  seconds: number | undefined;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 106 AS problem_id, '  seconds: number = 0;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 106);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 107, '小橘', '🐱', 'TypeScript 型別', 'Tuple type ''[number, number]'' of length ''2'' has no element at index ''2''.', 'tuple 沒有那個位置：這個函式回傳的 tuple 只有兩個元素，你卻想拿第三個位置的值。', 'function getRange(values: number[]): [number, number] {\n  return [Math.min(...values), Math.max(...values)];\n}\nconst bounds = getRange([4, 9, 2]);\nconst lowest = bounds[0];\nconst highest = bounds[2];\nconsole.log(lowest, highest);', 6, '【哪裡出錯】getRange 回傳的型別是 [number, number]，只有位置 0 和位置 1，但第 6 行去拿位置 2，那裡什麼都沒有。\n【用生活例子想】就像一個只有兩格的藥盒，你卻想打開第三格拿藥，TypeScript 在你伸手之前就先告訴你那一格不存在。\n【一句話記住】tuple 的位置從 0 開始數，長度是 2 就只能用 0 和 1。\n【容易選錯】bounds[2] as number 看起來像是在告訴 TypeScript 放心，但 as 只能改變型別的說法，不能讓第三格憑空出現，位置 2 還是不存在，編譯照樣報同樣的錯。\n【小字典】tuple：固定長度、每個位置型別都寫死的陣列。索引：陣列裡的位置編號，從 0 開始。型別檢查：程式執行前先檢查資料用得對不對。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 107);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 107 AS problem_id, 'const highest = bounds[1];' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 107 AS problem_id, 'const highest = bounds[2] as number;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 107 AS problem_id, 'const highest = bounds[3];' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 107);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 108, '小橘', '🐱', 'TypeScript 型別', 'Type ''"done"'' is not assignable to type ''never''.', '型別不合：switch 最後想確認每種狀態都處理過，但編譯器說還有 "done" 沒被處理到。', 'type Status = "idle" | "loading" | "done";\nfunction label(status: Status): string {\n  switch (status) {\n    case "idle": return "待命";\n    case "loading": return "載入中";\n    case "loading": return "完成";\n    default:\n      const unreachable: never = status;\n      return unreachable;\n  }\n}\nconsole.log(label("done"));', 6, '【哪裡出錯】第 6 行的 case 又寫了一次 "loading"，應該要寫 "done"，所以 "done" 沒人處理，掉到 default 後型別就不是 never。\n【用生活例子想】就像點名，名單上有三個人，你卻把同一個人叫了兩次，最後一個人沒被叫到，老師一核對就發現有人漏掉。\n【一句話記住】用 never 做窮舉檢查時，每一種可能的值都要有自己的 case，複製貼上後記得改名字。\n【容易選錯】換成 case "finish" 看起來像是在處理完成狀態，但 "finish" 不在 Status 裡，編譯器會說它不能和 Status 比對，而且 "done" 還是沒人處理，default 的 never 照樣報錯。\n【小字典】never：代表不可能出現的型別，沒有任何值能放進去。窮舉檢查：確認每一種可能都處理過。聯集型別：用 | 把幾個可選的值串在一起的型別。case：switch 裡對應某一個值的分支。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 108);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 108 AS problem_id, '    case "idle": return "完成";' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 108 AS problem_id, '    case "done": return "完成";' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 108 AS problem_id, '    case "finish": return "完成";' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 108);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 109, '小橘', '🐱', 'TypeScript 型別', 'Property ''length'' does not exist on type ''T''.', '屬性不存在：T 可以是任何型別，TypeScript 不敢保證每種型別都有 length 這個屬性。', 'function getLength<T>(item: T): number {\n  return item.length;\n}\nconst nameLength = getLength("Momo");\nconst listLength = getLength([1, 2, 3]);\nconsole.log(nameLength, listLength);', 1, '【哪裡出錯】泛型 T 沒有任何限制，什麼型別都能傳進來，像數字就沒有 length，所以第 2 行用 item.length 會被擋下來。\n【用生活例子想】就像你說「任何東西都可以放進這個盒子」，卻又要量它的長度，萬一放進一顆球就量不出來。要先規定「只收有長度的東西」。\n【一句話記住】想在泛型裡用某個屬性，就要用 extends 先規定它一定有這個屬性。\n【容易選錯】把 T 限制成 string 看起來也能用 length，第 2 行的錯誤會消失。但第 5 行傳進去的是陣列，不是字串，TypeScript 會改在那裡報錯，所以還是不對。\n【小字典】泛型：先用 T 當代號，等呼叫時才決定真正的型別。extends：在泛型裡表示 T 至少要符合的條件。屬性：物件身上的資料，例如字串的 length。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 109);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 109 AS problem_id, 'function getLength<T extends string>(item: T): number {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 109 AS problem_id, 'function getLength<T extends object>(item: T): number {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 109 AS problem_id, 'function getLength<T extends { length: number }>(item: T): number {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 109);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 110, '小橘', '🐱', 'TypeScript 型別', '''Cart'' cannot be used as a value because it was imported using ''import type''.', '不能當值使用：Cart 是用 import type 匯入的，卻被拿來 new 出物件。', 'import type { Cart } from "./cart.js";\n\nfunction checkout(cart: Cart) {\n  return cart.total();\n}\nconst cart = new Cart();\ncart.add("apple", 30);\ncart.add("tea", 45);\nconsole.log(checkout(cart));', 1, '【哪裡出錯】第 1 行用 import type 匯入 Cart，TypeScript 會把它當成只有「型別」的東西，執行時根本不存在，所以第 6 行 new Cart() 就報錯。\n【用生活例子想】import type 像是只拿到商品的說明書，可以照說明書檢查規格，但沒辦法用說明書直接變出一台真的機器。\n【一句話記住】要 new 或呼叫的東西，就要用一般的 import，只有單純當型別標註才用 import type。\n【容易選錯】改成 import { type Cart } 看起來像是換了寫法，但 type 這個字還是把 Cart 標成只有型別，所以 new Cart() 一樣會報同樣的錯。\n【小字典】import type：只匯入型別的寫法，編譯後會被整句拿掉。類別 class：同時是型別也是可以 new 的值。new：用類別做出一個新物件的動作。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 110);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 110 AS problem_id, 'import { Cart } from "./cart.js";' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 110 AS problem_id, 'import { type Cart } from "./cart.js";' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 110 AS problem_id, 'import type { Cart } from "./cart";' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 110);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 111, '小橘', '🐱', 'TypeScript 型別', 'Cannot create an instance of an abstract class.', '不能建立抽象類別的實例：abstract class 只是設計藍圖，不能直接 new 出物件。', 'abstract class Shape {\n  abstract area(): number;\n}\nclass Circle extends Shape {\n  constructor(private r: number) { super(); }\n  area() { return Math.PI * this.r ** 2; }\n}\nconst shape = new Shape();\nconsole.log(shape.area());', 8, '【哪裡出錯】第 8 行用 new 直接建立 Shape，但 Shape 是 abstract class，area 只有宣告、沒有實作，所以 TypeScript 不讓你直接建立它。\n【用生活例子想】abstract class 像一張「房子設計草圖」，上面寫著要有門窗，但沒人能住在草圖裡，要照草圖蓋出真正的房子才行。\n【一句話記住】abstract class 只能被繼承，要 new 就 new 繼承它、有完整實作的子類別。\n【容易選錯】有人會想幫 new Shape 加上參數，寫成 new Shape(2)，但問題不在參數，Shape 本身就不能被 new，所以還是一樣報錯。\n【小字典】abstract class：抽象類別，只當模板使用，不能直接建立物件。new：用類別建立出一個物件的指令。extends：讓子類別繼承父類別的內容。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 111);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 111 AS problem_id, 'const shape = new Shape(2);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 111 AS problem_id, 'const shape = new Circle(2);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 111 AS problem_id, 'const shape: Circle = new Shape();' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 111);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 112, '小橘', '🐱', 'TypeScript 型別', 'Type ''string | undefined'' is not assignable to type ''string''.', '型別不相符：函式說一定會回傳文字，但找不到人的時候 ?. 會給出 undefined', 'type User = { id: number; name: string };\nconst users: User[] = [{ id: 1, name: "Amy" }, { id: 2, name: "Ben" }];\nfunction getUserName(id: number): string {\n  const user = users.find((u) => u.id === id);\n  return user?.name;\n}\nconsole.log(getUserName(1));\nconsole.log(getUserName(3));', 5, '【哪裡出錯】find 找不到人時會得到 undefined，所以 user?.name 的型別是 string | undefined，但函式承諾回傳 string，TypeScript 就報錯。\n【用生活例子想】像櫃台說「我一定給你一張名牌」，可是找不到人時手上空空的，那就違反承諾了，要先準備一張「查無此人」的備用名牌。\n【一句話記住】?. 會多帶一個 undefined 出來，要用 ?? 補上預設值才算真的回傳 string。\n【容易選錯】改成 return user.name; 看起來最直接，但 user 可能是 undefined，TypeScript 會說 ''user'' is possibly ''undefined''，錯誤只是換了個地方。\n【小字典】可選鏈 ?.：物件可能不存在時，安全地往下取屬性，不存在就得到 undefined。??：左邊是 undefined 或 null 時，改用右邊的值。聯合型別：用 | 表示可以是好幾種型別其中之一。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 112);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 112 AS problem_id, '  return user.name;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 112 AS problem_id, '  return user?.name ?? 0;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 112 AS problem_id, '  return user?.name ?? "查無此人";' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 112);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 113, '小橘', '🐱', 'TypeScript 型別', 'Property ''balance'' is private and only accessible within class ''Account''.', '屬性是私有的：balance 被標成 private，只有類別裡面的程式可以讀，外面不能直接拿。', 'class Account {\n  private balance = 0;\n  deposit(n: number) { this.balance += n; }\n  getBalance() { return this.balance; }\n}\nconst acc = new Account();\nacc.deposit(100);\nconsole.log(acc.balance);', 8, '【哪裡出錯】balance 前面寫了 private，表示只有 Account 類別裡面的程式能用，第 8 行在類別外面直接讀 acc.balance，TypeScript 就擋下來。\n【用生活例子想】private 就像銀行的保險箱，客人不能自己伸手進去拿錢，要請櫃台人員（getBalance）幫你查。\n【一句話記住】private 的東西在外面不能直接碰，要透過類別提供的公開方法來拿。\n【容易選錯】改成 acc.balance() 看起來像是在呼叫方法，但 balance 還是 private，而且它是數字不是函式，所以一樣會報錯。\n【小字典】private：只能在類別內部使用的成員。method：類別裡的函式，也叫方法。getter 方法：專門把內部資料安全地回傳給外面的方法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 113);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 113 AS problem_id, 'console.log(acc.getBalance());' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 113 AS problem_id, 'console.log(acc.balance());' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 113 AS problem_id, 'console.log(acc.getbalance());' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 113);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 114, '小橘', '🐱', 'TypeScript 型別', 'Function lacks ending return statement and return type does not include ''undefined''.', '函式缺少結尾的回傳：宣告會回傳字串，但找不到人的時候，函式走到最後什麼都沒回傳。', 'type User = { id: number; name: string };\nconst users: User[] = [{ id: 1, name: "Amy" }, { id: 2, name: "Ben" }];\nfunction findName(id: number): string {\n  for (const user of users) {\n    if (user.id === id) {\n      return user.name;\n    }\n  }\n}\nconsole.log(findName(1));', 3, '【哪裡出錯】第 3 行說這個函式一定會回傳 string，但迴圈找不到 id 時，程式會直接跑到最後，什麼都沒回傳，等於回傳 undefined，所以和宣告不一致。\n【用生活例子想】像櫃台說「我一定給你一張號碼牌」，但名單上找不到你的時候，櫃台人員卻兩手空空，沒有發牌也沒說明。\n【一句話記住】函式可能找不到東西時，回傳型別要寫成 string | undefined，老實告訴呼叫的人可能沒有結果。\n【容易選錯】最像正確答案的是 string | null，但函式找不到時實際上是什麼都沒回傳，也就是 undefined，不是 null，所以 TypeScript 還是會報同樣的錯。\n【小字典】回傳型別：函式承諾會交出什麼型別的值。聯集型別：用 | 表示值可能是好幾種型別之一。undefined：代表沒有值，沒寫 return 時函式就會回傳它。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 114);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 114 AS problem_id, 'function findName(id: number): string | null {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 114 AS problem_id, 'function findName(id: number): string | undefined {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 114 AS problem_id, 'function findName(id: number): void {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 114);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 115, '小橘', '🐱', 'TypeScript 型別', 'Argument of type ''string'' is not assignable to parameter of type ''Direction''.', '參數型別不合：move 只收 Direction 那幾個固定字串，但傳進去的 startDir 被當成一般的 string。', 'type Direction = "up" | "down" | "left" | "right";\nconst position = { x: 0, y: 0 };\nfunction move(dir: Direction) {\n  if (dir === "up") position.y += 1;\n  if (dir === "down") position.y -= 1;\n}\nconst settings = { startDir: "up", speed: 2 };\nmove(settings.startDir);\nconsole.log(position);', 7, '【哪裡出錯】錯誤雖然跳在第 8 行呼叫 move 的地方，但真正的原因在第 7 行：物件裡的 "up" 會被 TypeScript 放寬成一般的 string，不再是 Direction 的 "up"。\n【用生活例子想】就像餐廳菜單只能點「紅茶、綠茶」，你在便條紙上只寫「飲料」，店員就不知道你點的是不是菜單上那一項。要在紙上寫清楚是哪一種才行。\n【一句話記住】物件裡的字串預設會變寬，要加 as Direction 或 as const 才會保持固定的值。\n【容易選錯】最像正確答案的是把 settings 明確標成 { startDir: string; speed: number }，但這樣 startDir 還是一般的 string，傳進 move 一樣會報同樣的錯。\n【小字典】字面值型別：只允許某一個固定值的型別，例如 "up"。型別放寬：TypeScript 為了讓你之後能改值，把 "up" 當成 string。as 斷言：告訴編譯器這個值要當成哪種型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 115);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 115 AS problem_id, 'const settings: { startDir: string; speed: number } = { startDir: "up", speed: 2 };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 115 AS problem_id, 'let settings = { startDir: "up", speed: 2 };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 115 AS problem_id, 'const settings = { startDir: "up" as Direction, speed: 2 };' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 115);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 116, '小橘', '🐱', 'TypeScript 型別', 'Property ''radius'' does not exist on type ''Square''.', '屬性不存在：編譯器說 Square 沒有 radius 這個屬性，但你明明在 Shape 裡看過它。', 'type Circle = { kind: "circle"; radius: number };\ntype Square = { kind: "square"; side: number };\ntype Shape = Circle | Square;\n\nfunction area(shape: Shape): number {\n  if (shape.kind === "circle") {\n    return Math.PI * shape.radius ** 2;\n  }\n  return shape.radius * shape.radius;\n}\n\nconsole.log(area({ kind: "square", side: 3 }));', 9, '【哪裡出錯】第 6 行的 if 已經把圓形處理完並 return 了，所以第 9 行時 TypeScript 知道 shape 只剩 Square，而 Square 只有 side，沒有 radius。\n【用生活例子想】就像餐廳先把點圓盤餐的客人都服務完了，剩下的桌子一定是點方盤餐的，你不能再拿圓盤的規格去招呼他們。\n【一句話記住】用 kind 判斷過的分支，剩下的就是另一種型別，要用它自己的屬性。\n【容易選錯】把其中一個改成 side 的那個選項（shape.radius * shape.side）看起來改了一半，但前面的 shape.radius 還在，Square 還是沒有 radius，所以一樣會報同樣的錯。\n【小字典】判別聯合：用同一個欄位（例如 kind）的不同值來區分幾種型別的聯合型別。型別縮小：TypeScript 根據 if 判斷，推測變數現在只可能是哪一種型別。屬性：物件裡的欄位，例如 side 或 radius。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 116);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 116 AS problem_id, '  return shape.side * shape.side;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 116 AS problem_id, '  return shape.radius * shape.side;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 116 AS problem_id, '  return (shape as Circle).side * shape.side;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 116);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 117, '小橘', '🐱', 'TypeScript 型別', '''config'' is of type ''unknown''.', '型別是 unknown：變數 config 被當成「什麼都不知道」的型別，所以不能直接拿它的屬性來用。', 'type Config = { port: number };\nfunction parseConfig(text: string): unknown {\n  return JSON.parse(text);\n}\nconst config = parseConfig(''{"port":3000}'');\nconst port: number = config.port;\nconsole.log(port);', 2, '【哪裡出錯】錯誤出現在第 6 行的 config.port，但真正的原因在第 2 行：函式的回傳型別寫成 unknown，所以 config 什麼屬性都不能碰。\n【用生活例子想】就像外送員拿到一個沒貼標籤的盒子，你卻直接問他裡面的飲料是不是無糖，他當然答不出來。盒子要先貼上標籤，他才知道裡面是什麼。\n【一句話記住】unknown 是「還沒確認的型別」，要先標清楚或檢查過，才能拿來用。\n【容易選錯】改成 object 看起來比 unknown 更具體，但 object 只表示「是個物件」，並沒有 port 這個屬性，所以第 6 行還是會報 Property ''port'' does not exist on type ''object''。\n【小字典】unknown：什麼型別都可能，使用前一定要先檢查。回傳型別：函式執行完交出來的資料是什麼型別。型別收窄：用判斷或標註，把寬鬆的型別縮成更明確的型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 117);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 117 AS problem_id, 'function parseConfig(text: string): object {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 117 AS problem_id, 'function parseConfig(text: string): Config {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 117 AS problem_id, 'function parseConfig(text: string): Config | undefined {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 117);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 118, '小橘', '🐱', 'TypeScript 型別', 'This comparison appears to be unintentional because the types ''"error"'' and ''"idle"'' have no overlap.', '比較沒有重疊：到了這一行，status 只可能剩下一種值，你卻拿它去跟一個已經排除掉的值比較', 'type Status = "idle" | "loading" | "error";\nfunction label(status: Status): string {\n  if (status === "idle") return "待命";\n  if (status === "loading") return "載入中";\n  if (status === "idle") return "出錯了";\n  return "未知";\n}\nconsole.log(label("error"));', 5, '【哪裡出錯】第 3 行和第 4 行已經處理掉 "idle" 和 "loading" 並提早 return，所以到第 5 行 status 只剩 "error"，卻又拿它跟 "idle" 比較，永遠不可能成立。\n【用生活例子想】像籃子裡本來有蘋果、香蕉、櫻桃，你已經把蘋果和香蕉拿走了，現在又問「籃子裡還有蘋果嗎？」答案一定是沒有，問這題沒有意義。\n【一句話記住】前面用 return 排除過的值，後面的 TypeScript 都當它不存在，再拿來比較就會報錯。\n【容易選錯】改成 status == "idle" 看起來只是換個比較符號，但 == 一樣是在比 "error" 和 "idle"，兩者沒有重疊，TypeScript 還是報同樣的錯。\n【小字典】型別縮小：TypeScript 根據 if 判斷把可能的型別範圍變小。字面值型別：只允許某幾個固定字串的型別。提早 return：條件成立就直接結束函式，後面的程式碼就不會再碰到這種情況。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 118);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 118 AS problem_id, '  if (status == "idle") return "出錯了";' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 118 AS problem_id, '  if (status === "Error") return "出錯了";' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 118 AS problem_id, '  if (status === "error") return "出錯了";' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 118);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 119, '小橘', '🐱', 'TypeScript 型別', 'Property ''name'' does not exist on type ''boolean''.', '屬性不存在：TypeScript 說 u 是 boolean，boolean 沒有 name 可以讀。原因在更上面建立陣列的那一行。', 'type User = { id: number; name: string; active: boolean };\nconst users: User[] = [\n  { id: 1, name: "Amy", active: true },\n  { id: 2, name: "Ben", active: false },\n];\nconst activeUsers = users.map((u) => u.active);\nactiveUsers.forEach((u) => {\n  console.log(u.name);\n});', 6, '【哪裡出錯】第 6 行用 map，每個使用者都被換成 u.active，所以 activeUsers 變成 boolean[]，第 8 行的 u 只是 true 或 false，沒有 name。\n【用生活例子想】像老師點名，map 是把每位同學換成「到了沒」的打勾紀錄，名單上就只剩勾勾，沒有名字了。想留下到的同學本人，要用 filter 把人挑出來。\n【一句話記住】map 是把每個元素換成新東西，filter 才是把符合條件的元素原樣留下。\n【容易選錯】改成 users.map((u) => u.name) 看起來有碰到 name，但陣列會變成 string[]，u 是字串，字串沒有 name 屬性，第 8 行還是同樣報錯。\n【小字典】map：把陣列每個元素轉換成新值，產生新陣列。filter：留下條件成立的元素，元素本身不變。型別推論：TypeScript 會根據程式內容自動猜出變數的型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 119);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 119 AS problem_id, 'const activeUsers = users.filter((u) => u.active);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 119 AS problem_id, 'const activeUsers = users.map((u) => u.name);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 119 AS problem_id, 'const activeUsers = users.map((u) => u.active && u);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 119);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 120, '小橘', '🐱', 'TypeScript 型別', 'Element implicitly has an ''any'' type because expression of type ''string'' can''t be used to index type ''Prices''.', '索引型別不合：Prices 只有三個固定的屬性名稱，但迴圈拿到的 name 是任意文字，TypeScript 不敢保證它是對的名稱。', 'type Prices = {\n  apple: number;\n  banana: number;\n  cherry: number;\n};\nconst prices: Prices = { apple: 30, banana: 20, cherry: 90 };\nlet total = 0;\nfor (const name of Object.keys(prices)) {\n  total += prices[name];\n}\nconsole.log(total);', 9, '【哪裡出錯】Object.keys(prices) 回傳的是 string[]，所以 name 的型別是 string，不是 "apple" | "banana" | "cherry"。第 9 行拿 string 去取 Prices 的屬性，TypeScript 無法確定這個名字一定存在，就報錯了。\n【用生活例子想】Prices 像一張只有三格的置物櫃，格子名字固定是 apple、banana、cherry。你手上拿著一張寫著「隨便一個字」的鑰匙牌，櫃子當然不敢讓你開，要先確認牌子上寫的是那三個名字之一。\n【一句話記住】用 Object.keys 取出來的名字是 string，要用 as keyof 型別 告訴 TypeScript 它是物件真正有的屬性名稱。\n【容易選錯】最像的是 prices[name] as number，看起來像是把結果轉成數字就好。但錯誤出在括號裡的索引 name，不是結果；as number 只轉換整個取值結果，索引那一步還是不合法，所以同樣的錯誤還是會出現。\n【小字典】keyof：取出一個型別所有屬性名稱組成的聯合型別。索引：用 obj[key] 的方式依名字取得屬性值。型別斷言：用 as 告訴 TypeScript 某個值該當成哪種型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 120);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 120 AS problem_id, '  total += prices[name] as number;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 120 AS problem_id, '  total += prices[name as keyof Prices];' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 120 AS problem_id, '  total += prices[name as string];' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 120);

-- 慢慢：非同步 await
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 121, '慢慢', '🐢', '非同步 await', 'The console prints an array of Promise objects instead of the three names.', '印出來的是一排 Promise 物件，不是三個名字：map 裡呼叫 async 函式只會拿到 Promise，還沒拿到真正的值。', 'const getName = async (id) => {\n  return "user-" + id;\n};\nconst ids = [1, 2, 3];\nconst names = ids.map((id) => getName(id));\nconsole.log(names);', 5, '【哪裡出錯】第 5 行的 map 每次呼叫 getName 都只會拿到一個 Promise，所以 names 裡裝的是三張「取貨單」，不是真正的名字。\n【用生活例子想】你點了三杯飲料，店員給你三張取餐號碼牌，號碼牌不是飲料，要等在櫃台全部領到手才能喝。\n【一句話記住】map 出來一堆 Promise，要用 await Promise.all 把它們一次等完。\n【容易選錯】第二個選項只在 map 前面加 await，但 await 等的是整個陣列，不是陣列裡的 Promise，所以 names 還是一排 Promise。\n【小字典】Promise：代表「之後才會有結果」的承諾物件。Promise.all：收一個 Promise 陣列，等全部完成後給你結果陣列。await：暫停等 Promise 完成再拿值。map：把陣列每一項轉換後組成新陣列。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 121);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 121 AS problem_id, 'const names = await ids.map((id) => getName(id));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 121 AS problem_id, 'const names = await Promise.all(ids.map((id) => getName(id)));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 121 AS problem_id, 'const names = ids.map(async (id) => await getName(id));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 121);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 122, '慢慢', '🐢', '非同步 await', 'Error: Network down', '錯誤沒被接住：明明有寫 try/catch，程式還是被錯誤弄當，catch 裡的訊息也沒印出來。', 'const save = async () => { throw new Error("Network down"); };\ntry {\n  save();\n} catch (err) {\n  console.log("儲存失敗");\n}', 3, '【哪裡出錯】save() 是 async 函式，錯誤會被包進 Promise 裡，沒有 await 的話，try/catch 看不到這個錯誤，程式就當掉了。\n【用生活例子想】就像你請朋友去辦事，卻沒等他回報就離開現場，他搞砸了也沒人在旁邊處理。加上 await 就是站在原地等他回報。\n【一句話記住】想用 try/catch 接 async 函式的錯誤，呼叫它的時候一定要加 await。\n【容易選錯】save().then(...) 看起來有在處理 Promise，但它只處理成功的情況，失敗時沒有人接，錯誤還是會跑出去，catch 裡的訊息一樣不會印出來。\n【小字典】async 函式：一定會回傳 Promise 的函式。Promise：代表以後才會有結果的東西，結果可能成功也可能失敗。await：等 Promise 完成再繼續往下走。try/catch：把可能出錯的程式包起來，出錯時跳去 catch 處理。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 122);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 122 AS problem_id, '  save().then(() => console.log("儲存成功"));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 122 AS problem_id, '  Promise.resolve(save());' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 122 AS problem_id, '  await save();' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 122);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 123, '慢慢', '🐢', '非同步 await', 'The program prints no wait instead of waited, because the sleep function finishes immediately.', '等待沒有生效：sleep(200) 應該要等 0.2 秒，結果一下子就結束了，畫面印出 no wait。', 'const sleep = (ms) => new Promise((resolve) => {\n  setTimeout(resolve(), ms);\n});\nconst start = Date.now();\nawait sleep(200);\nconsole.log(Date.now() - start >= 150 ? "waited" : "no wait");', 2, '【哪裡出錯】第 2 行寫成 resolve()，多了括號，函式當場就被執行，Promise 立刻完成，setTimeout 根本沒機會幫你等。\n【用生活例子想】就像你跟朋友說「十分鐘後再按電梯」，結果你現在就按了，電梯馬上來，完全沒有等十分鐘。\n【一句話記住】setTimeout 要收「函式本身」，後面不要加括號，不然就變成現在立刻執行。\n【容易選錯】第二個選項 () => resolve 看起來有包成函式，但箭頭函式只是回傳 resolve 本身，並沒有真的呼叫它，Promise 永遠不會完成，程式會一直卡住。\n【小字典】resolve：告訴 Promise「事情做完了」的按鈕。Promise：先承諾之後會有結果的盒子。setTimeout：過一段時間再執行某個函式的計時器。回呼函式：先交給別人，等時間到再幫你呼叫的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 123);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 123 AS problem_id, '  setTimeout(resolve, ms);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 123 AS problem_id, '  setTimeout(() => resolve, ms);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 123 AS problem_id, '  setTimeout(resolve(ms), 0);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 123);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 124, '慢慢', '🐢', '非同步 await', 'The console prints Promise { 95 } instead of the number 95.', '印出的不是分數 95，而是一個 Promise 物件：async 函式回傳的是 Promise，不是直接的數字。', 'async function getScore() {\n  return 95;\n}\nconst score = getScore();\nconsole.log("Score:", score);', 4, '【哪裡出錯】第 4 行呼叫 async 函式 getScore()，但沒有 await，所以 score 拿到的是 Promise 這個「承諾」，不是裡面的 95。\n【用生活例子想】就像你在餐廳點餐，服務生先給你一張取餐號碼牌，那張牌不是餐點，要等叫號領餐才算拿到。\n【一句話記住】async 函式一定回傳 Promise，想要裡面的值就加 await。\n【容易選錯】選 getScore().then((n) => n) 看起來有處理結果，但 then 會回傳新的 Promise，score 還是 Promise，印出來仍然不是 95。\n【小字典】async：加在函式前面，讓函式的回傳值自動包成 Promise。Promise：代表一件還沒做完的事，之後會有結果。await：等 Promise 完成，並拿出裡面的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 124);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 124 AS problem_id, 'const score = getScore().then((n) => n);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 124 AS problem_id, 'const score = await getScore();' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 124 AS problem_id, 'const score = getScore().value;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 124);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 125, '慢慢', '🐢', '非同步 await', 'The success handler runs and prints an Error object, and the catch handler never runs.', 'catch 沒有執行：商品明明沒貨，程式卻把錯誤當成成功的結果印出來。', 'const checkStock = (count) => new Promise((resolve, reject) => {\n  if (count > 0) resolve("有貨");\n  else resolve(new Error("沒貨"));\n});\ncheckStock(0)\n  .then((msg) => console.log("結果:", msg))\n  .catch((err) => console.log("錯誤:", err.message));', 3, '【哪裡出錯】第 3 行用 resolve 傳出 Error，Promise 會被當成成功，所以 then 執行，catch 完全不會跑。\n【用生活例子想】就像店員說「沒貨」，卻把它蓋上「訂單完成」的章，客人只會以為買到了東西。\n【一句話記住】Promise 要表示失敗，就用 reject，不要用 resolve 傳 Error。\n【容易選錯】改成 resolve(new Error("沒貨").message) 看起來比較乾淨，但還是 resolve，then 會印出「結果: 沒貨」，失敗仍被當成成功。\n【小字典】resolve：告訴 Promise 成功了並交出結果。reject：告訴 Promise 失敗了並交出原因。catch：Promise 失敗時才會執行的處理區。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 125);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 125 AS problem_id, '  else resolve(new Error("沒貨").message);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 125 AS problem_id, '  else return new Error("沒貨");' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 125 AS problem_id, '  else reject(new Error("沒貨"));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 125);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 126, '慢慢', '🐢', '非同步 await', 'The console prints an array of both server names instead of only the fastest one.', '結果多了一個：我只想要最快回應的那台伺服器名字，畫面卻印出兩台的名字，而且等了比較久。', 'const wait = (ms, name) => new Promise((resolve) => setTimeout(() => resolve(name), ms));\nconst slowServer = wait(200, "slow server");\nconst fastServer = wait(100, "fast server");\nconst fastest = await Promise.all([slowServer, fastServer]);\nconsole.log("Reply from:", fastest);', 4, '【哪裡出錯】第 4 行用了 Promise.all，它會等兩台伺服器都回完才一起交出陣列，所以拿到兩個名字，也多等了 200 毫秒。\n【用生活例子想】兩個同學同時跑去福利社幫你買飲料，你只要先回來的那一個。Promise.all 是等兩個人都到齊，Promise.race 是誰先到就用誰。\n【一句話記住】只要最先完成的結果就用 Promise.race，要全部都完成才用 Promise.all。\n【容易選錯】最像的錯誤選項是在 Promise.all 後面取 [0]，但陣列順序是照你放進去的順序，不是完成的順序，[0] 永遠是 slow server，答案還是錯的。\n【小字典】Promise.all：等全部成功，結果依放入順序排成陣列。Promise.race：誰先有結果就用誰。Promise.allSettled：等全部結束，回傳每個的成功或失敗狀態物件。陣列索引：用數字取出陣列裡的第幾個東西，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 126);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 126 AS problem_id, 'const fastest = await Promise.race([slowServer, fastServer]);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 126 AS problem_id, 'const fastest = (await Promise.all([slowServer, fastServer]))[0];' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 126 AS problem_id, 'const fastest = await Promise.allSettled([slowServer, fastServer]);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 126);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 127, '慢慢', '🐢', '非同步 await', 'Error: Server B is down', '有一個失敗就全倒：三台伺服器只有 B 壞掉，但 A 和 C 的結果也都拿不到，程式直接報錯。', 'const checkServer = async (name) => {\n  if (name === "B") throw new Error("Server B is down");\n  return name + " ok";\n};\nconst names = ["A", "B", "C"];\nconst results = await Promise.all(names.map(checkServer));\nfor (const r of results) {\n  console.log(r.status === "fulfilled" ? r.value : "skip");\n}', 6, '【哪裡出錯】Promise.all 只要其中一個失敗，整批就會跟著失敗，所以 B 壞掉時 A 和 C 的好結果也被丟掉了，程式還直接報錯。\n【用生活例子想】像班上三個人一起交報告，老師規定只要有一個人沒交，全班都算沒交。你其實想要的是每個人各自記錄交了沒。\n【一句話記住】想讓每個任務都有結果，不管成功或失敗，就用 Promise.allSettled。\n【容易選錯】最像答案的是在 Promise.all 後面接 .catch(() => [])，這樣確實不會報錯了，但失敗時 results 會變成空陣列，A 和 C 的好結果還是全部拿不到，迴圈什麼也不會印。\n【小字典】Promise.all：等全部成功才給結果，有一個失敗就整批失敗。allSettled：等全部做完，每個都回報成功或失敗的狀態。reject：Promise 失敗的結果。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 127);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 127 AS problem_id, 'const results = await Promise.race(names.map(checkServer));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 127 AS problem_id, 'const results = await Promise.allSettled(names.map(checkServer));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 127 AS problem_id, 'const results = await Promise.all(names.map(checkServer)).catch(() => []);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 127);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 128, '慢慢', '🐢', '非同步 await', 'The three downloads take about 300 ms in total instead of about 100 ms.', '下載三個檔案都對了，但花的時間是三倍：每個檔案都排隊等前一個下載完才開始。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nconst download = async (id) => { await wait(100); return `file${id}`; };\nasync function downloadAll(ids) {\n  const tasks = [];\n  for (const id of ids) {\n    tasks.push(await download(id));\n  }\n  return Promise.all(tasks);\n}\nconst start = Date.now();\nconst files = await downloadAll([1, 2, 3]);\nconsole.log(files.join(","), Date.now() - start < 200 ? "parallel" : "sequential");', 6, '【哪裡出錯】第 6 行在迴圈裡對每個 download 都寫了 await，程式會等第一個下載完才開始第二個，三個就變成排隊慢慢做。\n【用生活例子想】就像三個人要影印，你叫第一個印完才讓第二個去印，其實三台影印機可以同時開工。\n【一句話記住】想讓事情同時做，先把 Promise 收進陣列，最後再用 Promise.all 一起等。\n【容易選錯】tasks.push(await Promise.resolve(download(id))) 看起來有包一層 Promise，但前面還是有 await，每一圈照樣要等下載完才往下，還是一個一個排隊。\n【小字典】await：暫停在這一行，等 Promise 完成才往下走。Promise：代表未來會完成的工作。Promise.all：等陣列裡全部的 Promise 都完成。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 128);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 128 AS problem_id, '    tasks.push(await Promise.resolve(download(id)));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 128 AS problem_id, '    tasks.push(download);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 128 AS problem_id, '    tasks.push(download(id));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 128);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 129, '慢慢', '🐢', '非同步 await', 'The console prints Got: Error: Request timed out instead of going into the catch block.', '逾時沒有進 catch：逾時的時候程式照樣印出「成功」的結果，只是內容是一個錯誤物件。', 'const slowTask = () => new Promise((resolve) => setTimeout(() => resolve("data"), 250));\nconst timeout = (ms) => new Promise((resolve, reject) => setTimeout(() => resolve(new Error("Request timed out")), ms));\n\ntry {\n  const data = await Promise.race([slowTask(), timeout(100)]);\n  console.log("Got:", data);\n} catch (err) {\n  console.log("Failed:", err.message);\n}', 2, '【哪裡出錯】第 2 行的計時器時間到時呼叫的是 resolve，所以 Promise.race 把逾時當成「成功」，catch 永遠不會執行。\n【用生活例子想】就像外送平台說「等太久會取消訂單」，結果時間到卻把一張寫著「太久了」的紙當成餐點送給你，你還以為訂單成功了。\n【一句話記住】要讓 await 丟出錯誤、被 catch 接住，就要用 reject，不是 resolve。\n【容易選錯】最像的是把 resolve 裡改成字串 "Request timed out"，但它還是 resolve，race 還是把它當成功結果，會印出 Got: Request timed out，catch 還是不會執行。\n【小字典】Promise.race：同時比賽，誰先完成就用誰的結果，不管成功或失敗。resolve：告訴 Promise「成功了」並交出結果。reject：告訴 Promise「失敗了」，讓 catch 接手。逾時：等太久就放棄。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 129);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 129 AS problem_id, 'const timeout = (ms) => new Promise((resolve, reject) => setTimeout(() => reject(new Error("Request timed out")), ms));' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 129 AS problem_id, 'const timeout = (ms) => new Promise((resolve, reject) => setTimeout(() => resolve("Request timed out"), ms));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 129 AS problem_id, 'const timeout = (ms) => new Promise((resolve, reject) => setTimeout(() => { throw new Error("Request timed out"); }, ms));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 129);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 130, '慢慢', '🐢', '非同步 await', 'The console prints [ undefined, undefined, undefined ] instead of [ 10, 20, 30 ].', '三個商品的價格都查完了，但印出來的陣列全是 undefined，沒有看到 10、20、30。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nasync function getPrice(id) {\n  await wait(50);\n  return id * 10;\n}\nconst ids = [1, 2, 3];\nconst prices = await Promise.all(ids.map(async (id) => {\n  getPrice(id);\n}));\nconsole.log(prices);', 8, '【哪裡出錯】map 裡的 async 函式用了大括號，卻沒有 return，所以每一格的結果都是 undefined，Promise.all 收集到的就是三個 undefined。\n【用生活例子想】就像你請三個同學去查價格，他們查完卻把答案留在心裡沒告訴你，你收回來的三張紙條全是空白。\n【一句話記住】用大括號寫的函式，要把結果交出去就得自己寫 return。\n【容易選錯】await getPrice(id); 看起來有等結果，但等完之後沒有 return，函式還是回傳 undefined，陣列還是三個 undefined。\n【小字典】return：把值交給呼叫的人。Promise.all：等一群 Promise 都完成，再把結果收成陣列。map：把陣列每一格轉成新的值。undefined：表示沒有值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 130);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 130 AS problem_id, '  await getPrice(id);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 130 AS problem_id, '  return getPrice(id);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 130 AS problem_id, '  getPrice(id).then((price) => price);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 130);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 131, '慢慢', '🐢', '非同步 await', 'Error: upload failed', '一個失敗全部報錯：三張圖裡只有一張上傳失敗，程式卻直接中斷，沒有印出成功的張數', 'const upload = async (name) => {\n  if (name === "b.png") throw new Error("upload failed");\n  return name;\n};\nconst files = ["a.png", "b.png", "c.png"];\nconst results = await Promise.all(files.map(upload));\nconst ok = results.filter((r) => r.status === "fulfilled");\nconsole.log(ok.length + " uploaded");', 6, '【哪裡出錯】Promise.all 只要其中一個 Promise 失敗，整個就會立刻失敗並丟出錯誤，所以後面的程式根本沒機會執行。\n【用生活例子想】就像老師說「全班都交作業才能下課」，只要一個人沒交，全班都不能走。allSettled 則是老師把每個人交或沒交都記下來，最後再統計。\n【一句話記住】想知道每個任務各自的成功或失敗，用 Promise.allSettled，不要用 Promise.all。\n【容易選錯】加上 .catch(() => []) 最像正確答案，錯誤確實不會再中斷程式，但 results 變成空陣列，成功的兩張也被丟掉，結果印出 0 uploaded，還是不對。\n【小字典】Promise.all：等全部成功，只要有一個失敗就整個失敗。Promise.allSettled：等全部結束，回傳每個結果的狀態。Promise.any：回傳第一個成功的值。rejected：Promise 失敗的狀態。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 131);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 131 AS problem_id, 'const results = await Promise.all(files.map(upload)).catch(() => []);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 131 AS problem_id, 'const results = await Promise.any(files.map(upload));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 131 AS problem_id, 'const results = await Promise.allSettled(files.map(upload));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 131);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 132, '慢慢', '🐢', '非同步 await', 'The console prints Total: [object Promise]30 instead of Total: 60.', '總價算出來是一串怪字，開頭是 [object Promise]，而不是 10、20、30 加起來的 60。', 'const getPrice = (id) => new Promise((resolve) => setTimeout(() => resolve(id * 10), 10));\nconst ids = [1, 2, 3];\nconst total = await ids.reduce(async (sum, id) => {\n  const price = await getPrice(id);\n  return sum + price;\n}, 0);\nconsole.log("Total:", total);', 5, '【哪裡出錯】reduce 的回呼是 async 函式，所以每一輪回傳的都是 Promise，下一輪拿到的 sum 就變成 Promise，Promise 加數字會變成文字 [object Promise]20。\n【用生活例子想】就像你收到一張寫著「錢在信封裡」的紙條，卻直接拿紙條去跟別人的錢相加，你得先打開信封（await）才看得到錢。\n【一句話記住】async 的 reduce 裡，上一輪留下來的累加值是 Promise，用之前要先 await。\n【容易選錯】把 price 加上 await 看起來很合理，但 price 早就是數字了，真正的問題是 sum 還是 Promise，所以結果還是 [object Promise]30。\n【小字典】reduce：把陣列一個一個累積成單一結果的方法。累加器：reduce 每一輪帶到下一輪的那個值。Promise：代表未來才會有結果的物件。await：等 Promise 完成並拿出裡面的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 132);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 132 AS problem_id, '  return (await sum) + price;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 132 AS problem_id, '  return sum + (await price);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 132 AS problem_id, '  return Promise.resolve(sum) + price;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 132);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 133, '慢慢', '🐢', '非同步 await', 'The console prints done before tick, with no 100 ms wait.', '順序不對：明明有 await，卻先印出 done，過了一下才印出 tick，好像沒有等。', 'async function countdown() {\n  console.log("start");\n  await setTimeout(() => console.log("tick"), 100);\n  console.log("done");\n}\ncountdown();', 3, '【哪裡出錯】setTimeout 不是回傳 Promise，它只是排好一個鬧鐘就立刻結束，所以 await 沒有東西可以等，馬上就繼續印 done。\n【用生活例子想】就像你設好手機鬧鐘後馬上說「我睡醒了」，鬧鐘還沒響你就往下做事。要等的話，得先約好「鬧鐘響了才算醒」。\n【一句話記住】要 await 計時，就把 setTimeout 包進 new Promise，時間到再呼叫 resolve。\n【容易選錯】用 new Promise 包住 setTimeout 但沒有呼叫 resolve 最像正確答案，可是這個 Promise 永遠不會完成，tick 印完後 done 永遠不會出現。\n【小字典】Promise：代表一件以後才會完成的事的物件。resolve：告訴 Promise 事情做完了的函式。await：等 Promise 完成才繼續往下。setTimeout：過一段時間後才執行某個函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 133);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 133 AS problem_id, '  await new Promise(() => setTimeout(() => console.log("tick"), 100));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 133 AS problem_id, '  await new Promise((resolve) => setTimeout(() => { console.log("tick"); resolve(); }, 100));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 133 AS problem_id, '  await (() => setTimeout(() => console.log("tick"), 100))();' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 133);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 134, '慢慢', '🐢', '非同步 await', 'TypeError: Cannot read properties of undefined (reading ''port'')', '型別錯誤：讀不到 undefined 的 port。明明是設定檔不存在，卻看不到「找不到設定檔」的錯誤。', 'const readConfig = (name, callback) => {\n  setTimeout(() => {\n    if (name !== "app") return callback(new Error("Config not found: " + name));\n    callback(null, { port: 3000 });\n  }, 50);\n};\nconst readConfigAsync = (name) => new Promise((resolve, reject) => {\n  readConfig(name, (err, data) => resolve(data));\n});\ntry { const config = await readConfigAsync("db"); console.log("port", config.port); }\ncatch (err) { console.log("Caught:", String(err)); }', 8, '【哪裡出錯】第 8 行的 callback 不管有沒有錯，都直接 resolve(data)。設定檔不存在時 data 是 undefined，真正的錯誤被吞掉，直到第 10 行讀 config.port 才爆出另一個錯。\n【用生活例子想】你請同學去影印，他說「影印機壞了」，你卻只聽到他手上沒東西，就當作任務完成，回頭才發現沒有講義。\n【一句話記住】把 callback 包成 Promise 時，有 err 就 reject，沒有才 resolve。\n【容易選錯】resolve(err || data) 看起來有顧到錯誤，但它是用 resolve 把錯誤物件當成「成功的結果」交出去。await 不會丟錯，config 變成 Error 物件，config.port 是 undefined，畫面印出 port undefined，錯誤還是沒被 catch 接到。\n【小字典】reject：讓 Promise 變成失敗，await 會丟出錯誤。resolve：讓 Promise 變成成功並交出結果。callback：做完事之後被呼叫的函式，第一個參數通常放錯誤。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 134);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 134 AS problem_id, '  readConfig(name, (err, data) => resolve(err || data));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 134 AS problem_id, '  readConfig(name, (err, data) => { if (err) console.log(err.message); resolve(data); });' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 134 AS problem_id, '  readConfig(name, (err, data) => (err ? reject(err) : resolve(data)));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 134);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 135, '慢慢', '🐢', '非同步 await', 'TypeError: Cannot read properties of undefined (reading ''name'')', '讀取 undefined 的屬性：錯誤明明被 catch 接住了，user 卻變成 undefined，下一行就壞掉。', 'const loadUser = async (id) => {\n  if (id !== 1) throw new Error("User not found");\n  return { name: "Mia" };\n};\nasync function showUser(id) {\n  const user = await loadUser(id).catch((err) => console.log("Load failed:", err.message));\n  console.log("Hello " + user.name);\n}\nawait showUser(2);', 6, '【哪裡出錯】第 6 行的 catch 只印出訊息，沒有回傳任何東西，所以錯誤被接住後 user 變成 undefined，第 7 行讀 user.name 才爆炸。\n【用生活例子想】就像外送員說「餐點賣完了」就走了，卻沒留下替代餐點，你打開袋子拿叉子吃飯，袋子裡什麼都沒有。\n【一句話記住】catch 接住錯誤後，要回傳備用的值，後面的程式才有東西可用。\n【容易選錯】最像的是用 then 的第二個參數處理錯誤那個選項，它一樣只印出訊息，沒有回傳備用值，所以 user 還是 undefined，讀 user.name 還是會報錯。\n【小字典】catch：Promise 失敗時才會執行的處理函式。undefined：代表沒有值，對它讀屬性就會報錯。回傳值：函式結束時交出去的結果，沒寫 return 就是 undefined。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 135);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 135 AS problem_id, '  const user = await loadUser(id).catch((err) => { console.log("Load failed:", err.message); return { name: "Guest" }; });' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 135 AS problem_id, '  const user = await loadUser(id).finally(() => console.log("Load failed"));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 135 AS problem_id, '  const user = await loadUser(id).then((u) => u, (err) => console.log("Load failed:", err.message));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 135);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 136, '慢慢', '🐢', '非同步 await', 'The balance shows 80 instead of 50 after withdrawing 30 and 20.', '兩筆提款同時進行，100 元領了 30 和 20，餘額應該剩 50，畫面卻顯示 80，其中一筆好像消失了。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nlet balance = 100;\n\nasync function withdraw(amount) {\n  const current = balance;\n  await wait(50);\n  balance = current - amount;\n}\n\nawait Promise.all([withdraw(30), withdraw(20)]);\nconsole.log("餘額", balance);', 7, '【哪裡出錯】第 5 行在 await 之前就把 balance 抄下來存進 current，兩筆提款同時開始，都抄到 100。等待結束後各自用舊的 100 去算，後寫入的那筆把前一筆蓋掉了。\n【用生活例子想】兩個人同時看白板上寫 100 元，各自走開算帳，回來一個寫 70，另一個又把它擦掉寫 80，先寫的那筆就不見了。\n【一句話記住】await 之後要用最新的值，別拿 await 之前抄下來的舊值去算。\n【容易選錯】「balance -= current - amount;」看起來也有扣款，但 current 是舊的 100，會先算出 100 - 30 = 70 再從 balance 扣掉，結果數字完全亂掉，不是 50。\n【小字典】await：暫停函式等結果，這段時間別的程式會跑。Promise.all：同時啟動多個工作，等全部做完。舊值：先前存下來、之後可能已被改掉的資料。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 136);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 136 AS problem_id, '  balance = current + amount;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 136 AS problem_id, '  balance -= amount;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 136 AS problem_id, '  balance -= current - amount;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 136);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 137, '慢慢', '🐢', '非同步 await', 'The console prints Amy, Ben, Cat even though Ben is offline.', '名單過濾失效：明明 Ben 不在線上，結果卻把三個人全部印出來，沒有任何人被過濾掉。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nconst isOnline = async (user) => {\n  await wait(20);\n  return user.online;\n};\nconst users = [{ name: "Amy", online: true }, { name: "Ben", online: false }, { name: "Cat", online: true }];\nconst checks = await Promise.all(users.map(isOnline));\nconst onlineUsers = users.filter(async (user) => await isOnline(user));\nconsole.log(onlineUsers.map((u) => u.name).join(", "));', 8, '【哪裡出錯】第 8 行的 filter 收到的是 async 函式，async 函式永遠回傳 Promise，Promise 是物件，在 filter 眼中一律算真，所以沒有人被濾掉。\n【用生活例子想】像警衛問你「他有票嗎」，你只遞給他一張「查票中」的收據，警衛看到有東西就放行，根本沒等查票結果。\n【一句話記住】filter 不會等 await，要先用 Promise.all 把答案都拿到，再用拿到的真假值去過濾。\n【容易選錯】改成 users.filter((user) => isOnline(user)) 看起來少了 async，但 isOnline 本身還是回傳 Promise，一樣永遠為真，結果還是三個人全出現。\n【小字典】Promise：代表「未來才會有結果」的物件，拿到時還不是最終答案。filter：留下判斷結果為真的項目。Promise.all：等一整排 Promise 都完成，再一次給你所有結果。truthy：在判斷式裡會被當成真的值，物件都是 truthy。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 137);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 137 AS problem_id, 'const onlineUsers = users.filter((user) => isOnline(user));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 137 AS problem_id, 'const onlineUsers = users.filter((user, i) => checks);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 137 AS problem_id, 'const onlineUsers = users.filter((user, i) => checks[i]);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 137);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 138, '慢慢', '🐢', '非同步 await', 'The console prints undefined instead of dark.', '設定明明讀成功了，也存進 state.cache，最後卻印出 undefined，主題色不見了。', 'const state = { loading: true, cache: null };\nasync function loadConfig() {\n  try {\n    const res = await fetch("/api/config");\n    state.cache = await res.json();\n    return state.cache;\n  } finally {\n    state.loading = false;\n    return state;\n  }\n}\nconsole.log((await loadConfig()).theme);', 9, '【哪裡出錯】finally 裡面寫了 return state，它會蓋掉 try 裡面的 return state.cache，所以呼叫的人拿到的是整個 state，讀 theme 就變成 undefined。\n【用生活例子想】你在櫃台領到一份便當，要離開時門口的人又硬塞給你一個空盒子，你手上拿的就變成空盒子，原本的便當等於白拿。\n【一句話記住】finally 只拿來收尾，例如關閉或重設，不要在裡面 return。\n【容易選錯】改成 return { ...state } 看起來像是回傳複製品比較安全，但它還是在 finally 裡 return，一樣會蓋掉 state.cache，theme 還是 undefined。\n【小字典】finally：不管成功或失敗最後都會執行的區塊。return：結束函式並把值交給呼叫的人。state：程式用來存目前狀態的物件。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 138);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 138 AS problem_id, '    console.log("loading finished");' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 138 AS problem_id, '    return { ...state };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 138 AS problem_id, '    return state.loading;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 138);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 139, '慢慢', '🐢', '非同步 await', 'The console prints requests: 3 instead of requests: 1 when getUser(1) is called three times at once.', '同時查三次同一個使用者，明明有做快取，卻還是送出了三次請求，快取好像沒有發揮作用。', 'const cache = new Map();\nlet requests = 0;\nfunction loadUser(id) {\n  requests++;\n  return fetch(`/api/users/${id}`).then((res) => res.json());\n}\nasync function getUser(id) {\n  if (!cache.has(id)) cache.set(id, await loadUser(id));\n  return cache.get(id);\n}\nawait Promise.all([getUser(1), getUser(1), getUser(1)]);\nconsole.log("requests:", requests);', 8, '【哪裡出錯】第 8 行先 await 等資料回來才存進快取，三次呼叫同時進來時快取都還是空的，所以各自去發了一次請求。\n【用生活例子想】好比三個人同時想喝同一款手搖飲，要等第一杯做好才記下「這款有人點了」，那三個人都會各點一杯；應該一有人點就先記下「已經在做了」，其他人跟著等就好。\n【一句話記住】快取要存 Promise 本身，後來的人拿到同一個 Promise 就會一起等，不會重複請求。\n【容易選錯】用 loadUser(id).then(...) 再存起來，看起來很像在快取，但它還是要等資料回來才存，三次呼叫同時進來時快取仍是空的，requests 還是 3。\n【小字典】快取：把查過的結果先記起來，下次直接拿來用。Promise：代表「之後才會有結果」的東西，可以被很多人一起等。同時呼叫：不等前一個結束就開始下一個。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 139);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 139 AS problem_id, '  if (!cache.has(id)) await loadUser(id).then((user) => cache.set(id, user));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 139 AS problem_id, '  if (!cache.has(id)) cache.set(id, loadUser(id));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 139 AS problem_id, '  cache.set(id, await loadUser(id));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 139);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 140, '慢慢', '🐢', '非同步 await', 'The console prints Total: 0[object Object][object Object] instead of Total: 170.', '總分算錯：應該是 170，畫面卻出現一串 [object Object]，像是把物件當成分數在相加。', 'const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\nasync function getScore(name, score) {\n  await wait(20);\n  if (score < 0) throw new Error("bad score for " + name);\n  return score;\n}\nconst results = await Promise.allSettled([getScore("Amy", 80), getScore("Ben", -1), getScore("Cat", 90)]);\nconst scores = results.filter((r) => r.status === "fulfilled").map((r) => r);\nconst total = scores.reduce((sum, s) => sum + s, 0);\nconsole.log("Total:", total);', 8, '【哪裡出錯】Promise.allSettled 回傳的每一項都是像 { status: "fulfilled", value: 80 } 的包裝物件，第 8 行直接把整個物件留下來，沒有取出 value，所以第 9 行是在拿物件相加。\n【用生活例子想】就像宅配送來的是一個包裹盒，盒子上貼著「成功送達」的標籤，你要拆開盒子才拿得到裡面的東西，不能直接把盒子當成商品用。\n【一句話記住】allSettled 的結果要先看 status，成功的值要用 .value 拆出來。\n【容易選錯】選 r.reason 看起來很像，因為它也是包裝物件裡的欄位，但 reason 只有失敗的項目才有。成功的項目沒有 reason，會得到 undefined，加起來變成 NaN，結果還是錯的。\n【小字典】allSettled：等所有 Promise 都結束，不管成功或失敗都會回報結果。fulfilled：表示這個 Promise 成功完成。value：成功時包裝物件裡存放結果的欄位。reduce：把陣列的值一個一個累加成單一結果的方法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 140);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 140 AS problem_id, 'const scores = results.filter((r) => r.status === "fulfilled").map((r) => r.reason);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 140 AS problem_id, 'const scores = results.filter((r) => r.status === "fulfilled").map((r) => r.result);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 140 AS problem_id, 'const scores = results.filter((r) => r.status === "fulfilled").map((r) => r.value);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 140);

-- 跳跳：模組路徑
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 141, '跳跳', '🐰', '模組路徑', 'SyntaxError: Identifier ''add'' has already been declared', '名稱重複宣告：add 已經用 import 拿進來了，你又在第 4 行用 const 宣告了一個同名的 add。', 'import { add } from ''./math.mjs''\nconst price = 100\nconst tax = 5\nconst add = add(price, tax)\nconsole.log(total)', 4, '【哪裡出錯】第 1 行已經用 import 拿到 add 這個名字，第 4 行又用 const 宣告一個叫 add 的變數，同一個檔案裡名字撞名，JavaScript 在執行前就報錯了。\n【用生活例子想】就像班上已經有一位同學叫小明，你又幫新同學取名小明，老師點名時根本分不清是誰。把結果取名 total，後面 console.log(total) 才找得到它。\n【一句話記住】import 進來的名字就是已經被占用的名字，自己的新變數要取不一樣的名字。\n【容易選錯】最像的是 let add = add(price, tax)，只把 const 換成 let。但 add 這個名字還是被 import 占走了，一樣會報重複宣告的錯，而且後面要印的 total 也還是不存在。\n【小字典】import：把別的檔案匯出的東西拿進來用。宣告：用 const、let、var 替變數取名字。SyntaxError：語法錯誤，程式還沒開始跑就被擋下來。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 141);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 141 AS problem_id, 'let add = add(price, tax)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 141 AS problem_id, 'const total = math.add(price, tax)' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 141 AS problem_id, 'const total = add(price, tax)' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 141);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 142, '跳跳', '🐰', '模組路徑', 'ReferenceError: require is not defined in ES module scope, you can use import instead', 'require 找不到：這個檔案是 ESM（.mjs），裡面沒有 require 這個東西，要改用 import。', 'const { readFileSync } = require(''node:fs'')\nconst file = new URL(''./note.txt'', import.meta.url)\nconst text = readFileSync(file, ''utf8'')\nconsole.log(text.trim())', 1, '【哪裡出錯】main.mjs 是 ESM 檔案，ESM 不認識 require，所以第 1 行一執行就報錯。\n【用生活例子想】就像你去日本的商店刷悠遊卡，店家只收他們自己的卡，用台灣的方式付錢會被拒絕，要換成他們的方式。\n【一句話記住】副檔名是 .mjs 或 package.json 設了 type module，就要用 import，不要用 require。\n【容易選錯】「const { readFileSync } = require(''fs'')」只是把 node:fs 改成 fs，但還是在 ESM 裡用 require，一樣會報 require is not defined，所以沒有解決問題。\n【小字典】ESM：JavaScript 新式的模組寫法，用 import 和 export。require：舊式 CommonJS 載入模組的函式，ESM 裡沒有。import：ESM 載入別的模組的語法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 142);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 142 AS problem_id, 'import { readFileSync } from ''node:fs''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 142 AS problem_id, 'const { readFileSync } = require(''fs'')' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 142 AS problem_id, 'import readFileSync from ''node:fs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 142);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 143, '跳跳', '🐰', '模組路徑', 'Error [ERR_MODULE_NOT_FOUND]: Cannot find package ''utils'' imported from /app/main.mjs', '找不到套件：路徑前面沒有 ./，Node 以為你要載入一個叫 utils 的套件，而不是你自己的資料夾', 'import { greet } from ''utils/greet.mjs''\n\nconst name = ''Ruei''\nconsole.log(greet(name))', 1, '【哪裡出錯】第 1 行的路徑 ''utils/greet.mjs'' 前面沒有 ./，Node 會以為 utils 是從 npm 裝進來的套件，結果當然找不到。\n【用生活例子想】就像你跟朋友說「去美術館」，他會想到全市有名的那間；你要說「從我家門口走過去的那間」，他才知道是附近的。./ 就是「從這個檔案旁邊開始找」。\n【一句話記住】自己寫的檔案要用 ./ 或 ../ 開頭，沒有的話 Node 會去找套件。\n【容易選錯】選 ''/utils/greet.mjs'' 最像對，但開頭的 / 代表從整台電腦的根目錄開始找，那裡沒有 utils 資料夾，所以還是找不到檔案。\n【小字典】相對路徑：從目前這個檔案的位置出發去找檔案的寫法。套件：別人寫好、用 npm 安裝的工具包。import：把別的檔案裡匯出的東西拿進來用。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 143);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 143 AS problem_id, 'import { greet } from ''/utils/greet.mjs''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 143 AS problem_id, 'import { greet } from ''./utils/greet.mjs''' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 143 AS problem_id, 'import { greet } from ''utils/greet''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 143);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 144, '跳跳', '🐰', '模組路徑', 'Error [ERR_MODULE_NOT_FOUND]: Cannot find package ''greet.mjs'' imported from /app/main.mjs', '找不到套件：Node 說它找不到叫 greet.mjs 的套件，但你其實是想引入同資料夾的檔案。', '// greet.mjs 和這個檔案在同一個資料夾\nimport { greet } from ''greet.mjs''\nconst message = greet(''Ruei'')\nconsole.log(message)', 2, '【哪裡出錯】第 2 行的路徑 ''greet.mjs'' 前面沒有 ./，Node 以為你要找安裝在 node_modules 裡的套件，所以找不到。\n【用生活例子想】就像你跟朋友說「去找小明」，朋友會去全校找；你要說「找我隔壁的小明」，他才會看旁邊。./ 就是「我旁邊」的意思。\n【一句話記住】引入自己寫的檔案，路徑一定要用 ./ 或 ../ 開頭。\n【容易選錯】''/greet.mjs'' 看起來很像，但開頭一個斜線是從電腦最外層的根目錄找，不是從目前資料夾找，所以還是會找不到檔案。\n【小字典】相對路徑：從目前這個檔案出發去找另一個檔案的寫法。套件名稱：沒有 ./ 開頭的名字，Node 會去 node_modules 裡找。根目錄：整台電腦檔案結構的最外層。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 144);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 144 AS problem_id, 'import { greet } from ''/greet.mjs''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 144 AS problem_id, 'import { greet } from ''../greet.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 144 AS problem_id, 'import { greet } from ''./greet.mjs''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 144);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 145, '跳跳', '🐰', '模組路徑', 'SyntaxError: The requested module ''./greet.mjs'' does not provide an export named ''default''', '找不到 default 匯出：你用不加大括號的寫法匯入，但 greet.mjs 裡根本沒有寫 export default。', 'import greet from ''./greet.mjs''\n\nconst message = greet(''Mina'')\nconsole.log(message)', 1, '【哪裡出錯】greet.mjs 用的是 export function greet，這是具名匯出，但第 1 行用 import greet 去拿 default，所以找不到。\n【用生活例子想】就像店裡的商品架上貼了名字叫 greet 的標籤，你卻去找「招牌商品」那一格，那一格根本是空的。\n【一句話記住】具名匯出要用大括號 { } 匯入，export default 才可以不加大括號。\n【容易選錯】import { default as greet } 看起來像是在指定名字，但它還是去拿 default，而 greet.mjs 沒有 default，所以錯誤一樣會出現。\n【小字典】具名匯出：用 export 加上名字送出去，匯入時名字要對上。default 匯出：每個檔案最多一個，用 export default 送出，匯入時可以自己取名。大括號：匯入具名匯出時用來框住名字的符號。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 145);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 145 AS problem_id, 'import { greet } from ''./greet.mjs''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 145 AS problem_id, 'import * as greet from ''./greet.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 145 AS problem_id, 'import { default as greet } from ''./greet.mjs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 145);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 146, '跳跳', '🐰', '模組路徑', 'Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:fs/promise', '找不到內建模組：Node 說沒有叫 node:fs/promise 的內建模組，請檢查 import 後面的名稱。', 'import { readFile } from ''node:fs/promise''\n\nconst text = await readFile(new URL(''./note.txt'', import.meta.url), ''utf8'')\nconsole.log(text.trim())', 1, '【哪裡出錯】第 1 行把內建模組 node:fs/promises 少打了最後的 s，Node 找不到這個名稱的內建模組，所以一開始就報錯。\n【用生活例子想】就像去圖書館櫃台借書，書名少寫一個字，櫃台人員會說查無此書，連書架都不會帶你去。\n【一句話記住】內建模組的名稱要一字不差，讀檔的 Promise 版本是 node:fs/promises，結尾有 s。\n【容易選錯】改成 import { readFile } from ''node:fs'' 最像對的，因為模組真的存在。但這個 readFile 是舊式的 callback 版本，你用 await 又沒給 callback，執行時會丟出 ERR_INVALID_ARG_TYPE 的錯誤。\n【小字典】內建模組：Node 本來就附贈的工具箱，不用另外安裝。node: 前綴：明確告訴 Node 這是內建模組，不是 npm 套件。callback：舊式寫法，要傳一個函式等結果回來。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 146);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 146 AS problem_id, 'import { readFile } from ''node:fs''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 146 AS problem_id, 'import { readFile } from ''node:fs/promises''' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 146 AS problem_id, 'import { readFile } from ''node:fs.promises''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 146);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 147, '跳跳', '🐰', '模組路徑', 'Error [ERR_UNSUPPORTED_DIR_IMPORT]: Directory import ''/app/utils'' is not supported resolving ES modules imported from /app/main.mjs', '不支援匯入資料夾：Node 的 ESM 不會自動幫你找資料夾裡的 index 檔，路徑要寫到真正的檔案。', '// 專案結構：main.mjs 和 utils/index.mjs 在同一層\nimport { formatPrice } from ''./utils''\n\nconst items = [120, 80, 45]\nconst total = items.reduce((sum, n) => sum + n, 0)\nconsole.log(formatPrice(total))', 2, '【哪裡出錯】第 2 行只寫了 ''./utils''，這是一個資料夾，Node 的 ESM 不會自動幫你打開資料夾去找 index 檔，所以直接報錯。\n【用生活例子想】就像寄包裹只寫「幸福大樓」，卻沒寫幾樓幾號，快遞不會自己猜你要送哪一戶，一定要寫到完整門牌才送得到。\n【一句話記住】在 ESM 裡 import 要寫到真正的檔案，資料夾要寫成 ''./utils/index.mjs''。\n【容易選錯】''./utils/'' 最像正確答案，但結尾加斜線還是指向資料夾，Node 一樣不會幫你找 index 檔，仍然會報目錄匯入的錯。\n【小字典】ESM：JavaScript 新式的模組寫法，用 import 和 export。資料夾匯入：只寫資料夾名稱就想載入裡面的 index 檔，ESM 不支援。index 檔：放在資料夾裡、習慣上當作入口的檔案。相對路徑：從目前這個檔案所在位置出發去找另一個檔案的寫法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 147);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 147 AS problem_id, 'import { formatPrice } from ''./utils/''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 147 AS problem_id, 'import { formatPrice } from ''./utils.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 147 AS problem_id, 'import { formatPrice } from ''./utils/index.mjs''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 147);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 148, '跳跳', '🐰', '模組路徑', 'TypeError [ERR_IMPORT_ATTRIBUTE_MISSING]: Module "file:///app/settings.json" needs an import attribute of "type: json"', '缺少匯入屬性：Node 說這個模組需要 type: json 的屬性，你匯入 JSON 檔時沒有告訴它這是 JSON。', 'import { greet } from ''./greet.mjs''\nimport settings from ''./settings.json''\n\nconst name = settings.userName\nconsole.log(greet(name))\nconsole.log(`Port: ${settings.port}`)', 2, '【哪裡出錯】第 2 行用 import 讀 JSON 檔，卻沒有加 with { type: ''json'' }，Node 不敢直接把它當成 JavaScript 模組來讀。\n【用生活例子想】就像寄包裹要在外面註明裡面是食物還是玻璃，快遞員才知道怎麼搬，沒寫標籤就會被退回來。\n【一句話記住】在 ESM 裡 import JSON 檔，後面一定要補 with { type: ''json'' }。\n【容易選錯】with { type: ''module'' } 看起來也有補標籤，但標籤寫錯了，JSON 檔不是 JavaScript 模組，Node 不接受這個種類，還是會報錯。\n【小字典】import attribute：寫在 import 後面的附加標籤，告訴 Node 這個檔案是什麼種類。JSON：一種用文字記錄資料的格式，常拿來放設定。default import：不加大括號、拿到整個內容的匯入方式，JSON 只能這樣匯入。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 148);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 148 AS problem_id, 'import settings from ''./settings.json'' with { type: ''json'' }' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 148 AS problem_id, 'import settings from ''./settings.json'' with { type: ''module'' }' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 148 AS problem_id, 'import { settings } from ''./settings.json'' with { type: ''json'' }' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 148);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 149, '跳跳', '🐰', '模組路徑', 'ReferenceError: __dirname is not defined in ES module scope', '__dirname 沒定義：這個檔案是 ES module，舊的 CommonJS 變數 __dirname 在這裡不存在', 'import { readFileSync } from ''node:fs''\nimport { join } from ''node:path''\n\n// data.txt 和 main.mjs 放在同一個資料夾\nconst file = join(__dirname, ''data.txt'')\nconst text = readFileSync(file, ''utf8'')\nconsole.log(text.trim())', 5, '【哪裡出錯】main.mjs 是 ES module，裡面沒有 CommonJS 才有的 __dirname，所以第 5 行一用就當機。\n【用生活例子想】就像你去新學校還拿舊學校的校門鑰匙，新學校根本沒有這種鎖，要改用新學校發的卡片 import.meta.dirname。\n【一句話記住】ESM 裡找檔案所在資料夾，用 import.meta.dirname，不要用 __dirname。\n【容易選錯】最像的是 __filename，它也是 CommonJS 才有的變數，在 ES module 裡一樣沒定義，換上去還是會報 ReferenceError。\n【小字典】ES module：用 import 和 export 的新模組寫法。CommonJS：用 require 和 module.exports 的舊模組寫法。__dirname：CommonJS 提供的目前檔案所在資料夾路徑。import.meta.dirname：ESM 裡提供同樣資訊的寫法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 149);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 149 AS problem_id, 'const file = join(__filename, ''data.txt'')' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 149 AS problem_id, 'const file = join(import.meta.dirname, ''data.txt'')' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 149 AS problem_id, 'const file = join(import.meta.url, ''data.txt'')' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 149);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 150, '跳跳', '🐰', '模組路徑', 'TypeError: add is not a function', '不是函式：add 被當成函式來呼叫，但它其實是一整包模組物件，不是函式。', 'const label = ''計算結果：''\nconst add = await import(''./math.mjs'')\nconst total = add(2, 3)\nconsole.log(label + total)', 2, '【哪裡出錯】第 2 行的 await import() 拿回來的是「整個模組物件」，裡面才有 add，你卻把整包直接叫做 add，所以第 3 行呼叫 add(2, 3) 時才說它不是函式。\n【用生活例子想】這就像你去買一整盒工具組，卻把整個盒子當成螺絲起子來轉，要先從盒子裡把螺絲起子拿出來才能用。\n【一句話記住】動態 import 給你的是工具箱，要用大括號 { add } 把工具拿出來。\n【容易選錯】選 const { default: add } = await import(''./math.mjs'') 看起來也有用大括號解構，但它拿的是 default 預設匯出，而 math.mjs 只有具名匯出 add，沒有 default，所以 add 會是 undefined，第 3 行還是會說 add is not a function。\n【小字典】動態 import：在程式執行中才載入模組的寫法，會回傳一個 Promise。模組物件：把模組所有 export 包在一起的物件。解構：用大括號從物件裡取出需要的屬性。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 150);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 150 AS problem_id, 'const add = await import(''./math.mjs'').default' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 150 AS problem_id, 'const { default: add } = await import(''./math.mjs'')' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 150 AS problem_id, 'const { add } = await import(''./math.mjs'')' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 150);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 151, '跳跳', '🐰', '模組路徑', 'TypeError: Assignment to constant variable.', '賦值給常數：程式想改 import 進來的 count，但別的檔案匯出的變數在你這裡只能讀、不能改。', 'import { count, increase } from ''./counter.mjs''\n\nfunction onClick() {\n  count++\n}\nconsole.log(''start:'', count)\nonClick()\nconsole.log(''now:'', count)', 4, '【哪裡出錯】count 是從 counter.mjs import 進來的，在 main.mjs 裡只能讀，不能直接 count++ 去改它。\n【用生活例子想】就像圖書館的書，你可以借來看，但不能在書上亂寫字；要改內容，得請櫃台（原本的檔案）幫你改。\n【一句話記住】import 進來的變數是唯讀的，想改它就呼叫原檔案匯出的函式。\n【容易選錯】count = count + 1 看起來像換個寫法，但它一樣是在對 import 進來的名字賦值，還是會噴 Assignment to constant variable。\n【小字典】import：把別的檔案匯出的東西拿進來用。export：讓別的檔案可以使用這個變數或函式。唯讀：只能讀取值，不能重新賦值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 151);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 151 AS problem_id, '  increase()' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 151 AS problem_id, '  count += 1' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 151 AS problem_id, '  count = increase()' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 151);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 152, '跳跳', '🐰', '模組路徑', 'Error [ERR_PACKAGE_PATH_NOT_EXPORTED]: Package subpath ''./src/format.mjs'' is not defined by "exports" in /app/node_modules/price-tools/package.json imported from /app/main.mjs', '套件路徑沒有開放：price-tools 的 package.json 只開放了幾個入口，你直接伸手去拿裡面的檔案，Node 不讓你進。', 'import { formatPrice } from ''price-tools/src/format.mjs''\n\nconst items = [{ name: ''tea'', price: 45 }, { name: ''cake'', price: 120 }]\nconst total = items.reduce((sum, item) => sum + item.price, 0)\n\nconsole.log(''Total: '' + formatPrice(total))', 1, '【哪裡出錯】price-tools 的 package.json 裡有 exports 欄位，只開放 "." 和 "./format" 兩個入口，直接寫 src/format.mjs 這個內部檔案路徑不在名單上，所以被擋下來。\n【用生活例子想】就像大樓有管理員，訪客只能從櫃台登記的大門進去，你不能自己跑去翻後面的倉庫門，就算那扇門真的存在也一樣。\n【一句話記住】套件有寫 exports 的話，只能用它開放的名字來匯入，不能直接指到裡面的檔案路徑。\n【容易選錯】最像的是把副檔名拿掉，寫成 price-tools/src/format。但 exports 名單裡根本沒有 ./src/format，換上去還是會報同樣的 ERR_PACKAGE_PATH_NOT_EXPORTED。\n【小字典】exports：package.json 裡的欄位，規定這個套件對外開放哪些匯入路徑。subpath：套件名稱後面接的那一段路徑，例如 price-tools/format 的 ./format。入口：套件對外開放、讓別人匯入的名字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 152);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 152 AS problem_id, 'import { formatPrice } from ''price-tools/src/format''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 152 AS problem_id, 'import { formatPrice } from ''price-tools/format''' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 152 AS problem_id, 'import { formatPrice } from ''price-tools/format.mjs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 152);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 153, '跳跳', '🐰', '模組路徑', 'ReferenceError: add is not defined', '名字沒定義：程式裡用了 add，但這個檔案裡根本沒有 add 這個名字可以用', 'export { add } from ''./math.mjs''\n\nconst prices = [120, 80, 60]\nlet total = 0\nfor (const price of prices) {\n  total = add(total, price)\n}\nconsole.log(total)', 1, '【哪裡出錯】export { add } from ''./math.mjs'' 只是把 add 轉手送給別的檔案，並不會讓這個檔案自己多一個 add，所以第 6 行用 add 時找不到。\n【用生活例子想】就像快遞站幫你把包裹轉寄給朋友，包裹只是經過，你自己手上並沒有留一份可以用。\n【一句話記住】要在自己檔案裡用，就一定要用 import 把它拿進來。\n【容易選錯】export * from ''./math.mjs'' 看起來把整包都帶進來了，但它一樣只是轉出去給別人用，這個檔案裡還是沒有 add，照樣報 add is not defined。\n【小字典】re-export：從別的檔案匯入後直接再匯出，自己不能用。import：把別的檔案匯出的東西拿進來當自己的變數。ReferenceError：用了一個不存在的名字時的錯誤。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 153);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 153 AS problem_id, 'export * from ''./math.mjs''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 153 AS problem_id, 'export { add as sum } from ''./math.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 153 AS problem_id, 'import { add } from ''./math.mjs''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 153);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 154, '跳跳', '🐰', '模組路徑', 'Error [ERR_MODULE_NOT_FOUND]: Cannot find module ''/utils/cart.mjs'' imported from /app/main.mjs', '找不到模組：程式去電腦最外層的 /utils 資料夾找 cart.mjs，但檔案其實在專案裡面。', '// 專案結構：main.mjs 和 utils 資料夾放在同一層\nimport { calcTotal } from ''/utils/cart.mjs''\n\nconst items = [{ name: ''tea'', price: 45 }, { name: ''cake'', price: 60 }]\nconst total = calcTotal(items)\nconsole.log(`Total: ${total}`)', 2, '【哪裡出錯】第 2 行的路徑以 / 開頭，Node 會把它當成整台電腦的最外層，而不是你的專案資料夾，所以找不到 cart.mjs。\n【用生活例子想】就像你說「去 /客廳 拿遙控器」，聽的人會跑去整個社區的最外面找，而不是你家的客廳。要說「從我這裡走過去」才對。\n【一句話記住】同一層或往下找檔案，路徑要用 ./ 開頭，代表從目前這個檔案所在的位置出發。\n【容易選錯】改成 ../utils/cart.mjs 最像對的，但 ../ 是往上一層資料夾，main.mjs 的上一層根本沒有 utils，還是會找不到模組。\n【小字典】相對路徑：從目前檔案的位置出發去找別的檔案。絕對路徑：從電腦最外層開始寫的完整位置。./：代表目前這個資料夾。../：代表上一層資料夾。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 154);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 154 AS problem_id, 'import { calcTotal } from ''./utils/cart.mjs''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 154 AS problem_id, 'import { calcTotal } from ''../utils/cart.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 154 AS problem_id, 'import { calcTotal } from ''utils/cart.mjs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 154);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 155, '跳跳', '🐰', '模組路徑', 'SyntaxError: The requested module ''./utils/index.mjs'' does not provide an export named ''add''', '找不到匯出的名字：main.mjs 向 index.mjs 要 add，但 index.mjs 並沒有把 add 轉出來。', '// utils/index.mjs 把工具函式集中轉出\n// greet.mjs 裡是 export const greet = (name) => `Hi ${name}`\n// math.mjs 裡是 export default function add(a, b) { return a + b }\nexport * from ''./greet.mjs''\nexport * from ''./math.mjs''', 5, '【哪裡出錯】export * 只會轉出別的檔案裡「有名字」的匯出，不包含 default，而 add 是 math.mjs 的 default 匯出，所以 index.mjs 沒有轉出 add，main.mjs 來拿就報錯。\n【用生活例子想】像搬家公司說「把貼了名牌的箱子全搬走」，但 add 是那個沒貼名牌的「主要箱子」，就被留在原地；你得另外交代「主要箱子也搬走，並貼上 add 的名牌」。\n【一句話記住】export * 不會帶走 default，要用 export { default as 名字 } from 轉出去。\n【容易選錯】export { add } from ''./math.mjs'' 最像答案，但 math.mjs 裡根本沒有叫 add 的具名匯出，只有 default，所以換上去一樣會報找不到 add 的 SyntaxError。\n【小字典】re-export：把別的檔案匯出的東西再轉手匯出。default export：每個檔案最多一個的預設匯出。具名匯出：有名字、可以用大括號匯入的匯出。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 155);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 155 AS problem_id, 'export { add } from ''./math.mjs''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 155 AS problem_id, 'export { default as add } from ''./math.mjs''' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 155 AS problem_id, 'export * as add from ''./math.mjs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 155);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 156, '跳跳', '🐰', '模組路徑', 'SyntaxError: Named export ''greet'' not found. The requested module ''./legacy.cjs'' is a CommonJS module, which may not support all module.exports as named exports.', '找不到具名匯出：舊式 CommonJS 檔案是整包丟出一個函式，你卻用大括號去拿一個叫 greet 的名字。', 'import { greet } from ''./legacy.cjs''\n\nconst guests = [''Amy'', ''Ben'', ''Cara'']\n\nfunction welcomeAll(list) {\n  return list.map((name) => greet(name))\n}\n\nconsole.log(welcomeAll(guests).join('' | ''))', 1, '【哪裡出錯】legacy.cjs 是用 module.exports = 函式 整個丟出去，裡面沒有叫 greet 的具名匯出，所以第 1 行用大括號拿 greet 會失敗，程式連一行都還沒跑就停了。\n【用生活例子想】就像店家把整盒便當直接遞給你，你卻說「我要盒子裡那個叫 greet 的菜」，盒子本身就是 greet，沒有再分菜名。\n【一句話記住】module.exports = 某個東西 的檔案，用 import 名字 from 拿整包，不要加大括號。\n【容易選錯】import * as greet 看起來像「全部拿來」，但它拿到的是模組命名空間物件，不是函式本身，所以執行 greet(name) 會出現 greet is not a function。\n【小字典】CommonJS：Node 早期的模組寫法，用 module.exports 和 require。default 匯入：不加大括號、拿到模組主要輸出的那一個東西。命名空間物件：import * as 得到的一包所有匯出的集合。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 156);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 156 AS problem_id, 'import greet from ''./legacy''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 156 AS problem_id, 'import * as greet from ''./legacy.cjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 156 AS problem_id, 'import greet from ''./legacy.cjs''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 156);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 157, '跳跳', '🐰', '模組路徑', 'ReferenceError: Cannot access ''currency'' before initialization', '變數還沒初始化就被讀取：format.mjs 一啟動就讀了 currency，但 currency 所在的那一行還沒執行到。', '// store.mjs: import { label } from ''./format.mjs''\n//           export const currency = ''TWD''\n// format.mjs: import { currency } from ''./store.mjs''\n//             export const label = `Prices in ${currency}`\n//             export { price } from ''./store.mjs''\nimport { price } from ''./store.mjs''\nimport { label } from ''./format.mjs''\n\nconsole.log(label)\nconsole.log(price(100))', 6, '【哪裡出錯】main 先載入 store.mjs，store 又先去載入 format.mjs，format 一開始就要用 currency，但 store 還沒執行到宣告 currency 的那一行。\n【用生活例子想】兩個人互相借東西：你進門前先要朋友的鑰匙，朋友卻要先拿你的鑰匙才能開門，誰先進門就決定誰會卡住。從 format 先進門，store 就能先把 currency 準備好。\n【一句話記住】循環 import 時，被讀取的 const 必須先執行完，所以要從「不會在頂層用到對方」的那個檔案先進入。\n【容易選錯】多匯入 currency 但還是寫 ''./store.mjs''，進入順序一樣是 store 先，format 還是會在 currency 準備好之前就讀它，錯誤照樣發生。\n【小字典】循環 import：兩個檔案互相 import 對方。TDZ：const 在宣告那一行之前不能被讀取，一讀就報錯。re-export：用 export { x } from 檔案 把別的檔案的東西轉出去。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 157);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 157 AS problem_id, 'import { price } from ''./format.mjs''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 157 AS problem_id, 'import { price, currency } from ''./store.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 157 AS problem_id, 'import { price } from ''./store''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 157);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 158, '跳跳', '🐰', '模組路徑', 'The app prints mode: development even though APP_MODE was set to production before the import.', '明明在上面先把 APP_MODE 設成 production，畫面卻印出 development，好像設定被忽略了。', '// main.mjs\nprocess.env.APP_MODE = ''production''\nconsole.log(''start app'')\n\nimport { mode, apiUrl } from ''./config.mjs''\n\nconsole.log(''mode:'', mode)\nconsole.log(''api:'', apiUrl)', 5, '【哪裡出錯】靜態的 import 會被提升到整個檔案最前面先執行，所以 config.mjs 讀 APP_MODE 的時候，第 2 行還沒有跑，讀到的是空的。\n【用生活例子想】就像你想先把鬧鐘設好再出門，但出門的人早就先走了，鬧鐘設定根本沒人看到。\n【一句話記住】想等設定完才載入模組，就要用 await import()，不要用最上面那種靜態 import。\n【容易選錯】在路徑後面加 ?env=production 看起來像把設定傳進去，但那只是網址的一段字，config.mjs 並不會去讀它，而且 import 還是先執行，所以仍然印出 development。\n【小字典】import 提升：靜態 import 會在其他程式碼之前先載入並執行。動態 import：寫成 import() 的函式形式，執行到那一行才載入，會回傳 Promise。process.env：Node 裡存放環境變數的物件。await：等 Promise 完成後才拿到結果。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 158);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 158 AS problem_id, 'import { mode, apiUrl } from ''./config.mjs?env=production''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 158 AS problem_id, 'const { mode, apiUrl } = await import(''./config.mjs'')' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 158 AS problem_id, 'const { mode, apiUrl } = import(''./config.mjs'')' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 158);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 159, '跳跳', '🐰', '模組路徑', 'Error [ERR_MODULE_NOT_FOUND]: Cannot find module ''/app/src/lib/format.mjs.mjs'' imported from /app/main.mjs', '找不到模組：錯誤訊息裡的檔名變成 format.mjs.mjs，副檔名好像被多加了一次。', '// package.json 的 imports："#lib/*": "./src/lib/*.mjs"\n// 檔案位置：src/lib/format.mjs 和 src/lib/tax.mjs\nimport { formatPrice } from ''#lib/format.mjs''\nimport { addTax } from ''#lib/tax''\n\nconst subtotal = 100\nconsole.log(formatPrice(addTax(subtotal)))', 3, '【哪裡出錯】package.json 的 imports 把 #lib/* 的星號換成你寫的字，再接上 .mjs。第 3 行已經寫了 .mjs，變成 format.mjs.mjs，這個檔案不存在。\n【用生活例子想】就像宅配單上的地址已經印好「號」字，你寫地址時又多寫一個「號」，結果寄到「12號號」，根本沒有這個地方。\n【一句話記住】用 # 別名匯入時，副檔名由 package.json 的規則補，import 裡不要再寫。\n【容易選錯】改成 ''#lib/format.js'' 看起來像是換了副檔名，但規則會再補一個 .mjs，變成 format.js.mjs，檔案一樣不存在，還是會報找不到模組。\n【小字典】imports 欄位：package.json 裡替專案內部路徑取別名的設定。#lib/*：別名規則，星號會被你後面寫的文字取代。ERR_MODULE_NOT_FOUND：Node 找不到你要載入的檔案時的錯誤代碼。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 159);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 159 AS problem_id, 'import { formatPrice } from ''#lib/format.js''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 159 AS problem_id, 'import { formatPrice } from ''#format''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 159 AS problem_id, 'import { formatPrice } from ''#lib/format''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 159);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 160, '跳跳', '🐰', '模組路徑', 'SyntaxError: The requested module ''./utils/index.mjs'' contains conflicting star exports for name ''format''', '星號匯出衝突：index 檔用 export * 同時轉出兩個檔案，它們都有 format，所以程式一載入就報錯。', '// utils/index.mjs 裡面有兩行：\n// export * from ''./date.mjs''\n// export * from ''./money.mjs''\n// 兩個檔案都有 export function format\nimport { format } from ''./utils/index.mjs''\n\nconst price = 1280\nconst label = format(price)\nconsole.log(label)', 5, '【哪裡出錯】index.mjs 用 export * 同時轉出 date.mjs 和 money.mjs，兩邊都有叫 format 的函式，名字撞在一起，所以從 index.mjs 匯入 format 時 Node 不知道要拿哪一個而報錯。\n【用生活例子想】就像班上有兩個同學都叫小明，老師喊「小明來一下」，大家都愣住了，要喊全名才知道是誰。\n【一句話記住】同名的東西從兩個地方都轉出來時，要直接從你要的那個檔案匯入。\n【容易選錯】最像的是改成從 date.mjs 匯入 format，這樣確實不會報錯，但那是處理日期的 format，拿 1280 去用會印出日期而不是金額，結果還是不對。\n【小字典】export *：把另一個檔案的所有具名匯出一次轉出去。具名匯出：用名字匯出的東西，匯入時要用大括號寫同樣的名字。index 檔：把很多檔案集中轉出的入口檔。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 160);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 160 AS problem_id, 'import { format } from ''./utils/money.mjs''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 160 AS problem_id, 'import { format } from ''./utils/date.mjs''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 160 AS problem_id, 'import format from ''./utils/index.mjs''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 160);

-- 嚕嚕：React 列表 key
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 161, '嚕嚕', '🐹', 'React 列表 key', 'Each child in a list should have a unique "key" prop.', '清單項目缺少 key：React 說清單裡每一項都需要獨一無二的 key，可是你明明有寫 key 啊。', 'function TeamList({ members }) {\n  return <ul>{members.map((m) => <li><span key={m.id}>{m.name}</span></li>)}</ul>;\n}\nconst members = [{ id: 1, name: "小明" }, { id: 2, name: "阿華" }];', 2, '【哪裡出錯】key 被放在裡面的 span 上，但 map 每一圈回傳的最外層元素是 li，React 只看最外層有沒有 key，所以還是抱怨。\n【用生活例子想】就像老師點名，名牌要貼在走進教室的那個人身上，貼在他書包裡的筆袋上，老師是看不到的。\n【一句話記住】key 要寫在 map 回傳的最外層那個元素上。\n【容易選錯】把 span 的 key 改成 m.name 看起來像是換了更好的值，但 key 還是貼在 span 上，最外層的 li 依然沒有 key，警告照樣出現。\n【小字典】key：React 用來分辨清單每一項的名牌。map：把陣列每一項變成另一種東西的方法。最外層元素：箭頭函式回傳的那個最上面的標籤。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 161);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 161 AS problem_id, '  return <ul>{members.map((m) => <li key={m.id}><span>{m.name}</span></li>)}</ul>;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 161 AS problem_id, '  return <ul>{members.map((m) => <li><span key={m.name}>{m.name}</span></li>)}</ul>;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 161 AS problem_id, '  return <ul>{members.map((m) => <li data-key={m.id}><span>{m.name}</span></li>)}</ul>;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 161);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 162, '嚕嚕', '🐹', 'React 列表 key', 'Each child in a list should have a unique "key" prop.', '缺少 key：外層清單的 li 已經有 key，但內層用 map 產生的標籤沒有，React 還是會警告。', 'function CourseList() {\n  const courses = [{ id: 1, tags: ["必修", "大一"] }];\n  return (\n    <ul>\n      {courses.map((c) => <li key={c.id}>{c.tags.map((tag) => <small>{tag}</small>)}</li>)}\n    </ul>\n  );\n}', 5, '【哪裡出錯】內層的 c.tags.map 也是在產生清單，但每個 <small> 都沒有 key，所以 React 照樣警告。\n【用生活例子想】想像學校有很多班級，每班都有座號。班級有班級號碼，班上的同學也要有自己的座號，不能只靠班級號碼分辨。\n【一句話記住】每一層 map 產生的清單，最外層的元素都要有自己的 key。\n【容易選錯】只在 map 的函式裡多寫 (tag, i) 看起來像有處理，但 i 只是拿來放著沒用，<small> 還是沒有 key，警告照樣出現。\n【小字典】key：React 用來分辨清單項目的名牌。巢狀清單：清單裡面又有另一個清單。警告：程式還能跑，但 React 提醒你寫法有問題。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 162);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 162 AS problem_id, '      {courses.map((c) => <li key={c.id}>{c.tags.map((tag, i) => <small>{tag}</small>)}</li>)}' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 162 AS problem_id, '      {courses.map((c) => <li key={c.id}>{c.tags.map((tag) => <small key={tag}>{tag}</small>)}</li>)}' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 162 AS problem_id, '      {courses.map((c) => <li key={c.id}>{c.tags.map((tag) => <><small key={tag}>{tag}</small></>)}</li>)}' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 162);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 163, '嚕嚕', '🐹', 'React 列表 key', 'The empty-state message never appears when the todo list is empty; the page shows an empty list.', '待辦清單是空的時候，應該顯示「目前沒有待辦」，但畫面上什麼提示都沒有，只有一個空的清單。', 'function TodoList() {\n  const todos = [];\n  return <ul>{todos.map((t) => <li key={t.id}>{t.title}</li>) || <li>目前沒有待辦</li>}</ul>;\n}', 3, '【哪裡出錯】todos.map(...) 在清單是空的時候會回傳空陣列 []，而 [] 在 JavaScript 裡算「真值」，所以 || 後面的備用畫面永遠不會被用到。\n【用生活例子想】就像你打開一個空的便當盒，盒子本身還是存在的，所以店員不會因為「沒有便當」就幫你換一個，你得自己先數一數裡面有幾個才知道。\n【一句話記住】要判斷清單有沒有東西，請檢查 length，不要拿陣列本身當條件。\n【容易選錯】用 ?? 看起來像是在做備用值，但 ?? 只會在左邊是 null 或 undefined 時才換，空陣列兩者都不是，所以結果一樣是空清單。\n【小字典】真值：放進條件判斷時會被當成 true 的值，空陣列就是其中一種。||：左邊是假值才會用右邊。??：左邊是 null 或 undefined 才會用右邊。三元運算子：用 條件 ? A : B 二選一。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 163);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 163 AS problem_id, '  return <ul>{todos.map((t) => <li key={t.id}>{t.title}</li>) ?? <li>目前沒有待辦</li>}</ul>;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 163 AS problem_id, '  return <ul>{todos.length === 0 ? todos.map((t) => <li key={t.id}>{t.title}</li>) : <li>目前沒有待辦</li>}</ul>;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 163 AS problem_id, '  return <ul>{todos.length > 0 ? todos.map((t) => <li key={t.id}>{t.title}</li>) : <li>目前沒有待辦</li>}</ul>;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 163);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 164, '嚕嚕', '🐹', 'React 列表 key', 'ReferenceError: id is not defined', '變數不存在：key 裡寫的 id 在這個程式裡從來沒有宣告過，程式找不到它就直接報錯', 'function ProductList() {\n  const products = [{ id: 1, name: "鉛筆" }, { id: 2, name: "橡皮擦" }];\n  return (\n    <ul>\n      {products.map((product) => <li key={id}>{product.name}</li>)}\n    </ul>\n  );\n}', 5, '【哪裡出錯】第 5 行的 key={id} 直接用了 id，但程式裡沒有宣告叫 id 的變數，id 其實是藏在 product 這個物件裡面。\n【用生活例子想】全班同學都在 product 這個袋子裡，你喊「座號」卻沒說是誰的，老師找不到人；要說「這位同學的座號」才對。\n【一句話記住】map 裡每一筆資料的欄位，要寫成 product.id，不能只寫 id。\n【容易選錯】key={index} 看起來很合理，但 index 也沒有宣告，因為 map 只接了 product 一個參數，所以還是會報 ReferenceError。\n【小字典】ReferenceError：用了一個沒宣告過的變數名稱時出現的錯誤。key：React 用來分辨清單每一項的名牌。map：把陣列每一筆資料轉成另一種東西的方法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 164);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 164 AS problem_id, '      {products.map((product) => <li key={product.id}>{product.name}</li>)}' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 164 AS problem_id, '      {products.map((product) => <li key={index}>{product.name}</li>)}' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 164 AS problem_id, '      {products.map((product) => <li key={name}>{product.name}</li>)}' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 164);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 165, '嚕嚕', '🐹', 'React 列表 key', 'TypeError: tags.map is not a function', 'map 不是函式：tags 是一整串文字，不是陣列，文字沒有 map 可以用', 'function TagList() {\n  const tags = "react,vue,svelte";\n  return (\n    <ul>\n      {tags.map((tag) => <li key={tag}>{tag}</li>)}\n    </ul>\n  );\n}', 5, '【哪裡出錯】tags 是一整串用逗號連起來的文字，不是陣列，而 map 只有陣列才有，所以程式說 tags.map 不是函式。\n【用生活例子想】就像一整條沒切的吐司，你不能直接一片一片發給同學，要先用刀切成一片一片，才發得出去。\n【一句話記住】想用 map 畫清單，資料一定要先是陣列，文字要先用 split 切開。\n【容易選錯】split("") 看起來也有切，但引號裡是空字串，會把每一個字母都切開，畫面會出現 r、e、a、c、t 一個字一個項目，不是三個標籤。\n【小字典】split：把文字依照指定符號切成陣列。map：把陣列每一項變成一個新東西，常用來畫清單。陣列：用中括號裝好幾筆資料的清單。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 165);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 165 AS problem_id, '      {tags.split("").map((tag) => <li key={tag}>{tag}</li>)}' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 165 AS problem_id, '      {tags.split(",").map((tag) => <li key={tag}>{tag}</li>)}' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 165 AS problem_id, '      {tags.slice(",").map((tag) => <li key={tag}>{tag}</li>)}' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 165);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 166, '嚕嚕', '🐹', 'React 列表 key', 'Each row starts with undefined instead of its id, and the console warns that key is not a prop.', '清單每一列開頭都顯示 undefined，不是編號 1、2，主控台還警告 key 不是 prop。', 'function Row(props) {\n  const label = props.key + ". " + props.title;\n  return <li>{label}</li>;\n}\nfunction BookList() {\n  const books = [{ id: 1, title: "小王子" }, { id: 2, title: "夏洛的網" }];\n  return <ul>{books.map((b) => <Row key={b.id} id={b.id} title={b.title} />)}</ul>;\n}', 2, '【哪裡出錯】key 是給 React 自己用的標記，不會傳進子元件的 props，所以 props.key 讀出來是 undefined。要用編號，要讀另外傳進來的 props.id。\n【用生活例子想】key 像學校幫你登記的學號，只有學校系統看得到。如果老師上課想叫你的編號，你得自己再報一次座號給他。\n【一句話記住】key 只給 React 看，子元件要用的值，另外用別的 prop 傳。\n【容易選錯】props["key"] 看起來像換了一種讀法，但它跟 props.key 是同一件事，React 一樣不會把 key 放進 props，讀出來還是 undefined，警告也還在。\n【小字典】props：父元件傳給子元件的資料。key：React 用來分辨清單項目的特殊標記。undefined：代表沒有值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 166);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 166 AS problem_id, '  const label = props["key"] + ". " + props.title;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 166 AS problem_id, '  const label = props.keys + ". " + props.title;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 166 AS problem_id, '  const label = props.id + ". " + props.title;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 166);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 167, '嚕嚕', '🐹', 'React 列表 key', 'The first row reads the name followed by 1 and a dot and then 0, instead of showing 1. followed by the name.', '畫面上排行榜的文字亂掉：名字跑到前面，後面還接著奇怪的數字，沒有出現「1. 名字」的樣子。', 'function RankList() {\n  const names = ["小明", "阿華", "美美"];\n  return (\n    <ol>\n      {names.map((index, name) => (\n        <li key={index}>{index + 1}. {name}</li>\n      ))}\n    </ol>\n  );\n}', 5, '【哪裡出錯】map 的 callback 第一個參數一定是「項目本身」，第二個才是「索引」，這裡寫反了，所以 index 其實拿到名字，name 拿到的是數字。\n【用生活例子想】就像點名，名單上第一欄是人名、第二欄是座號，你卻把人名欄當成座號來讀，當然會讀出怪怪的結果。\n【一句話記住】map 的參數順序是 (item, index)，名字隨你取，位置不能換。\n【容易選錯】只把參數改成 (name) 看起來像是少一個參數就好，但第 6 行還在用 index，執行時會直接報 index is not defined。\n【小字典】callback：交給 map 去對每個項目呼叫的函式。index：項目在陣列裡的位置，從 0 開始。解構：把物件的屬性拆出來變成變數的寫法。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 167);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 167 AS problem_id, '      {names.map((name, index) => (' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 167 AS problem_id, '      {names.map((name) => (' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 167 AS problem_id, '      {names.map(({ name, index }) => (' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 167);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 168, '嚕嚕', '🐹', 'React 列表 key', 'The rating shows no stars at all, and there is no error.', '畫面上應該要有 3 顆星，結果一顆都沒出現，也沒有任何錯誤訊息。', 'function StarRating() {\n  const rating = 3;\n  const stars = new Array(rating).map((_, i) => <span key={i}>★</span>);\n  return (\n    <div>{stars}</div>\n  );\n}', 3, '【哪裡出錯】new Array(3) 只是做出 3 個「空格子」，格子裡還沒有放任何東西，而 map 會跳過空格子，所以 callback 一次都沒跑，stars 是空的。\n【用生活例子想】就像你買了一個有 3 格的空蛋盒，叫工人「把每個雞蛋塗上顏色」，但盒子裡根本沒有蛋，工人當然什麼都沒塗。\n【一句話記住】要用數字產生清單，請用 Array.from({ length: n }, ...)，讓每一格真的有值。\n【容易選錯】Array.of(rating) 看起來也是在做陣列，但它做出的是只有一個元素 3 的陣列 [3]，所以只會出現 1 顆星，不是 3 顆。\n【小字典】空洞陣列：長度有了但格子裡沒有值的陣列。Array.from：依照規則真的把每一格都建出來的方法。callback：交給 map 去對每個項目執行的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 168);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 168 AS problem_id, '  const stars = Array.of(rating).map((_, i) => <span key={i}>★</span>);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 168 AS problem_id, '  const stars = Array.from({ length: rating }, (_, i) => <span key={i}>★</span>);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 168 AS problem_id, '  const stars = new Array(rating).forEach((_, i) => <span key={i}>★</span>);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 168);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 169, '嚕嚕', '🐹', 'React 列表 key', 'Every task shows a blank status, even the finished one, and there is no error.', '狀態欄一片空白：兩個任務旁邊都沒有字，連已經完成的也一樣，而且沒有任何錯誤訊息。', 'const tasks = [\n  { id: 1, title: "寫作業", done: true },\n  { id: 2, title: "洗衣服", done: false },\n];\nfunction TaskList() {\n  return (\n    <ul>\n      {tasks.map((t) => <li key={t.id}>{t.title}<span>{t.done}</span></li>)}\n    </ul>\n  );\n}', 8, '【哪裡出錯】第 8 行直接把 t.done 放進 JSX，但它是 true 或 false，React 不會把布林值畫到畫面上，所以 span 裡什麼都沒有。\n【用生活例子想】就像出席表的「到了嗎」那一欄，老師只在格子裡寫「是」或「否」才看得懂，如果只丟一個開關進去，格子就是空的。\n【一句話記住】true 和 false 不會顯示，要用三元運算子把它換成想給人看的文字。\n【容易選錯】改成 {t.done && "完成"} 最像答案，已完成的任務會出現「完成」，但 done 是 false 時整個運算結果是 false，未完成的任務狀態欄還是空白，所以還是不對。\n【小字典】布林值：只有 true 和 false 兩種值的資料。三元運算子：條件 ? 值A : 值B，條件成立用 A，否則用 B。渲染：把資料變成畫面上看得到的內容。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 169);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 169 AS problem_id, '      {tasks.map((t) => <li key={t.id}>{t.title}<span>{t.done && "完成"}</span></li>)}' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 169 AS problem_id, '      {tasks.map((t) => <li key={t.id}>{t.title}<span>{t.done.toString}</span></li>)}' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 169 AS problem_id, '      {tasks.map((t) => <li key={t.id}>{t.title}<span>{t.done ? "完成" : "未完成"}</span></li>)}' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 169);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 170, '嚕嚕', '🐹', 'React 列表 key', 'Each row shows single letters such as a: p and b: a instead of apple: 30 and banana: 20.', '畫面上每一列只出現單一個字母，像「a: p」，而不是「apple: 30」，而且沒有報錯。', 'const prices = { apple: 30, banana: 20, guava: 45 };\n\nfunction PriceList() {\n  return (\n    <ul>\n      {Object.keys(prices).map(([name, price]) => (\n        <li key={name}>{`${name}: ${price}`}</li>\n      ))}\n    </ul>\n  );\n}', 6, '【哪裡出錯】Object.keys(prices) 只會給你一排名稱字串，像 "apple"，不會給名稱加價格的配對。你卻用 [name, price] 去拆它，結果字串被拆成一個個字母，name 變成 "a"，price 變成 "p"。\n【用生活例子想】Object.keys 像只給你一份菜名清單，上面沒有價錢。你硬要從菜名裡讀價錢，只能讀到菜名的第二個字。\n【一句話記住】要同時拿到名稱和值來渲染清單，就用 Object.entries，它會給你 [名稱, 值] 的配對。\n【容易選錯】改成 Object.values 看起來像在拿值，但每個值是數字 30，數字不能拿來拆成 [name, price]，執行時會直接報錯，而且名稱也不見了。\n【小字典】Object.keys：回傳物件所有屬性名稱組成的陣列。Object.entries：回傳 [名稱, 值] 配對組成的陣列。解構：把陣列或物件的內容一次拆給多個變數。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 170);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 170 AS problem_id, '      {Object.entries(prices).map(([name, price]) => (' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 170 AS problem_id, '      {Object.values(prices).map(([name, price]) => (' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 170 AS problem_id, '      {Object.keys(prices).map(({ name, price }) => (' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 170);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 171, '嚕嚕', '🐹', 'React 列表 key', 'TypeError: uniqueNames.map is not a function', '不是函式：uniqueNames 是 Set 不是陣列，Set 身上沒有 map 可以呼叫，所以畫面一渲染就壞掉', 'const visitors = ["Amy", "Ben", "Amy", "Cleo", "Ben"];\nfunction VisitorList() {\n  const uniqueNames = new Set(visitors);\n  return (\n    <ul>\n      {uniqueNames.map((name) => <li key={name}>{name}</li>)}\n    </ul>\n  );\n}', 3, '【哪裡出錯】new Set(visitors) 做出來的是 Set，不是陣列，Set 沒有 map，所以第 6 行呼叫 uniqueNames.map 就當掉了。\n【用生活例子想】Set 像一個不收重複名牌的籃子，只能拿出來看；map 是陣列這條生產線才有的機器，籃子上沒有，要先把名牌排成一列才能上線加工。\n【一句話記住】想用 map 畫列表，資料一定要是陣列；Set 要用 [...set] 或 Array.from 轉成陣列。\n【容易選錯】Array.from(visitors) 看起來像在轉陣列，但它轉的是原本有重複的 visitors，不是去重後的 Set，所以 Amy 和 Ben 會出現兩次，還會多出重複 key 的警告。\n【小字典】Set：一種不會有重複值的集合。展開運算子：用 ... 把可以逐一走訪的東西攤成陣列元素。Array.from：把類似陣列或可走訪的東西轉成真正的陣列。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 171);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 171 AS problem_id, '  const uniqueNames = Array.from(visitors);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 171 AS problem_id, '  const uniqueNames = [...new Set(visitors)];' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 171 AS problem_id, '  const uniqueNames = Object.keys(new Set(visitors));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 171);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 172, '嚕嚕', '🐹', 'React 列表 key', 'The fruit list is empty even though two products have category 1, and there is no error.', '清單是空的但沒有報錯：篩選用的 === 連型別都要一樣，字串 "1" 和數字 1 不會被當成同一個。', 'function FruitList() {\n  const categoryId = "1"; // 下拉選單選出來的值一定是字串\n  const products = [{ id: 1, name: "蘋果", categoryId: 1 }, { id: 2, name: "鉛筆", categoryId: 2 }, { id: 3, name: "香蕉", categoryId: 1 }];\n  const fruits = products.filter((p) => p.categoryId === categoryId);\n  return <ul>{fruits.map((p) => <li key={p.id}>{p.name}</li>)}</ul>;\n}', 4, '【哪裡出錯】categoryId 是字串 "1"，資料裡的 p.categoryId 是數字 1，=== 要求型別也相同，所以每一筆都被 filter 篩掉，清單變空。\n【用生活例子想】就像你拿著寫著「1」的紙條去對號碼牌，但櫃台只認數字 1 的牌子，格式不同就說不是同一個。\n【一句話記住】用 === 篩選清單前，先確認兩邊的型別一樣，必要時用 Number() 轉成數字。\n【容易選錯】把 p.categoryId 改成 Number(p.categoryId) 很像對的，但它是把資料那邊轉成數字，右邊的 categoryId 還是字串，兩邊型別還是不同，清單照樣是空的。\n【小字典】===：嚴格相等，值和型別都要一樣才算相等。filter：留下條件成立的項目，產生新陣列。Number()：把字串轉成數字的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 172);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 172 AS problem_id, '  const fruits = products.filter((p) => Number(p.categoryId) === categoryId);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 172 AS problem_id, '  const fruits = products.filter((p) => p.categoryId === String(categoryId));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 172 AS problem_id, '  const fruits = products.filter((p) => p.categoryId === Number(categoryId));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 172);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 173, '嚕嚕', '🐹', 'React 列表 key', 'TypeError: admins.map is not a function', 'map 不是函式：admins 拿到的不是陣列，所以不能呼叫 map。', 'function AdminList() {\n  const users = [\n    { id: 1, name: "Amy", role: "admin" },\n    { id: 2, name: "Ben", role: "member" },\n    { id: 3, name: "Cleo", role: "admin" },\n  ];\n  const admins = users.find((u) => u.role === "admin");\n  return <ul>{admins.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;\n}', 7, '【哪裡出錯】users.find 找到第一個符合的人就停下來，只回傳那一個物件，不是陣列，所以 admins.map 會說 map 不是函式。\n【用生活例子想】find 像老師點名只叫出第一個舉手的同學，filter 才是把所有舉手的同學都請到台前排成一排。\n【一句話記住】要把符合條件的全部渲染成清單，用 filter 拿到陣列再 map。\n【容易選錯】加上 || [] 看起來有保險，但 find 找到人時是一個物件，物件是真值，備用的空陣列根本不會用到，還是會報同樣的錯。\n【小字典】find：找出第一個符合條件的項目並回傳那一個。filter：挑出所有符合條件的項目，回傳新陣列。真值：在判斷式裡會被當成 true 的值，例如物件。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 173);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 173 AS problem_id, '  const admins = users.filter((u) => u.role === "admin");' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 173 AS problem_id, '  const admins = users.find((u) => u.role === "admin") || [];' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 173 AS problem_id, '  const admins = users.findLast((u) => u.role === "admin");' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 173);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 174, '嚕嚕', '🐹', 'React 列表 key', 'Searching for app lists only Pineapple, and Apple is missing, with no error.', '搜尋 app 時，清單只出現 Pineapple，Apple 不見了，而且沒有任何錯誤訊息。', 'function FruitSearch() {\n  const fruits = ["Apple", "Banana", "Pineapple"];\n  const query = "app";\n  const matched = fruits.filter((f) => f.includes(query));\n  return (\n    <ul>{matched.map((f) => <li key={f}>{f}</li>)}</ul>\n  );\n}', 4, '【哪裡出錯】includes 會分大小寫，"Apple" 的 A 是大寫，和小寫的 "app" 對不起來，所以 Apple 被 filter 擋掉了。\n【用生活例子想】就像點名時老師唱名 "app"，但名單上寫的是 "App"，如果字母大小寫要完全一樣，這個人就會被當成不在名單上。\n【一句話記住】搜尋文字前，先把兩邊都轉成小寫再比對。\n【容易選錯】把 query 轉小寫看起來很合理，但 query 本來就是小寫，Apple 的大寫 A 還是沒處理，結果仍然只有 Pineapple。\n【小字典】filter：留下符合條件的項目，組成新陣列。includes：檢查字串裡有沒有包含某段文字，會分大小寫。toLowerCase：把字串全部變成小寫。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 174);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 174 AS problem_id, '  const matched = fruits.filter((f) => f.includes(query.toLowerCase()));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 174 AS problem_id, '  const matched = fruits.filter((f) => f.toLowerCase().includes(query));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 174 AS problem_id, '  const matched = fruits.filter((f) => f.toLowerCase().startsWith(query));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 174);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 175, '嚕嚕', '🐹', 'React 列表 key', 'The total shows 0 instead of 73 even though both items are listed.', '畫面上兩個商品都有出現，但上面的總價卻顯示 0，不是 73，而且沒有任何錯誤訊息。', 'function Cart() {\n  const items = [{ id: 1, name: "筆記本", price: 45 }, { id: 2, name: "原子筆", price: 28 }];\n  let total = 0;\n  return <div>\n    <p>總價 {total}</p>\n    <ul>{items.map((item) => {\n      total += item.price;\n      return <li key={item.id}>{item.name}</li>;\n    })}</ul>\n  </div>;\n}', 5, '【哪裡出錯】第 5 行的 {total} 在 JSX 裡排在清單前面，React 由上往下算，算到它的時候 map 還沒跑，total 還是 0。\n【用生活例子想】就像你在收銀台前先把總價寫在帳單最上面，可是商品還沒一個一個掃，當然只能先寫 0。\n【一句話記住】要顯示的數字，請在那個位置直接算好，不要靠後面的 map 順便累加。\n【容易選錯】total.toFixed(0) 只是把 0 變成文字 "0"，值還是 0；total || items[0].price 會在 0 時改拿第一個商品的 45，也不是 73，所以兩個都不對。\n【小字典】副作用：函式順便改動外面變數的行為，像 map 裡的 total += 就是。reduce：把陣列一路合併成一個值，常用來加總。求值順序：程式和 JSX 由上往下、由左往右一個一個算。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 175);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 175 AS problem_id, '    <p>總價 {total.toFixed(0)}</p>' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 175 AS problem_id, '    <p>總價 {total || items[0].price}</p>' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 175 AS problem_id, '    <p>總價 {items.reduce((sum, item) => sum + item.price, 0)}</p>' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 175);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 176, '嚕嚕', '🐹', 'React 列表 key', 'The list shows the text [object Object][object Object] instead of the two product names.', '畫面上沒有商品名稱，只看到一串 [object Object]。問題不在最後的 return，要往上找 rows 是怎麼做出來的。', 'const products = [\n  { id: 1, name: "鉛筆" },\n  { id: 2, name: "筆記本" },\n];\nfunction ProductList() {\n  const rows = products.map((p) => <li key={p.id}>{p.name}</li>).join("");\n  return <ul>{rows}</ul>;\n}', 6, '【哪裡出錯】第 6 行的 map 做出的是 li 元素陣列，後面又接 join("")，把每個元素硬變成文字，變成 [object Object] 黏在一起。\n【用生活例子想】就像你把一排做好的便當盒直接倒進果汁機，打出來的只是一杯看不出原樣的東西，React 也就畫不出清單了。\n【一句話記住】React 的清單直接放 map 回傳的陣列就好，不要再用 join 把它變成字串。\n【容易選錯】改成 join("\\n") 看起來像是換個分隔符號，但 join 照樣把每個 li 元素轉成文字，畫面還是 [object Object]。改成 toString() 也一樣，因為陣列轉成字串後元素都變成文字。\n【小字典】join：把陣列裡的東西接成一個字串。toString：把值轉成文字。JSX 元素：用 JSX 寫出來的是物件，不是文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 176);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 176 AS problem_id, '  const rows = products.map((p) => <li key={p.id}>{p.name}</li>);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 176 AS problem_id, '  const rows = products.map((p) => <li key={p.id}>{p.name}</li>).join("\\n");' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 176 AS problem_id, '  const rows = products.map((p) => <li key={p.id}>{p.name}</li>).toString();' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 176);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 177, '嚕嚕', '🐹', 'React 列表 key', 'The sign-up order list shows Ben, Cleo, Amy instead of Amy, Ben, Cleo.', '排行榜排好了，但下面「報名順序」的清單也跟著被排成分數高低，沒有保持原本的順序。', 'function Leaderboard() {\n  const players = [{ id: 1, name: "Amy", score: 40 }, { id: 2, name: "Ben", score: 90 }, { id: 3, name: "Cleo", score: 70 }];\n  const ranked = players.sort((a, b) => b.score - a.score);\n  return (\n    <div>\n      <ol>{ranked.map((p) => <li key={p.id}>{p.name}</li>)}</ol>\n      <ul>{players.map((p) => <li key={p.id}>{p.name}</li>)}</ul>\n    </div>\n  );\n}', 3, '【哪裡出錯】第 3 行的 sort 會直接把 players 這個原陣列改掉，ranked 和 players 其實是同一個陣列，所以下面用 players 的清單也跟著變了順序。\n【用生活例子想】就像你把班上的座位表直接拿來重新排名次，貼在公布欄上，原本的座位表也被你改掉了；要排名次應該先影印一份再改。\n【一句話記住】sort 會改動原陣列，要排序又想保留原本順序，就先用 [...陣列] 複製一份再排。\n【容易選錯】最像的是在 sort 後面再接 map：map 雖然會產生新陣列，但 sort 早就已經把 players 改掉了，所以報名順序的清單還是被排亂。\n【小字典】sort：把陣列排序，而且會直接修改原陣列。展開運算子：寫成 [...players] 可以複製出一個新陣列。原陣列：最早建立、被別處共用的那個陣列。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 177);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 177 AS problem_id, '  const ranked = players.sort((a, b) => b.score - a.score).map((p) => p);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 177 AS problem_id, '  const ranked = [...players].sort((a, b) => b.score - a.score);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 177 AS problem_id, '  const ranked = players.sort((a, b) => a.score - b.score);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 177);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 178, '嚕嚕', '🐹', 'React 列表 key', 'Page 1 shows the 4th to 6th fruits instead of the 1st to 3rd, and there is no error.', '第 1 頁應該顯示前三種水果，畫面卻顯示第 4 到第 6 種，而且沒有任何錯誤訊息。', 'const fruits = ["蘋果", "香蕉", "芭樂", "葡萄", "西瓜", "柚子"];\nconst pageSize = 3;\nconst page = 1;\nconst start = page * pageSize;\nconst visible = fruits.slice(start, start + pageSize);\nfunction FruitPage() {\n  return (\n    <ul>\n      {visible.map((fruit) => <li key={fruit}>{fruit}</li>)}\n    </ul>\n  );\n}', 4, '【哪裡出錯】第 4 行把起點算成 page * pageSize，第 1 頁變成從第 3 格開始切，所以跳過了前三筆。陣列的格子是從 0 開始數，但頁數是從 1 開始數。\n【用生活例子想】想像一本書每頁印 3 個水果，第 1 頁是最前面的 3 個。如果你直接翻到第 1 頁乘 3 的位置，等於已經翻過了第一頁。\n【一句話記住】頁數從 1 開始，格子從 0 開始，起點要先把頁數減 1 再乘每頁筆數。\n【容易選錯】最像的是 page * pageSize - 1，它只是往前退一格，起點變成 2，會顯示芭樂、葡萄、西瓜，還是不是第一頁的內容。\n【小字典】slice：從陣列切出一段新陣列，包含起點、不包含終點。pageSize：每一頁要顯示幾筆。索引：陣列裡每個項目的位置編號，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 178);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 178 AS problem_id, 'const start = page * pageSize - 1;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 178 AS problem_id, 'const start = (page + 1) * pageSize;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 178 AS problem_id, 'const start = (page - 1) * pageSize;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 178);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 179, '嚕嚕', '🐹', 'React 列表 key', 'The author line ends with a stray comma after Cleo, and there is no error.', '作者名單最後一個名字 Cleo 後面多了一個逗號，畫面沒有任何錯誤訊息。', 'function AuthorLine() {\n  const names = ["Amy", "Ben", "Cleo"];\n  return (\n    <p>\n      {names.map((name, i) => (\n        <span key={name}>{i < names.length ? name + ", " : name}</span>\n      ))}\n    </p>\n  );\n}', 6, '【哪裡出錯】索引 i 最大只會到 2，但 names.length 是 3，所以 i < names.length 每一次都成立，最後一個名字也被加上逗號。\n【用生活例子想】三個人排隊發糖果，每個人後面都要說「還有下一位」，但最後一位後面沒有人了，所以不能說。\n【一句話記住】索引從 0 開始，最後一項的索引是 length - 1，所以判斷「不是最後一項」要寫 i < length - 1。\n【容易選錯】i <= names.length - 1 看起來很像在處理最後一項，但最後一項的索引剛好等於 length - 1，所以條件還是每次都成立，逗號照樣多出來。\n【小字典】索引（index）：項目在陣列裡的位置，從 0 開始算。length：陣列裡有幾個項目。三元運算子：條件 ? 結果A : 結果B，條件成立用 A，不成立用 B。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 179);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 179 AS problem_id, '        <span key={name}>{i < names.length - 1 ? name + ", " : name}</span>' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 179 AS problem_id, '        <span key={name}>{i <= names.length - 1 ? name + ", " : name}</span>' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 179 AS problem_id, '        <span key={name}>{i < names.length - 2 ? name + ", " : name}</span>' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 179);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 180, '嚕嚕', '🐹', 'React 列表 key', 'The list shows 2 blank items instead of the 3 product names.', '清單只出現 2 個空白項目，而不是 3 個商品名稱，主控台還警告缺少 key。', 'function ProductList() {\n  const categories = [\n    { id: 1, products: [{ id: 11, name: "筆記本" }, { id: 12, name: "原子筆" }] },\n    { id: 2, products: [{ id: 21, name: "書包" }] },\n  ];\n  const products = categories.map((c) => c.products);\n  return <ul>{products.map((p) => <li key={p.id}>{p.name}</li>)}</ul>;\n}', 6, '【哪裡出錯】第 6 行用 map 取出每個分類的 products，結果是「陣列裡面還有陣列」，共 2 包而不是 3 個商品。第 7 行的 p 其實是一整包商品陣列，所以 p.id 和 p.name 都是 undefined，畫出 2 個空白項目。\n【用生活例子想】你把兩個便當盒收進一個袋子，袋子裡只有 2 個盒子，不是 3 道菜。要先把每個盒子打開，把菜倒在同一個盤子裡，才能一道一道數。\n【一句話記住】每個分類裡還有清單時，用 flatMap 先攤平成一層，再拿去 map 渲染。\n【容易選錯】categories.map((c) => c.products.map((p) => p)) 看起來有處理到裡面那層，但外層 map 還是會多包一層陣列，結果仍是 2 包陣列，畫面還是 2 個空白項目。\n【小字典】map：把每個項目轉成新項目，筆數不變。flatMap：先 map 再攤平一層。巢狀陣列：陣列裡面還有陣列。key：React 用來分辨清單項目的名牌。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 180);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 180 AS problem_id, '  const products = categories.map((c) => c.products.map((p) => p));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 180 AS problem_id, '  const products = categories.flatMap((c) => c.products);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 180 AS problem_id, '  const products = categories.map((c) => c.products[0]);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 180);

-- 阿福：React 狀態
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 181, '阿福', '🐶', 'React 狀態', 'TypeError: Cannot read properties of undefined (reading ''name'')', '讀不到屬性：props.user 是 undefined，你卻想從它裡面再拿 name，所以畫面出錯。', 'function Welcome(props) {\n  return <h1>你好，{props.user.name}</h1>;\n}\n\nconst app = <Welcome name="小明" />;', 2, '【哪裡出錯】呼叫元件時只傳了 name，沒有傳 user，所以 props.user 是 undefined，再去讀它的 name 就當機了。\n【用生活例子想】就像朋友只給你一張寫著名字的紙條，你卻跑去找他的「身分證資料夾」，當然找不到東西可以翻。\n【一句話記住】收到什麼 props 就讀什麼 props，名稱要和傳進來的一模一樣。\n【容易選錯】props.user?.name 只是讓程式不當機，但 user 還是不存在，畫面只會顯示「你好，」，沒有名字，問題並沒有解決。\n【小字典】props：父元件傳給子元件的資料。undefined：代表這個東西不存在、沒有值。元件：用來組成畫面的小積木，寫成函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 181);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 181 AS problem_id, '  return <h1>你好，{props.username}</h1>;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 181 AS problem_id, '  return <h1>你好，{props.name}</h1>;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 181 AS problem_id, '  return <h1>你好，{props.user?.name}</h1>;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 181);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 182, '阿福', '🐶', 'React 狀態', 'After clicking the button, the label stays as OFF instead of switching to ON.', '按了按鈕，文字一直停在「關」，不會變成「開」。', 'function Toggle() {\n  const [on, setOn] = useState(false);\n  return (\n    <button onClick={() => setOn(on)}>\n      {on ? "開" : "關"}\n    </button>\n  );\n}', 4, '【哪裡出錯】第 4 行的 setOn(on) 把目前的值又設回去，值沒有變，畫面就不會更新。\n【用生活例子想】電燈開關現在是關的，你卻對自己說「請維持現在的狀態」，燈當然不會亮。\n【一句話記住】想切換開關，就要把狀態取反，寫成 setOn(!on)。\n【容易選錯】選 setOn(false) 看起來像在設定新值，但它每次都設成關，按幾次都是「關」，還是不會切換。\n【小字典】state：元件記住的資料，改了畫面才會跟著變。setState：用來更新 state 的函式，例如 setOn。!：取反的符號，true 變 false，false 變 true。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 182);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 182 AS problem_id, '    <button onClick={() => setOn(false)}>' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 182 AS problem_id, '    <button onClick={() => setOn(on && !on)}>' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 182 AS problem_id, '    <button onClick={() => setOn(!on)}>' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 182);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 183, '阿福', '🐶', 'React 狀態', 'Clicking the button does nothing and the label always stays on the expand text.', '點按鈕沒有任何反應：按下去之後文字一直停在「展開」，面板打不開。', 'function Panel() {\n  const [open, setOpen] = useState(false);\n  const toggle = () => setOpen(open);\n  return <button onClick={toggle}>{open ? "收起" : "展開"}</button>;\n}', 3, '【哪裡出錯】toggle 把目前的 open 又原封不動丟回 setOpen，值沒有變，所以畫面永遠不會更新。\n【用生活例子想】電燈開關現在是關的，你卻說「請把燈維持現在的狀態」，燈當然不會亮。你要說的是「切到相反的那一邊」。\n【一句話記住】想切換布林值，就把相反的值交給 setter：setOpen(!open)。\n【容易選錯】setOpen(true) 最像正確答案，第一次點擊會變成「收起」，看起來有效。但之後再點還是 true，面板永遠關不起來，所以它不是切換。\n【小字典】state：元件記住的資料，改了畫面就會重畫。setter：像 setOpen 這種用來更新 state 的函式。布林值：只有 true 和 false 兩種值。! 運算子：把 true 變 false、false 變 true。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 183);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 183 AS problem_id, '  const toggle = () => setOpen(!open);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 183 AS problem_id, '  const toggle = () => setOpen(true);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 183 AS problem_id, '  const toggle = () => setOpen(open = !open);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 183);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 184, '阿福', '🐶', 'React 狀態', 'TypeError: Cannot read properties of undefined (reading ''toUpperCase'')', '讀不到東西：name 是 undefined，卻被拿來呼叫 toUpperCase。想一想，父元件到底有沒有把 name 傳進來？', 'function Welcome({ name }) {\n  return <h1>Hello, {name.toUpperCase()}</h1>;\n}\nfunction App() {\n  return <Welcome username="amy" />;\n}', 5, '【哪裡出錯】Welcome 元件想收的 props 叫 name，但 App 傳的卻是 username，所以 Welcome 裡的 name 是 undefined，對它呼叫 toUpperCase 就報錯。\n【用生活例子想】就像寄包裹，收件人欄寫的是「小美」，但寄的時候寫成「小梅」，郵差找不到人，包裹就送不到。\n【一句話記住】傳 props 的名字，要和元件接收的名字一模一樣。\n【容易選錯】改成 Name="amy" 看起來很像對了，但 props 的名字有分大小寫，Name 和 name 是不同的，Welcome 還是收不到 name，一樣是 undefined。\n【小字典】props：父元件傳給子元件的資料。undefined：代表這個東西不存在、沒有值。解構：用 { name } 這種寫法直接從物件裡拿出同名的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 184);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 184 AS problem_id, '  return <Welcome Name="amy" />;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 184 AS problem_id, '  return <Welcome name="amy" />;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 184 AS problem_id, '  return <Welcome name={amy} />;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 184);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 185, '阿福', '🐶', 'React 狀態', 'After typing a letter, the input box shows [object HTMLInputElement] instead of the letter.', '輸入框顯示怪字：你打了一個字，框裡卻出現 [object HTMLInputElement]，不是你打的字。', 'function NameBox() {\n  const [name, setName] = useState("");\n  const handleChange = (e) => {\n    setName(e.target);\n  };\n  return <input value={name} onChange={handleChange} />;\n}', 4, '【哪裡出錯】第 4 行把 e.target 存進 state，e.target 是整個 input 元素，不是使用者打的字，所以框裡會顯示 [object HTMLInputElement]。\n【用生活例子想】就像朋友請你幫忙記電話號碼，你卻把整支手機交給他，他要的只是手機裡的那串數字。\n【一句話記住】想拿輸入框裡的文字，要用 e.target.value，不是 e.target。\n【容易選錯】選 setName(e.value) 看起來很接近，但事件物件 e 本身沒有 value，會得到 undefined，輸入框會變成不受控，打的字也不會被正確存起來。\n【小字典】e.target：觸發事件的那個網頁元素，這裡就是 input。value：輸入框目前裡面的文字。state：元件用來記住資料的地方，改了它畫面才會更新。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 185);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 185 AS problem_id, '    setName(e.value);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 185 AS problem_id, '    setName(e.target.innerText);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 185 AS problem_id, '    setName(e.target.value);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 185);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 186, '阿福', '🐶', 'React 狀態', 'Error: Too many re-renders. React limits the number of renders to prevent an infinite loop.', '重新渲染太多次：元件一畫出來就改了 state，改完又重畫，重畫又改，永遠停不下來', 'import { useState, useEffect } from "react";\n\nexport function Visit() {\n  const [visits, setVisits] = useState(0);\n  setVisits(visits + 1);\n  return <p>你是第 {visits} 位訪客</p>;\n}', 5, '【哪裡出錯】第 5 行直接寫在元件裡，每次畫畫面都會執行一次 setVisits，state 一改又要重畫，重畫又改，變成無限迴圈。\n【用生活例子想】就像你每次打開冰箱都順手在便條紙上加一筆，結果打開冰箱本身就是在加筆，永遠數不完。要等你「進門一次」才記一筆才對。\n【一句話記住】想在畫面出現時做一次事情，要放進 useEffect，不要直接寫在元件本體裡。\n【容易選錯】最像的錯誤選項是 useEffect(setVisits(visits + 1), [])，它長得像有用 useEffect，但 setVisits(visits + 1) 被加了括號，會在 render 時馬上執行，傳給 useEffect 的只是它的回傳值，所以還是無限重畫。\n【小字典】render：React 把元件變成畫面的過程。useEffect：畫面出現後才執行的區塊，第二個參數 [] 代表只跑一次。state：元件記住的資料，改了就會重畫。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 186);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 186 AS problem_id, '  useEffect(() => setVisits((v) => v + 1), []);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 186 AS problem_id, '  setVisits((v) => v + 1);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 186 AS problem_id, '  useEffect(setVisits(visits + 1), []);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 186);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 187, '阿福', '🐶', 'React 狀態', 'After clicking the enlarge button, the text size shows 16[object Object] instead of 18.', '點「放大」後，字的大小變成 16[object Object]，而不是 18。', 'function FontSizer() {\n  const [size, setSize] = useState(16);\n  const changeSize = (delta) => setSize(size + delta);\n  return (\n    <div>\n      <button onClick={() => changeSize(-2)}>縮小</button>\n      <button onClick={changeSize}>放大</button>\n      <p style={{ fontSize: size }}>文字大小 {size}</p>\n    </div>\n  );\n}', 7, '【哪裡出錯】第 7 行的 onClick={changeSize} 只把函式交給 React，點擊時 React 會把事件物件當成第一個參數 delta 傳進去，所以 size + delta 變成 16 加上一個物件。\n【用生活例子想】就像你請店員幫你加糖，卻沒說加幾匙，店員只塞給你一張點餐單，你拿它去算糖的數量，當然算出怪東西。\n【一句話記住】要傳自己的參數給事件處理函式，就包一層箭頭函式：onClick={() => fn(2)}。\n【容易選錯】onClick={() => changeSize} 看起來也有包箭頭函式，但它只是回傳函式本身，並沒有真的呼叫，所以點了之後什麼都不會發生，大小還是 16。\n【小字典】事件物件：React 在事件發生時自動產生、描述這次點擊細節的物件。參數：呼叫函式時傳進去給它用的值。箭頭函式：用 => 寫的簡短函式，常用來包住要延後執行的呼叫。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 187);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 187 AS problem_id, '      <button onClick={() => changeSize}>放大</button>' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 187 AS problem_id, '      <button onClick={() => changeSize(2)}>放大</button>' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 187 AS problem_id, '      <button onClick={changeSize(2)}>放大</button>' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 187);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 188, '阿福', '🐶', 'React 狀態', 'After the checkbox is checked once, clicking it again does not uncheck it and the label keeps showing the agreed text.', '勾選一次之後，再點一次不會取消勾選，旁邊的文字也一直顯示「已同意」。', 'function Agreement() {\n  const [agree, setAgree] = useState(false);\n  return (\n    <label>\n      <input type="checkbox" checked={agree} onChange={(e) => setAgree(e.target.value)} />\n      {agree ? "已同意" : "未同意"}\n    </label>\n  );\n}', 5, '【哪裡出錯】第 5 行用 e.target.value 當勾選狀態，但 checkbox 的 value 是固定字串 "on"，不是有沒有勾。所以 agree 只會變成 "on"，永遠是真的。\n【用生活例子想】就像問你有沒有交作業，你卻回答「作業本的封面寫著數學」，那是作業本上的字，跟你有沒有交一點關係都沒有。\n【一句話記住】checkbox 要讀 e.target.checked，文字輸入框才讀 e.target.value。\n【容易選錯】value === "on" 看起來像在判斷，但 value 永遠是 "on"，結果永遠是 true，勾了之後還是取消不掉，所以還是錯的。\n【小字典】checked：checkbox 目前有沒有被勾起來，值是 true 或 false。value：表單欄位帶的字串，checkbox 預設是 "on"。受控元件：畫面的值由 state 決定的表單欄位。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 188);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 188 AS problem_id, '      <input type="checkbox" checked={agree} onChange={(e) => setAgree(e.target.value === "on")} />' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 188 AS problem_id, '      <input type="checkbox" checked={agree} onChange={(e) => setAgree(!e.target.value)} />' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 188 AS problem_id, '      <input type="checkbox" checked={agree} onChange={(e) => setAgree(e.target.checked)} />' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 188);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 189, '阿福', '🐶', 'React 狀態', 'After typing 2 in the number input, the text shows 21 items instead of 3.', '畫面結果不對：輸入框填 2，下面的「加購後共幾件」卻顯示 21，不是 3。', 'function QuantityPicker() {\n  const [qty, setQty] = useState(1);\n  return (\n    <div>\n      <input type="number" value={qty} onChange={(e) => setQty(e.target.value)} />\n      <p>加購後共 {qty + 1} 件</p>\n    </div>\n  );\n}', 5, '【哪裡出錯】e.target.value 永遠是文字，就算輸入框是 type="number" 也一樣，所以 qty 變成 "2"，"2" + 1 變成 "21"。\n【用生活例子想】就像你在紙條上寫下「2」，那只是一個字，不是兩顆蘋果，你要先把它當成數量來看，才能拿去加。\n【一句話記住】從 input 拿到的值是文字，要計算前先用 Number() 轉成數字。\n【容易選錯】寫成 e.target.value || 0 看起來像有處理空值，但輸入 2 時拿到的還是文字 "2"，加 1 還是 21，沒有真的轉型。\n【小字典】e.target.value：輸入框目前的內容，型別是字串。Number()：把文字轉成數字的函式。型別：資料的種類，例如數字和文字，兩者用加號的結果不一樣。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 189);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 189 AS problem_id, '      <input type="number" value={qty} onChange={(e) => setQty(Number(e.target.value))} />' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 189 AS problem_id, '      <input type="number" value={qty} onChange={(e) => setQty(e.target.value || 0)} />' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 189 AS problem_id, '      <input type="number" value={qty} onChange={(e) => setQty(e.target.value.toString())} />' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 189);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 190, '阿福', '🐶', 'React 狀態', 'After clicking the button, the label becomes blank instead of showing the second pet''s name.', '點下按鈕後，畫面上的名字變成空白，沒有出現第二隻寵物的名字。', 'function PetPicker() {\n  const [selectedId, setSelectedId] = useState(1);\n  const names = { 1: "小黑", 2: "小白" };\n  const pick = (id) => setSelectedId(id);\n  return <button onClick={() => pick("小白")}>{names[selectedId]}</button>;\n}', 5, '【哪裡出錯】selectedId 存的是編號，但按鈕呼叫 pick 時傳進去的是名字「小白」，names["小白"] 找不到東西，所以畫面變空白。\n【用生活例子想】就像餐廳點餐要報號碼，你卻報了菜名，櫃台的號碼表裡查不到，就沒有餐點給你。\n【一句話記住】state 存什麼型別，setState 就要收到什麼型別。\n【容易選錯】pick(names[2]) 看起來有用到 names，但它傳進去的是名字「小白」，selectedId 還是變成文字，names["小白"] 依然是 undefined，畫面還是空白。\n【小字典】state：元件記住的資料。編號：用來查表的 key，這裡是數字 1 或 2。undefined：找不到值時得到的空值，畫面上不會顯示任何東西。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 190);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 190 AS problem_id, '  return <button onClick={() => pick(names[2])}>{names[selectedId]}</button>;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 190 AS problem_id, '  return <button onClick={() => pick(2)}>{names[selectedId]}</button>;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 190 AS problem_id, '  return <button onClick={() => pick()}>{names[selectedId]}</button>;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 190);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 191, '阿福', '🐶', 'React 狀態', 'After clicking the rename button, the pet name on the screen does not change.', '點了改名按鈕，畫面上的名字完全沒變。子元件呼叫父元件傳來的函式時，好像把東西放錯位置了。', 'function Row({ id, onRename }) {\n  return <button onClick={() => onRename("小白", id)}>改名</button>;\n}\nfunction Pets() {\n  const [names, setNames] = useState({ 1: "小黑", 2: "阿花" });\n  const rename = (id, name) => setNames({ ...names, [id]: name });\n  return (<div><Row id={2} onRename={rename} /><p>{names[2]}</p></div>);\n}', 2, '【哪裡出錯】父元件的 rename 先收 id 再收 name，但子元件呼叫時卻先給 "小白" 再給 id，結果 id 變成 "小白"，name 變成數字 2，names[2] 根本沒被改到。\n【用生活例子想】就像填表格，第一格要寫座號、第二格要寫名字，你卻把名字寫在座號那格，老師當然找不到這個人。\n【一句話記住】呼叫函式時，參數的順序要和函式定義的順序一模一樣。\n【容易選錯】只寫 onRename(id) 看起來有帶 id，但 name 沒有傳，會變成 undefined，names[2] 被改成 undefined，畫面變空白，還是不對。\n【小字典】props：父元件傳給子元件的資料或函式。回呼函式：子元件需要通知父元件時會去呼叫的函式。參數：呼叫函式時放在括號裡的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 191);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 191 AS problem_id, '  return <button onClick={() => onRename(id)}>改名</button>;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 191 AS problem_id, '  return <button onClick={() => onRename("小白")}>改名</button>;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 191 AS problem_id, '  return <button onClick={() => onRename(id, "小白")}>改名</button>;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 191);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 192, '阿福', '🐶', 'React 狀態', 'After clicking the submit button, the page reloads and the message count stays at 0.', '畫面重新整理了：按下送出後整個頁面重新載入，留言數量又回到 0，好像什麼都沒發生。', 'function MessageForm() {\n  const [messages, setMessages] = useState([]);\n  const handleSubmit = (e) => {\n    e.preventDefault;\n    setMessages([...messages, "新留言"]);\n  };\n  return <form onSubmit={handleSubmit}><button>送出</button>共 {messages.length} 則</form>;\n}', 4, '【哪裡出錯】第 4 行的 e.preventDefault 後面少了小括號，只是「提到」這個函式，並沒有真的執行，所以瀏覽器還是照預設行為送出表單並重新載入頁面，state 也跟著被清空。\n【用生活例子想】就像你想取消訂單，只是在紙上寫了「取消」兩個字，卻沒有真的打電話給店家，餐點還是會送來。\n【一句話記住】函式名字後面要加 ()，才是真的叫它做事。\n【容易選錯】e.stopPropagation(); 看起來也像在阻止事情，但它只是不讓事件往外層傳，並不會擋掉表單的預設送出，所以頁面還是會重新載入。\n【小字典】preventDefault：叫瀏覽器不要做它原本會做的事，例如表單送出後換頁。預設行為：瀏覽器自己內建的反應。事件物件 e：事件發生時 React 傳給處理函式的資訊包。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 192);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 192 AS problem_id, '    e.preventDefault();' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 192 AS problem_id, '    e.stopPropagation();' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 192 AS problem_id, '    return false;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 192);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 193, '阿福', '🐶', 'React 狀態', 'TypeError: Cannot assign to read only property ''count'' of object ''#<Object>''', '不能改 props：子元件收到的 props 是唯讀的，你卻在點擊時想直接改它，所以報錯、數字也不會變', 'function Parent() {\n  const [count, setCount] = useState(0);\n  return <Child count={count} onAdd={() => setCount(count + 1)} />;\n}\nfunction Child(props) {\n  const add = () => { props.count = props.count + 1; };\n  return <button onClick={add}>{props.count}</button>;\n}', 6, '【哪裡出錯】Child 收到的 props.count 是爸爸 Parent 給的，是唯讀的，不能在子元件裡直接改，所以點擊時才會報錯。\n【用生活例子想】props 像爸爸給你的一張影印的成績單，你不能直接在上面改分數；想改，要請爸爸去改原本的那一份。\n【一句話記住】子元件不能改 props，要改資料就呼叫爸爸傳下來的函式，讓爸爸自己更新 state。\n【容易選錯】最像正確答案的是 props.count += 1，只是換個寫法，本質上還是在改唯讀的 props，一樣會報同樣的錯，畫面也不會變。\n【小字典】props：爸爸傳給子元件的資料，子元件只能讀不能改。state：元件自己記住的資料，要用 setState 才能更新。onAdd：爸爸傳下來的函式，子元件呼叫它就能請爸爸更新 state。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 193);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 193 AS problem_id, '  const add = () => { props.count += 1; };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 193 AS problem_id, '  const add = () => { props.onAdd(); };' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 193 AS problem_id, '  const add = () => { props.setCount(props.count + 1); };' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 193);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 194, '阿福', '🐶', 'React 狀態', 'After clicking the button once, the button text shows only the label and the quantity disappears instead of showing 2.', '點一下按鈕後，數量整個不見了，只剩前面的文字，應該要變成 2 才對。', 'function Cart() {\n  const [qty, setQty] = useState(1);\n  const addOne = () => {\n    setQty((prev) => {\n      prev + 1;\n    });\n  };\n  return <button onClick={addOne}>數量：{qty}</button>;\n}', 5, '【哪裡出錯】setQty 裡的更新函式用了大括號，卻沒有 return，所以函式回傳 undefined，qty 就變成 undefined，畫面上什麼都不顯示。\n【用生活例子想】就像你請同學算好數字寫在紙上交給你，他心裡算出 2，卻沒把紙交出來，你手上就什麼都沒有。\n【一句話記住】更新函式如果用大括號，就一定要寫 return，把新的值交出去。\n【容易選錯】最像的是 prev = prev + 1;，它看起來有把 prev 加 1，但只是改了函式裡的區域變數，函式還是沒有 return，qty 一樣變成 undefined。prev++; 也一樣，而且它還沒有回傳任何東西。\n【小字典】更新函式：傳給 setState 的函式，React 會把目前的值當參數丟進來，並用它的回傳值當新 state。return：把結果交出函式的指令，沒寫就會得到 undefined。undefined：代表沒有值，放進畫面不會顯示任何東西。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 194);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 194 AS problem_id, '      prev = prev + 1;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 194 AS problem_id, '      prev++;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 194 AS problem_id, '      return prev + 1;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 194);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 195, '阿福', '🐶', 'React 狀態', 'After clicking the raise button, the shipping-included price still shows 150 instead of 160.', '畫面沒更新：按下漲價後，父層的價格變了，但子元件顯示的含運費價還是舊的 150。', 'function Price({ amount }) {\n  const [total, setTotal] = useState(amount + 50);\n  return <p>含運費：{total}</p>;\n}\nfunction Shop() {\n  const [amount, setAmount] = useState(100);\n  return <div><Price amount={amount} /><button onClick={() => setAmount(amount + 10)}>漲價</button></div>;\n}', 2, '【哪裡出錯】第 2 行把 props 的 amount 拿去當 useState 的初始值，但初始值只在元件第一次出現時用一次，之後父層的 amount 變了，total 也不會跟著變。\n【用生活例子想】就像你抄了一份今天的菜單貼在牆上，老闆之後改了價錢，你牆上那份還是舊的；想看最新價錢，要直接問老闆，不要看自己抄的那份。\n【一句話記住】能從 props 算出來的值直接在 render 裡算，不要再複製一份放進 state。\n【容易選錯】改成 useState(() => amount + 50) 看起來比較講究，但這只是延後算初始值，還是只算一次，按漲價後仍然顯示 150。\n【小字典】初始值：useState 括號裡的值，只在元件第一次出現時使用。props：父層傳給子元件的資料。衍生值：可以由其他資料算出來的值，不需要另外存成 state。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 195);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 195 AS problem_id, '  const total = amount + 50;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 195 AS problem_id, '  const [total, setTotal] = useState(() => amount + 50);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 195 AS problem_id, '  const [total, setTotal] = useState(Number(amount) + 50);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 195);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 196, '阿福', '🐶', 'React 狀態', 'After clicking the search button, the page reloads and the result text goes back to its initial state instead of showing the search result.', '按下搜尋後畫面一閃，整個頁面重新載入，結果文字又變回「尚未搜尋」，看不到搜尋結果。', 'function SearchBox() {\n  const [keyword, setKeyword] = useState("");\n  const [result, setResult] = useState("尚未搜尋");\n  const handleSubmit = (e) => { setResult("搜尋：" + keyword); };\n  return (\n    <form onSubmit={handleSubmit}>\n      <input value={keyword} onChange={(e) => setKeyword(e.target.value)} />\n      <button type="submit">搜尋</button>\n      <p>{result}</p>\n    </form>\n  );\n}', 4, '【哪裡出錯】handleSubmit 有收到事件 e，卻沒有擋掉 form 送出時瀏覽器預設的動作，所以 setResult 剛執行完，整個頁面就被重新載入，state 全部歸零。\n【用生活例子想】就像你在紙上寫好答案，老師卻在你交卷的瞬間把整張紙換成空白的新卷，你剛寫的內容當然看不到。\n【一句話記住】form 的 onSubmit 裡先呼叫 e.preventDefault()，瀏覽器才不會重新整理頁面。\n【容易選錯】e.preventDefault 後面少了括號最像正確答案，但這樣只是讀到函式卻沒有執行它，等於什麼都沒擋，頁面還是會重新載入。\n【小字典】preventDefault：取消瀏覽器對這個事件原本會做的事。onSubmit：表單送出時觸發的事件。state：React 記住的資料，頁面重新載入就會消失。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 196);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 196 AS problem_id, '  const handleSubmit = (e) => { e.preventDefault; setResult("搜尋：" + keyword); };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 196 AS problem_id, '  const handleSubmit = (e) => { e.preventDefault(); setResult("搜尋：" + keyword); };' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 196 AS problem_id, '  const handleSubmit = (e) => { setResult("搜尋：" + keyword); return false; };' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 196);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 197, '阿福', '🐶', 'React 狀態', 'After clicking the remove button, the pet is removed but the card also shows the viewing message.', '點「送走」按鈕時，卡片上也跑出了「正在查看」的訊息，好像同時點到了整張卡片。', 'function PetCard() {\n  const [name, setName] = useState("小白");\n  const [message, setMessage] = useState("");\n  const remove = () => setName("");\n  return (\n    <div onClick={() => setMessage("正在查看 " + name)}>\n      <h3>{name || "已送走"}</h3>\n      <button onClick={remove}>送走</button>\n      <p>{message}</p>\n    </div>\n  );\n}', 4, '【哪裡出錯】按鈕在外層 div 裡面，點按鈕時事件會一路往上傳（冒泡），所以 div 的 onClick 也被執行了，第 4 行的 remove 沒有擋住它。\n【用生活例子想】你在電梯裡按「關門」鈕，整棟大樓的警報也跟著響，因為訊號一路傳到了管理室。要先把這個訊號攔下來，大樓才不會誤會。\n【一句話記住】內層元素的事件會往外層傳，不想讓外層知道，就在內層呼叫 e.stopPropagation()。\n【容易選錯】選 setMessage("") 看起來像把訊息清掉，但內層先執行，接著外層 div 的 onClick 又把訊息設成「正在查看」，最後還是會顯示出來。preventDefault 只擋瀏覽器預設行為，不會擋冒泡，也一樣沒用。\n【小字典】冒泡：事件從被點的元素一路往父元素傳上去。stopPropagation：叫事件不要再往上傳。preventDefault：取消瀏覽器的預設動作，例如表單送出。事件物件 e：瀏覽器交給處理函式的點擊資訊。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 197);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 197 AS problem_id, '  const remove = (e) => { e.preventDefault(); setName(""); };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 197 AS problem_id, '  const remove = () => { setName(""); setMessage(""); };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 197 AS problem_id, '  const remove = (e) => { e.stopPropagation(); setName(""); };' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 197);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 198, '阿福', '🐶', 'React 狀態', 'When the dog name text inside the button is clicked, the selected line shows nothing instead of dog-1.', '點到按鈕裡面的小黑文字時，「已選擇」那一行變成空白，沒有顯示 dog-1。', 'function PetPicker() {\n  const [selected, setSelected] = useState("none");\n  const pick = (e) => setSelected(e.target.dataset.id);\n  return (\n    <div>\n      <button data-id="dog-1" onClick={pick}><strong>小黑</strong></button>\n      <p>已選擇：{selected}</p>\n    </div>\n  );\n}', 3, '【哪裡出錯】e.target 是真正被點到的那個元素，點到裡面的 strong 時它就是 strong，而 strong 沒有 data-id，所以讀到 undefined，畫面就變空白。\n【用生活例子想】包裹上寫著收件人，你剛好戳到包裹上的貼紙。要看收件人得看整個包裹（currentTarget），不是那張貼紙（target）。\n【一句話記住】事件綁在誰身上，就用 e.currentTarget 讀它的資料，e.target 可能是裡面的子元素。\n【容易選錯】e.target.parentNode 版本點到 strong 時剛好抓得到按鈕，但點到按鈕邊緣的空白處時 e.target 就是按鈕本人，parentNode 變成外層 div，又讀到 undefined。\n【小字典】e.target：實際被點到的元素。e.currentTarget：綁定事件處理函式的那個元素。dataset：用來讀取 data- 開頭屬性的物件。undefined：代表沒有值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 198);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 198 AS problem_id, '  const pick = (e) => setSelected(e.currentTarget.dataset.id);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 198 AS problem_id, '  const pick = (e) => setSelected(e.target.dataset.id || "none");' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 198 AS problem_id, '  const pick = (e) => setSelected(e.target.parentNode.dataset.id);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 198);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 199, '阿福', '🐶', 'React 狀態', 'After clicking the button, the text still shows 30, 5, 100 instead of 5, 30, 100.', '畫面沒有更新：按下排序按鈕後，價格順序還是原本的 30, 5, 100，沒有變成由小到大。', 'function PriceList() {\n  const [prices, setPrices] = useState([30, 5, 100]);\n  const sortAsc = () => {\n    const sorted = prices.sort((a, b) => a - b);\n    setPrices(sorted);\n  };\n  return <button onClick={sortAsc}>{prices.join(", ")}</button>;\n}', 4, '【哪裡出錯】第 4 行的 sort 會直接改動原本的 prices 陣列，還會把同一個陣列傳回來，setPrices 收到的仍是同一個陣列，React 以為沒有變就不重畫畫面。\n【用生活例子想】像你在原本的點名單上直接塗改再交給老師，老師看到還是同一張紙，就覺得沒換新的。要先影印一份再改，老師才知道是新的。\n【一句話記住】更新陣列 state 要給 React 一個新陣列，sort 之前先用 [...prices] 複製一份。\n【容易選錯】[...prices].sort() 看起來也有複製，但沒給比較函式時 sort 會把數字當文字比，結果變成 100, 30, 5，順序還是不對；prices.sort((a, b) => b - a) 沒有複製，還是同一個陣列，畫面一樣不會更新。\n【小字典】state：元件記住的資料。展開運算子 [...a]：複製出一個新陣列。比較函式：告訴 sort 怎麼比兩個值大小的函式。同一個參照：指向記憶體裡同一個東西。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 199);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 199 AS problem_id, '    const sorted = [...prices].sort();' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 199 AS problem_id, '    const sorted = [...prices].sort((a, b) => a - b);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 199 AS problem_id, '    const sorted = prices.sort((a, b) => b - a);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 199);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 200, '阿福', '🐶', 'React 狀態', 'TypeError: picked.join is not a function', '型別不對：點一下按鈕後畫面就壞掉，說 picked 沒有 join 可以用，可是 picked 明明是陣列。', 'function PetPicker() {\n  const [picked, setPicked] = useState([]);\n  const toggle = (id) => {\n    setPicked(\n      picked.includes(id) ? picked.filter((p) => p !== id) : picked.push(id)\n    );\n  };\n  const label = picked.length === 0 ? "尚未選擇" : picked.join("、");\n  return <button onClick={() => toggle("小白")}>{label}</button>;\n}', 5, '【哪裡出錯】第 5 行用 picked.push(id)，push 回傳的是新的長度（數字 1），不是陣列，所以 picked 變成數字，下一次渲染第 8 行的 join 就壞了。\n【用生活例子想】push 就像把名牌放進籃子，然後有人跟你說「籃子裡現在有 1 個」，你拿到的是數量，不是那個籃子。\n【一句話記住】setState 要放新的陣列，用 [...picked, id] 做出新陣列，別用 push 的回傳值。\n【容易選錯】picked.push(id) && picked 看起來有把陣列還回去，但 push 是直接改原陣列，回傳的還是同一個陣列，React 看不出變化就不會更新畫面，點了沒反應。\n【小字典】push：把東西加到陣列最後面，直接改原陣列，回傳新的長度。展開運算子：用 ... 把舊陣列的內容攤開，放進新陣列。state：React 記住的資料，要用 setState 換成新值才會更新畫面。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 200);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 200 AS problem_id, '      picked.includes(id) ? picked.filter((p) => p !== id) : picked.unshift(id)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 200 AS problem_id, '      picked.includes(id) ? picked.filter((p) => p !== id) : picked.push(id) && picked' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 200 AS problem_id, '      picked.includes(id) ? picked.filter((p) => p !== id) : [...picked, id]' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 200);

-- 企企：迴圈邊界
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 201, '企企', '🐧', '迴圈邊界', 'The list should print red, green and blue, but the screen shows 0, 1 and 2.', '印出來的是 0、1、2，不是顏色名稱：迴圈拿到的變數不是你以為的東西。', 'const colors = ["red", "green", "blue"];\nfor (const c in colors) {\n  console.log("顏色：" + c);\n}', 2, '【哪裡出錯】for...in 會把陣列的「索引」一個一個交給變數 c，所以 c 是 0、1、2，不是 red、green、blue。\n【用生活例子想】就像點名時只念座號，沒有念名字。想要聽到名字，就要用會直接給你內容的方法。\n【一句話記住】要拿陣列裡的值用 for...of，for...in 只會給你索引。\n【容易選錯】最像的是 for (const c of colors.keys())，它用了 for...of 但 keys() 給的還是索引 0、1、2，所以畫面還是印出數字。\n【小字典】索引：陣列裡每個位置的編號，從 0 開始。for...of：依序拿出陣列每個元素的迴圈。for...in：依序拿出物件每個屬性名稱的迴圈。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 201);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 201 AS problem_id, 'for (const c in colors.length) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 201 AS problem_id, 'for (const c of colors.keys()) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 201 AS problem_id, 'for (const c of colors) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 201);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 202, '企企', '🐧', '迴圈邊界', 'The program never finishes. It keeps running until it is stopped manually.', '程式一直跑不完：想從 3 倒數到 1，但程式卡住停不下來。', 'let ticks = 0;\nfor (let i = 3; i > 0; i++) {\n  ticks += 1;\n}\nconsole.log("倒數了 " + ticks + " 次");', 2, '【哪裡出錯】條件是 i > 0，但每圈卻做 i++，i 越變越大，永遠都大於 0，迴圈就停不下來。\n【用生活例子想】就像倒數計時卻一直往上數：3、4、5……永遠到不了 0，鬧鐘不會響。\n【一句話記住】條件要往「不成立」的方向走，倒數就用 i--。\n【容易選錯】改成 i >= 0 但還是 i++ 的話，i 還是越變越大，永遠大於等於 0，迴圈一樣停不下來，只是多了一個條件邊界而已。\n【小字典】迴圈條件：每圈開始前檢查，成立才會繼續跑。i++：把 i 加 1。i--：把 i 減 1。無窮迴圈：條件永遠成立，程式停不下來。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 202);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 202 AS problem_id, 'for (let i = 3; i > 0; i--) {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 202 AS problem_id, 'for (let i = 3; i >= 0; i++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 202 AS problem_id, 'for (let i = 3; i < 0; i--) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 202);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 203, '企企', '🐧', '迴圈邊界', 'The sum of 1 to 5 shows 10 instead of 15.', '想算 1 加到 5 的總和，答案應該是 15，畫面卻顯示 10。', 'const n = 5;\nlet total = 0;\nfor (let i = 1; i < n; i++) {\n  total += i;\n}\nconsole.log("1 到 " + n + " 的總和：" + total);', 3, '【哪裡出錯】第 3 行的條件寫成 i < n，所以 i 跑到 4 就停了，5 沒有被加進去，總和變成 1+2+3+4=10。\n【用生活例子想】就像點名 1 號到 5 號，你在 5 號前面就喊停，5 號同學就被漏掉了。\n【一句話記住】想包含最後一個數字，條件要用 <=，不要用 <。\n【容易選錯】把開頭改成 i = 0 但還是用 i < n，i 會跑 0 到 4，加起來還是 10，5 一樣沒被加到，答案不會變。\n【小字典】迴圈條件：每一輪開始前都會檢查的規則，成立才會繼續跑。累加：把每次的數字一直加到同一個變數裡。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 203);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 203 AS problem_id, 'for (let i = 0; i < n; i++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 203 AS problem_id, 'for (let i = 1; i <= n; i++) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 203 AS problem_id, 'for (let i = 1; i < n + 2; i++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 203);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 204, '企企', '🐧', '迴圈邊界', 'The total shows 0012 instead of 6.', '總和變成 0012：本來應該把 1、2、3 加起來得到 6，結果數字像被接在一起的文字。', 'const nums = [1, 2, 3];\nlet sum = 0;\nfor (const n in nums) {\n  sum += n;\n}\nconsole.log(sum);', 3, '【哪裡出錯】第 3 行用了 for...in，它每次給你的是索引（"0"、"1"、"2"），而且是文字，不是陣列裡的數字。\n【用生活例子想】就像排隊時你拿到的是每個人的號碼牌，而不是他手上的錢，把號碼牌湊在一起當然算不出總金額。\n【一句話記住】想直接拿陣列裡的值就用 for...of，for...in 是拿索引（屬性名稱）。\n【容易選錯】for (const n in nums.length) 看起來像在處理長度，但 nums.length 是數字 3，for...in 對數字一圈都不會跑，所以 sum 會停在 0，還是錯的。\n【小字典】for...in：逐一走訪物件的屬性名稱，拿到的是文字。for...of：逐一走訪可迭代物件的每個值。索引：元素在陣列裡的位置編號，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 204);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 204 AS problem_id, 'for (const n in nums.length) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 204 AS problem_id, 'for (const n = 0; n < nums.length; n++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 204 AS problem_id, 'for (const n of nums) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 204);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 205, '企企', '🐧', '迴圈邊界', 'The sum shows 3 instead of 16.', '加總少了：想略過負數再繼續加，結果一遇到負數整個加總就停了，只算出 3。', 'let sum = 0;\nfor (const n of [3, -1, 5, 8]) {\n  if (n < 0) break;\n  sum += n;\n}\nconsole.log(sum);', 3, '【哪裡出錯】第 3 行用了 break，遇到 -1 時整個迴圈直接結束，後面的 5 和 8 都沒有被加到。\n【用生活例子想】像在排隊收作業，遇到一份沒名字的作業，你是把它放一邊繼續收下一份（continue），而不是直接宣布收作業結束（break）。\n【一句話記住】想略過這一個、後面還要做，用 continue；想整個停下來，才用 break。\n【容易選錯】改成 if (n <= 0) break; 看起來只是把條件放寬，但還是 break，遇到 -1 迴圈照樣結束，結果還是 3。\n【小字典】break：立刻跳出整個迴圈。continue：跳過這一圈剩下的程式，直接進下一圈。累加器：用來一路加總的變數，這裡是 sum。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 205);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 205 AS problem_id, '  if (n < 0) continue;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 205 AS problem_id, '  if (n <= 0) break;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 205 AS problem_id, '  if (n > 0) continue;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 205);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 206, '企企', '🐧', '迴圈邊界', 'The queue shows [ ''A'', ''E'' ] instead of [ ''A'', ''D'', ''E'' ].', '只想刪掉 B 和 C，結果 D 也跟著不見了，陣列只剩 A 和 E。', 'const queue = ["A", "B", "C", "D", "E"];\n// 要刪掉 B 和 C\nqueue.splice(1, 3);\nconsole.log(queue);', 3, '【哪裡出錯】splice(1, 3) 的意思是從索引 1 開始，刪掉 3 個元素，所以 B、C、D 都被刪了。\n【用生活例子想】排隊時你說「從第 2 個人開始，請 3 個人離開」，離開的就是 3 個人，不是走到第 3 個人為止。\n【一句話記住】splice(開始位置, 要刪幾個)，第二個數字是數量。\n【容易選錯】選 queue.slice(1, 3) 看起來有 1 和 3，但 slice 只是複製一段，不會改動原陣列，所以印出來還是 A 到 E 五個。\n【小字典】splice：直接刪除或插入陣列元素，會改動原陣列。slice：複製一段陣列，不會改動原陣列。索引：元素在陣列裡的位置，從 0 開始算。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 206);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 206 AS problem_id, 'queue.splice(1, 1);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 206 AS problem_id, 'queue.splice(1, 2);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 206 AS problem_id, 'queue.slice(1, 3);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 206);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 207, '企企', '🐧', '迴圈邊界', 'The positive total shows 3 instead of 12.', '想把陣列裡的正數加起來，結果只加到第一個數字就停了，答案比預期小很多。', 'const numbers = [3, -1, 4, 5];\nlet total = 0;\nfor (const n of numbers) {\n  if (n < 0) break;\n  total += n;\n}\nconsole.log("Total: " + total);', 4, '【哪裡出錯】第 4 行遇到負數 -1 就用 break，整個迴圈直接結束，後面的 4 和 5 都沒有被加到。\n【用生活例子想】你在檢查一排便當有沒有過期，看到一個壞掉的就說「不用檢查了」然後回家，後面好的便當就都沒拿到。你應該只是把壞的放一邊，繼續看下一個。\n【一句話記住】想跳過這一個、繼續做下一個用 continue，想整個停下來才用 break。\n【容易選錯】第二個選項 n <= 0 搭配 break，遇到 -1 還是會直接結束整個迴圈，4 和 5 一樣加不到，結果還是 3。\n【小字典】break：立刻結束整個迴圈。continue：跳過這一圈剩下的程式，直接進入下一圈。累加：把每個數字一個一個加進同一個變數。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 207);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 207 AS problem_id, '  if (n <= 0) break;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 207 AS problem_id, '  if (n > 0) continue;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 207 AS problem_id, '  if (n < 0) continue;' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 207);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 208, '企企', '🐧', '迴圈邊界', 'The highest temperature shows 0 instead of -2.', '四天的氣溫都是零下，最高的應該是 -2，但畫面卻顯示最高溫是 0，好像憑空多出一個數字。', 'const temps = [-5, -2, -8, -3];\nlet highest = 0;\nfor (const t of temps) {\n  if (t > highest) {\n    highest = t;\n  }\n}\nconsole.log("最高溫：" + highest);', 2, '【哪裡出錯】第 2 行把 highest 一開始設成 0，但每天的氣溫都比 0 小，if 永遠不成立，所以 0 一直沒被換掉。\n【用生活例子想】像比賽選最高的人，你先站一個身高 0 公分的假人當第一名，真的選手怎麼比都贏不了他。\n【一句話記住】找最大值時，起始值要用陣列裡真的有的數字，例如第一個元素。\n【容易選錯】最像正確答案的是 let highest = -1;，它看起來有考慮到負數，但所有氣溫（-5、-2、-8、-3）都比 -1 小，if 還是永遠不成立，結果會顯示 -1，還是錯的。\n【小字典】起始值：迴圈開始前先放進變數的第一個數字。元素：陣列裡的一個項目。累加器：在迴圈中一路記錄結果的變數。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 208);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 208 AS problem_id, 'let highest = temps[0];' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 208 AS problem_id, 'let highest = -1;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 208 AS problem_id, 'let highest = Infinity;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 208);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 209, '企企', '🐧', '迴圈邊界', 'The cleaned list still shows [ 4, 7 ] instead of [ 7 ].', '想把偶數全部刪掉，結果清單裡還剩下 4：邊跑邊刪，有些元素被跳過沒檢查到。', 'const nums = [2, 4, 6, 7, 8];\nfor (let i = 0; i < nums.length; i++) {\n  if (nums[i] % 2 === 0) {\n    nums.splice(i, 1);\n  }\n}\nconsole.log(nums);', 2, '【哪裡出錯】從前面往後跑時，刪掉一個元素，後面的元素會往前補位，但 i 還是照樣加 1，所以補上來的那一個就被跳過了。\n【用生活例子想】像排隊點名，你叫完第一個人就請他離開，後面的人全部往前站一步，你再往下叫下一個位置，剛往前站的那個人就沒被叫到。\n【一句話記住】要邊跑邊刪，就從最後面往前跑，這樣前面的位置不會被擠動。\n【容易選錯】把條件改成 i <= nums.length 看起來像是多跑一圈就能補到漏掉的，但還是從前面往後跑，補位的元素照樣被跳過，結果仍然是 [ 4, 7 ]。\n【小字典】splice：從陣列指定位置刪掉元素，會直接改動原本的陣列。索引：元素在陣列中的位置編號，從 0 開始。迴圈：重複做同一件事的程式結構。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 209);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 209 AS problem_id, 'for (let i = 0; i <= nums.length; i++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 209 AS problem_id, 'for (let i = nums.length - 1; i >= 0; i--) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 209 AS problem_id, 'for (let i = 1; i < nums.length; i++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 209);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 210, '企企', '🐧', '迴圈邊界', 'The seat list shows A1,A1,A1,B2,B2,B2 instead of A1,A2,A3,B1,B2,B3.', '座位清單重複了：每一排都一直印同一個座位，不是把整排的座位依序印出來。', 'const seats = [["A1", "A2", "A3"], ["B1", "B2", "B3"]];\nconst labels = [];\nfor (let row = 0; row < seats.length; row++) {\n  for (let col = 0; col < seats[row].length; col++) {\n    labels.push(seats[row][row]);\n  }\n}\nconsole.log(labels.join(","));', 5, '【哪裡出錯】第 5 行取座位時，第二個括號用了外層的 row，不是內層的 col，所以內層迴圈雖然跑了 3 次，每次卻都拿到同一個座位。\n【用生活例子想】就像電影院劃位，先看第幾排，再看那一排的第幾號。如果你兩次都只看排數，就會一直指到同一個位子。\n【一句話記住】二維陣列用 [外層][內層] 取值，內層迴圈的變數一定要用在第二個括號。\n【容易選錯】seats[col][row] 看起來只是把兩個變數對調，但這樣 col 會被拿去選排數。col 跑到 2 的時候，seats[2] 根本不存在，程式會直接報錯，結果還是不對。\n【小字典】巢狀迴圈：迴圈裡面再放一個迴圈。二維陣列：陣列裡面的每一項又是一個陣列，像表格。索引：陣列中位置的編號，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 210);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 210 AS problem_id, '    labels.push(seats[col][row]);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 210 AS problem_id, '    labels.push(seats[col][col]);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 210 AS problem_id, '    labels.push(seats[row][col]);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 210);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 211, '企企', '🐧', '迴圈邊界', 'The differences list ends with NaN: [ 4, 7, 4, NaN ] instead of [ 4, 7, 4 ].', '算相鄰兩次讀數的差，結果最後多出一個 NaN，應該只有三個差值才對。', 'const readings = [10, 14, 21, 25];\nconst diffs = [];\nfor (let i = 0; i < readings.length; i++) {\n  diffs.push(readings[i + 1] - readings[i]);\n}\nconsole.log(diffs);', 3, '【哪裡出錯】迴圈跑到最後一格時，readings[i + 1] 已經超出陣列，變成 undefined，undefined 減 25 就得到 NaN。\n【用生活例子想】比身高差要拿「這個人」和「後面那個人」比，排在最後的人後面沒有人，就沒有人可以比，所以只要比到倒數第二個人就好。\n【一句話記住】只要用到 i + 1，迴圈就要少跑一圈，條件寫成 i < length - 1。\n【容易選錯】改成 let i = 1 看起來像是避開邊界，但它只是把起點往後移，最後一圈 readings[4] 還是 undefined，結果仍然會出現 NaN，而且還少算了第一個差。\n【小字典】NaN：代表「不是一個有效的數字」，例如 undefined 拿來做減法就會得到它。undefined：讀取陣列不存在的位置時得到的值。off-by-one：邊界多算或少算一格的錯誤。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 211);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 211 AS problem_id, 'for (let i = 0; i < readings.length - 1; i++) {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 211 AS problem_id, 'for (let i = 1; i < readings.length; i++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 211 AS problem_id, 'for (let i = 0; i <= readings.length; i++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 211);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 212, '企企', '🐧', '迴圈邊界', 'The flipped table has only 2 rows instead of 3: [ [ 1, 4 ], [ 2, 5 ] ]', '表格翻轉後少了一排：原本 2 列 3 欄的資料，翻完應該有 3 列，結果只有 2 列，最後一欄不見了。', 'const matrix = [[1, 2, 3], [4, 5, 6]];\nconst flipped = [];\nfor (let c = 0; c < matrix.length; c++) {\n  flipped[c] = [];\n  for (let r = 0; r < matrix.length; r++) {\n    flipped[c][r] = matrix[r][c];\n  }\n}\nconsole.log(flipped);', 3, '【哪裡出錯】外層迴圈是在一欄一欄跑，要跑 3 欄，但 matrix.length 是列數 2，所以只跑了 2 次，第 3 欄就被漏掉了。\n【用生活例子想】想像把教室座位表轉 90 度：原本 2 排每排 3 人，轉完要有 3 排。如果你只數有幾排（2），就只會搬走 2 個人的位置，剩下一個沒搬。\n【一句話記住】外層走每一欄，就要用「一列有幾格」matrix[0].length 當界線。\n【容易選錯】改成 c <= matrix[0].length 最像對的，但 <= 會多跑一次，c 變成 3，matrix[r][3] 不存在，結果多出一排 undefined，還是錯。\n【小字典】matrix：用陣列包陣列做成的二維表格。matrix[0].length：第一列有幾格，也就是欄數。undefined：讀到不存在的位置時得到的空值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 212);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 212 AS problem_id, 'for (let c = 0; c <= matrix[0].length; c++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 212 AS problem_id, 'for (let c = 0; c < matrix[0].length; c++) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 212 AS problem_id, 'for (let c = 0; c < matrix[0].length - 1; c++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 212);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 213, '企企', '🐧', '迴圈邊界', 'The finished tasks are not all removed: the list shows [ ''B'', ''C'' ] instead of [ ''C'' ].', '已完成的任務應該全部被刪掉，但 B 還留在清單裡，只刪掉了 A。', 'const tasks = [\n  { name: "A", done: true },\n  { name: "B", done: true },\n  { name: "C", done: false },\n];\nfor (let i = 0; i < tasks.length; i++) {\n  if (tasks[i].done) tasks.splice(i, 1);\n}\nconsole.log(tasks.map(t => t.name));', 6, '【哪裡出錯】從前面往後跑時，刪掉 A 之後 B 會往前補到位置 0，但 i 已經變成 1，所以 B 被跳過沒檢查。\n【用生活例子想】就像排隊點名，你叫完第一個人請他離開，後面的人全部往前站一步，你卻直接叫第二個位置，結果漏掉剛往前站的那個人。\n【一句話記住】要一邊跑一邊刪元素，就從最後面倒著跑，刪掉的位置不會影響還沒檢查的元素。\n【容易選錯】改成 i 從 1 開始，看起來像是避開刪除的影響，但這樣一開始就沒檢查 A，B 被刪掉後 C 往前補，迴圈就結束了，A 還留著，結果變成 A 和 C，還是不對。\n【小字典】splice：從陣列中刪除或插入元素，會直接改變原本的陣列。索引：元素在陣列中的位置編號，從 0 開始。倒著跑：從最後一格往第一格走，i 每次減 1。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 213);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 213 AS problem_id, 'for (let i = 1; i < tasks.length; i++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 213 AS problem_id, 'for (let i = 0; i <= tasks.length; i++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 213 AS problem_id, 'for (let i = tasks.length - 1; i >= 0; i--) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 213);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 214, '企企', '🐧', '迴圈邊界', 'The pages overlap and repeat photos: [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5 ] ] instead of [ [ 1, 2 ], [ 3, 4 ], [ 5 ] ].', '照片要每 2 張分成一頁，結果每一頁都和上一頁重複，還多出好幾頁。', 'const photos = [1, 2, 3, 4, 5];\nconst size = 2;\nconst pages = [];\n\nfor (let i = 0; i < photos.length; i++) {\n  pages.push(photos.slice(i, i + size));\n}\n\nconsole.log(pages);', 5, '【哪裡出錯】第 5 行的 i++ 每次只往前一格，所以每一頁都從上一頁的第二張開始，頁與頁就重疊了。\n【用生活例子想】把 5 張照片分給同學，每人拿 2 張。分完第一個人要從第 3 張開始發，不是從第 2 張再發一次。\n【一句話記住】一次切一組，下一圈就要往前跳一整組的大小，用 i += size。\n【容易選錯】i += size + 1 看起來像有跳過，但一次跳 3 格，第 3 張照片會被漏掉，結果變成 [ [ 1, 2 ], [ 4, 5 ] ]，還是不對。\n【小字典】slice：從陣列切出一段新陣列，結尾位置不包含在內。i += size：讓 i 一次增加 size 這麼多。步長：迴圈每一圈前進的距離。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 214);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 214 AS problem_id, 'for (let i = 0; i < photos.length; i += size) {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 214 AS problem_id, 'for (let i = 0; i < photos.length; i += size + 1) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 214 AS problem_id, 'for (let i = 0; i < photos.length; i += size - 1) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 214);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 215, '企企', '🐧', '迴圈邊界', 'The moving averages show only 2 values instead of 3.', '五天的溫度，每連續三天算一次平均，應該有 3 個平均值，但畫面上只出現 2 個，最後一組沒被算到。', 'const temps = [20, 22, 24, 26, 28];\nconst k = 3;\nconst avgs = [];\nfor (let i = 0; i < temps.length - k; i++) {\n  const chunk = temps.slice(i, i + k);\n  const sum = chunk.reduce((a, b) => a + b, 0);\n  avgs.push(sum / k);\n}\nconsole.log(avgs);', 4, '【哪裡出錯】第 4 行的條件寫 i < temps.length - k，也就是 i < 2，所以 i 只會是 0 和 1，起點在位置 2 的最後一組（24、26、28）就被漏掉了。\n【用生活例子想】像拿一個能框住 3 格的相框在 5 格的照片牆上滑動，最後一個位置是從第 3 格開始框到第 5 格，如果相框停在它前一格就不動了，最後一組照片就沒被看到。\n【一句話記住】最後一個起點是 length - k，要用 <= 才會跑到它。\n【容易選錯】i <= temps.length 看起來有包含最後一組，但 i 會一路跑到 5，後面幾次視窗已經超出陣列，只拿到不足 3 個的資料，還是照樣除以 3，多出 18、9.33、0 這些錯的平均值。\n【小字典】視窗：每次從陣列取出的一小段連續元素。起點：視窗開始的位置，這裡就是 i。平均：總和除以個數。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 215);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 215 AS problem_id, 'for (let i = 0; i <= temps.length; i++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 215 AS problem_id, 'for (let i = 0; i <= temps.length - k; i++) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 215 AS problem_id, 'for (let i = 0; i < temps.length - 1; i++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 215);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 216, '企企', '🐧', '迴圈邊界', 'The search for 23 shows index -1 instead of 5.', '23 明明就在清單最後面，搜尋卻說找不到，回傳 -1。程式沒有報錯，只是結果不對。', 'function binarySearch(list, target) {\n  let lo = 0;\n  let hi = list.length - 1;\n  while (lo < hi) {\n    const mid = Math.floor((lo + hi) / 2);\n    if (list[mid] === target) return mid;\n    if (list[mid] < target) lo = mid + 1;\n    else hi = mid - 1;\n  }\n  return -1;\n}\nconsole.log("index:", binarySearch([2, 5, 8, 12, 16, 23], 23));', 4, '【哪裡出錯】第 4 行的 while (lo < hi) 在 lo 和 hi 剛好指到同一格時就停了，最後一格沒有被檢查，所以回傳 -1。\n【用生活例子想】像在一排信箱裡找信，你把範圍縮到只剩一個信箱，卻說「只剩一個不用看了」，信其實就在那一格。\n【一句話記住】範圍縮到只剩一格時，還是要打開看一眼，所以用 <= 而不是 <。\n【容易選錯】while (lo != hi) 看起來像是「還沒碰頭就繼續找」，但 lo 和 hi 指到同一格時 != 也是 false，迴圈一樣馬上停，最後一格還是沒檢查，結果仍然是 -1。\n【小字典】二分搜尋：每次看中間那一格，把要找的範圍砍掉一半。lo 和 hi：目前還沒排除的範圍的左端和右端。mid：lo 和 hi 中間那一格的位置。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 216);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 216 AS problem_id, '  while (lo != hi) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 216 AS problem_id, '  while (lo < hi - 1) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 216 AS problem_id, '  while (lo <= hi) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 216);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 217, '企企', '🐧', '迴圈邊界', 'The last item 7 never appears on any page, and the total shows 2 pages instead of 3.', '最後一個商品沒有出現在任何一頁，總頁數只有 2 頁，但明明應該有 3 頁。', 'const items = [1, 2, 3, 4, 5, 6, 7];\nconst size = 3;\nconst pages = Math.floor(items.length / size);\nfor (let p = 0; p < pages; p++) {\n  const start = p * size;\n  const chunk = items.slice(start, start + size);\n  console.log("Page " + (p + 1) + ": " + chunk.join(","));\n}\nconsole.log("Total pages: " + pages);', 3, '【哪裡出錯】7 個商品每頁放 3 個，7 除以 3 約等於 2.33，Math.floor 會把小數捨去變成 2，所以迴圈只跑 2 圈，第 7 個商品沒有頁可以放。\n【用生活例子想】7 顆蛋要用每盒 3 顆的盒子裝，裝滿 2 盒還剩 1 顆，你還是需要第 3 個盒子，不能把剩下的蛋丟掉。\n【一句話記住】算總頁數時，有餘數就要多一頁，所以用 Math.ceil 無條件進位。\n【容易選錯】Math.round 看起來是在四捨五入很合理，但 2.33 四捨五入還是 2，還是只有 2 頁，第 7 個商品照樣被漏掉。\n【小字典】Math.floor：無條件捨去小數。Math.ceil：無條件進位到整數。Math.round：四捨五入。slice：取出陣列一段，結尾那格不包含。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 217);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 217 AS problem_id, 'const pages = Math.ceil(items.length / size);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 217 AS problem_id, 'const pages = Math.round(items.length / size);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 217 AS problem_id, 'const pages = Math.trunc(items.length / size);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 217);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 218, '企企', '🐧', '迴圈邊界', 'The schedule lists Amy vs Amy and has 6 matches instead of 3.', '賽程表裡出現了自己對自己的比賽，場數是 6 場，但 3 個人兩兩對戰應該只有 3 場。', 'const players = ["Amy", "Ben", "Cat"];\nconst matches = [];\nfor (let i = 0; i < players.length; i++) {\n  for (let j = i; j < players.length; j++) {\n    matches.push(players[i] + " vs " + players[j]);\n  }\n}\nconsole.log(matches);', 4, '【哪裡出錯】內層迴圈的 j 從 i 開始，所以 i 和 j 相同時，Amy 會配到 Amy，多出自己對自己的比賽。\n【用生活例子想】班上 3 個人要兩兩握手，你不會自己跟自己握手，所以要從「自己後面的人」開始找對象。\n【一句話記住】兩兩配對時，內層迴圈從 i + 1 開始，就不會配到自己，也不會重複配對。\n【容易選錯】改成 j = 0 看起來像是「每個人都配一次」，但會變成 9 場，自己配自己還在，Amy vs Ben 和 Ben vs Amy 也會重複出現。\n【小字典】巢狀迴圈：迴圈裡面再放一個迴圈。內層迴圈：被包在外層迴圈裡面的那個迴圈。配對：從一群東西裡每次挑出兩個組合在一起。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 218);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 218 AS problem_id, '  for (let j = 0; j < players.length; j++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 218 AS problem_id, '  for (let j = i + 1; j < players.length; j++) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 218 AS problem_id, '  for (let j = i + 2; j < players.length; j++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 218);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 219, '企企', '🐧', '迴圈邊界', 'The averages list has only 2 numbers: [ 6, 9 ] instead of [ 6, 9, 12 ].', '少了最後一組：每 3 筆算一次平均，5 筆資料應該有 3 個平均值，結果只出現 2 個。', 'const readings = [3, 6, 9, 12, 15];\nconst size = 3;\nconst averages = [];\nfor (let i = 0; i < readings.length - size; i++) {\n  const windowItems = readings.slice(i, i + size);\n  const sum = windowItems.reduce((a, b) => a + b, 0);\n  averages.push(sum / size);\n}\nconsole.log(averages);', 4, '【哪裡出錯】第 4 行的迴圈條件是 i < readings.length - size，也就是 i < 2，所以 i 只會是 0 和 1。最後一個視窗從 i = 2 開始，卻被漏掉了。\n【用生活例子想】5 個人排一排，每次選連續 3 個人拍照，起點可以是第 0、1、2 個人，共 3 張。如果只讓起點到第 1 個人，最後一張照片就沒拍。\n【一句話記住】最後一個視窗的起點是 length - size，要用 <= 才會包含它。\n【容易選錯】i <= readings.length - size - 1 看起來像有補上 <=，但再減 1 之後等於又回到 i < length - size，還是只跑 i = 0 和 1，結果仍是 [ 6, 9 ]。\n【小字典】視窗：每次取連續幾個元素來一起算。slice(start, end)：取出從 start 到 end 之前的元素，不含 end。reduce：把陣列的值一個一個累加成一個結果。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 219);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 219 AS problem_id, 'for (let i = 0; i <= readings.length - size - 1; i++) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 219 AS problem_id, 'for (let i = 0; i <= readings.length - 1; i++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 219 AS problem_id, 'for (let i = 0; i <= readings.length - size; i++) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 219);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 220, '企企', '🐧', '迴圈邊界', 'The seats list looks unchanged after reversing: [ 1, 2, 3, 4, 5 ] instead of [ 5, 4, 3, 2, 1 ].', '座位陣列明明做了前後交換，印出來卻跟原本一模一樣，完全沒有反轉。', 'const seats = [1, 2, 3, 4, 5];\nconst last = seats.length - 1;\nfor (let i = 0; i < seats.length; i++) {\n  const j = last - i;\n  const temp = seats[i];\n  seats[i] = seats[j];\n  seats[j] = temp;\n}\nconsole.log(seats);', 3, '【哪裡出錯】第 3 行讓 i 跑完整個陣列，每一對位置會被交換兩次，所以第二次又把它換回原樣。\n【用生活例子想】兩個同學互換座位，換完一次就好，如果老師再喊一次換座位，他們又坐回原位，等於沒換。\n【一句話記住】前後對調只要走到中間，迴圈跑一半就好，不然會換回去。\n【容易選錯】改成 i < seats.length - 1 看起來只少跑一圈，但 i 跑到 3 時會把第 3 格和第 1 格再換一次，結果變成 [ 5, 2, 3, 4, 1 ]，還是錯的。\n【小字典】原地反轉：不建立新陣列，直接在原本的陣列裡交換位置。交換：把兩個位置的值對調。索引：陣列中每個元素的位置編號，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 220);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 220 AS problem_id, 'for (let i = 0; i < seats.length / 2; i++) {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 220 AS problem_id, 'for (let i = 0; i < seats.length - 1; i++) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 220 AS problem_id, 'for (let i = 0; i <= last; i++) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 220);

-- 狐狐：型別轉換
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 221, '狐狐', '🦊', '型別轉換', 'The page says the target was missed even though the average and the target both show 3.3.', '平均值明明顯示 3.3，目標也是 3.3，程式卻說沒有達標。提示：看看 toFixed 回傳的東西是什麼型別。', 'const average = (10 / 3).toFixed(1); // ''3.3''\nconst target = 3.3;\nconst reached = average === target;\nconsole.log(reached ? ''Target reached'' : ''Target missed'');', 3, '【哪裡出錯】toFixed(1) 算完回傳的是文字 ''3.3''，不是數字 3.3，而 === 會連種類一起比，文字和數字永遠不相等。\n【用生活例子想】就像手寫在紙條上的「3.3」和體重計上真正量出來的 3.3 公斤，看起來一樣，但一個是字、一個是重量，不能直接當成同一個東西。\n【一句話記住】toFixed 會把數字變成文字，要拿來比大小或比相等，先用 Number 轉回數字。\n【容易選錯】parseInt(average) 看起來也是把文字轉成數字，但它只取整數部分，''3.3'' 會變成 3，3 === 3.3 還是 false，所以仍然顯示沒達標。\n【小字典】toFixed：把數字四捨五入到指定小數位數，結果是字串。===：嚴格相等，值和型別都要一樣才算相等。Number()：把文字轉成數字的函式。parseInt：把文字轉成整數，小數部分會被丟掉。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 221);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 221 AS problem_id, 'const reached = Number(average) === target;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 221 AS problem_id, 'const reached = parseInt(average) === target;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 221 AS problem_id, 'const reached = String(average) === target;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 221);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 222, '狐狐', '🦊', '型別轉換', 'The list shows "Items: apple,milk,egg" instead of "Items: apple / milk / egg".', '畫面上的清單用逗號擠在一起，沒有照我們想要的「 / 」分隔。陣列直接和字串相加，結果不是你想的那樣。', 'const items = [''apple'', ''milk'', ''egg''];\nconst label = ''Items: '' + items;\nconsole.log(label);', 2, '【哪裡出錯】第 2 行把陣列直接加在字串後面，JavaScript 會偷偷把陣列轉成字串，而且固定用逗號連接，所以你想要的分隔符號完全沒機會出現。\n【用生活例子想】就像你把一串購物清單直接丟給店員，他自己決定用逗號唸出來，你想要的「 / 」他根本不知道。\n【一句話記住】要自己決定陣列怎麼串起來，就用 join 告訴它分隔符號。\n【容易選錯】最像的是 items.toString()，但陣列的 toString 結果固定用逗號連接，換上去還是印出 apple,milk,egg，分隔符號依然不是「 / 」。\n【小字典】隱性轉換：JavaScript 在你沒要求時自動幫你換資料型別。join：把陣列每一項用你指定的符號接成一個字串。toString：把東西轉成字串，陣列的結果固定用逗號分隔。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 222);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 222 AS problem_id, 'const label = ''Items: '' + items.toString();' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 222 AS problem_id, 'const label = ''Items: '' + items.join('' / '');' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 222 AS problem_id, 'const label = ''Items: '' + String(items);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 222);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 223, '狐狐', '🦊', '型別轉換', 'Dark mode shows as on even though the saved setting is false.', '畫面顯示深色模式是開的，但設定檔存的明明是 false：字串 ''false'' 被當成「有東西」，結果變成 true。', 'const setting = ''false''; // 從設定檔讀到的字串\nconst isDarkMode = Boolean(setting);\nconsole.log(isDarkMode ? ''Dark mode: on'' : ''Dark mode: off'');', 2, '【哪裡出錯】Boolean(setting) 只看字串是不是空的，''false'' 有五個字，所以被當成 true，深色模式就被打開了。\n【用生活例子想】就像你問店員「這個袋子是空的嗎？」，袋子裡放了一張寫著「沒有」的紙，袋子還是不空，不會因為紙上寫沒有就變空。\n【一句話記住】字串 ''false'' 不等於布林值 false，要自己比對文字是不是 ''true''。\n【容易選錯】最像的是 const isDarkMode = !!setting;，它其實跟 Boolean(setting) 做一樣的事，''false'' 還是非空字串，換上去結果仍然是 true，深色模式還是會被打開。\n【小字典】Boolean：把值轉成 true 或 false 的函式。truthy：轉成布林後會變 true 的值，例如非空字串。字串：用引號包起來的文字，內容是什麼都只是文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 223);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 223 AS problem_id, 'const isDarkMode = !!setting;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 223 AS problem_id, 'const isDarkMode = Boolean(setting.length);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 223 AS problem_id, 'const isDarkMode = setting === ''true'';' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 223);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 224, '狐狐', '🦊', '型別轉換', 'Entering 0 as the quantity shows the empty-field warning instead of accepting 0.', '使用者輸入 0 是有填的，畫面卻跳出「請輸入數量」的提醒，好像他什麼都沒填一樣。', 'const quantity = 0; // 使用者在數量欄輸入的 0\nif (quantity == '''') {\n  console.log(''Please enter a quantity'');\n} else {\n  console.log(`Quantity: ${quantity}`);\n}', 2, '【哪裡出錯】第 2 行用 == 比較，JavaScript 會先把空字串 '''' 轉成數字 0，所以 0 == '''' 變成 true，輸入 0 被當成沒填。\n【用生活例子想】就像櫃台人員覺得「寫 0 元」跟「空白沒寫」是同一件事，結果你明明寫了數字，卻被退件說你沒填。\n【一句話記住】要分辨「空字串」和「0」，就用 === 不要用 ==，這樣不會偷偷轉型。\n【容易選錯】改成 if (!quantity) 看起來更簡潔，但 0 是 falsy，!0 還是 true，照樣被當成沒填。改成 == '' '' 也不行，因為 '' '' 轉成數字也是 0，0 == '' '' 一樣是 true。\n【小字典】==：寬鬆相等，比較前會自動轉型。===：嚴格相等，型別不同就直接是 false。falsy：放進 if 會當成 false 的值，例如 0、''''、null。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 224);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 224 AS problem_id, 'if (quantity === '''') {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 224 AS problem_id, 'if (!quantity) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 224 AS problem_id, 'if (quantity == '' '') {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 224);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 225, '狐狐', '🦊', '型別轉換', 'The total shows 20.005 instead of 25.', '畫面上的總額變成 20.005，應該是 25。四捨五入之後再加 5，結果卻像把字接在一起。', 'const price = 19.999;\nconst rounded = price.toFixed(2);\nconst total = rounded + 5;\nconsole.log(total);', 3, '【哪裡出錯】toFixed(2) 回傳的是字串 "20.00"，不是數字，所以 rounded + 5 變成字串相接，得到 "20.005"。\n【用生活例子想】就像把「20.00」寫在紙條上，再貼上一張寫著「5」的紙條，兩張紙條只是排在一起，並沒有真的加起來。\n【一句話記住】toFixed 吐出來的是字串，要拿去算數就先用 Number 轉回數字。\n【容易選錯】Number(rounded + 5) 看起來有轉成數字，但順序錯了：它先把 "20.00" 和 5 接成 "20.005"，才轉成數字 20.005，答案還是錯的。\n【小字典】toFixed：把數字四捨五入到指定小數位數，並回傳字串。字串相接：+ 遇到字串時，會把兩邊接成一段文字。Number()：把字串轉成數字的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 225);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 225 AS problem_id, 'const total = Number(rounded + 5);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 225 AS problem_id, 'const total = Number(rounded) + 5;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 225 AS problem_id, 'const total = rounded + Number(5);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 225);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 226, '狐狐', '🦊', '型別轉換', 'The cart is empty, but the page says it has items and goes to checkout.', '購物車明明是空的，畫面卻說有商品並前往結帳：if 判斷把空陣列當成「有東西」。', 'const cart = []; // 使用者還沒加任何商品\nif (cart) {\n  console.log(''購物車有商品，前往結帳'');\n} else {\n  console.log(''購物車是空的'');\n}', 2, '【哪裡出錯】if (cart) 只檢查 cart 存不存在，空陣列 [] 也是一個存在的物件，所以在 if 裡算 truthy，永遠走進「有商品」那一邊。\n【用生活例子想】空的購物籃也是一個籃子，你不能因為手上有籃子，就說裡面有東西。要打開來看有幾樣商品才準。\n【一句話記住】要判斷陣列有沒有東西，請檢查 length，不要直接把陣列丟進 if。\n【容易選錯】if (Boolean(cart)) 看起來像是更明確的轉換，但 Boolean([]) 還是 true，結果跟原本一樣，還是會印出有商品。\n【小字典】truthy：放進 if 會被當成 true 的值，例如 []、{}、''0''。length：陣列裡有幾個項目。Boolean()：把值轉成 true 或 false 的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 226);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 226 AS problem_id, 'if (cart != null) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 226 AS problem_id, 'if (Boolean(cart)) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 226 AS problem_id, 'if (cart.length > 0) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 226);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 227, '狐狐', '🦊', '型別轉換', 'The total shows NaN instead of 60.', '三個分數明明都是數字字串，加起來卻變成 NaN。問題出在把字串轉成數字的那一行。', 'const rawScores = [''10'', ''20'', ''30'']; // 從表單拿到的字串\nconst scores = rawScores.map(parseInt);\nlet total = 0;\nfor (const n of scores) {\n  total += n;\n}\nconsole.log(`Total: ${total}`);', 2, '【哪裡出錯】map 會把「值、索引、整個陣列」三個東西丟給函式，parseInt 就把索引當成第二個參數（進位制），''20'' 被用 1 進位解讀，結果變成 NaN。\n【用生活例子想】就像店員只要你給他一張鈔票，你卻連座位號碼也塞給他，他還以為那是匯率，算出來的錢就全亂了。\n【一句話記住】要用 parseInt 轉換就自己包一層，寫成 (s) => parseInt(s, 10)，不要直接把 parseInt 丟給 map。\n【容易選錯】rawScores.map(parseInt, 10) 看起來像是把進位制 10 傳進去，但 map 的第二個參數是 this 的指向，不是給 parseInt 的。parseInt 還是會收到索引當進位制，結果照樣是 NaN。\n【小字典】進位制：數字用幾進位來讀，例如 10 代表十進位。NaN：Not a Number，代表算不出數字。map：把陣列每個元素轉換後組成新陣列。索引：元素在陣列裡的位置編號，從 0 開始。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 227);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 227 AS problem_id, 'const scores = rawScores.map((s) => parseInt(s, 10));' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 227 AS problem_id, 'const scores = rawScores.map(parseInt, 10);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 227 AS problem_id, 'const scores = rawScores.map(Number.parseInt);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 227);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 228, '狐狐', '🦊', '型別轉換', 'The page says the bill is not due yet even though today is after the deadline.', '今天 10 月 1 日明明已經超過 9 月 15 日的截止日，畫面卻說還沒到期。', 'const deadline = ''2024-9-15''; // 繳費截止日\nconst today = ''2024-10-01''; // 今天\nif (today > deadline) {\n  console.log(''已逾期，請盡快繳費'');\n} else {\n  console.log(''還沒到期'');\n}', 3, '【哪裡出錯】today 和 deadline 都是字串，用 > 比較時會從第一個字元開始一個一個比，比到月份時是 ''1'' 對 ''9''，''1'' 比較小，所以程式以為 10 月比 9 月早。\n【用生活例子想】就像查字典排名字，只看第一個字，''1'' 開頭的會排在 ''9'' 開頭的前面，不管後面還有沒有 0。\n【一句話記住】要比日期先用 new Date 變成日期物件，不要直接比字串。\n【容易選錯】parseInt(today) 只會讀到第一個減號前面的 2024，兩邊都變成 2024，2024 > 2024 是 false，所以畫面還是顯示還沒到期。\n【小字典】字串比較：照字元順序一個一個比，不是比大小。Date：JavaScript 內建的日期物件，可以比較先後。NaN：不是數字的結果，拿它比大小永遠是 false。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 228);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 228 AS problem_id, 'if (Number(today) > Number(deadline)) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 228 AS problem_id, 'if (new Date(today) > new Date(deadline)) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 228 AS problem_id, 'if (parseInt(today) > parseInt(deadline)) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 228);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 229, '狐狐', '🦊', '型別轉換', 'The empty cart says it has 0 items instead of saying the cart is empty.', '購物車明明是空的，畫面卻顯示「有 0 件商品」，沒有走到「購物車是空的」那個分支。', 'const cart = [];\n\nfunction renderCart(items) {\n  if (items) {\n    return `購物車有 ${items.length} 件商品`;\n  }\n  return ''購物車是空的'';\n}\n\nconsole.log(renderCart(cart));', 4, '【哪裡出錯】第 4 行的 if (items) 只是問「這個東西存不存在」，空陣列 [] 也是一個存在的物件，所以會被當成 true，永遠走進「有商品」那一邊。\n【用生活例子想】空的購物籃還是一個籃子，你問「有籃子嗎」答案是有，但你真正想問的是「籃子裡有東西嗎」。\n【一句話記住】要判斷陣列有沒有資料，請檢查 length，不要直接拿陣列當條件。\n【容易選錯】最像的是 Boolean(items)，它只是把寫法換成明確轉成布林值，但空陣列轉出來還是 true，所以照樣顯示「有 0 件商品」。\n【小字典】truthy：放進 if 裡會被當成 true 的值，例如 []、{} 和 ''0''。length：陣列裡有幾個元素。物件：陣列也是物件的一種，所以只要存在就算 truthy。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 229);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 229 AS problem_id, '  if (items !== undefined) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 229 AS problem_id, '  if (Boolean(items)) {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 229 AS problem_id, '  if (items.length > 0) {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 229);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 230, '狐狐', '🦊', '型別轉換', 'The box width shows NaNpx instead of 150px.', '寬度變成 NaNpx：程式想把 CSS 的 ''120px'' 轉成數字再加 30，但轉出來不是數字。', 'const box = { style: { width: ''120px'' } };\nfunction widen(el, extra) {\n  const current = Number(el.style.width);\n  el.style.width = (current + extra) + ''px'';\n}\nwiden(box, 30);\nconsole.log(box.style.width);', 3, '【哪裡出錯】第 3 行用 Number(''120px'')，字串裡夾著 px，Number 看不懂整串，就回傳 NaN，後面再加 30 還是 NaN。\n【用生活例子想】像收銀機只收純數字，你把「120元」整張紙條塞進去，它會說讀不懂；parseInt 則像先把前面的 120 剪下來再輸入。\n【一句話記住】Number 要整串都是數字才行，parseInt 會讀到第一個不是數字的字就停。\n【容易選錯】用 +el.style.width 看起來像換個寫法轉數字，但它和 Number 的規則一樣，遇到 px 還是 NaN；用 parseInt(..., 2) 會把字串當二進位讀，只讀到 1，結果變成 31px，一樣不對。\n【小字典】NaN：代表不是一個有效的數字。parseInt：從字串開頭讀出整數，遇到不能讀的字就停下。進位制：parseInt 第二個參數，10 代表一般的十進位。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 230);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 230 AS problem_id, '  const current = parseInt(el.style.width, 10);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 230 AS problem_id, '  const current = +el.style.width;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 230 AS problem_id, '  const current = parseInt(el.style.width, 2);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 230);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 231, '狐狐', '🦊', '型別轉換', 'The page hides the red dot even though there are 3 unread messages.', '紅點沒有出現：明明有 3 則未讀訊息，畫面卻選擇隱藏紅點。', 'function getBadgeAction(count) {\n  if (count == true) {\n    return ''顯示紅點'';\n  }\n  return ''隱藏紅點'';\n}\nconst unreadCount = 3;\nconsole.log(getBadgeAction(unreadCount));', 2, '【哪裡出錯】count == true 時，JavaScript 會先把 true 變成數字 1，再拿 3 去比 1，結果是 false，所以走到隱藏紅點。\n【用生活例子想】就像老師問「有沒有帶作業」，你帶了 3 本，卻被要求一定要剛好 1 本才算有帶，多帶反而被當成沒帶。\n【一句話記住】不要拿數字去 == true，要比數量就直接寫 count > 0。\n【容易選錯】count === true 看起來更嚴格，但 3 是數字、true 是布林，型別不同，一定是 false，還是會隱藏紅點。\n【小字典】==：寬鬆相等，比較前會偷偷轉型。===：嚴格相等，型別不同就直接是 false。隱性轉型：JavaScript 自己幫你把值換成別的型別。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 231);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 231 AS problem_id, '  if (count === true) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 231 AS problem_id, '  if (count > 0) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 231 AS problem_id, '  if (count == ''true'') {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 231);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 232, '狐狐', '🦊', '型別轉換', 'The page says course 2 is not open even though it is in the open list.', '下拉選單選了課程 2，清單裡明明有 2，畫面卻說這門課沒開放。', 'function canEnroll(courseId) {\n  const openCourses = [1, 2, 3];\n  return openCourses.includes(courseId);\n}\nconst selected = ''2''; // 從下拉選單拿到的值\nconsole.log(canEnroll(selected) ? ''可以報名'' : ''此課程未開放'');', 3, '【哪裡出錯】selected 是從下拉選單拿到的字串 ''2''，但 openCourses 裡放的是數字 2，includes 比對時不會幫你轉型，所以找不到。\n【用生活例子想】就像名單上寫的是「數字 2 號」，你手上拿的卻是寫著「2」的文字卡片，保全會說這張卡不在名單上。\n【一句話記住】用 includes 找東西之前，先確定兩邊的型別一樣。\n【容易選錯】改成 indexOf(courseId) !== -1 看起來像換個方法找，但 indexOf 也是嚴格比較，字串 ''2'' 還是找不到，結果一樣是未開放。\n【小字典】includes：檢查陣列裡有沒有某個值，比對時型別也要一樣。Number：把字串轉成數字的函式。嚴格比較：不只比內容，連型別都要相同才算相等。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 232);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 232 AS problem_id, '  return openCourses.indexOf(courseId) !== -1;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 232 AS problem_id, '  return openCourses.includes(String(courseId));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 232 AS problem_id, '  return openCourses.includes(Number(courseId));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 232);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 233, '狐狐', '🦊', '型別轉換', 'The log shows [object Object] instead of the order id and total.', '畫面上看不到訂單內容：log 印出來的是 [object Object]，而不是 id 和金額。', 'const order = { id: 7, total: 120 };\nfunction describe(o) {\n  const detail = { id: o.id, total: o.total };\n  return ''訂單資料：'' + detail;\n}\nconsole.log(describe(order));', 4, '【哪裡出錯】字串加上物件時，JavaScript 會偷偷把物件轉成文字，結果變成固定的 [object Object]，裡面的 id 和 total 都看不到。\n【用生活例子想】就像你把一整個便當盒當成標籤貼在外面，別人只看到「便當盒」三個字，看不到裡面有什麼菜。\n【一句話記住】想把物件變成看得懂的文字，要用 JSON.stringify，不要直接用 + 相接。\n【容易選錯】改成 String(detail) 看起來像是明確轉型，但物件轉字串的預設結果還是 [object Object]，所以畫面一樣沒變。\n【小字典】隱性轉型：JavaScript 自動幫你把型別換掉。JSON.stringify：把物件轉成 JSON 格式的文字。[object Object]：物件預設轉成文字的樣子。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 233);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 233 AS problem_id, '  return ''訂單資料：'' + JSON.stringify(detail);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 233 AS problem_id, '  return ''訂單資料：'' + String(detail);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 233 AS problem_id, '  return `訂單資料：${detail}`;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 233);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 234, '狐狐', '🦊', '型別轉換', 'The report counts 5 valid scores instead of 3, and the average shows 77 instead of 80.', '成績檢查寫了 0 到 100 的範圍，但 150 和 -5 也被當成有效分數，有效人數和平均都不對。', 'const scores = [80, 150, 70, -5, 90];\n\nfunction isValidScore(score) {\n  return 0 <= score <= 100;\n}\n\nconst valid = scores.filter(isValidScore);\nconst average = valid.reduce((sum, s) => sum + s, 0) / valid.length;\nconsole.log(`Valid: ${valid.length}, average: ${average}`);', 4, '【哪裡出錯】JavaScript 不會把 0 <= score <= 100 當成「介於 0 到 100」，而是先算 0 <= score 得到 true 或 false，再拿這個結果去比 100，true 會被當成 1，所以 150 和 -5 都過關。\n【用生活例子想】就像先問「你成年了嗎？」得到「是」，再拿這個「是」去跟身高 100 公分比大小，答案當然亂掉。\n【一句話記住】範圍判斷要拆成兩個條件，中間用 && 接起來。\n【容易選錯】最像正確答案的是把 && 換成 ||：只要分數大於等於 0 或小於等於 100 就過關，每個數字至少會符合其中一個，所以 150 和 -5 還是被當成有效，結果仍然是 5 個。\n【小字典】隱性轉換：JavaScript 自動把一種型別當成另一種來用。布林值：只有 true 和 false 兩種值，比較大小時 true 會變 1、false 會變 0。filter：只留下函式回傳 true 的項目。&&：兩邊都成立，整個條件才成立。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 234);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 234 AS problem_id, '  return score >= 0 || score <= 100;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 234 AS problem_id, '  return score >= 0 && score <= 100;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 234 AS problem_id, '  return 0 < score < 101;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 234);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 235, '狐狐', '🦊', '型別轉換', 'The page says item 102 is available even though its stock is 0.', '商品 102 庫存明明是 0，頁面卻說還有貨。問題的原因和顯示結果不在同一行，要往前找。', 'const stockByItem = { 101: 5, 102: 0, 103: 12 };\nconst soldOut = [];\nfor (const id in stockByItem) {\n  if (stockByItem[id] === 0) {\n    soldOut.push(id);\n  }\n}\nconst hasSoldOut = soldOut.includes(102);\nconsole.log(hasSoldOut ? ''Item 102 is sold out'' : ''Item 102 is available'');', 5, '【哪裡出錯】for...in 拿到的 id 是字串 ''102''，不是數字 102，所以第 5 行把字串放進 soldOut，後面 includes(102) 用嚴格比對，找不到就誤判成有貨。\n【用生活例子想】物件的鍵就像信箱上貼的名牌，名牌上寫的永遠是文字。你拿寫著 ''102'' 的名牌去對數字 102，系統會說不是同一個東西。\n【一句話記住】for...in 和 Object.keys 拿到的鍵一律是字串，要比數字就先用 Number 轉。\n【容易選錯】最像的是 id.toString()，但 id 本來就已經是字串，轉完還是 ''102''，includes(102) 嚴格比對依然找不到，頁面還是說有貨。\n【小字典】for...in：逐一走訪物件的鍵。includes：檢查陣列裡有沒有某個值，而且型別要一樣。Number：把值轉成數字的函式。嚴格比對：連型別都要相同才算相等。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 235);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 235 AS problem_id, '    soldOut.push(id.toString());' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 235 AS problem_id, '    soldOut.push(id + 0);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 235 AS problem_id, '    soldOut.push(Number(id));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 235);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 236, '狐狐', '🦊', '型別轉換', 'The volume shows 50 instead of 0 after the user muted the app.', '使用者已經把音量調成 0（靜音），畫面卻顯示音量是 50，設定好像被偷偷改掉了。', 'function getVolume(settings) {\n  return settings.volume || 50;\n}\nfunction applySettings(settings) {\n  const volume = getVolume(settings);\n  console.log(`音量設為 ${volume}`);\n}\nconst saved = JSON.parse(''{"volume":0}'');\napplySettings(saved);', 2, '【哪裡出錯】第 2 行用 || 當預設值，但 0 在 JavaScript 裡算 falsy，所以存好的 0 被當成「沒設定」，換成了 50。\n【用生活例子想】就像老師問你考幾分，你明明考 0 分，老師卻以為你沒回答，直接幫你填 50 分。\n【一句話記住】想只在 null 或 undefined 時才用預設值，要用 ??，不要用 ||。\n【容易選錯】Number(settings.volume) || 50 看起來有先轉成數字，但 0 轉完還是 0，一樣是 falsy，結果還是 50。\n【小字典】falsy：放進條件判斷會被當成 false 的值，例如 0、空字串、null。??：只有左邊是 null 或 undefined 才會用右邊的值。預設值：沒有人提供資料時先拿來用的備用值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 236);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 236 AS problem_id, '  return settings.volume ?? 50;' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 236 AS problem_id, '  return Number(settings.volume) || 50;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 236 AS problem_id, '  return settings.volume ? settings.volume : 50;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 236);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 237, '狐狐', '🦊', '型別轉換', 'The average shows 48 instead of 80.', '平均分數變低了：有兩位同學缺考（null），但平均好像把他們當成 0 分算進去了。', 'const rawScores = [90, null, 70, null, 80]; // null 代表缺考\nconst scores = rawScores.map(Number);\nlet sum = 0;\nfor (const s of scores) {\n  sum += s;\n}\nconst average = sum / scores.length;\nconsole.log(`平均 ${average}`);', 2, '【哪裡出錯】第 2 行用 Number 轉換時，null 會變成 0，缺考的人就悄悄變成 0 分，還被算進人數，所以平均從 80 掉到 48。\n【用生活例子想】班上 5 個人只有 3 個人考試，老師卻把缺考的 2 個人也當成考 0 分，全班平均當然被拉低。\n【一句話記住】Number(null) 是 0，不是 NaN，要先把 null 挑掉再轉型別。\n【容易選錯】改成 parseInt(s, 10) 看起來能避開 0，但 parseInt(null) 會得到 NaN，加總後整個平均變成 NaN，還是錯的。\n【小字典】null：代表刻意留空、沒有值。NaN：Not a Number，代表不是有效數字。map：把陣列每一項轉換成新的值。filter：只留下符合條件的項目。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 237);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 237 AS problem_id, 'const scores = rawScores.map((s) => parseInt(s, 10));' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 237 AS problem_id, 'const scores = rawScores.filter((s) => s !== null).map(Number);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 237 AS problem_id, 'const scores = rawScores.map((s) => +s);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 237);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 238, '狐狐', '🦊', '型別轉換', 'The page says all scores are valid even though the second entry is abc.', '畫面說所有成績都有效，但第二筆明明是 abc，應該要指出第 2 筆無效才對。', 'const rawScores = [''85'', ''abc'', ''90''];\nconst scores = rawScores.map((s) => Number(s));\nconst badIndex = scores.indexOf(NaN);\nif (badIndex === -1) {\n  console.log(''全部成績都有效'');\n} else {\n  console.log(`第 ${badIndex + 1} 筆成績無效`);\n}', 3, '【哪裡出錯】第 2 行把 ''abc'' 轉成了 NaN，但第 3 行用 indexOf(NaN) 找不到它，所以一直回傳 -1，程式以為沒有壞資料。\n【用生活例子想】NaN 像一張沒有名字的號碼牌，每張都說自己「不等於任何人」，連自己也不認，所以拿它去對號碼永遠對不上。\n【一句話記住】要找 NaN 不能用比較，要用 Number.isNaN 來問「你是不是 NaN」。\n【容易選錯】改成 findIndex((n) => n === NaN) 看起來有在檢查，但 n === NaN 永遠是 false，結果還是 -1，畫面照樣說全部有效。\n【小字典】NaN：代表不是有效數字的特殊值。indexOf：用嚴格相等一個一個比對，找不到就回傳 -1。findIndex：用你寫的條件函式找第一個符合的位置。Number.isNaN：專門判斷值是不是 NaN 的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 238);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 238 AS problem_id, 'const badIndex = scores.indexOf(Number.NaN);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 238 AS problem_id, 'const badIndex = scores.findIndex((n) => n === NaN);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 238 AS problem_id, 'const badIndex = scores.findIndex((n) => Number.isNaN(n));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 238);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 239, '狐狐', '🦊', '型別轉換', 'The course count shows 4 instead of 3.', '課程數量多算了：已選的課程編號是數字，表單拿到的是文字，同一門課被算成兩門。', 'const savedIds = [1, 2];\nconst formData = new URLSearchParams(''course=2&course=3'');\nconst checkedIds = formData.getAll(''course'');\nconst merged = new Set(savedIds);\ncheckedIds.forEach((id) => merged.add(id));\nconsole.log(`共選了 ${merged.size} 門課`);\nconsole.log([...merged].join('',''));', 5, '【哪裡出錯】savedIds 裡的 2 是數字，但從表單 getAll 拿到的 ''2'' 是字串，Set 認為它們不一樣，所以 2 被加進去兩次，總數變成 4。\n【用生活例子想】就像點名表上登記學號是數字 2，同學卻在紙上寫「2」這個字，老師用嚴格比對時會以為是兩個不同的人。\n【一句話記住】要放進 Set 去重複之前，先把型別統一，表單拿到的值要先用 Number 轉成數字。\n【容易選錯】最像正確答案的是先用 has 檢查再 add：但 has(''2'') 會去找字串 ''2''，Set 裡只有數字 2，所以找不到，還是照樣加進去，總數依然是 4。\n【小字典】Set：一種不會放重複值的集合。嚴格相等：型別和值都一樣才算相等，1 和 ''1'' 不相等。URLSearchParams：用來讀取網址參數的工具，讀出來的值都是字串。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 239);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 239 AS problem_id, 'checkedIds.forEach((id) => merged.add(Number(id)));' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 239 AS problem_id, 'checkedIds.forEach((id) => { if (!merged.has(id)) merged.add(id); });' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 239 AS problem_id, 'checkedIds.forEach((id) => merged.add(String(id)));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 239);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 240, '狐狐', '🦊', '型別轉換', 'The total shows 353 instead of 3649.', '總金額算錯：三個價格加起來應該是 3649，畫面卻只顯示 353，好像有些價格被切掉了。', 'const prices = [''1,299'', ''350'', ''2,000''];\nfunction toNumber(text) {\n  return parseFloat(text);\n}\nlet total = 0;\nfor (const p of prices) {\n  total += toNumber(p);\n}\nconsole.log(`總計 ${total} 元`);', 3, '【哪裡出錯】第 3 行的 parseFloat 讀到逗號就停了，''1,299'' 只會讀到 1，''2,000'' 只會讀到 2，所以總和變成 353。\n【用生活例子想】就像收銀員看到價格牌寫「1,299」，只念到逗號前面的「1」就不念了，當然會少收很多錢。\n【一句話記住】字串裡有逗號，要先把逗號拿掉，再轉成數字。\n【容易選錯】改成 parseInt(text, 10) 看起來很正規，但它一樣讀到逗號就停，結果還是 1、350、2，總計還是 353。\n【小字典】parseFloat：從字串開頭讀出數字，遇到不能讀的字元就停止。replace：把字串裡的某些字換成別的字。正規表達式 /,/g：找出字串裡所有的逗號。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 240);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 240 AS problem_id, '  return Number(text);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 240 AS problem_id, '  return parseFloat(text.replace(/,/g, ''''));' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 240 AS problem_id, '  return parseInt(text, 10);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 240);

-- 圓圓：fetch 與 JSON
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 241, '圓圓', '🐼', 'fetch 與 JSON', 'The search log shows [R] instead of [R&B].', '搜尋 R&B 卻只查到 R：網址裡的 & 被當成分隔符號，後面的字被切掉了。', 'async function search(keyword) {\n  const res = await fetch(`/api/search?q=${keyword}`);\n  const data = await res.json();\n  console.log("Searched for [" + data.q + "]");\n}\nawait search("R&B");', 2, '【哪裡出錯】第 2 行把 keyword 直接塞進網址，R&B 裡的 & 在網址中代表「下一個參數開始」，所以後端只收到 q=R，B 被當成另一個參數。\n【用生活例子想】就像寄包裹時地址寫「A路 & B路」，郵差會以為是兩個地址；要先用特別的寫法包起來，他才知道這是同一個名字。\n【一句話記住】把使用者輸入放進網址的 query string 前，一定要用 encodeURIComponent 編碼。\n【容易選錯】最像的是 encodeURI(keyword)，但它是設計來編碼整條網址的，不會處理 & 這種在網址裡有意義的符號，所以 & 還是原樣送出，後端還是只收到 R。\n【小字典】query string：網址問號後面帶的參數，例如 ?q=abc。encodeURIComponent：把 & 和空白這些特殊符號轉成安全寫法的函式。encodeURI：只適合編碼整條網址，不會處理 &，所以不能拿來包參數值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 241);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 241 AS problem_id, '  const res = await fetch(`/api/search?q=${encodeURI(keyword)}`);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 241 AS problem_id, '  const res = await fetch(`/api/search?q=${encodeURIComponent(keyword)}`);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 241 AS problem_id, '  const res = await fetch(`/api/search?q=${keyword.trim()}`);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 241);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 242, '圓圓', '🐼', 'fetch 與 JSON', 'SyntaxError: Unexpected token ''p'', "pong" is not valid JSON', 'JSON 格式不合：後端只回傳一段純文字 pong，你卻用 res.json() 當成 JSON 來讀，所以讀不下去。', 'async function checkServer() {\n  const res = await fetch("/api/ping");\n  const status = await res.json();\n  console.log("Server says:", status);\n}\ncheckServer();', 3, '【哪裡出錯】後端 /api/ping 只回傳純文字 pong，不是 JSON，但第 3 行用 res.json() 去解析，p 不是合法的 JSON 開頭，所以報錯。\n【用生活例子想】就像同學傳來一張紙條只寫「到了」，你卻拿解碼表去翻譯密碼，當然翻不出來，直接念出來就好。\n【一句話記住】回傳的是純文字就用 res.text()，回傳的是 JSON 才用 res.json()。\n【容易選錯】JSON.parse(await res.text()) 看起來很安全，但 pong 還是不是 JSON 格式，JSON.parse 一樣會丟出 SyntaxError。\n【小字典】res.json()：把回應內容當成 JSON 解析成物件。res.text()：把回應內容原封不動當成字串讀出來。JSON.parse：把 JSON 格式的字串轉成 JavaScript 的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 242);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 242 AS problem_id, '  const status = JSON.parse(await res.text());' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 242 AS problem_id, '  const status = await res.json;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 242 AS problem_id, '  const status = await res.text();' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 242);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 243, '圓圓', '🐼', 'fetch 與 JSON', 'The console prints 401 even though the token is correct.', '明明有帶 token，伺服器還是回 401，說你沒有登入。', 'const token = "abc123";\nconst res = await fetch("/api/me", {\n  headers: { "Authorization": token }\n});\nconsole.log(res.status);', 3, '【哪裡出錯】Authorization 標頭只放了 token，前面少了 Bearer 這個字，伺服器看不懂格式，所以回 401。\n【用生活例子想】就像進演唱會要出示「票種加票號」，你只喊票號，門口的人不知道這是哪一種票，只好請你離開。\n【一句話記住】帶 token 要寫成 Bearer 空一格再接 token。\n【容易選錯】只寫 "Bearer" 看起來有照格式，但後面沒有 token，伺服器還是對不上，一樣回 401。\n【小字典】Authorization：放身分憑證的請求標頭。Bearer：一種憑證格式，意思是持有這個 token 的人就是本人。token：伺服器發給你的通行字串。401：伺服器說你還沒通過身分驗證。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 243);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 243 AS problem_id, '  headers: { "Authorization": `Bearer ${token}` }' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 243 AS problem_id, '  headers: { "Authorization": "Bearer" }' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 243 AS problem_id, '  headers: { "Authorization": `Bearer: ${token}` }' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 243);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 244, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: fetch(...).json is not a function', 'json 不是函式：你對還沒拿到結果的 fetch 直接呼叫 .json()，它不是回應本身。', 'app.get("/api/user", (req, res) => res.json({ name: "Amy" }));\nasync function loadName() {\n  const data = await fetch("/api/user").json();\n  console.log(data.name);\n}\nloadName();', 3, '【哪裡出錯】第 3 行的 fetch("/api/user") 會先回傳一個 Promise，還沒有 json() 可以用，你卻直接在後面接 .json()，所以報錯。\n【用生活例子想】就像你在線上點餐，訂單成立只是拿到取餐單，還沒拿到餐點。要先等店員把餐交給你，才能拆開來吃。\n【一句話記住】先 await fetch 拿到 Response，再用 await res.json() 讀內容，兩步都要等。\n【容易選錯】最像的是去掉括號的 fetch("/api/user").json，這樣不會呼叫函式，只是拿到 undefined，後面 data.name 還是會報錯。\n【小字典】Promise：代表未來才會有結果的東西。await：等 Promise 完成再繼續往下。Response：fetch 拿到的回應物件，裡面有 json() 可以讀內容。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 244);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 244 AS problem_id, '  const data = await fetch("/api/user").json;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 244 AS problem_id, '  const data = await (await fetch("/api/user")).json();' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 244 AS problem_id, '  const data = await fetch("/api/user");' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 244);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 245, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: Cannot read properties of undefined (reading ''name'')', '讀不到屬性：profile 是 undefined，卻想去拿它的 name，所以程式當掉了。', 'async function loadProfile() {\n  const res = await fetch("/api/profile");\n  const profile = res.data;\n  console.log("Hello, " + profile.name);\n}\nloadProfile();', 3, '【哪裡出錯】fetch 回來的 res 是一個 Response 物件，裡面沒有 data 這個欄位，所以 res.data 是 undefined，下一行再讀 profile.name 就當掉了。\n【用生活例子想】res 像一個還沒拆的包裹，包裹上沒有寫「內容物」這個欄位，你要動手拆開（res.json()）才看得到裡面的東西。\n【一句話記住】fetch 要先 await res.json() 拆包裹，不能像 axios 一樣直接寫 res.data。\n【容易選錯】最像的是 res.body，但它是一個資料流（ReadableStream），不是解析好的物件，所以 profile.name 還是 undefined，印出來會是 Hello, undefined。\n【小字典】Response：fetch 回傳的回應物件，裝著狀態碼、標頭和還沒讀出來的內容。res.json()：把回應內容讀出來並轉成 JavaScript 物件，要加 await。axios：另一個常用的請求套件，它的回應才有 data 欄位。undefined：代表這個東西不存在或沒有值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 245);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 245 AS problem_id, '  const profile = res.body;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 245 AS problem_id, '  const profile = await res.text();' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 245 AS problem_id, '  const profile = await res.json();' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 245);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 246, '圓圓', '🐼', 'fetch 與 JSON', 'The names list shows [ undefined, undefined ] instead of [ ''Amy'', ''Ben'' ].', '名字全部是 undefined：程式一次抓了好幾個使用者，但拿到的不是資料，名字都讀不出來。', 'async function loadNames(ids) {\n  const fetchUser = (id) => fetch(`/api/users/${id}`).then((res) => res.json());\n  const users = ids.map(fetchUser);\n  return users.map((user) => user.name);\n}\nconst names = await loadNames([1, 2]);\nconsole.log(names);', 3, '【哪裡出錯】ids.map(fetchUser) 得到的是一排還沒拆開的 Promise，不是使用者資料，所以 user.name 讀不到，變成 undefined。\n【用生活例子想】就像你幫兩個朋友訂了便當，手上只拿到兩張取餐單。要等便當都做好、領回來，才吃得到飯，不能直接對取餐單說「給我雞腿」。\n【一句話記住】map 產生一排 Promise 時，要用 await Promise.all 等它們全部完成。\n【容易選錯】const users = await ids.map(fetchUser) 看起來有 await，但 await 只會等一個 Promise，這裡拿到的是一個陣列，等不到裡面的 Promise，users 還是一排 Promise，名字照樣是 undefined。\n【小字典】Promise：代表一件還沒做完的事，之後會給你結果。Promise.all：把一排 Promise 包成一個，等全部完成才回傳結果陣列。await：暫停在這一行，等 Promise 完成再往下走。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 246);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 246 AS problem_id, '  const users = await Promise.all(ids.map(fetchUser));' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 246 AS problem_id, '  const users = await ids.map(fetchUser);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 246 AS problem_id, '  const users = ids.map(async (id) => await fetchUser(id));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 246);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 247, '圓圓', '🐼', 'fetch 與 JSON', 'The page shows Load failed even though the server responded with 200 OK.', '伺服器明明回 200 成功，畫面卻顯示載入失敗：if 條件一直不成立，程式永遠走到失敗那一邊。', 'async function loadProfile() {\n  const res = await fetch("/api/profile");\n  if (res.status === "200") {\n    const data = await res.json();\n    return data.name;\n  }\n  return "Load failed";\n}\nconsole.log(await loadProfile());', 3, '【哪裡出錯】res.status 是數字 200，但第 3 行拿它跟字串 "200" 用 === 比較，型別不同所以永遠是 false，成功的回應也被當成失敗。\n【用生活例子想】就像櫃台只收「數字 200 號」的號碼牌，你卻拿出一張寫著文字「200」的紙，櫃台說這不是同一種東西，不讓你進去。\n【一句話記住】res.status 是數字，要跟數字比，或直接用 res.ok。\n【容易選錯】最像的是 res.status.toString() === 200：toString() 會把數字 200 變成字串 "200"，結果又拿字串去跟數字 200 用 === 比較，型別還是不同，條件依然是 false。\n【小字典】狀態碼：伺服器用數字告訴你請求結果，200 代表成功。===：嚴格相等，連型別都要一樣才算相等。型別：資料的種類，例如數字、字串、布林值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 247);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 247 AS problem_id, '  if (res.status === 201) {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 247 AS problem_id, '  if (res.status === 200) {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 247 AS problem_id, '  if (res.status.toString() === 200) {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 247);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 248, '圓圓', '🐼', 'fetch 與 JSON', 'The orders list is empty ([]) instead of showing Tea and Book.', '訂單清單是空的：後端明明有這位使用者的訂單，畫面卻什麼都沒有，也沒有報錯。', 'const user = { id: 7, name: "Amy" };\nasync function loadOrders(user) {\n  const res = await fetch(`/api/users/${user}/orders`);\n  const data = await res.json();\n  console.log(data.orders);\n}\nawait loadOrders(user);', 3, '【哪裡出錯】網址裡的 ${user} 放的是整個物件，物件變成文字會是 [object Object]，後端收到的 id 就不是 7，所以找不到訂單。\n【用生活例子想】就像寄包裹時，地址欄寫的是「一整張會員卡」而不是「門牌號碼」，郵差當然送不到。\n【一句話記住】拼網址時要放物件裡的欄位（像 user.id），不要把整個物件丟進去。\n【容易選錯】最像的是 ${user.name}，它確實只放了一個欄位，但後端要的是數字 id 7，收到 Amy 還是對不到訂單，結果還是空清單。\n【小字典】樣板字串：用反引號包起來、可以用 ${} 放變數的字串。[object Object]：物件直接轉成文字時的預設樣子。路由參數：網址中像 :id 這種會變動的部分。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 248);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 248 AS problem_id, '  const res = await fetch(`/api/users/${user.name}/orders`);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 248 AS problem_id, '  const res = await fetch(`/api/users/${JSON.stringify(user)}/orders`);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 248 AS problem_id, '  const res = await fetch(`/api/users/${user.id}/orders`);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 248);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 249, '圓圓', '🐼', 'fetch 與 JSON', 'SyntaxError: Unexpected end of JSON input', 'JSON 資料提早結束：刪除其實成功了，但程式想把「空的回應」當成 JSON 來讀，結果報錯。', 'app.delete("/api/todos/:id", (req, res) => res.status(204).end());\nasync function removeTodo(id) {\n  const res = await fetch(`/api/todos/${id}`, { method: "DELETE" });\n  const data = await res.json();\n  console.log("deleted", id, res.status);\n}\nremoveTodo(1);', 4, '【哪裡出錯】後端刪除成功後回 204，代表「成功，但沒有內容」，body 是空的，res.json() 想解析空字串就丟出 Unexpected end of JSON input。\n【用生活例子想】就像你寄了一個空信封，對方還硬要你唸出信裡的內容，當然唸不出來。\n【一句話記住】204 沒有內容，先檢查 res.ok 或狀態碼，不要對空 body 呼叫 res.json()。\n【容易選錯】改成 JSON.parse(await res.text()) 看起來很安全，但 text() 拿到的是空字串，JSON.parse("") 一樣丟出 Unexpected end of JSON input；用 clone().json() 也一樣，因為複製的 body 還是空的。\n【小字典】204：HTTP 狀態碼，表示成功但沒有回傳內容。res.ok：狀態碼在 200 到 299 之間時為 true。JSON.parse：把 JSON 字串轉成物件的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 249);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 249 AS problem_id, '  if (!res.ok) throw new Error("Delete failed");' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 249 AS problem_id, '  const data = JSON.parse(await res.text());' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 249 AS problem_id, '  const data = await res.clone().json();' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 249);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 250, '圓圓', '🐼', 'fetch 與 JSON', 'The console prints Content-Type: undefined instead of application/json.', '印出來是 undefined：伺服器明明有回傳內容類型，但程式一直讀不到。', 'app.get("/api/report", (req, res) => res.json({ total: 3 }));\nasync function checkType() {\n  const res = await fetch("/api/report");\n  const type = res.headers["content-type"];\n  console.log("Content-Type:", type);\n}\nawait checkType();', 4, '【哪裡出錯】res.headers 不是一般物件，而是 Headers 物件，用 ["content-type"] 去拿會找不到，所以得到 undefined。\n【用生活例子想】Headers 像一間有櫃台的服務處，你要跟櫃台說「請幫我拿某某資料」，不能自己伸手去翻櫃子。\n【一句話記住】讀回應標頭要用 res.headers.get("名稱")，不要用中括號。\n【容易選錯】res.headers.get["content-type"] 看起來很像，但 get 後面用了中括號，是去找 get 這個函式身上的屬性，一樣會得到 undefined。\n【小字典】Headers：fetch 回應裡放說明資訊的物件，例如內容類型。get：Headers 提供的方法，用名稱取出標頭的值。undefined：代表找不到值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 250);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 250 AS problem_id, '  const type = res.headers.get["content-type"];' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 250 AS problem_id, '  const type = res.headers.get("content-type");' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 250 AS problem_id, '  const type = res.headers("content-type");' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 250);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 251, '圓圓', '🐼', 'fetch 與 JSON', 'The console shows { saved: null } even though the title was sent.', '後端收不到資料：明明送出了待辦標題，回來的卻是 saved: null，好像什麼都沒收到。', 'app.use(express.json());\napp.post("/api/todos", (req, res) => res.json({ saved: req.body?.title ?? null }));\nconst res = await fetch("/api/todos", {\n  method: "POST",\n  header: { "Content-Type": "application/json" },\n  body: JSON.stringify({ title: "買牛奶" })\n});\nconsole.log(await res.json());', 5, '【哪裡出錯】第 5 行的欄位名稱拼成 header，fetch 只認 headers，多了就被默默忽略，所以沒有送出 Content-Type。\n【用生活例子想】就像寄包裹時，把收件人寫在不認得的欄位，郵差看不懂，就當作沒寫。\n【一句話記住】fetch 的標頭欄位是 headers，有 s，拼錯不會報錯，只會被忽略。\n【容易選錯】改成 headers 但值寫 text/json 很像對，可是 express.json() 只認 application/json，後端還是不解析，結果一樣是 null。\n【小字典】headers：請求的標頭，用來告訴伺服器資料的格式與身分。Content-Type：說明 body 是什麼格式。express.json()：後端用來把 JSON body 解析成物件的中介軟體。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 251);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 251 AS problem_id, '  headers: { "Content-Type": "text/json" },' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 251 AS problem_id, '  headers: { "Accept": "application/json" },' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 251 AS problem_id, '  headers: { "Content-Type": "application/json" },' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 251);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 252, '圓圓', '🐼', 'fetch 與 JSON', 'The console prints Welcome undefined instead of Welcome { name: ''Amy'', level: 3 }.', '畫面印出 Welcome undefined：後端明明有回傳資料，但下一步拿到的卻是空的。', 'app.get("/api/profile", (req, res) => {\n  res.json({ name: "Amy", level: 3 });\n});\nfetch("/api/profile")\n  .then((res) => { res.json(); })\n  .then((profile) => console.log("Welcome", profile));', 5, '【哪裡出錯】第 5 行的 then 回呼用了大括號，裡面呼叫了 res.json() 卻沒有 return，所以這個 then 的結果是 undefined，下一個 then 的 profile 就是 undefined。\n【用生活例子想】像同學幫你去影印資料，影印好了卻自己放在桌上沒交給你，你伸手拿到的當然是空的。\n【一句話記住】then 的回呼只要用了大括號，就要自己寫 return；想省略就改成不加大括號的箭頭函式。\n【容易選錯】改成 res.text() 看起來也是在讀內容，但一樣沒有 return，下一步還是 undefined，而且文字也不是物件。\n【小字典】then：Promise 完成後接著要做的事，它回傳的值會交給下一個 then。return：把結果交出去的指令。箭頭函式：用 => 寫的簡短函式，省略大括號時會自動回傳那個值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 252);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 252 AS problem_id, '  .then((res) => res.json())' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 252 AS problem_id, '  .then((res) => { res.text(); })' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 252 AS problem_id, '  .then((res) => { return res.json; })' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 252);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 253, '圓圓', '🐼', 'fetch 與 JSON', 'The search log shows q=cat?page=2, page=null instead of q=cat, page=2.', '搜尋的關鍵字變成「cat?page=2」，頁碼 page 卻是 null，後端好像沒收到頁碼。', 'async function loadPage(keyword, page) {\n  const url = `/api/search?q=${encodeURIComponent(keyword)}?page=${page}`;\n  const res = await fetch(url);\n  const data = await res.json();\n  console.log(`q=${data.q}, page=${data.page}`);\n}\nawait loadPage("cat", 2);', 2, '【哪裡出錯】網址裡的 ? 只能出現一次，用來開始 query string；第二個參數前面又寫了 ?，所以後端把 ?page=2 當成 q 的內容，page 就收不到。\n【用生活例子想】像填地址，「縣市」只能在開頭寫一次，後面的欄位要用固定的分隔符號隔開，不能再重寫一次開頭。\n【一句話記住】第一個參數前面用 ?，後面的參數之間用 &。\n【容易選錯】改成 # 看起來也像分隔符號，但 # 後面是頁面錨點，fetch 不會把它送給後端，所以 page 還是 null。\n【小字典】query string：網址 ? 後面帶給後端的參數。&：連接多個參數的符號。encodeURIComponent：把特殊字元轉成網址可以安全使用的格式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 253);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 253 AS problem_id, '  const url = `/api/search?q=${encodeURIComponent(keyword)}#page=${page}`;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 253 AS problem_id, '  const url = `/api/search?q=${encodeURIComponent(keyword)}&page=${page}`;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 253 AS problem_id, '  const url = `/api/search?q=${encodeURIComponent(keyword)};page=${page}`;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 253);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 254, '圓圓', '🐼', 'fetch 與 JSON', 'The console shows Saved tags: {} instead of [ ''home'', ''urgent'' ].', '標籤明明加了兩個，伺服器存回來卻是空的物件 {}，一個標籤都沒有。', 'const tags = new Set();\ntags.add("home");\ntags.add("urgent");\nconst todo = { title: "買牛奶", tags };\nconst res = await fetch("/api/todos", {\n  method: "POST",\n  headers: { "Content-Type": "application/json" },\n  body: JSON.stringify(todo)\n});\nconst data = await res.json();\nconsole.log("Saved tags:", data.tags);', 4, '【哪裡出錯】第 4 行把 Set 直接放進 todo，JSON.stringify 不認得 Set，會把它變成空物件 {}，所以伺服器收到的 tags 是空的。\n【用生活例子想】Set 像一個特殊形狀的收納盒，郵局只收一般紙箱（陣列），你不先把東西倒進紙箱，寄出去的就是空盒子。\n【一句話記住】要送 JSON 的資料先把 Set 或 Map 轉成陣列或一般物件，再交給 JSON.stringify。\n【容易選錯】tags.values() 看起來像是把值取出來了，但它回傳的是迭代器物件，不是陣列，JSON.stringify 還是會把它變成空物件 {}，所以結果依然不對。\n【小字典】Set：不會重複的值的集合。JSON.stringify：把 JavaScript 資料轉成 JSON 文字。展開運算子 [...]：把可以逐一取出的東西攤開放進陣列。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 254);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 254 AS problem_id, 'const todo = { title: "買牛奶", tags: tags.values() };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 254 AS problem_id, 'const todo = { title: "買牛奶", tags: String(tags) };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 254 AS problem_id, 'const todo = { title: "買牛奶", tags: [...tags] };' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 254);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 255, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: openAt.getUTCHours is not a function', '型別不對：openAt 拿到的是一串文字，不是日期物件，所以不能呼叫日期才有的方法。', 'app.get("/api/event", (req, res) => {\n  res.json({ title: "Concert", openAt: new Date("2024-05-01T10:00:00Z") });\n});\nasync function loadEvent() {\n  const res = await fetch("/api/event");\n  const event = await res.json();\n  const openAt = event.openAt;\n  console.log("Opens at hour", openAt.getUTCHours());\n}\nawait loadEvent();', 7, '【哪裡出錯】後端把 Date 用 res.json 送出時，會變成像 "2024-05-01T10:00:00.000Z" 的文字，前端 res.json() 讀回來還是文字，第 7 行直接拿來用，第 8 行才爆錯。\n【用生活例子想】就像朋友傳訊息告訴你「明天下午三點」，你收到的只是一句話，不是行事曆上的活動，要自己把它建立成活動才能設提醒。\n【一句話記住】JSON 裡沒有日期這種型別，收到日期文字後要用 new Date(文字) 轉回日期物件。\n【容易選錯】Date(event.openAt) 看起來最像，但少了 new，Date 當一般函式呼叫只會回傳「現在時間」的文字，還是字串，第 8 行一樣報 getUTCHours is not a function。\n【小字典】JSON：一種用文字表示資料的格式，只有字串、數字、布林、陣列、物件和 null。Date 物件：JavaScript 裡代表時間的東西，有 getUTCHours 這類方法。ISO 字串：像 2024-05-01T10:00:00.000Z 這種標準的時間文字。new：用來建立物件的關鍵字，沒有它 Date 只會回傳文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 255);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 255 AS problem_id, '  const openAt = new Date(event.openAt);' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 255 AS problem_id, '  const openAt = Date(event.openAt);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 255 AS problem_id, '  const openAt = JSON.parse(event.openAt);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 255);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 256, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: Failed to execute ''json'' on ''Response'': body stream already read', '內容已經被讀過了：Response 的 body 只能讀一次，第二次再讀就會報錯，而且報錯的位置不是你讀第一次的那一行。', 'async function readJson(res) {\n  return await res.json();\n}\nasync function loadOrder() {\n  const res = await fetch("/api/orders/7");\n  const order = await res.json();\n  const detail = await readJson(res);\n  console.log(order.id, detail.total);\n}\nloadOrder();', 6, '【哪裡出錯】第 6 行用 res.json() 把 body 讀掉了，第 7 行的 readJson 又去讀同一個 res，所以在第 2 行爆出 body 已經被讀過。\n【用生活例子想】Response 像一封拆開就丟進碎紙機的信，你讀完一次就沒了，別人想再看只能事先影印一份。\n【一句話記住】想讀兩次 body，就先用 res.clone() 影印一份，一份給別人讀，一份自己讀。\n【容易選錯】改成 JSON.parse(await res.text()) 看起來像換了讀法，但 text() 也會把 body 讀掉，readJson 再讀還是會報同樣的錯。\n【小字典】body：Response 裡真正的內容，只能被讀取一次。clone：複製一份 Response，兩份可以各讀一次。Promise：還沒完成的結果，要用 await 或 then 才拿得到值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 256);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 256 AS problem_id, '  const order = JSON.parse(await res.text());' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 256 AS problem_id, '  const order = await res.clone().json();' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 256 AS problem_id, '  const order = res.json();' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 256);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 257, '圓圓', '🐼', 'fetch 與 JSON', 'The console shows { title: ''missing'' } instead of the todo title.', '後端收到的資料是空的，找不到待辦事項的標題。表單明明有填，Content-Type 也設對了。', 'const form = new FormData();\nform.append("title", "買牛奶");\nform.append("qty", "2");\n\nconst payload = JSON.stringify(form);\nconst res = await fetch("/api/todos", {\n  method: "POST",\n  headers: { "Content-Type": "application/json" },\n  body: payload\n});\nconsole.log(await res.json());', 5, '【哪裡出錯】第 5 行把 FormData 直接丟給 JSON.stringify，結果只會得到 "{}"，標題和數量全都不見，後端當然讀不到。\n【用生活例子想】FormData 像一個上了鎖的資料夾，外面看起來空空的。JSON.stringify 只會拍資料夾外面的照片，你得先把文件一張一張拿出來攤在桌上，它才拍得到。\n【一句話記住】FormData 要先用 Object.fromEntries 變成普通物件，再交給 JSON.stringify。\n【容易選錯】JSON.stringify([...form]) 看起來有把內容展開，但會變成 [["title","買牛奶"],["qty","2"]] 這種陣列，後端的 req.body 變成陣列，req.body.title 還是 undefined，所以依然讀不到標題。\n【小字典】FormData：瀏覽器用來收集表單欄位的物件。JSON.stringify：把 JavaScript 的值轉成 JSON 字串。Object.fromEntries：把「鍵值對」清單轉成一般物件。req.body：後端 express 解析後的請求內容。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 257);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 257 AS problem_id, 'const payload = JSON.stringify([...form]);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 257 AS problem_id, 'const payload = JSON.stringify(form.entries());' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 257 AS problem_id, 'const payload = JSON.stringify(Object.fromEntries(form));' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 257);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 258, '圓圓', '🐼', 'fetch 與 JSON', 'The profile still shows nickname Amy after clearing it, expected null.', '清掉暱稱後，後端回傳的暱稱還是 Amy：明明有送出清空的請求，資料卻沒有改變。', 'let profile = { nickname: "Amy" };\napp.use(express.json());\napp.patch("/api/profile", (req, res) => res.json((profile = { ...profile, ...req.body })));\nasync function clearNickname() {\n  const changes = { nickname: undefined };\n  const body = JSON.stringify(changes);\n  const res = await fetch("/api/profile", { method: "PATCH", headers: { "Content-Type": "application/json" }, body });\n  console.log((await res.json()).nickname);\n}\nawait clearNickname();', 5, '【哪裡出錯】第 5 行把 nickname 設成 undefined，JSON.stringify 轉字串時會直接把這個欄位丟掉，送出去的內容變成 {}，後端沒收到要改的東西，暱稱就維持 Amy。\n【用生活例子想】就像你在表單上把「暱稱」那一格用立可白塗掉，老師收到的表單根本沒有這一格，只會以為你沒要改。要明確寫「無」，老師才知道你想清空。\n【一句話記住】想清空欄位要送 null，undefined 在 JSON 裡會整個消失。\n【容易選錯】改成 nickname: "" 看起來像清空，但後端收到的是空字串，不是 null，畫面印出來是空白一行，跟預期的 null 還是不一樣。\n【小字典】undefined：代表這個值還沒被設定。null：代表有這個欄位，但刻意放空。JSON.stringify：把 JavaScript 資料轉成 JSON 文字。PATCH：只修改資料的一部分。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 258);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 258 AS problem_id, '  const changes = { nickname: null };' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 258 AS problem_id, '  const changes = { nickname: "" };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 258 AS problem_id, '  const changes = {};' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 258);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 259, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: Do not know how to serialize a BigInt', 'BigInt 無法序列化：送出訂單時 JSON.stringify 不知道怎麼把超大整數變成 JSON 文字，程式直接報錯。', 'const orderId = 9007199254740993n;\nasync function sendOrder() {\n  const payload = { orderId, items: ["Tea", "Book"] };\n  const res = await fetch("/api/orders", {\n    method: "POST",\n    headers: { "Content-Type": "application/json" },\n    body: JSON.stringify(payload)\n  });\n  console.log(await res.json());\n}\nsendOrder();', 3, '【哪裡出錯】orderId 是 BigInt（數字後面有 n），JSON 格式沒有 BigInt 這種型別，所以第 7 行的 JSON.stringify 會報錯，真正的原因在第 3 行放進了 payload。\n【用生活例子想】就像寄包裹時，海關表格只有「數字」和「文字」兩種欄位，你的超長編號是特殊格式，不先抄成文字，櫃台就不收。\n【一句話記住】BigInt 要送給後端，先用 String() 變成字串再放進 JSON。\n【容易選錯】改成 Number(orderId) 看起來能解決報錯，但 Number 放不下這麼大的整數，會變成 9007199254740992，尾數被偷偷改掉，訂單編號就錯了。\n【小字典】BigInt：可以存超大整數的型別，數字後面加 n。序列化：把資料變成可以傳送的文字。JSON.stringify：把 JavaScript 值轉成 JSON 字串的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 259);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 259 AS problem_id, '  const payload = { orderId: Number(orderId), items: ["Tea", "Book"] };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 259 AS problem_id, '  const payload = { orderId: String(orderId), items: ["Tea", "Book"] };' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 259 AS problem_id, '  const payload = { orderId: JSON.stringify(orderId), items: ["Tea", "Book"] };' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 259);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 260, '圓圓', '🐼', 'fetch 與 JSON', 'TypeError: Converting circular structure to JSON', '循環結構不能轉成 JSON：送出留言串時程式直接當掉，錯誤出在送出的那一行，原因卻在更前面。', 'const parent = { id: 1, title: "公告", replies: [] };\nconst reply = { id: 2, text: "收到", parent: parent };\nparent.replies.push(reply);\nconst res = await fetch("/api/threads", {\n  method: "POST",\n  headers: { "Content-Type": "application/json" },\n  body: JSON.stringify(parent)\n});\nconst data = await res.json();\nconsole.log("Saved replies:", data.saved);', 2, '【哪裡出錯】第 2 行讓 reply 的 parent 指回 parent，第 3 行又把 reply 放進 parent.replies，兩邊互相指，變成一個圈。第 7 行 JSON.stringify 轉到一半繞不出來，就丟出錯誤。\n【用生活例子想】就像兩個人互相說「我的地址在對方家裡」，快遞員去送件永遠找不到真正的地址，只會繞圈圈。\n【一句話記住】要變成 JSON 的資料只能往下包，子物件想指回父物件，請只存 id。\n【容易選錯】把 parent 換成只有 title 和 replies 的新物件看起來斷開了，但 replies 還是同一個陣列，裡面有 reply，reply 又指到這個新物件，圈還在，stringify 照樣報錯。\n【小字典】循環參照：A 裡面有 B，B 裡面又有 A，形成一個圈。JSON.stringify：把 JavaScript 物件轉成 JSON 文字。parentId：只存父物件的編號，不存整個物件。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 260);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 260 AS problem_id, 'const reply = { id: 2, text: "收到", parent: { title: parent.title, replies: parent.replies } };' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 260 AS problem_id, 'const reply = { id: 2, text: "收到", parent: { ...parent } };' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 260 AS problem_id, 'const reply = { id: 2, text: "收到", parentId: parent.id };' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 260);

-- 熊熊：SQL 語法
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 261, '熊熊', '🐻', 'SQL 語法', 'ERROR 1054 (42S22): Unknown column ''coin'' in ''field list''', '找不到欄位：SELECT 裡寫的 coin 在 users 表裡不存在，可能是名字少打了一個字母', 'SELECT username, coin\nFROM users\nORDER BY coins DESC;', 1, '【哪裡出錯】第 1 行 SELECT 後面寫了 coin，但 users 表裡的欄位叫 coins，少了最後的 s，MySQL 找不到所以報錯。\n【用生活例子想】就像你去圖書館櫃台說要借「哈利波特一」，但書名其實是「哈利波特一集」，館員翻遍書架也找不到。\n【一句話記住】欄位名稱要跟資料表裡一個字都不差，報 Unknown column 就先去檢查拼字。\n【容易選錯】最像答案的是加上反引號的 `coin`，反引號只是用來包住名稱，不會幫你改拼字，MySQL 還是找不到 coin 這個欄位，一樣報 Unknown column。\n【小字典】欄位：資料表裡的一直行，像 username 或 coins。SELECT：決定要把哪些欄位拿出來看。field list：SELECT 後面列出的那串欄位。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 261);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 261 AS problem_id, 'SELECT username, coin_count' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 261 AS problem_id, 'SELECT username, `coin`' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 261 AS problem_id, 'SELECT username, coins' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 261);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 262, '熊熊', '🐻', 'SQL 語法', 'ERROR 1242 (21000): Subquery returns more than 1 row', '子查詢回傳多筆：等號一次只能跟一個值比，但括號裡的查詢找到了不只一位台北的使用者', 'SELECT name\nFROM pets\nWHERE owner_id = (SELECT id FROM users WHERE city = ''Taipei'');', 3, '【哪裡出錯】括號裡的子查詢找到兩位住台北的使用者，回傳了兩個 id，但 = 一次只能跟一個值比較，所以 MySQL 報錯。\n【用生活例子想】老師問「座號等於哪一個人的同學舉手」，如果有兩個人符合，就不知道要對哪一個。改問「座號在這群人裡面的同學舉手」，就沒問題了。\n【一句話記住】子查詢可能回傳很多筆時，用 IN 而不是 =。\n【容易選錯】最像答案的是在子查詢裡加 AND id > 0，看起來像是在縮小範圍，但台北的兩位使用者 id 都大於 0，還是回傳兩筆，所以仍然報同樣的錯。\n【小字典】子查詢：寫在括號裡、先執行的小查詢，結果會交給外面的查詢用。IN：判斷某個值是不是在一群值裡面。=：只能拿一個值來比較。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 262);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 262 AS problem_id, 'WHERE owner_id IN (SELECT id FROM users WHERE city = ''Taipei'');' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 262 AS problem_id, 'WHERE owner_id <> (SELECT id FROM users WHERE city = ''Taipei'');' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 262 AS problem_id, 'WHERE owner_id = (SELECT id FROM users WHERE city = ''Taipei'' AND id > 0);' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 262);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 263, '熊熊', '🐻', 'SQL 語法', 'The count shows 0 instead of 3 pets whose names start with Mo.', '我想數有幾隻寵物的名字以 Mo 開頭，資料明明有 3 隻，結果卻是 0。', 'SELECT COUNT(*) AS total\nFROM pets\nWHERE name LIKE ''Mo'';', 3, '【哪裡出錯】LIKE ''Mo'' 裡沒有萬用字元，所以只會找名字剛好等於 Mo 的寵物，資料裡沒有，結果就是 0。\n【用生活例子想】就像在通訊錄搜尋，只打「小」會找到名字剛好叫「小」的人，要打「小%」才會找到所有姓小的朋友。\n【一句話記住】想找開頭是某些字，就要在後面加 %。\n【容易選錯】LIKE ''%Mo'' 看起來也有萬用字元，但它找的是結尾是 Mo 的名字，這份資料裡沒有，結果還是 0。\n【小字典】LIKE：用來做模糊比對的條件。%：代表任意長度的任意字元，可以是零個或很多個。_：代表剛好一個任意字元。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 263);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 263 AS problem_id, 'WHERE name LIKE ''%Mo'';' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 263 AS problem_id, 'WHERE name LIKE ''Mo%'';' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 263 AS problem_id, 'WHERE name LIKE ''Mo_'';' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 263);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 264, '熊熊', '🐻', 'SQL 語法', 'ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''group FROM menu_items'' at line 1', 'SQL 語法錯誤：MySQL 看到 group 就以為你要寫 GROUP BY，結果後面接不起來，所以報錯。', 'SELECT name, group\nFROM menu_items\nORDER BY name;', 1, '【哪裡出錯】欄位名稱剛好叫 group，但 group 是 MySQL 的保留字，直接寫會被當成 GROUP BY 的開頭，所以語法錯誤。\n【用生活例子想】就像班上有個同學的名字叫「下課」，老師喊「下課」大家都跑出去了，要寫成「同學下課」才分得清楚。\n【一句話記住】欄位名撞到保留字，就用反引號 ` ` 把它包起來。\n【容易選錯】改成 ''group'' 最像對的，但單引號代表文字，MySQL 只會每一列都印出 group 這個字，不會去讀欄位裡的資料，所以結果還是不對。\n【小字典】保留字：MySQL 已經拿來當語法用的單字，例如 group、order、select。反引號：鍵盤左上角 ~ 那顆鍵的符號，用來包住欄位或表格名稱。字串：用單引號包起來的文字，只是一段內容，不是欄位。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 264);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 264 AS problem_id, 'SELECT name, ''group''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 264 AS problem_id, 'SELECT name, group_name' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 264 AS problem_id, 'SELECT name, `group`' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 264);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 265, '熊熊', '🐻', 'SQL 語法', 'ERROR 1052 (23000): Column ''id'' in field list is ambiguous', '欄位不明確：pets 和 users 兩張表都有 id 欄位，MySQL 不知道你要的是哪一個', 'SELECT id, name, username\nFROM pets\nJOIN users ON pets.owner_id = users.id;', 1, '【哪裡出錯】pets 和 users 兩張表都有 id 欄位，SELECT 只寫 id，MySQL 不知道要拿哪一張表的，所以報錯。\n【用生活例子想】班上有兩個同學都叫小明，老師只喊小明，大家不知道是誰要站起來，要喊三年二班的小明才清楚。\n【一句話記住】JOIN 之後遇到同名欄位，一定要寫成 表名.欄位。\n【容易選錯】只把 name 改成 pets.name 看起來很用心，但真正撞名的是 id，id 還是沒加表名，一樣會報 ambiguous 的錯。\n【小字典】JOIN：把兩張表依條件接起來。ambiguous：意思是不明確，有不只一種可能。欄位前綴：在欄位前面加表名和點，例如 pets.id。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 265);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 265 AS problem_id, 'SELECT pets.id, name, username' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 265 AS problem_id, 'SELECT id, pets.name, username' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 265 AS problem_id, 'SELECT DISTINCT id, name, username' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 265);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 266, '熊熊', '🐻', 'SQL 語法', 'The all_members list shows Amy,Cara and leaves out Ben, who has not placed any order yet.', '會員名單少了人：Ben 還沒下過訂單，結果名單裡就沒有他，三個會員只出現兩個。', 'SELECT GROUP_CONCAT(users.username ORDER BY users.id) AS all_members\nFROM users\nJOIN orders ON orders.user_id = users.id;', 3, '【哪裡出錯】第 3 行的 JOIN 預設是 INNER JOIN，只留下兩邊都對得上的資料，沒有訂單的 Ben 就被丟掉了。\n【用生活例子想】像點名時只叫有交作業的人，沒交作業的同學就不會出現在名單上，但你其實想列出全班。\n【一句話記住】想保留左邊表格的每一筆，就用 LEFT JOIN。\n【容易選錯】RIGHT JOIN 看起來也是 JOIN 的一種，但它是保留右邊 orders 的全部資料，而每筆訂單都有對應的會員，結果還是只有 Amy 和 Cara，Ben 依然不見。\n【小字典】INNER JOIN：只保留兩個表格都配對成功的資料。LEFT JOIN：左邊表格全部保留，右邊配不到就補 NULL。GROUP_CONCAT：把多筆資料接成一個字串。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 266);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 266 AS problem_id, 'RIGHT JOIN orders ON orders.user_id = users.id;' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 266 AS problem_id, 'LEFT JOIN orders ON orders.user_id = users.id;' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 266 AS problem_id, 'JOIN orders ON orders.user_id = users.id OR orders.user_id IS NULL;' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 266);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 267, '熊熊', '🐻', 'SQL 語法', 'The buyers count shows 7 instead of 3 even though only 3 different users paid.', '人數算太多：想知道有幾個不同的人付款，結果出現的是付款的筆數，同一個人被重複算好幾次。', 'SELECT COUNT(user_id) AS buyers\nFROM orders\nWHERE status = ''paid''\n  AND created_at >= ''2025-01-01'';', 1, '【哪裡出錯】COUNT(user_id) 是一筆訂單算一次，同一個人買 3 次就被算成 3 個人，所以出現 7 而不是 3。\n【用生活例子想】班上園遊會有 3 個同學來買飲料，但他們一共買了 7 杯。如果你數收據有幾張，會得到 7，數不重複的人才會得到 3。\n【一句話記住】想數有幾個不同的人或東西，就用 COUNT(DISTINCT 欄位)。\n【容易選錯】SELECT DISTINCT COUNT(user_id) 看起來有加 DISTINCT，但它是對算完的結果去重複，COUNT 已經先算出 7 了，所以還是 7。\n【小字典】COUNT：幫你數有幾筆資料。DISTINCT：把重複的值只留一個。欄位：資料表裡的一直行，例如 user_id。別名：用 AS 幫結果取的名字，例如 buyers。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 267);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 267 AS problem_id, 'SELECT DISTINCT COUNT(user_id) AS buyers' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 267 AS problem_id, 'SELECT COUNT(*) AS buyers' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 267 AS problem_id, 'SELECT COUNT(DISTINCT user_id) AS buyers' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 267);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 268, '熊熊', '🐻', 'SQL 語法', 'The report counts 2 users instead of all 4 users, even though users with no paid order should still be counted.', 'LEFT JOIN 明明要保留所有使用者，結果只剩 2 人：沒有付款訂單的人在 WHERE 那一關被刷掉了。', 'SELECT\n  COUNT(DISTINCT users.id) AS users_listed\nFROM users\nLEFT JOIN orders\n  ON orders.user_id = users.id\nWHERE orders.status = ''paid'';', 6, '【哪裡出錯】LEFT JOIN 遇到沒有訂單的人，會把 orders 的欄位補成 NULL。接著 WHERE orders.status = ''paid'' 對 NULL 不成立，這些人就被整個丟掉，LEFT JOIN 等於白寫。\n【用生活例子想】像班上點名表要列出全班同學，你卻在點名之前先規定「只有交過作業的人才能進教室」，沒交作業的人連名字都不會出現在表上。\n【一句話記住】想保留左表所有人，右表的篩選條件要放在 ON 裡，不要放在 WHERE。\n【容易選錯】WHERE orders.status = ''paid'' OR orders.status IS NULL 看起來能救回沒有訂單的人，但只有完全沒訂單的人會是 NULL。像 Cara 只有一張 pending 的訂單，狀態不是 paid 也不是 NULL，還是被篩掉，結果只有 3 人，不是 4 人。\n【小字典】LEFT JOIN：左表的資料全部保留，右邊沒配對到的欄位會變成 NULL。ON：決定兩張表怎麼配對的條件，篩選也可以寫在這裡。WHERE：配對完成後，再把整列結果篩一次的條件。NULL：代表沒有值，拿它做 = 比較不會成立。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 268);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 268 AS problem_id, '  AND orders.status = ''paid'';' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 268 AS problem_id, 'WHERE orders.status = ''paid'' OR orders.status IS NULL;' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 268 AS problem_id, 'WHERE orders.status IN (''paid'', ''pending'');' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 268);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 269, '熊熊', '🐻', 'SQL 語法', 'The list shows Ben at level 3 even though only Taipei or Taichung players with level 10 or higher should appear.', '結果多了不該出現的人：我只想要台北或台中、而且等級 10 以上的玩家，卻看到一個等級 3 的人。', 'SELECT username, city, level\nFROM users\nWHERE city = ''Taipei'' OR city = ''Taichung''\n  AND level >= 10\nORDER BY level DESC;', 3, '【哪裡出錯】SQL 會先算 AND 再算 OR，所以第 3、4 行被讀成「所有台北的人」或「台中而且等級 10 以上的人」，台北等級 3 的 Ben 就跑進來了。\n【用生活例子想】就像你說「我要台北或台中的同學，而且要會游泳」，沒加括號的話，對方會聽成「台北的全部都要」，再加上「台中而且會游泳的」。\n【一句話記住】OR 的條件要先用括號包起來，再接 AND。\n【容易選錯】最像的是 WHERE city = ''Taipei'' OR (city = ''Taichung'')，它只是在 Taichung 那邊加了括號，AND 還是只綁住第二個條件，Ben 還是會跑出來，所以還是不對。\n【小字典】WHERE：用來篩選資料的條件。AND：兩邊條件都要成立才會留下。OR：兩邊條件只要有一邊成立就會留下。括號：讓括號裡的條件先算。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 269);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 269 AS problem_id, 'WHERE city = ''Taipei'' AND city = ''Taichung''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 269 AS problem_id, 'WHERE (city = ''Taipei'' OR city = ''Taichung'')' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 269 AS problem_id, 'WHERE city = ''Taipei'' OR (city = ''Taichung'')' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 269);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 270, '熊熊', '🐻', 'SQL 語法', 'The result includes Milk Tea priced 120, but every item should cost less than 100.', '想找 100 元以下的飲料和甜點，結果卻出現一杯 120 元的奶茶，價格條件好像只管到甜點。', 'SELECT name, category, price\nFROM products\nWHERE category = ''drink'' OR category = ''dessert''\n  AND price < 100\nORDER BY name;', 3, '【哪裡出錯】AND 會比 OR 先算，所以 SQL 把條件看成「是飲料」或是「甜點而且低於 100 元」，飲料完全沒被價格限制。\n【用生活例子想】就像媽媽說「買飲料或甜點，而且要便宜」，你卻只把「便宜」聽成是甜點的規定，結果貴的飲料也買回家了。\n【一句話記住】AND 和 OR 混用時，想先算的部分一定要用括號包起來。\n【容易選錯】只把 (category = ''dessert'') 包起來看似有改，但括號裡原本就是單一條件，運算順序完全沒變，貴的飲料還是會跑出來。\n【小字典】WHERE：篩選資料列的條件。AND：兩個條件都要成立。OR：其中一個成立就可以。運算優先順序：多個運算符號同時出現時，誰先被計算的規則。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 270);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 270 AS problem_id, 'WHERE category = ''drink'' OR (category = ''dessert'')' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 270 AS problem_id, 'WHERE category = ''drink'' AND category = ''dessert''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 270 AS problem_id, 'WHERE (category = ''drink'' OR category = ''dessert'')' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 270);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 271, '熊熊', '🐻', 'SQL 語法', 'Class 1 average shows 75.0 instead of 50.0 even though one absent student should count as 0.', '平均分數偏高：有一位學生缺考，分數是空的，應該算 0 分，但平均好像把他當作不存在。', 'SELECT class_id,\n       COUNT(*) AS students,\n       ROUND(AVG(score), 1) AS avg_score\nFROM exam_scores\nGROUP BY class_id\nORDER BY class_id;', 3, '【哪裡出錯】AVG(score) 會直接跳過 score 是 NULL 的那一列，所以缺考的學生沒有被算進分母，1 班變成只拿 90 和 60 來平均，得到 75.0。\n【用生活例子想】老師算全班平均時，缺考的同學如果直接不點名，平均就會被好成績的同學拉高，其實他應該被記 0 分才公平。\n【一句話記住】AVG 會無視 NULL，想把空值當 0，就先用 COALESCE(欄位, 0) 換掉再平均。\n【容易選錯】用 AVG(NULLIF(score, 0)) 看起來像在處理特殊值，但 NULLIF 是把 0 變成 NULL，原本就是 NULL 的缺考還是被略過，結果依然是 75.0。\n【小字典】NULL：代表沒有值或未知，不等於 0。AVG：算平均的聚合函式，會略過 NULL。COALESCE：回傳參數裡第一個不是 NULL 的值。聚合函式：把很多列合成一個結果，例如 SUM、COUNT、AVG。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 271);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 271 AS problem_id, '       ROUND(AVG(COALESCE(score, 0)), 1) AS avg_score' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 271 AS problem_id, '       ROUND(AVG(NULLIF(score, 0)), 1) AS avg_score' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 271 AS problem_id, '       ROUND(SUM(score) / COUNT(score), 1) AS avg_score' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 271);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 272, '熊熊', '🐻', 'SQL 語法', 'ERROR 1054 (42S22): Unknown column ''subtotal'' in ''where clause''', '找不到欄位：WHERE 裡用了 subtotal，但資料表裡根本沒有這個欄位名稱', 'SELECT product,\n       price * quantity AS subtotal\nFROM order_items\nWHERE subtotal >= 100\nORDER BY subtotal DESC;', 4, '【哪裡出錯】subtotal 是 SELECT 裡幫算式取的別名，但 WHERE 執行得比 SELECT 早，那時候 subtotal 還不存在，所以 MySQL 說找不到欄位。\n【用生活例子想】就像熊熊還沒進教室，老師就先點名叫「小明的綽號」，這時候綽號還沒發下去，沒有人知道是誰。\n【一句話記住】WHERE 先篩選、SELECT 才取別名，所以 WHERE 要寫原本的算式，不能用別名。\n【容易選錯】WHERE order_items.subtotal >= 100 看起來很正式，但 order_items 這張表本來就沒有 subtotal 欄位，加上表名一樣會報找不到欄位。\n【小字典】別名：用 AS 幫欄位或算式取的暫時名字。WHERE：在分組和顯示之前先挑出符合條件的資料列。SUM：把很多列加總的聚合函式，不能直接放在 WHERE 裡。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 272);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 272 AS problem_id, 'WHERE order_items.subtotal >= 100' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 272 AS problem_id, 'WHERE price * quantity >= 100' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 272 AS problem_id, 'WHERE SUM(price * quantity) >= 100' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 272);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 273, '熊熊', '🐻', 'SQL 語法', 'The top 3 richest list shows Amy, Dan and Cara, who are the poorest players with coins.', '排行榜應該列出金幣最多的前三名，結果出現的卻是金幣最少的人。', 'SELECT username, coins\nFROM users\nWHERE coins > 0\nORDER BY coins\nLIMIT 3;', 4, '【哪裡出錯】ORDER BY coins 沒有寫方向，MySQL 預設由小到大排，所以 LIMIT 3 拿到的是金幣最少的三個人。\n【用生活例子想】就像考試成績表從最低分排到最高分，你想看前三名卻只翻開前三行，看到的全是倒數的人。\n【一句話記住】想要最大的排前面，就要寫 ORDER BY 欄位 DESC，再用 LIMIT 取前幾筆。\n【容易選錯】ORDER BY coins ASC 看起來像有明確指定方向，但 ASC 就是預設的由小到大，結果和原本一模一樣，還是最窮的三個人。\n【小字典】ORDER BY：決定結果怎麼排序。ASC：由小到大，是預設值。DESC：由大到小。LIMIT：只取前面幾筆。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 273);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 273 AS problem_id, 'ORDER BY coins ASC' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 273 AS problem_id, 'ORDER BY username DESC' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 273 AS problem_id, 'ORDER BY coins DESC' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 273);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 274, '熊熊', '🐻', 'SQL 語法', 'The May report shows 1 order with revenue 100, but 3 paid orders worth 350 were placed in May.', '五月報表只算到 1 筆訂單、金額 100，但五月其實有 3 筆已付款訂單。五月 31 日的訂單好像不見了。', 'SELECT\n  COUNT(*) AS order_count,\n  SUM(total) AS revenue\nFROM orders\nWHERE status = ''paid''\n  AND created_at BETWEEN ''2024-05-01'' AND ''2024-05-31''\nGROUP BY status;', 6, '【哪裡出錯】created_at 是 DATETIME，會帶時間。''2024-05-31'' 會被當成 5 月 31 日 00:00:00，所以 5 月 31 日白天和晚上的訂單都被排除了。\n【用生活例子想】就像店家說營業到 31 號，你卻在 31 號凌晨 0 點就把門鎖上，當天來的客人全都進不去。\n【一句話記住】篩 DATETIME 的日期範圍，用「大於等於起始日」加上「小於隔天」最安全。\n【容易選錯】把結束日改成 ''2024-05-31 00:00:00'' 最像對的，但這和原本寫 ''2024-05-31'' 其實一模一樣，還是只到 31 日凌晨 0 點，31 日的訂單照樣被漏掉。\n【小字典】DATETIME：同時記錄日期和時間的欄位型態。BETWEEN：包含頭尾的範圍比較，但頭尾只是單一時間點。GROUP BY：把相同值的資料分成一組再統計。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 274);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 274 AS problem_id, '  AND created_at >= ''2024-05-01'' AND created_at < ''2024-06-01''' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 274 AS problem_id, '  AND created_at BETWEEN ''2024-05-01'' AND ''2024-05-30''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 274 AS problem_id, '  AND created_at BETWEEN ''2024-05-01'' AND ''2024-05-31 00:00:00''' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 274);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 275, '熊熊', '🐻', 'SQL 語法', 'The never_paid list shows none even though Ben and Dan have never paid for an order.', '想找出沒付過錢的會員，明明有 Ben 和 Dan，結果卻顯示 none。問題不在外層，而在括號裡抓出來的名單。', 'SELECT IFNULL(GROUP_CONCAT(u.username ORDER BY u.username), ''none'') AS never_paid\nFROM users u\nWHERE u.id NOT IN (\n  SELECT o.user_id\n  FROM orders o\n  WHERE o.status = ''paid''\n);', 6, '【哪裡出錯】括號裡抓出來的 user_id 名單混進了 NULL（訪客下的單沒有會員編號），NOT IN 碰到 NULL 就沒辦法確定誰不在名單裡，所以一個人都不回傳。\n【用生活例子想】像點名時名單上有一格是「不知道是誰」，你就沒辦法肯定地說某人沒來，只好都先不算。\n【一句話記住】NOT IN 的子查詢只要可能有 NULL，就要用 IS NOT NULL 先濾掉。\n【容易選錯】最像的是 OR o.user_id IS NULL 那個選項，它還特地把 NULL 那筆也抓進名單，結果名單裡的 NULL 沒有少，反而更確定存在，NOT IN 還是一個人都不回傳。\n【小字典】NULL：代表不知道或沒有值，不是 0 也不是空字串。子查詢：寫在括號裡的小查詢，結果給外層使用。NOT IN：不在這份名單裡的意思。IS NOT NULL：用來檢查欄位有值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 275);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 275 AS problem_id, '  WHERE o.status = ''paid'' OR o.user_id IS NULL' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 275 AS problem_id, '  WHERE o.status = ''paid'' AND o.user_id IS NOT NULL' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 275 AS problem_id, '  WHERE o.status = ''paid'' AND o.user_id IS NULL' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 275);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 276, '熊熊', '🐻', 'SQL 語法', 'The coupon list includes SAVEX30 and SAVE50 even though only codes starting with SAVE_ should appear.', '優惠碼清單多出不該有的資料：只想找 SAVE_ 開頭的券，結果 SAVEX30 和 SAVE50 也跑出來了。', 'SELECT code,\n       discount,\n       expires_on\nFROM coupons\nWHERE active = 1\n  AND code LIKE ''SAVE_%''\n  AND expires_on >= ''2025-01-01''\nORDER BY code;', 6, '【哪裡出錯】在 LIKE 裡，底線 _ 不是普通符號，而是代表「任意一個字」的萬用字元，所以 ''SAVE_%'' 會把 SAVEX30 和 SAVE50 也抓進來。\n【用生活例子想】就像點名單上寫「小_」，老師會把小明、小華、小美全部叫起來，不是只叫名字真的叫「小_」的那個人。\n【一句話記住】想在 LIKE 裡找真正的 _ 或 %，要用 ESCAPE 指定跳脫字元，放在符號前面。\n【容易選錯】改成 ''SAVE__%'' 看起來像是把底線管得更嚴，但兩個底線一樣都是萬用字元，只是要求 SAVE 後面至少兩個字，SAVEX30 和 SAVE50 還是會被抓進來。\n【小字典】萬用字元：LIKE 裡可以代替其他字的特殊符號，% 代表任意多個字，_ 代表剛好一個字。ESCAPE：指定一個跳脫字元，讓後面的符號變成普通字。跳脫：讓特殊符號失去特殊功能，只當一般文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 276);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 276 AS problem_id, '  AND code LIKE ''SAVE%''' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 276 AS problem_id, '  AND code LIKE ''SAVE__%''' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 276 AS problem_id, '  AND code LIKE ''SAVE!_%'' ESCAPE ''!''' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 276);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 277, '熊熊', '🐻', 'SQL 語法', 'The monthly report shows rows 2024-15, 2024-30 and 2024-45 instead of 2024-01, 2024-02 and 2024-03.', '月報表的月份欄位長得很怪，出現 2024-15、2024-30 這種「月份」，而且不同月份的訂單被加在一起。', 'SELECT\n  DATE_FORMAT(created_at, ''%Y-%i'') AS month,\n  COUNT(*) AS order_count,\n  SUM(total) AS revenue\nFROM orders\nWHERE status = ''paid''\nGROUP BY month\nORDER BY month;', 2, '【哪裡出錯】第 2 行的格式字串寫成 %i，在 MySQL 裡 %i 是「分鐘」不是「月份」，所以訂單被依照下單的分鐘分組，不同月份被混在同一組。\n【用生活例子想】這就像整理發票，你本來要按月份分資料夾，結果卻按「幾點幾分開的」分，一月和三月的發票就被塞進同一個資料夾。\n【一句話記住】DATE_FORMAT 裡小寫 %m 是月，%i 是分，%d 是日，用錯字母就會分錯組。\n【容易選錯】把 %i 改成 %d 看起來像有改，但 %d 是「幾號」，結果會變成 2024-05、2024-20 這種日期，仍然不是月份，也一樣會把不同月份同一天的訂單加在一起。\n【小字典】DATE_FORMAT：把日期時間轉成指定格式的文字。GROUP BY：把相同值的資料分成一組再統計。格式字串：用 %Y、%m 這種代號告訴 MySQL 要怎麼顯示日期。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 277);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 277 AS problem_id, '  DATE_FORMAT(created_at, ''%Y-%m'') AS month,' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 277 AS problem_id, '  DATE_FORMAT(created_at, ''%Y-%d'') AS month,' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 277 AS problem_id, '  DATE_FORMAT(created_at, ''%Y-%M'') AS month,' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 277);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 278, '熊熊', '🐻', 'SQL 語法', 'The total_sales shows 600 instead of 800 even though all five sales should be added up.', '總銷售額少算了：線上和門市一共五筆銷售，加起來應該是 800，結果卻只有 600。', 'SELECT SUM(amount) AS total_sales\nFROM (\n  SELECT amount\n  FROM online_sales\n  UNION\n  SELECT amount\n  FROM store_sales\n) AS all_sales;', 5, '【哪裡出錯】第 5 行用了 UNION，它會把合併後金額相同的列當成重複的丟掉，100 本來有三筆卻只剩一筆，所以總和變成 600。\n【用生活例子想】想像把兩疊發票合成一疊，UNION 像有人看到金額一樣的發票就丟掉，UNION ALL 才是整疊全部留下來。\n【一句話記住】要把兩個查詢的結果全部接起來，不想去重複，就用 UNION ALL。\n【容易選錯】UNION DISTINCT 看起來比較明確，但它跟 UNION 一模一樣，一樣會去重複，總和還是 600。\n【小字典】UNION：合併兩個查詢結果並去掉重複列。UNION ALL：合併兩個查詢結果並保留所有列。SUM：把欄位的數字加總。子查詢：放在括號裡、先算出一張暫時表的查詢。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 278);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 278 AS problem_id, '  UNION DISTINCT' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 278 AS problem_id, '  UNION ALL' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 278 AS problem_id, '  INTERSECT' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 278);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 279, '熊熊', '🐻', 'SQL 語法', 'The spent column shows Amy 400 and Ben 240 instead of Amy 200 and Ben 80.', '每位玩家的消費總額都算太多：訂單金額被商品筆數重複加了好幾次。', 'SELECT u.username,\n       SUM(o.total) AS spent\nFROM users u\nJOIN orders o ON o.user_id = u.id\nJOIN order_items i ON i.order_id = o.id\nGROUP BY u.id, u.username\nORDER BY u.username;', 2, '【哪裡出錯】orders 每筆訂單 JOIN order_items 之後，有幾個商品就會變成幾列，所以 o.total 被重複加了好幾次。\n【用生活例子想】一張 100 元的收據上有 2 樣東西，你把收據影印成 2 份再把金額全部加起來，就變成 200 元了。\n【一句話記住】JOIN 到「多」的那一邊之後，再去加「一」那一邊的欄位就會重複計算，要改加多的那一邊自己的欄位。\n【容易選錯】SUM(DISTINCT o.total) 看起來能去掉重複，但 Amy 的兩張訂單剛好都是 100，DISTINCT 會把它們當成同一個值只算一次，結果變成 100 而不是 200。\n【小字典】JOIN：把兩張表依條件接在一起。SUM：把一欄的數字加總。DISTINCT：只留下不重複的值。一對多：一筆資料對應到好幾筆資料。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 279);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 279 AS problem_id, '       SUM(DISTINCT o.total) AS spent' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 279 AS problem_id, '       SUM(i.price) AS spent' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 279 AS problem_id, '       SUM(i.price * i.qty) AS spent' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 279);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 280, '熊熊', '🐻', 'SQL 語法', 'The top 3 list shows Ben 95, Cara 9 and Dan 80, but Amy with 100 is missing.', '前三名榜單怪怪的：只有 9 分的 Cara 排進前三，100 分的 Amy 卻不見了。', 'SELECT\n  p.name,\n  s.score\nFROM players AS p\nJOIN scores AS s ON s.player_id = p.id\nWHERE s.season = 2024\nORDER BY s.score DESC\nLIMIT 3;', 7, '【哪裡出錯】score 欄位是 VARCHAR（文字），ORDER BY 會一個字一個字比，''9'' 比 ''1'' 大，所以 ''9'' 排在 ''100'' 前面。\n【用生活例子想】就像字典排序，「9」會排在「100」前面，因為先比第一個字，9 比 1 大。\n【一句話記住】欄位存成文字時，排大小前要先用 CAST 轉成數字。\n【容易選錯】改成 ORDER BY CAST(s.score AS CHAR) DESC 看起來有轉型，但轉成 CHAR 還是文字，排序結果和原本一樣，Cara 還是會擠進前三。\n【小字典】VARCHAR：存文字的欄位型別。CAST：把值轉成另一種型別。UNSIGNED：不帶負號的整數型別。ORDER BY：決定結果的排列順序。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 280);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 280 AS problem_id, 'ORDER BY CAST(s.score AS UNSIGNED) DESC' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 280 AS problem_id, 'ORDER BY CAST(s.score AS CHAR) DESC' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 280 AS problem_id, 'ORDER BY s.score ASC' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 280);

-- 咕咕：Express 回應
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 281, '咕咕', '🦉', 'Express 回應', 'The response for a missing pet has status 200 instead of 404.', '查不到的寵物回傳了成功的狀態碼：找不到資料時，回應的狀態碼還是 200，不是 404。', 'app.get("/api/pets/:id", (req, res) => {\n  const pet = { 1: "咕咕" }[req.params.id];\n  if (!pet) return res.json({ error: "Pet not found" }).status(404);\n  res.json({ name: pet });\n});', 3, '【哪裡出錯】res.json() 一呼叫就把回應送出去了，後面才接 .status(404) 已經來不及，狀態碼還是預設的 200。\n【用生活例子想】就像信已經投進郵筒才在信封上寫「急件」，郵差早就收走了，寫了也沒用。\n【一句話記住】要先 res.status() 設好狀態碼，最後才 res.json() 送出。\n【容易選錯】選 res.status(200).json(...) 的話，順序雖然對了，但狀態碼被你明確設成 200，找不到資料還是回報成功，跟原本的問題一樣沒解決。\n【小字典】狀態碼：伺服器告訴瀏覽器結果好不好的數字，200 代表成功，404 代表找不到。res.json：把資料轉成 JSON 並送出回應。鏈式呼叫：把好幾個方法用點接起來，由左到右依序執行。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 281);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 281 AS problem_id, '  if (!pet) return res.status(404).json({ error: "Pet not found" });' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 281 AS problem_id, '  if (!pet) return res.status(200).json({ error: "Pet not found" });' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 281 AS problem_id, '  if (!pet) return res.json({ error: "Pet not found", status: 404 });' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 281);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 282, '咕咕', '🦉', 'Express 回應', 'The client gets Express''s default HTML error page instead of the JSON error message.', '錯誤處理沒生效：路由出錯後，前端收到的是一大段 HTML 錯誤頁，不是我們寫好的 JSON 訊息。', 'app.get("/api/boom", (req, res) => {\n  throw new Error("資料庫壞掉了");\n});\napp.use((err, req, res) => {\n  res.status(500).json({ ok: false, message: "伺服器出錯了" });\n});', 4, '【哪裡出錯】Express 靠函式有幾個參數，來分辨它是不是錯誤處理 middleware。這裡只寫了三個參數，Express 把它當成一般 middleware，出錯時就跳過它。\n【用生活例子想】就像公司只認「四個欄位都填好」的申訴單才轉給客服部門，少填一欄，申訴單就被當成普通文件，客服根本看不到。\n【一句話記住】錯誤處理 middleware 一定要寫成 (err, req, res, next) 四個參數，少一個都不算。\n【容易選錯】最像的是 (req, res, next, err) 這個寫法，它雖然有四個參數，但 Express 是照位置給值的，第一個永遠是錯誤，所以 req 會拿到錯誤物件，res 拿到 req，呼叫 res.status 就會再出錯，還是回 HTML 錯誤頁。\n【小字典】middleware：請求到回應之間負責處理事情的中間函式。參數：函式括號裡接收資料的名字。錯誤處理 middleware：專門接住路由丟出的錯誤的特殊函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 282);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 282 AS problem_id, 'app.use((req, res, next, err) => {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 282 AS problem_id, 'app.use((err, req, res, next) => {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 282 AS problem_id, 'app.use((req, res, next) => {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 282);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 283, '咕咕', '🦉', 'Express 回應', 'Cannot GET /api/pets', '找不到路由：瀏覽器打開 /api/pets 卻看到 Cannot GET，伺服器說沒有這條路。', 'const router = express.Router()\nrouter.get(''/pets'', (req, res) => {\n  res.json([{ id: 1, name: ''咕咕'' }])\n})\napp.use(''/api/pets'', router)', 5, '【哪裡出錯】router 裡已經寫了 /pets，app.use 又掛在 /api/pets，兩段接起來變成 /api/pets/pets，所以 /api/pets 找不到。\n【用生活例子想】就像地址已經寫了「台北市」，門牌又重複寫一次「台北市」，郵差會找不到正確的家。\n【一句話記住】掛載路徑加上 router 內的路徑，才是最後的網址，不要重複寫。\n【容易選錯】最像的錯誤選項是 app.use(''/api/pets/pets'', router)，這樣網址變成 /api/pets/pets/pets，還是不是 /api/pets，所以一樣是 Cannot GET。\n【小字典】router：把一組路由收在一起的小單位。掛載：用 app.use 把 router 接到某個網址底下。路徑：網址中斜線後面的那一段。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 283);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 283 AS problem_id, 'app.use(''/pets'', router)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 283 AS problem_id, 'app.use(''/api/pets/pets'', router)' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 283 AS problem_id, 'app.use(''/api'', router)' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 283);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 284, '咕咕', '🦉', 'Express 回應', 'The API returns an HTML error page with a stack trace instead of the JSON { error: boom }.', '我們寫了錯誤處理函式想回傳 JSON，但瀏覽器看到的卻是一整頁 HTML 錯誤和一堆程式路徑。', 'app.get(''/api/boom'', (req, res) => {\n  throw new Error(''boom'')\n})\napp.use((err, req, res) => {\n  res.status(500).json({ error: err.message })\n})', 4, '【哪裡出錯】Express 判斷一個函式是不是錯誤處理 middleware，是看它有沒有剛好四個參數，這裡只寫了三個，所以被當成普通 middleware，錯誤就沒有交給它。\n【用生活例子想】就像學校只有「四個人一組」的客服小組才會接客訴，你只派三個人去，客訴就被丟給預設的櫃台，櫃台只會貼出一張嚇人的公告。\n【一句話記住】錯誤處理 middleware 一定要寫成 (err, req, res, next) 四個參數，少一個都不算。\n【容易選錯】把參數改成 (req, res, next, err) 看起來有四個，但 Express 固定第一個傳進來的是 err，所以 res 其實是 req，呼叫 res.status 會直接壞掉，還是看到 HTML 錯誤頁。\n【小字典】middleware：夾在請求和回應中間的處理函式。錯誤處理 middleware：專門接住錯誤的 middleware，要有四個參數。stack trace：錯誤發生時一路列出的程式位置。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 284);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 284 AS problem_id, 'app.use((err, req, res, next) => {' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 284 AS problem_id, 'app.use((req, res, next, err) => {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 284 AS problem_id, 'app.use((err, req, next) => {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 284);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 285, '咕咕', '🦉', 'Express 回應', 'TypeError [ERR_INVALID_ARG_TYPE]: The "chunk" argument must be of type string or an instance of Buffer, TypedArray, or DataView. Received an instance of Array', '參數型別不合：res.end 只收文字或 Buffer，你卻把陣列直接丟給它，伺服器就出錯了', 'app.get("/api/pets", (req, res) => {\n  const pets = [{ id: 1, name: "Mochi" }];\n  console.log("pets count:", pets.length);\n  res.end(pets);\n});', 4, '【哪裡出錯】第 4 行的 res.end(pets) 把陣列直接交給 res.end，但它只吃文字或 Buffer，所以丟出 ERR_INVALID_ARG_TYPE，伺服器回 500。\n【用生活例子想】就像宅配櫃只收包好的箱子，你把一堆散裝東西直接塞進去，櫃子會拒收。\n【一句話記住】要回傳物件或陣列，請用 res.json()，它會幫你轉成 JSON 文字再送出。\n【容易選錯】改成 res.write(pets) 看起來像是在寫資料給對方，但 write 和 end 一樣只收文字或 Buffer，傳陣列還是會報同樣的錯。\n【小字典】res.end：直接結束回應，只能送文字或 Buffer。res.json：把資料轉成 JSON 並設定好標頭再送出。JSON：一種用文字表示物件和陣列的資料格式。Buffer：存放原始位元組資料的容器。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 285);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 285 AS problem_id, '  res.write(pets);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 285 AS problem_id, '  res.json(pets);' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 285 AS problem_id, '  res.end(pets, "utf8");' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 285);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 286, '咕咕', '🦉', 'Express 回應', 'The browser blocks the request because the Access-Control-Allow-Origin header is missing from the response.', '缺少標頭：前端從另一個網址呼叫 API，瀏覽器說回應裡沒有 Access-Control-Allow-Origin，所以把結果擋掉了。', 'app.use((req, res, next) => {\n  res.header(''Access-Control-Allow-Origins'', ''*'')\n  next()\n})\napp.get(''/api/hello'', (req, res) => {\n  res.json({ msg: ''hi'' })\n})', 2, '【哪裡出錯】標頭名稱多打了一個 s，變成 Access-Control-Allow-Origins，瀏覽器只認 Access-Control-Allow-Origin，所以等於沒設。\n【用生活例子想】就像社區警衛只看住戶名單上的名字，你把名字多寫一個字，警衛找不到就不讓你進門。\n【一句話記住】標頭名稱是固定暗號，少一個字或多一個字都會失效。\n【容易選錯】改成 Access-Control-Allow-Headers 看起來也是 CORS 的標頭，但它是管可以帶哪些標頭，不是管哪個網站可以讀回應，所以 Allow-Origin 還是沒有出現。\n【小字典】CORS：瀏覽器規定不同網站之間讀資料要先被允許的安全規則。標頭 header：隨著回應一起送出的附加資訊。middleware：請求到達路由前會先經過的處理函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 286);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 286 AS problem_id, '  res.header(''Access-Control-Allow-Headers'', ''*'')' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 286 AS problem_id, '  res.header(''Access-Control-Allow-Origins'', ''http://localhost:5173'')' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 286 AS problem_id, '  res.header(''Access-Control-Allow-Origin'', ''*'')' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 286);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 287, '咕咕', '🦉', 'Express 回應', 'Cannot GET /assets/hello.txt', '找不到路徑：檔案明明放在 public 資料夾，網頁用 /assets/hello.txt 去讀卻顯示找不到。', 'const publicDir = path.join(import.meta.dirname, "public");\n// 網頁上要用 /assets/hello.txt 來讀檔案\napp.use(express.static(publicDir));\napp.get("/api/ping", (req, res) => {\n  res.json({ ok: true });\n});', 3, '【哪裡出錯】express.static(publicDir) 沒有寫網址前綴，檔案會直接掛在根路徑，網址是 /hello.txt，不是 /assets/hello.txt。\n【用生活例子想】就像倉庫的貨放在一樓大廳，你卻跟客人說要去「assets 櫃檯」領，客人走到那裡當然找不到。\n【一句話記住】想讓網址多一個前綴，就在 app.use 的第一個參數寫上掛載路徑。\n【容易選錯】app.use("/public", express.static(publicDir)) 看起來有加前綴，但前綴是 /public，檔案網址變成 /public/hello.txt，用 /assets/hello.txt 去讀還是找不到。\n【小字典】express.static：讓 Express 把某個資料夾裡的檔案直接當網頁檔案提供出去。掛載路徑：app.use 第一個參數，代表網址要以什麼開頭才會進到這個 middleware。middleware：請求進來之後、回應出去之前會經過的處理函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 287);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 287 AS problem_id, 'app.use("/assets", express.static(publicDir));' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 287 AS problem_id, 'app.use("/public", express.static(publicDir));' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 287 AS problem_id, 'app.use("/assets", express.static("assets"));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 287);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 288, '咕咕', '🦉', 'Express 回應', 'The response says "Pets of user undefined" instead of "Pets of user 7".', '打開 /api/users/7/pets，回應卻寫「Pets of user undefined」，明明網址裡有 7，卻沒拿到使用者編號。', 'const router = express.Router()\nrouter.get(''/'', (req, res) => {\n  const { userId } = req.params\n  res.json({ message: `Pets of user ${userId}` })\n})\napp.use(''/api/users/:userId/pets'', router)', 1, '【哪裡出錯】:userId 寫在 app.use 掛載的路徑上，但 express.Router() 預設不會把上層的參數交給子路由，所以 req.params 裡沒有 userId，印出來就是 undefined。\n【用生活例子想】就像大樓管理室知道你住幾號房，但櫃台小姐預設不會把房號轉告給你家的訪客接待員，你要先跟她說「請把房號一起帶過去」。\n【一句話記住】子路由想用上層路徑的參數，建立 Router 時要加 { mergeParams: true }。\n【容易選錯】選 { strict: true} 看起來也是在設定 Router，但它只管網址結尾的斜線要不要嚴格比對，跟參數傳遞無關，所以 req.params 裡還是沒有 userId，仍然印出 undefined。\n【小字典】Router：一個小型的路由群組，可以掛到 app 的某個路徑底下。mergeParams：讓子路由也能讀到上層路徑參數的設定。req.params：網址路徑裡冒號參數的值。掛載：把 Router 接到某個網址前綴上。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 288);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 288 AS problem_id, 'const router = express.Router({ strict: true })' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 288 AS problem_id, 'const router = express.Router({ mergeParams: true })' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 288 AS problem_id, 'const router = express.Router({ caseSensitive: true })' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 288);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 289, '咕咕', '🦉', 'Express 回應', 'The response shows nextPage as "21" instead of 3 when requesting /api/items?page=2.', '下一頁的頁碼不對：網址帶 page=2，下一頁應該是 3，畫面卻出現 21。', 'const items = Array.from({ length: 10 }, (_, i) => `item${i + 1}`)\napp.get(''/api/items'', (req, res) => {\n  const page = req.query.page || 1\n  const nextPage = page + 1\n  res.json({ page, nextPage, item: items[page - 1] })\n})', 3, '【哪裡出錯】網址上的 page=2 被 Express 放進 req.query 時是字串 "2"，所以 page + 1 變成字串相加，結果是 "21"。\n【用生活例子想】就像有人在紙條上寫「2」，你把紙條接上「1」，看到的是「21」這兩個字，而不是算出 3。\n【一句話記住】從網址拿到的 query 和 params 一律是字串，要算數學先用 Number() 轉成數字。\n【容易選錯】選 req.query.page ?? 1 很像對的，它只是在沒帶 page 時給預設值 1，但有帶 page 時拿到的還是字串 "2"，page + 1 還是 "21"，所以還是錯。\n【小字典】req.query：網址問號後面的參數，例如 ?page=2。字串：用文字形式存的資料，加號會把它們接在一起。Number()：把文字轉成數字的函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 289);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 289 AS problem_id, '  const page = req.query.page.toString() || 1' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 289 AS problem_id, '  const page = req.query.page ?? 1' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 289 AS problem_id, '  const page = Number(req.query.page) || 1' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 289);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 290, '咕咕', '🦉', 'Express 回應', 'SyntaxError: Unexpected token ''N'', "Not Found" is not valid JSON', 'JSON 解析失敗：找不到寵物時，伺服器回的是純文字 Not Found，前端卻照 JSON 去讀，所以壞掉。', 'const pets = [{ id: 1, name: ''小白'' }, { id: 2, name: ''花花'' }]\napp.get(''/api/pets/:id'', (req, res) => {\n  const pet = pets.find(p => p.id === Number(req.params.id))\n  if (!pet) {\n    return res.sendStatus(404)\n  }\n  res.json(pet)\n})', 5, '【哪裡出錯】res.sendStatus(404) 只會送出狀態碼 404 和純文字 Not Found，不是 JSON，所以前端用 res.json() 讀的時候就解析失敗。\n【用生活例子想】這就像客人點的是一份附表格的報告，店員卻只在紙條上寫「沒有」，客人想照表格讀，當然讀不懂。改用 res.status(404).json(...) 才是把說明寫進表格裡。res.send 文字或 res.end() 也都不是 JSON，一樣讀不了。\n【一句話記住】前端要讀 JSON，錯誤也要用 res.status(...).json(...) 回 JSON。\n【容易選錯】res.status(404).send(''Pet not found'') 看起來有設定狀態碼也有說明文字，但 send 傳字串只會回純文字，前端用 res.json() 讀還是會解析失敗。\n【小字典】sendStatus：只送出狀態碼和對應的簡短文字。JSON：程式之間交換資料的文字格式，例如 {"error":"..."}。解析：把收到的文字轉成程式能用的資料。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 290);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 290 AS problem_id, '    return res.status(404).json({ error: ''Pet not found'' })' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 290 AS problem_id, '    return res.status(404).send(''Pet not found'')' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 290 AS problem_id, '    return res.status(404).end()' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 290);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 291, '咕咕', '🦉', 'Express 回應', 'The request to /api/pets/featured returns status 400 with an id error instead of the featured pet.', '/api/pets/featured 明明有寫路由，卻回傳 400 說 id 必須是數字，沒有看到精選寵物。', 'app.get("/api/pets/:id", (req, res, next) => {\n  if (!/^\\d+$/.test(req.params.id)) {\n    return res.status(400).json({ error: "id must be a number" });\n  }\n  res.json({ id: Number(req.params.id), name: "Mochi" });\n});\napp.get("/api/pets/featured", (req, res) => {\n  res.json({ name: "Rocky", featured: true });\n});', 3, '【哪裡出錯】/api/pets/:id 寫在前面，/api/pets/featured 也會被它接走，因為 featured 會被當成 id。它發現不是數字就直接回 400，後面的 featured 路由根本沒機會執行。\n【用生活例子想】像櫃台人員拿到一張不是自己負責的單子，卻直接退件，而不是轉給隔壁櫃台，隔壁的人當然永遠收不到。\n【一句話記住】這個路由不該處理時，呼叫 next() 把請求交給下一個符合的路由。\n【容易選錯】改成 res.status(404).json(...) 最像對的，但它還是自己回應了，請求一樣不會交給 featured 路由，只是 400 變成 404。\n【小字典】next：把請求交給下一個處理者的函式。路由順序：Express 由上往下找第一個符合的路由。params：網址裡冒號後面的變數，例如 :id。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 291);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 291 AS problem_id, '    return res.status(404).json({ error: "pet not found" });' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 291 AS problem_id, '    return next();' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 291 AS problem_id, '    return next(new Error("not a pet id"));' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 291);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 292, '咕咕', '🦉', 'Express 回應', 'The client receives status 204 with an empty body instead of the todo data.', '拿不到資料：伺服器看起來有成功回應，但前端收到的內容是空的，沒有待辦事項。', 'const todos = [{ id: 1, title: "買牛奶" }, { id: 2, title: "寫作業" }]\napp.get("/api/todos/:id", (req, res) => {\n  const todo = todos.find((t) => t.id === Number(req.params.id))\n  if (!todo) {\n    return res.status(404).json({ error: "Not found" })\n  }\n  res.status(204).json(todo)\n})', 7, '【哪裡出錯】第 7 行用了 204 狀態碼，204 的意思是「成功了，但沒有內容」，所以 Express 會把回應內容丟掉，前端只收到空的。\n【用生活例子想】就像你去櫃檯問資料，店員先對你說「辦好了，沒有東西要給你」，然後才遞出一張紙，你根本不會收到那張紙。\n【一句話記住】要回傳資料就用 200，204 是專門給「不需要回傳東西」的情況。\n【容易選錯】改成 res.status(204).send(todo) 看起來換了送資料的方法，但狀態碼還是 204，內容一樣會被丟掉，前端還是收到空的。\n【小字典】狀態碼：伺服器用數字告訴前端結果如何。204：成功但沒有內容。200：成功並且有內容。回應內容：前端收到的資料本體，英文叫 body。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 292);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 292 AS problem_id, '  res.status(204).send(todo)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 292 AS problem_id, '  res.status(304).json(todo)' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 292 AS problem_id, '  res.status(200).json(todo)' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 292);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 293, '咕咕', '🦉', 'Express 回應', 'TypeError: Do not know how to serialize a BigInt', '無法序列化 BigInt：金額是用 BigInt 算出來的，直接丟給 res.json 就報錯，API 回 500。', 'const orders = [{ id: 1, cents: 1250n }, { id: 2, cents: 830n }]\napp.get(''/api/orders/total'', (req, res) => {\n  let total = 0n\n  for (const order of orders) {\n    total += order.cents\n  }\n  res.json({ total })\n})', 7, '【哪裡出錯】total 是 BigInt（數字後面加 n），res.json 內部用 JSON.stringify，而 JSON 不認得 BigInt，所以直接丟出錯誤。\n【用生活例子想】就像寄包裹的郵局只收紙箱，你拿一個特殊形狀的容器去寄，櫃台會說無法處理，要先把東西裝進紙箱（轉成字串）才寄得出去。\n【一句話記住】要用 res.json 送 BigInt，先用 toString() 或 Number() 轉掉。\n【容易選錯】寫 total.valueOf() 看起來像是在取出真正的值，但 BigInt 的 valueOf 還是回傳 BigInt，res.json 照樣報同一個錯。\n【小字典】BigInt：可以存超大整數的型別，數字後面加 n。JSON：網路上傳資料常用的文字格式，只認字串、數字、布林、陣列、物件和 null。序列化：把資料變成可以傳送的文字。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 293);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 293 AS problem_id, '  res.json({ total: total.toString() })' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 293 AS problem_id, '  res.json({ total: total.valueOf() })' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 293 AS problem_id, '  res.json({ total: BigInt(total) })' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 293);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 294, '咕咕', '🦉', 'Express 回應', 'POST /api/pets returns status 200 with the old pet list and no new pet is added.', '送出新增寵物的 POST 請求後，回來的卻是舊的寵物清單，狀態碼也不是 201，新寵物沒有被加進去。', 'const pets = ["Mimi", "Coco"];\napp.use(express.json());\napp.use("/api/pets", (req, res) => {\n  res.json(pets);\n});\napp.post("/api/pets", (req, res) => {\n  pets.push(req.body.name);\n  res.status(201).json(pets);\n});', 3, '【哪裡出錯】第 3 行用了 app.use，它不管 GET 還是 POST 都會接，所以 POST 請求在第一個處理函式就被回應掉了，第 6 行的 app.post 永遠輪不到。\n【用生活例子想】就像門口的櫃台人員不分你是來查詢還是來辦理，一律先遞給你一份名單，後面真正辦理的窗口你根本走不到。\n【一句話記住】想只處理 GET 就寫 app.get，app.use 是全部方法都收。\n【容易選錯】app.all 看起來比較明確，但它的意思是所有方法都接，POST 還是會被第一個處理函式攔走，回來的還是舊清單。\n【小字典】app.use：掛上 middleware，不限制請求方法，路徑前綴符合就會執行。app.get：只處理 GET 請求。app.all：同一個路徑下所有 HTTP 方法都會處理。路由：網址加上請求方法對應到的處理函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 294);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 294 AS problem_id, 'app.all("/api/pets", (req, res) => {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 294 AS problem_id, 'app.get("/api/pets", (req, res) => {' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 294 AS problem_id, 'app.use("/api/pets/", (req, res) => {' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 294);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 295, '咕咕', '🦉', 'Express 回應', 'Error: ENOENT: no such file or directory, open ''notes/ghost.txt''', '錯誤丟在 callback 裡：Express 接不到這種錯誤，要找的檔案不存在時整個伺服器就直接當掉了。', 'import { readFile } from "node:fs";\napp.get("/api/notes/:name", (req, res, next) => {\n  readFile(`notes/${req.params.name}.txt`, "utf8", (err, text) => {\n    if (err) throw err;\n    res.json({ text });\n  });\n});\napp.use((err, req, res, next) => {\n  res.status(404).json({ error: "Note not found" });\n});', 4, '【哪裡出錯】readFile 的 callback 是之後才被呼叫的，這時 Express 早就離開路由函式了，所以 throw err 沒人接，整個程式崩潰。要用 next(err) 把錯誤交給下面的錯誤處理 middleware。\n【用生活例子想】你在餐廳廚房做菜，菜燒焦了，不能自己大叫然後衝出去，要把盤子交給店長（next），由店長決定怎麼跟客人道歉。\n【一句話記住】callback 裡出錯不要 throw，要 return next(err)。\n【容易選錯】「if (err) next(err);」最像正確答案，但少了 return。錯誤處理 middleware 會先回應 404，然後程式又繼續往下跑到 res.json，等於回應第二次，結果又丟出 headers 已經送出的錯誤，伺服器還是會崩潰。\n【小字典】callback：事情做完以後才會被呼叫的函式。next(err)：把錯誤交給 Express 的錯誤處理 middleware。throw：丟出錯誤，沒人接住程式就會崩潰。return：結束目前的函式，後面的程式就不會再執行。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 295);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 295 AS problem_id, '    if (err) next(err);' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 295 AS problem_id, '    if (err) return console.error(err.message);' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 295 AS problem_id, '    if (err) return next(err);' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 295);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 296, '咕咕', '🦉', 'Express 回應', 'PayloadTooLargeError: request entity too large', '請求太大：伺服器說送來的資料超過上限，但其實只是一篇很普通的筆記文字。', 'app.use(express.json({ limit: 100 }))\napp.post("/api/notes", (req, res) => {\n  const { title, content } = req.body\n  if (!title) {\n    return res.status(400).json({ error: "title is required" })\n  }\n  const note = { id: 1, title, content }\n  console.log("saved note", note.title)\n  res.status(201).json(note)\n})', 1, '【哪裡出錯】第 1 行的 limit: 100 沒有寫單位，Express 會當成 100 bytes，所以只要請求內容超過 100 個字元大小，在到達第 2 行的路由之前就被擋下來，回 413。\n【用生活例子想】就像宅配櫃的格子只有手機盒那麼大，你卻想放一整箱書，櫃子還沒打開就說放不下。你以為寫的是 100 公斤，其實櫃子認的是 100 公克。\n【一句話記住】limit 只寫數字就是 bytes，想要 KB 或 MB 就要寫成 "100kb" 或 "1mb" 這種字串。\n【容易選錯】改成 limit: 1000 看起來放寬很多，但它還是 1000 bytes，約 1KB，而這篇筆記有 1500 個字元，所以還是 413。\n【小字典】limit：body 解析器允許的請求內容大小上限。bytes：位元組，電腦計算資料大小的最小常用單位。413：HTTP 狀態碼，代表請求內容太大。middleware：請求進到路由之前先經過的處理函式。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 296);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 296 AS problem_id, 'app.use(express.json({ limit: "100kb" }))' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 296 AS problem_id, 'app.use(express.json({ limit: 1000 }))' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 296 AS problem_id, 'app.use(express.json({ limit: "100" }))' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 296);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 297, '咕咕', '🦉', 'Express 回應', 'TypeError: path must be absolute or specify root to res.sendFile', '路徑必須是絕對路徑：sendFile 要收完整的檔案位置，你卻給了相對路徑，所以請求直接變成 500。', 'import path from ''node:path''\nconst FILE_NAME = ''report.txt''\nconst reportFile = path.join(''public'', FILE_NAME)\napp.get(''/report'', (req, res) => {\n  console.log(''sending'', FILE_NAME)\n  res.type(''text/plain'')\n  res.sendFile(reportFile)\n})', 3, '【哪裡出錯】第 3 行用 path.join(''public'', FILE_NAME) 只組出 public/report.txt 這種相對路徑，到第 7 行 res.sendFile 才被拒絕，所以錯誤出現的地方和原因不在同一行。\n【用生活例子想】就像叫外送員去「文具店隔壁」，他不知道你從哪裡出發，一定要給完整地址他才找得到。\n【一句話記住】res.sendFile 要的是從根目錄開始的完整路徑，可以用 import.meta.dirname 當起點接上去。\n【容易選錯】path.join(''/public'', FILE_NAME) 看起來像絕對路徑所以不再丟錯，但它指向電腦最外層的 /public 資料夾，那裡沒有檔案，結果變成 404 找不到。\n【小字典】相對路徑：從目前所在位置開始算的路徑。絕對路徑：從根目錄開始的完整路徑。path.join：把幾段路徑接成一條。import.meta.dirname：目前這個檔案所在資料夾的完整路徑。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 297);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 297 AS problem_id, 'const reportFile = path.join(''/public'', FILE_NAME)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 297 AS problem_id, 'const reportFile = path.join(import.meta.dirname, ''public'', FILE_NAME)' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 297 AS problem_id, 'const reportFile = path.join(''./public'', FILE_NAME)' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 297);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 298, '咕咕', '🦉', 'Express 回應', 'A request without an API key still returns the reports with status 200 instead of 401.', '沒帶 API key 的請求照樣拿到報表資料，應該要被擋下來回 401 才對。', 'const requireKey = (req, res, next) => {\n  if (req.get(''x-api-key'') !== ''secret123'') {\n    return res.status(401).json({ error: ''Missing API key'' })\n  }\n  next()\n}\n\napp.get(''/api/reports'', (req, res) => {\n  res.json({ reports: [''Q1'', ''Q2''] })\n})', 8, '【哪裡出錯】requireKey 只是被定義出來，並沒有放進 /api/reports 這條路由，所以請求進來時根本沒人檢查 API key。\n【用生活例子想】就像社區請了警衛，卻沒有讓他站在大門口，訪客照樣直接走進去。\n【一句話記住】middleware 寫好還不夠，一定要掛在路由前面，請求才會先經過它。\n【容易選錯】寫成 requireKey() 看起來像在呼叫檢查，但這樣會在沒有 req 的情況下立刻執行，程式一啟動就報錯，也不是把它交給 Express 去用。\n【小字典】middleware：請求到達路由之前先經過的檢查站。API key：用來證明你有權限的一串密碼。401：代表沒有通過身分驗證的狀態碼。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 298);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 298 AS problem_id, 'app.get(''/api/reports'', requireKey(), (req, res) => {' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 298 AS problem_id, 'app.get(''/api/reports'', (req, res, requireKey) => {' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 298 AS problem_id, 'app.get(''/api/reports'', requireKey, (req, res) => {' AS option_text, TRUE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 298);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 299, '咕咕', '🦉', 'Express 回應', 'The pet list response body is {} instead of an array of pets.', '回應是空的：API 回了 200，但前端拿到的內容是 {}，寶物清單一隻寵物都沒有。', 'const petsById = new Map()\npetsById.set(''p1'', { id: ''p1'', name: ''Mochi'' })\npetsById.set(''p2'', { id: ''p2'', name: ''Coco'' })\n\napp.get(''/api/pets'', (req, res) => {\n  const count = petsById.size\n  res.set(''X-Pet-Count'', String(count))\n  res.json(petsById)\n})', 8, '【哪裡出錯】第 8 行把 Map 直接丟給 res.json，JSON 不認得 Map，Map 裡的資料不會被轉出來，所以變成 {}。\n【用生活例子想】Map 像一個上鎖的置物櫃，JSON 這台影印機只會影印攤開在桌上的紙，櫃子裡的東西要先拿出來排好才印得到。\n【一句話記住】res.json 只認得陣列和一般物件，Map 要先用 [...map.values()] 攤成陣列。\n【容易選錯】Array.from(petsById) 看起來有轉成陣列，但每一項是 [鍵, 值] 的小陣列，前端會拿到 [["p1",{...}],...]，格式還是不是寵物清單。\n【小字典】Map：一種用鍵找值的資料結構。JSON：傳資料用的文字格式。展開運算子 ...：把集合裡的東西一個一個攤開。values()：只取出 Map 裡所有的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 299);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 299 AS problem_id, '  res.json([...petsById.values()])' AS option_text, TRUE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 299 AS problem_id, '  res.json(petsById.values())' AS option_text, FALSE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 299 AS problem_id, '  res.json(Array.from(petsById))' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 299);
INSERT INTO problems (id, pet_name, emoji, topic, error_message, symptom_zh, code, bug_line, explanation)
SELECT 300, '咕咕', '🦉', 'Express 回應', 'A request with a wrong token still returns status 200 with the name shown as {} instead of status 401.', '拿錯誤的 token 去打 /api/me，應該被擋下來，卻回了 200，而且 name 是空物件，沒有被擋住。', 'async function findUser(token) {\n  const users = { abc123: ''Mina'' }\n  return users[token] ?? null\n}\napp.get(''/api/me'', async (req, res) => {\n  const user = findUser(req.headers[''x-token''])\n  if (!user) {\n    return res.status(401).json({ error: ''Unauthorized'' })\n  }\n  res.json({ name: user })\n})', 6, '【哪裡出錯】findUser 是 async 函式，不加 await 拿到的是 Promise 物件，不是使用者名字，而 Promise 永遠是真值，所以 if (!user) 永遠不成立，沒人會被擋下來。\n【用生活例子想】就像你請朋友去查名單，他還沒回來你就拿著他給你的「查詢單」說：我拿到結果了。查詢單本身永遠存在，但上面還沒有答案。\n【一句話記住】呼叫 async 函式想要拿到結果，一定要在前面加 await。\n【容易選錯】加上 .then(u => u) 看起來像在處理結果，但整行的值還是一個 Promise，user 一樣是真值，驗證還是被跳過。\n【小字典】Promise：代表一件還沒做完的事，之後才會有結果的物件。await：等 Promise 完成並拿出裡面的值。真值：在 if 判斷裡會被當成 true 的值。'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM problems WHERE id = 300);
INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order)
SELECT * FROM (
  SELECT 300 AS problem_id, '  const user = findUser(req.headers[''x-token'']).then(u => u)' AS option_text, FALSE AS is_correct, 1 AS sort_order
  UNION ALL
  SELECT 300 AS problem_id, '  const user = await findUser(req.headers[''x-token''])' AS option_text, TRUE AS is_correct, 2 AS sort_order
  UNION ALL
  SELECT 300 AS problem_id, '  const user = await findUser' AS option_text, FALSE AS is_correct, 3 AS sort_order
) AS o WHERE NOT EXISTS (SELECT 1 FROM problem_options WHERE problem_id = 300);

SELECT pet_name, COUNT(*) AS 題數 FROM problems GROUP BY pet_name;
