// 10 個主題：每個主題要涵蓋的觀念方向，和建議的驗證方式
export type Topic = {
  key: string
  pet_name: string
  emoji: string
  topic: string
  guide: string
}

export const topics: Topic[] = [
  {
    key: 'ts',
    pet_name: '小橘',
    emoji: '🐱',
    topic: 'TypeScript 型別',
    guide: `TypeScript 編譯錯誤。runner 用 "tsc"（strict 模式、lib 有 es2022 和 dom），code_path 用 main.ts。
error_message 要跟 tsc 印出來的訊息完全一樣（不含檔名、行號和 error TSxxxx 前綴）。
可以涵蓋：函式回傳型別、陣列元素型別、泛型、interface 繼承、readonly、never 與窮舉檢查、keyof、型別縮小、tuple、函式參數個數、enum、可選鏈搭配型別、unknown 要先檢查、類別屬性初始化、import type 等。`,
  },
  {
    key: 'async',
    pet_name: '慢慢',
    emoji: '🐢',
    topic: '非同步 await',
    guide: `JavaScript 非同步。runner 用 "node"，code_path 用 main.mjs。
需要假資料或 fetch 時，在 before 裡用 globalThis.fetch = async (url) => ({ ok: true, json: async () => ... }) 之類的方式模擬，不要連外網。setTimeout 的時間不要超過 300 毫秒。
可以涵蓋：forEach 裡 await 不會等、Promise.all、沒有 return 的 Promise、try/catch 接不到沒 await 的錯誤、async 函式回傳 Promise、迴圈裡依序 await 和平行、then 鏈忘記 return、setTimeout 包 Promise、Promise.race、finally、錯誤沒處理變成 unhandled rejection 等。`,
  },
  {
    key: 'module',
    pet_name: '跳跳',
    emoji: '🐰',
    topic: '模組路徑',
    guide: `模組 import/export 和路徑。runner 用 "node"，題目程式碼是其中一個檔案（code_path，例如 main.mjs 或 src/app.mjs），其他檔案放在 files（例如 utils/math.mjs、package.json）。
可以用 entry 指定要執行哪個檔案。錯誤訊息要是 node 真的會印出來的（例如 ERR_MODULE_NOT_FOUND、does not provide an export named）。
可以涵蓋：相對路徑的 ./ 和 ../、副檔名、default 和 named export 搞混、export 拼錯、CommonJS 和 ESM 混用、require 在 ESM 裡不能用、資料夾 index、package.json 的 type、import 大小寫、重複宣告、循環 import 拿到 undefined 等。
真的只能在 Next.js 或打包工具才會出現的錯誤，runner 用 "review"。`,
  },
  {
    key: 'react-key',
    pet_name: '嚕嚕',
    emoji: '🐹',
    topic: 'React 列表 key',
    guide: `React 列表渲染（map、key、條件渲染、JSX 規則）。code_path 用 main.jsx，runner 用 "node"：after 裡 import { renderToString } from 'react-dom/server' 然後 console.log(renderToString(<元件 />))，渲染時的錯誤和警告都會印出來。
React 是 19 版，警告訊息開頭沒有 Warning:，例如 Each child in a list should have a unique "key" prop.。
要點擊或 useEffect 之後才會看到的問題，renderToString 看不到，runner 改用 "review"。renderToString 也不會報 key 重複（Encountered two children with the same key），這類題目同樣用 "review"。
題目一定要跟「把資料渲染成列表」有關：用 map 產生清單、key、清單裡的條件渲染、清單資料的格式。跟列表無關的 JSX 規則（className、style 物件、單一根元素）不要出。
可以涵蓋：key 放錯元素、key 用了會變的值、map 沒有 return、清單筆數用 && 判斷遇到 0、清單項目是物件不能直接渲染、資料不是陣列、Fragment 要加 key、filter 和 map 順序、巢狀列表的 key、用 index 當 key 造成刪除後狀態錯位等。`,
  },
  {
    key: 'react-state',
    pet_name: '阿福',
    emoji: '🐶',
    topic: 'React 狀態',
    guide: `React useState、props、事件。code_path 用 main.jsx。
渲染時就會出錯的（例如 Too many re-renders、在 render 裡呼叫 setState、onClick={handle()}、hook 放在條件裡、props 拼錯造成 undefined），runner 用 "node"，after 裡用 react-dom/server 的 renderToString 渲染。
要點擊才看得到的問題（直接改 state 陣列、連續 setCount(count + 1)、state 更新後馬上讀到舊值、物件 state 只更新一部分、受控 input 沒有 onChange、事件處理函式傳錯參數），runner 用 "review"，而且要佔一半以上。
題目一定要考 state、props 或事件處理。列表和 key、map 沒有 return、&& 遇到 0、物件不能直接渲染這些是嚕嚕（React 列表 key）的主題，這裡不要出。`,
  },
  {
    key: 'loop',
    pet_name: '企企',
    emoji: '🐧',
    topic: '迴圈邊界',
    guide: `JavaScript 迴圈和陣列邊界。runner 用 "node"，code_path 用 main.mjs，用 console.log 印出結果。
無窮迴圈的題目 expect_buggy 填 "TIMEOUT"。
可以涵蓋：off-by-one、<= length、從 1 開始、倒著跑、slice 和 splice 的結尾不包含、while 忘記更新條件、break 和 continue、巢狀迴圈用錯變數、for...in 和 for...of、邊跑邊刪除元素、累加器初始值、分頁計算、二維陣列等。`,
  },
  {
    key: 'coerce',
    pet_name: '狐狐',
    emoji: '🦊',
    topic: '型別轉換',
    guide: `JavaScript 隱性型別轉換。runner 用 "node"，code_path 用 main.mjs，用 console.log 印出結果。
可以涵蓋：字串加數字、== 和 ===、parseInt 少了進位制或遇到小數、Number('') 是 0、NaN 不等於自己、truthy/falsy（'0'、[]、空字串）、sort 預設照字串排序、toFixed 回傳字串、JSON 數字變字串、日期字串比較、Boolean('false')、input 的值永遠是字串等。`,
  },
  {
    key: 'fetch',
    pet_name: '圓圓',
    emoji: '🐼',
    topic: 'fetch 與 JSON',
    guide: `前端 fetch 和 JSON。runner 用 "node"，code_path 用 main.mjs。
後端用 before 起一個 express（import express from 'express'，app.listen(0)，等它開好），再把 globalThis.fetch 包一層，讓 fetch("/api/...") 這種相對路徑接到這個 server。
瀏覽器才有的錯誤字串（例如 Failed to execute 'fetch' on 'Window'、Unexpected token '<', "<!DOCTYPE "...）node 印出來的字不一樣：error_message 可以寫瀏覽器的版本，但 message_from_run 要填 false，expect_buggy 填 node 真的會印出的關鍵字。
可以涵蓋：忘記 await res.json()、沒有設定 Content-Type、body 沒有 JSON.stringify、res.ok 沒檢查、HTTP 方法錯、網址拼錯、query string 沒編碼、回傳格式包在 data 裡、json() 讀兩次、204 沒有內容卻呼叫 json()、headers 拼錯、Authorization 格式等。`,
  },
  {
    key: 'sql',
    pet_name: '熊熊',
    emoji: '🐻',
    topic: 'SQL 語法',
    guide: `MySQL 8.4。大部分題目的 code 是 SQL 查詢，runner 用 "sql"：db_setup 放 CREATE TABLE 和 INSERT（每次都是全新的空資料庫），code 是有 bug 的 SQL，最後一句 SELECT 的結果會印出來。
錯誤訊息格式是 ERROR 1054 (42S22): Unknown column 'x' in 'where clause' 這種。邏輯錯誤（結果不對）的題目 expect_buggy 和 expect_fixed 填結果裡會出現的字。
也可以出 Node.js 搭配 mysql2 的題目：runner 用 "node"，db_setup 照樣建表，before 裡 import mysql from 'mysql2/promise'，用 mysql.createPool(process.env.CHECK_DB_URL) 連線。
可以涵蓋：WHERE 和 HAVING、GROUP BY、NULL 要用 IS NULL、LIKE 萬用字元、JOIN 條件、LEFT JOIN 後 WHERE 篩掉、ORDER BY 加 LIMIT、字串要加引號、保留字當欄位名、COUNT(*) 和 COUNT(欄位)、UPDATE 忘記 WHERE、INSERT 欄位數不合、子查詢回傳多筆、placeholder 用法、DISTINCT 等。`,
  },
  {
    key: 'express',
    pet_name: '咕咕',
    emoji: '🦉',
    topic: 'Express 回應',
    guide: `Express 後端路由。runner 用 "node"，code_path 用 main.mjs。
before 放 import express from 'express' 和 const app = express()（題目程式碼裡就不要再寫一次）；題目程式碼不要呼叫 app.listen。
after 用 const server = app.listen(0) 開 server，用 fetch 加 AbortSignal.timeout(1500) 打 API，印出狀態碼和回應內容，逾時就印出 NO RESPONSE，最後 server.close() 再 process.exit(0)。
可以涵蓋：忘記回應、回應兩次、status 和 json 的順序、沒有 express.json()、路由順序（/:id 在 /new 前面）、params 和 query 搞混、next 用法、錯誤處理 middleware 參數要四個、async 錯誤沒接、res.send 數字、CORS 標頭、靜態檔路徑、router 掛載路徑等。`,
  },
]
