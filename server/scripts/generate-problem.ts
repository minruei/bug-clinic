// 實驗：請 Claude 照題庫格式出一題，印出來看品質，不會寫進資料庫
// 先讀 .env，金鑰才會進到 process.env
process.loadEnvFile('.env')
// 執行：npx tsx --env-file=.env scripts/generate-problem.ts "主題"
import Anthropic from '@anthropic-ai/sdk'

type Draft = {
  topic: string
  error_message: string
  code: string
  bug_line: number
  explanation: string
  options: { text: string; correct: boolean }[]
}

const topic = process.argv[2] ?? '陣列 map 忘記 return'

const prompt = `你是程式除錯練習遊戲的出題老師，玩家是剛學程式的初學者。
請出一題「${topic}」的除錯題，只回傳 JSON，不要有其他文字。

規則：
1. code 是 3 到 8 行的 JavaScript 或 TypeScript，裡面只有一行有 bug
2. bug_line 是有 bug 的那一行，從 1 開始算
3. error_message 是執行時會看到的錯誤訊息或錯誤現象，一句話
4. options 有 3 個修法，只有 1 個 correct 是 true，其他 2 個要看起來合理但是錯的
5. explanation 用國中生聽得懂的繁體中文，分成四段，每段用 \\n 隔開：
   【哪裡出錯】【用生活例子想】【一句話記住】【小字典】
6. 不要用破折號

JSON 格式：
{"topic":"","error_message":"","code":"","bug_line":1,"explanation":"","options":[{"text":"","correct":true}]}`

// 檢查 AI 出的題目，有問題就列出來
function check(d: Draft) {
  const problems: string[] = []
  const lines = d.code.split('\n').length
  if (d.bug_line < 1 || d.bug_line > lines) problems.push(`bug_line ${d.bug_line} 超出範圍（共 ${lines} 行）`)
  const correct = d.options.filter((o) => o.correct).length
  if (correct !== 1) problems.push(`正確答案有 ${correct} 個，應該只有 1 個`)
  if (d.options.length !== 3) problems.push(`選項有 ${d.options.length} 個，應該是 3 個`)
  for (const part of ['【哪裡出錯】', '【用生活例子想】', '【一句話記住】', '【小字典】']) {
    if (!d.explanation.includes(part)) problems.push(`解說少了 ${part}`)
  }
  return problems
}

async function main() {
  const client = new Anthropic()
  console.log(`請 Claude 出一題「${topic}」...\n`)

  const res = await client.messages.create({
    model: process.argv[3] ?? 'claude-sonnet-5-5',
    max_tokens: 4000,
    messages: [{ role: 'user', content: prompt }],
  })

  // 回應可能分成好幾塊（例如思考過程），找出文字那一塊
  const block = res.content.find((b) => b.type === 'text')
  const text = block && block.type === 'text' ? block.text : ''
  // 有時候會包在 ```json 裡，只抓大括號中間的部分
  const json = text.slice(text.indexOf('{'), text.lastIndexOf('}') + 1)
  let d: Draft
  try {
    d = JSON.parse(json)
  } catch {
    console.log('JSON 解析失敗，Claude 的原文：\n', text)
    console.log('回應區塊：', res.content.map((b) => b.type), '結束原因：', res.stop_reason)
    return
  }

  console.log('主題：', d.topic)
  console.log('症狀：', d.error_message, '\n')
  d.code.split('\n').forEach((line, i) => {
    const mark = i + 1 === d.bug_line ? '��' : '  '
    console.log(`${mark} ${String(i + 1).padStart(2)} | ${line}`)
  })
  console.log('\n選項：')
  d.options.forEach((o) => console.log(`  ${o.correct ? '✅' : '❌'} ${o.text}`))
  console.log('\n解說：')
  console.log(d.explanation)

  const problems = check(d)
  console.log(problems.length ? `\n⚠️ 檢查發現問題：\n- ${problems.join('\n- ')}` : '\n✅ 格式檢查通過')
  console.log(`\n用量：輸入 ${res.usage.input_tokens} tokens，輸出 ${res.usage.output_tokens} tokens`)
}

main()
