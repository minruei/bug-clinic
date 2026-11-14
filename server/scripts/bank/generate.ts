// 題庫擴充：每個主題出新題，驗證通過才收進 out/batch-N.json，沒過的記在 out/rejects-N.json
// 執行：BANK_WORK_DIR=暫存資料夾 npx tsx scripts/bank/generate.ts --batch 1 --per-topic 10
process.loadEnvFile('.env')
import Anthropic from '@anthropic-ai/sdk'
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { parseArgs } from 'node:util'
import { loadExisting } from './existing'
import { mostSimilar } from './similar'
import { topics, type Topic } from './topics'
import { verify, type Draft, type Verified } from './verify'

const { values: args } = parseArgs({
  options: {
    batch: { type: 'string', default: '1' },
    'per-topic': { type: 'string', default: '10' },
    topics: { type: 'string', default: '' },
    'max-usd': { type: 'string', default: '12' },
    revise: { type: 'boolean', default: false },
  },
})

const MODEL = 'claude-sonnet-5-5'
// 美元／每百萬 token
const PRICE = { input: 2, output: 10, cacheWrite: 2.5, cacheRead: 0.1 }
const OUT = resolve(__dirname, 'out')
const DB_DIR = resolve(__dirname, '../../db')
const batch = args.batch
const perTopic = Number(args['per-topic'])
const maxUsd = Number(args['max-usd'])
// 每批的難度分配：淺 3、中 4、深 3
const LEVELS = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3]

export type Accepted = Draft & {
  topic_key: string
  pet_name: string
  emoji: string
  topic: string
  batch: string
  verified: Verified
  review: string[]
  revised?: boolean
}
type Rejected = {
  topic_key: string
  batch: string
  stage: string
  reasons: string[]
  draft?: Draft
}

mkdirSync(OUT, { recursive: true })
const readJson = <T>(file: string, fallback: T): T =>
  existsSync(join(OUT, file)) ? JSON.parse(readFileSync(join(OUT, file), 'utf8')) : fallback
const save = (file: string, data: unknown) =>
  writeFileSync(join(OUT, file), JSON.stringify(data, null, 2))

const accepted: Accepted[] = readJson(`batch-${batch}.json`, [])
const rejected: Rejected[] = readJson(`rejects-${batch}.json`, [])
const cost = readJson('cost.json', {
  usd: 0,
  input: 0,
  output: 0,
  cacheWrite: 0,
  cacheRead: 0,
  calls: 0,
})
// 其他批次已經收的題目也要拿來比對
const otherBatches: Accepted[] = ['1', '2']
  .filter((b) => b !== batch)
  .flatMap((b) => readJson<Accepted[]>(`batch-${b}.json`, []))
const existing = loadExisting(DB_DIR)

const client = new Anthropic()

function addUsage(u: Anthropic.Usage) {
  const write = u.cache_creation_input_tokens ?? 0
  const read = u.cache_read_input_tokens ?? 0
  cost.input += u.input_tokens
  cost.output += u.output_tokens
  cost.cacheWrite += write
  cost.cacheRead += read
  cost.calls++
  cost.usd +=
    (u.input_tokens * PRICE.input +
      u.output_tokens * PRICE.output +
      write * PRICE.cacheWrite +
      read * PRICE.cacheRead) /
    1e6
  save('cost.json', cost)
}

const str = { type: 'string' }
const draftSchema = {
  type: 'object',
  additionalProperties: false,
  required: [
    'concept',
    'difficulty',
    'error_message',
    'symptom_zh',
    'code',
    'bug_line',
    'explanation',
    'options',
    'check',
  ],
  properties: {
    concept: str,
    difficulty: { type: 'integer' },
    error_message: str,
    symptom_zh: str,
    code: str,
    bug_line: { type: 'integer' },
    explanation: str,
    options: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['text', 'correct'],
        properties: { text: str, correct: { type: 'boolean' } },
      },
    },
    check: {
      type: 'object',
      additionalProperties: false,
      required: [
        'runner',
        'code_path',
        'files',
        'before',
        'after',
        'entry',
        'db_setup',
        'expect_buggy',
        'expect_fixed',
        'message_from_run',
      ],
      properties: {
        runner: { type: 'string', enum: ['tsc', 'node', 'sql', 'review'] },
        code_path: str,
        files: {
          type: 'array',
          items: {
            type: 'object',
            additionalProperties: false,
            required: ['path', 'content'],
            properties: { path: str, content: str },
          },
        },
        before: str,
        after: str,
        entry: str,
        db_setup: str,
        expect_buggy: str,
        expect_fixed: str,
        message_from_run: { type: 'boolean' },
      },
    },
  },
}

const reviewSchema = {
  type: 'object',
  additionalProperties: false,
  required: ['ok', 'problems', 'suggestions'],
  properties: {
    ok: { type: 'boolean' },
    problems: { type: 'array', items: str },
    suggestions: { type: 'array', items: str },
  },
}

const RULES = `你是程式除錯練習遊戲「Bug Clinic」的出題老師，玩家是剛學程式的初學者（大學生或轉職者）。
每一題是一隻生病的動物：玩家先看症狀，點出 bug 在哪一行，再從三個修法裡選一個。

出題規則：
1. code 是 3 到 12 行，只有 bug_line 那一行有錯（行號從 1 開始）。程式碼要像真實專案會寫的樣子，變數名稱用英文，字串內容可以用中文。
2. options 是三個「整行替換」的寫法：玩家選了之後，bug_line 那一行會整行換成選項的文字，所以選項要包含原本的縮排、是完整的一行。
3. 只有一個 correct 是 true。兩個錯誤選項要看起來合理，而且換上去之後真的還是錯的（還是報錯、結果還是不對），不能只是「寫法比較不好但其實能跑」。三個選項都不能跟原本那一行一模一樣。
4. error_message 只能用英文，不能出現任何中文字（程式印出中文的話，用英文描述現象）：真的錯誤訊息就照實際格式寫；邏輯錯誤就用一句英文描述畫面上看到的現象，例如 The cart total shows 1005 instead of 105.。
5. symptom_zh 是給初學者看的中文說明，一兩句，不超過 80 字。真的錯誤訊息就用「重點：白話說明」的格式，例如「參數型別不合：這個函式要收數字，你卻傳了文字進去」；現象描述就直接用中文描述現象。
6. explanation 用台灣繁體中文，國中生聽得懂，剛好五行，用換行隔開，每行開頭依序是【哪裡出錯】【用生活例子想】【一句話記住】【容易選錯】【小字典】。【容易選錯】挑最像正確答案的那個錯誤選項，說明換上去會發生什麼、為什麼還是不對。【小字典】解釋 2 到 4 個名詞，格式是「名詞：解釋。」。
7. 不要用破折號，不要用 emoji。
8. concept 用一句中文短語寫這題考的觀念（例如「forEach 裡的 await 不會等」）。
9. 題目考的觀念一定要屬於這個主題，不能借用其他主題的觀念。
10. 玩家看到的 code 要能完整說明輸出：呼叫函式、console.log 印出結果都要寫在 code 裡。before / after 只能放模擬環境的東西（假資料、mock fetch、起 server、送 HTTP 請求、渲染 React 元件、關掉 server），不能偷偷呼叫題目裡的函式或印出結果。

難度：
1 淺：錯誤很直接，看錯誤訊息就知道哪一行，3 到 6 行。
2 中：要懂這個觀念才看得出來，5 到 9 行。
3 深：錯誤出現的地方和原因不在同一行，或是邏輯錯誤要想一下，7 到 12 行。

check 欄位是給自動驗證用的，玩家看不到：
- runner："tsc" 用 TypeScript 編譯檢查；"node" 用 Node.js 24 執行；"sql" 在 MySQL 8.4 執行；"review" 不執行，只交給人工審核（只有真的沒辦法在 node 重現時才用）。
- code_path：題目程式碼存成哪個檔案。
- files：其他需要的檔案（路徑和內容），沒有就給空陣列。
- before / after：執行時接在題目程式碼前面和後面的程式（ESM，可以用 import 和 top-level await），只能放模擬環境的東西（見規則 10）。沒有就給空字串。
- entry：要執行的檔案，空字串代表執行 code_path。
- db_setup：先在全新的空資料庫執行的 SQL（建表、放資料），沒有就給空字串。
- expect_buggy：有 bug 的版本執行後，輸出（stdout 加 stderr）裡一定會出現的一段文字；無窮迴圈或永遠等不到結果填 "TIMEOUT"（執行超過 8 秒會被中止）。
- expect_fixed：換上正確選項後輸出裡一定會出現的文字（例如正確的結果），只要求不報錯就給空字串。正確版本的輸出不能包含 expect_buggy。
- message_from_run：error_message 是不是跟執行時印出來的一字不差（tsc 題一定是 true）。
驗證時會真的跑：有 bug 的版本、換上正確選項的版本、換上兩個錯誤選項的版本。錯誤選項的版本如果也能通過，這題就會被退回。

只回傳 JSON。`

function topicSystem(t: Topic) {
  const list = existing
    .filter((p) => p.pet_name === t.pet_name)
    .map((p) => {
      const fix = p.options.find((o) => o.correct)?.text.trim()
      return `#${p.id} 症狀：${p.error_message}\n${p.code}\n正確修法：${fix}`
    })
    .join('\n\n')
  return `${RULES}

主題：${t.pet_name}（${t.topic}）
${t.guide}

這個主題已經有下面這些題目，新題目的觀念和程式碼都不能跟它們重複：
${list}`
}

async function ask<T>(
  system: string,
  user: string,
  schema: Record<string, unknown>,
  effort: 'medium' | 'high',
) {
  const res = await client.messages.create({
    model: MODEL,
    max_tokens: 16000,
    system: [{ type: 'text', text: system, cache_control: { type: 'ephemeral' } }],
    messages: [{ role: 'user', content: user }],
    output_config: { effort, format: { type: 'json_schema', schema } },
  })
  addUsage(res.usage)
  if (res.stop_reason !== 'end_turn') throw new Error(`stop_reason ${res.stop_reason}`)
  const block = res.content.find((b) => b.type === 'text')
  return JSON.parse(block && block.type === 'text' ? block.text : '') as T
}

// sandbox 和 MySQL 一次只跑一題，避免互相干擾
let queue: Promise<unknown> = Promise.resolve()
function serial<T>(fn: () => Promise<T>): Promise<T> {
  const next = queue.then(fn, fn)
  queue = next.catch(() => {})
  return next
}

function sameTopic(t: Topic) {
  return [
    ...existing.filter((p) => p.pet_name === t.pet_name),
    ...otherBatches.filter((p) => p.topic_key === t.key),
    ...accepted.filter((p) => p.topic_key === t.key),
  ]
}

// 這些主題的題目程式碼自己就能跑完，after 不需要放東西
const NO_AFTER = ['ts', 'async', 'module', 'loop', 'coerce']

function otherTopics(t: Topic) {
  return [
    ...existing.filter((p) => p.pet_name !== t.pet_name),
    ...otherBatches.filter((p) => p.topic_key !== t.key),
    ...accepted.filter((p) => p.topic_key !== t.key),
  ]
}

function similarIssue(t: Topic, d: Draft) {
  if (NO_AFTER.includes(t.key) && d.check.after.trim())
    return '呼叫函式和印出結果要寫在題目程式碼裡，after 要留空'
  const other = mostSimilar(d.code, otherTopics(t))
  if (other && other.score >= 0.5)
    return `程式碼跟其他主題的題目太像（相似度 ${other.score.toFixed(2)}）`
  const best = mostSimilar(d.code, sameTopic(t))
  if (!best) return null
  const head = (s: string) => s.toLowerCase().replace(/\W+/g, ' ').slice(0, 40)
  if (best.score >= 0.5) return `程式碼跟同主題題目太像（相似度 ${best.score.toFixed(2)}）`
  if (best.score >= 0.3 && head(best.item.error_message) === head(d.error_message))
    return `症狀相同且程式碼相似（相似度 ${best.score.toFixed(2)}）`
  return null
}

// self 是改寫中的那一題，不能拿自己的舊版本來比
type Review = { ok: boolean; problems: string[]; suggestions: string[] }

async function review(t: Topic, d: Draft, v: Verified, self?: Accepted) {
  const others = sameTopic(t)
    .filter((p) => p !== self)
    .map((p) => `- ${p.error_message}｜${p.code.split('\n').slice(0, 3).join(' ')}`)
    .join('\n')
  const run =
    v.mode === 'run'
      ? `這題已經真的執行過：
有 bug 的版本輸出：
${v.buggy?.out}
換上正確選項的輸出：
${v.fixed?.out}
換上兩個錯誤選項的輸出：
${v.wrong?.map((w) => w.out).join('\n---\n')}`
      : '這題沒有辦法自動執行，請你在腦中仔細執行每個版本來判斷。'
  const system = `你是程式除錯練習遊戲的審題老師，負責把關另一位老師出的題目。
檢查：
1. bug_line 那一行真的是錯誤的來源，換上正確選項後問題完全解決。
2. 兩個錯誤選項換上去真的還是錯的，不會也算對。
3. error_message 跟這段程式碼實際會出現的錯誤或現象一致；寫成瀏覽器錯誤訊息的話，要是瀏覽器真的會印出的樣子。邏輯錯誤的題目本來就是用一句英文描述畫面上的現象，這是允許的。
4. symptom_zh 跟 error_message 意思一致。
5. explanation 的內容正確、沒有誤導，初學者看得懂，用台灣繁體中文。
6. 跟同主題其他題目比，不能是觀念重複而且程式碼也相似的題目。判定重複要指出是跟哪一題；只是錯誤訊息相同，但考的觀念或情境不同，不算重複。
7. 難度標示合理（1 淺、2 中、3 深）。
8. 符合主題：考的觀念要屬於這個主題（看主題說明），借用別的主題的觀念就不合格。
9. 【容易選錯】挑的是最像正確答案的錯誤選項，而且說明正確。
10. 玩家看到的 code 跟實際執行的一致：db_setup（建表和資料）、files、before、after 都是模擬環境，玩家看不到是正常的。只有「呼叫題目的函式」或「印出結果」寫在 before 或 after 裡、code 裡看不到時，才算不一致。

只有會讓玩家學到錯的東西、答案有爭議、或題目跟實際執行結果不符的問題，才算不合格：ok 填 false，problems 用中文逐條寫出原因。
措辭可以更好、說明可以更完整這類不影響正確性的意見，寫在 suggestions，不影響 ok。
都合格 ok 填 true，problems 給空陣列。只回傳 JSON。`
  const { check, ...shown } = d
  const user = `主題：${t.pet_name}（${t.topic}）
主題說明：
${t.guide}

同主題其他題目：
${others}

要審的題目：
${JSON.stringify(shown, null, 2)}

執行時接在題目程式碼前面的 before：
${check.before || '（無）'}
接在後面的 after：
${check.after || '（無）'}
其他檔案：
${check.files.map((f) => `// ${f.path}\n${f.content}`).join('\n') || '（無）'}
資料庫的 db_setup：
${check.db_setup || '（無）'}

${run}`
  return ask<Review>(system, user, reviewSchema, 'medium')
}

// 額度用完或金鑰沒權限，重試也沒用，整批停下來
let halted = ''
function fatal(e: unknown) {
  if (e instanceof Anthropic.AuthenticationError || e instanceof Anthropic.PermissionDeniedError)
    return true
  return e instanceof Anthropic.BadRequestError && /credit balance|usage limit/.test(e.message)
}

async function runTopic(t: Topic) {
  let tries = 0
  let lastReason = ''
  const done = () => accepted.filter((p) => p.topic_key === t.key && p.batch === batch).length
  while (done() < perTopic && tries < perTopic * 2) {
    if (halted) return
    if (cost.usd >= maxUsd) return console.log(`[${t.pet_name}] 花費到上限，停止`)
    tries++
    // 先補還缺的難度，補齊後照淺、中、深的順序
    const mine = accepted.filter((p) => p.topic_key === t.key && p.batch === batch)
    const level =
      LEVELS.find(
        (lv, i) =>
          mine.filter((p) => p.difficulty === lv).length <
          LEVELS.slice(0, i + 1).filter((x) => x === lv).length,
      ) ?? LEVELS[done() % LEVELS.length]
    // 前面幾批收下的題目也要列出來，不然會一直出已經有的觀念
    const newOnes = [...otherBatches, ...accepted]
      .filter((p) => p.topic_key === t.key)
      .map((p) => `- ${p.concept}｜${p.error_message}`)
      .join('\n')
    const tried = rejected
      .filter((r) => r.topic_key === t.key && r.draft && /重複|太像|相似/.test(r.reasons.join('')))
      .map((r) => `- ${r.draft!.concept}`)
      .join('\n')
    const user = `請出一題難度 ${level} 的新題目。
${newOnes ? `之前新出的這些題目也不能重複：\n${newOnes}\n` : ''}${tried ? `這些觀念試過了，都跟現有題目重複，不要再出：\n${tried}\n` : ''}${lastReason ? `上一題被退回的原因（請避開）：${lastReason}\n` : ''}`
    const reject = (stage: string, reasons: string[], draft?: Draft) => {
      rejected.push({ topic_key: t.key, batch, stage, reasons, draft })
      save(`rejects-${batch}.json`, rejected)
      lastReason = reasons.join('；')
      console.log(`[${t.pet_name}] 淘汰（${stage}）${lastReason.slice(0, 120)}`)
    }

    let d: Draft
    try {
      d = await ask<Draft>(topicSystem(t), user, draftSchema, 'high')
    } catch (e) {
      if (fatal(e)) {
        halted = String(e)
        return console.log(`[${t.pet_name}] API 無法使用，停止：${halted.slice(0, 120)}`)
      }
      reject('api', [String(e)])
      continue
    }
    d.difficulty = level

    const similar = similarIssue(t, d)
    if (similar) {
      reject('similar', [similar], d)
      continue
    }

    const v = await serial(() => verify(d)).catch((e): Verified => ({
      mode: 'run',
      issues: [`執行驗證出錯：${e}`],
    }))
    if (v.issues.length) {
      reject(v.mode === 'run' ? 'run' : 'format', v.issues, d)
      continue
    }

    let r: Review
    try {
      r = await review(t, d, v)
    } catch (e) {
      if (fatal(e)) {
        halted = String(e)
        return console.log(`[${t.pet_name}] API 無法使用，停止：${halted.slice(0, 120)}`)
      }
      reject('api', [String(e)], d)
      continue
    }
    if (!r.ok) {
      reject('review', r.problems, d)
      continue
    }

    accepted.push({
      ...d,
      topic_key: t.key,
      pet_name: t.pet_name,
      emoji: t.emoji,
      topic: t.topic,
      batch,
      verified: v,
      review: r.suggestions,
    })
    save(`batch-${batch}.json`, accepted)
    lastReason = ''
    console.log(
      `[${t.pet_name}] 收下第 ${done()} 題（${v.mode}）${d.concept}  累計 $${cost.usd.toFixed(2)}`,
    )
  }
}

// 規則改了以後，已經收下的題目照新規則改寫，再重新執行和審核一次；沒過就淘汰，之後再補題
async function reviseTopic(t: Topic) {
  const mine = accepted.filter((p) => p.topic_key === t.key && p.batch === batch && !p.revised)
  for (const old of mine) {
    if (halted || cost.usd >= maxUsd) return
    const { topic_key, pet_name, emoji, topic, batch: b, verified, review: notes, ...draft } = old
    const user = `下面是一題已經收下的題目，請照現在的規則修改後回傳完整的 JSON：
1. explanation 加上【容易選錯】那一行，放在【一句話記住】和【小字典】之間，原本四行的內容不要改。
2. 如果 before 或 after 裡有呼叫題目的函式，或印出結果，把這些搬進 code，after 只留模擬環境。bug 本身不變，bug_line 跟著調整，選項文字照舊（縮排不對才調整）。沒有這個問題就不要動 code 和 check。
3. 其他欄位保持原樣，difficulty 填 ${old.difficulty}。

${JSON.stringify(draft, null, 2)}`
    const drop = (stage: string, reasons: string[], d?: Draft) => {
      accepted.splice(accepted.indexOf(old), 1)
      rejected.push({ topic_key: t.key, batch, stage, reasons, draft: d ?? draft })
      save(`batch-${batch}.json`, accepted)
      save(`rejects-${batch}.json`, rejected)
      console.log(`[${t.pet_name}] 改寫後淘汰（${stage}）${reasons.join('；').slice(0, 120)}`)
    }
    let d: Draft = draft
    // 已經有【容易選錯】的就不用再請模型改寫，直接重新驗證和審核
    if (!old.explanation.includes('【容易選錯】')) {
      try {
        d = await ask<Draft>(topicSystem(t), user, draftSchema, 'medium')
      } catch (e) {
        if (fatal(e)) {
          halted = String(e)
          return console.log(`[${t.pet_name}] API 無法使用，停止：${halted.slice(0, 120)}`)
        }
        drop('revise-api', [String(e)])
        continue
      }
    }
    d.difficulty = old.difficulty
    if (NO_AFTER.includes(t.key) && d.check.after.trim()) {
      drop('revise-format', ['呼叫函式和印出結果要寫在題目程式碼裡，after 要留空'], d)
      continue
    }
    const v = await serial(() => verify(d)).catch((e): Verified => ({
      mode: 'run',
      issues: [`執行驗證出錯：${e}`],
    }))
    if (v.issues.length) {
      drop(v.mode === 'run' ? 'revise-run' : 'revise-format', v.issues, d)
      continue
    }
    let r: Review
    try {
      r = await review(t, d, v, old)
    } catch (e) {
      drop('revise-api', [String(e)], d)
      continue
    }
    if (!r.ok) {
      drop('revise-review', r.problems, d)
      continue
    }
    accepted[accepted.indexOf(old)] = {
      ...old,
      ...d,
      verified: v,
      review: r.suggestions,
      revised: true,
    }
    save(`batch-${batch}.json`, accepted)
    console.log(`[${t.pet_name}] 改寫通過：${d.concept}  累計 $${cost.usd.toFixed(2)}`)
  }
}

async function main() {
  const picked = args.topics
    ? topics.filter((t) => args.topics!.split(',').includes(t.key))
    : topics
  await Promise.all(picked.map(args.revise ? reviseTopic : runTopic))
  console.log(
    `\n收下 ${accepted.length} 題，淘汰 ${rejected.length} 次，累計花費 $${cost.usd.toFixed(2)}`,
  )
  process.exit(0)
}

main()
