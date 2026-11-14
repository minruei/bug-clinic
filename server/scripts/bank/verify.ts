// 驗證一題：格式檢查，再到沙盒裡真的執行有 bug 的版本、正確選項、錯誤選項
import { spawn } from 'node:child_process'
import { mkdirSync, rmSync, symlinkSync, existsSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import mysql from 'mysql2/promise'

export type Check = {
  runner: 'tsc' | 'node' | 'sql' | 'review'
  code_path: string
  files: { path: string; content: string }[]
  before: string
  after: string
  entry: string
  db_setup: string
  expect_buggy: string
  expect_fixed: string
  message_from_run: boolean
}

export type Draft = {
  concept: string
  difficulty: number
  error_message: string
  symptom_zh: string
  code: string
  bug_line: number
  explanation: string
  options: { text: string; correct: boolean }[]
  check: Check
}

export type RunResult = { out: string; failed: boolean; timedOut: boolean }

const SERVER = resolve(__dirname, '../..')
const ROOT = resolve(SERVER, '..')
const WORK = process.env.BANK_WORK_DIR ?? ''
const DB_PORT = Number(process.env.BANK_MYSQL_PORT ?? 3310)
const TIMEOUT = 8000

// 沙盒：不能連外網，只能連 localhost；只能寫工作資料夾
function setupWork() {
  if (!WORK) throw new Error('請設定 BANK_WORK_DIR')
  mkdirSync(join(WORK, 'node_modules'), { recursive: true })
  mkdirSync(join(WORK, 'tmp'), { recursive: true })
  const links: Record<string, string> = {
    react: join(ROOT, 'node_modules/react'),
    'react-dom': join(ROOT, 'node_modules/react-dom'),
    express: join(SERVER, 'node_modules/express'),
    mysql2: join(SERVER, 'node_modules/mysql2'),
    esbuild: join(SERVER, 'node_modules/esbuild'),
  }
  for (const [name, target] of Object.entries(links)) {
    const link = join(WORK, 'node_modules', name)
    if (!existsSync(link)) symlinkSync(target, link)
  }
  // .jsx 檔在載入時用 esbuild 轉成一般 JS，React 用開發模式才會印出警告
  writeFileSync(
    join(WORK, 'jsx-hook.mjs'),
    `import { registerHooks } from 'node:module'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { transformSync } from 'esbuild'
registerHooks({
  load(url, context, next) {
    if (!url.endsWith('.jsx')) return next(url, context)
    const source = readFileSync(fileURLToPath(url), 'utf8')
    const { code } = transformSync(source, { loader: 'jsx', jsx: 'automatic', jsxDev: true, format: 'esm' })
    return { format: 'module', source: code, shortCircuit: true }
  },
})
`,
  )
  writeFileSync(
    join(WORK, 'sandbox.sb'),
    `(version 1)
(allow default)
(deny network-outbound)
(allow network-outbound (remote ip "localhost:*"))
(allow network-outbound (remote unix-socket))
(deny file-write*)
(allow file-write* (subpath "${WORK}") (subpath "/private/var/folders") (subpath "/dev"))
`,
  )
}
setupWork()

function run(cmd: string[], cwd: string, env: Record<string, string> = {}): Promise<RunResult> {
  return new Promise((done) => {
    const child = spawn('sandbox-exec', ['-f', join(WORK, 'sandbox.sb'), ...cmd], {
      cwd,
      env: {
        PATH: process.env.PATH ?? '',
        HOME: WORK,
        TMPDIR: join(WORK, 'tmp'),
        NODE_ENV: 'development',
        ...env,
      },
    })
    let out = ''
    child.stdout.on('data', (d) => (out += d))
    child.stderr.on('data', (d) => (out += d))
    let timedOut = false
    const timer = setTimeout(() => {
      timedOut = true
      child.kill('SIGKILL')
    }, TIMEOUT)
    child.on('close', (code) => {
      clearTimeout(timer)
      out = out.replace(/\x1b\[[0-9;]*m/g, '').slice(0, 4000)
      done({ out, failed: code !== 0, timedOut })
    })
  })
}

let caseNo = 0

async function withDb<T>(setup: string, fn: (url: string) => Promise<T>) {
  const name = `chk_${process.pid}_${++caseNo}`
  const conn = await mysql.createConnection({
    host: '127.0.0.1',
    port: DB_PORT,
    user: 'root',
    multipleStatements: true,
  })
  try {
    await conn.query(`CREATE DATABASE ${name}`)
    await conn.query(`USE ${name}`)
    if (setup.trim()) await conn.query(setup)
    return await fn(`mysql://root@127.0.0.1:${DB_PORT}/${name}`)
  } finally {
    await conn.query(`DROP DATABASE IF EXISTS ${name}`)
    await conn.end()
  }
}

// 把查詢結果排成文字：欄位名稱一行，每筆資料一行
function formatRows(result: unknown): string {
  const sets = Array.isArray(result) && Array.isArray(result[0]) ? result : [result]
  const last = sets[sets.length - 1]
  if (!Array.isArray(last)) return JSON.stringify(last)
  if (last.length === 0) return 'Empty set'
  const cols = Object.keys(last[0])
  return [cols.join('\t'), ...last.map((r) => cols.map((c) => String(r[c])).join('\t'))].join('\n')
}

async function runSql(check: Check, code: string): Promise<RunResult> {
  return withDb(check.db_setup, async (url) => {
    const conn = await mysql.createConnection({ uri: url, multipleStatements: true })
    try {
      const [rows] = await conn.query(code)
      return { out: formatRows(rows), failed: false, timedOut: false }
    } catch (e) {
      const err = e as { errno?: number; sqlState?: string; sqlMessage?: string; message: string }
      const out = err.errno
        ? `ERROR ${err.errno} (${err.sqlState}): ${err.sqlMessage}`
        : err.message
      return { out, failed: true, timedOut: false }
    } finally {
      await conn.end()
    }
  })
}

function writeCase(check: Check, code: string) {
  const dir = join(WORK, `case-${process.pid}-${++caseNo}`)
  rmSync(dir, { recursive: true, force: true })
  mkdirSync(dir, { recursive: true })
  const put = (path: string, content: string) => {
    mkdirSync(dirname(join(dir, path)), { recursive: true })
    writeFileSync(join(dir, path), content)
  }
  for (const f of check.files) put(f.path, f.content)
  const parts = check.runner === 'node' ? [check.before, code, check.after] : [code]
  put(check.code_path, parts.filter((p) => p.trim()).join('\n'))
  return dir
}

async function runNode(check: Check, code: string): Promise<RunResult> {
  const dir = writeCase(check, code)
  const entry = check.entry || check.code_path
  const jsx = [check.code_path, ...check.files.map((f) => f.path)].some((p) => p.endsWith('.jsx'))
  const cmd = jsx ? ['node', '--import', join(WORK, 'jsx-hook.mjs'), entry] : ['node', entry]
  if (check.db_setup.trim())
    return withDb(check.db_setup, (url) => run(cmd, dir, { CHECK_DB_URL: url }))
  return run(cmd, dir)
}

async function runTsc(check: Check, code: string): Promise<RunResult> {
  const dir = writeCase(check, code)
  writeFileSync(
    join(dir, 'tsconfig.json'),
    JSON.stringify({
      compilerOptions: {
        strict: true,
        target: 'es2022',
        lib: ['es2022', 'dom'],
        module: 'esnext',
        moduleResolution: 'bundler',
        noEmit: true,
        skipLibCheck: true,
        types: [],
      },
      include: ['**/*.ts'],
    }),
  )
  return run([join(SERVER, 'node_modules/.bin/tsc'), '-p', '.'], dir)
}

export function runVariant(check: Check, code: string) {
  if (check.runner === 'sql') return runSql(check, code)
  if (check.runner === 'tsc') return runTsc(check, code)
  return runNode(check, code)
}

const norm = (s: string) =>
  s.replace(/[‘’]/g, "'").replace(/[“”]/g, '"').replace(/\s+/g, ' ').trim()
const has = (out: string, part: string) => norm(out).includes(norm(part))

// 把 bug 那一行換成選項；選項沒寫縮排就沿用原本那一行的縮排
export function applyOption(code: string, bugLine: number, option: string) {
  const lines = code.split('\n')
  const indent = lines[bugLine - 1].match(/^\s*/)?.[0] ?? ''
  lines[bugLine - 1] = /^\s/.test(option) ? option : indent + option
  return lines.join('\n')
}

const CJK = /[㐀-鿿]/
const DASH = /[—–―]/

export function formatIssues(d: Draft): string[] {
  const issues: string[] = []
  const lines = d.code.split('\n')
  if (lines.length < 3 || lines.length > 12) issues.push(`程式碼 ${lines.length} 行，要 3 到 12 行`)
  if (!(d.bug_line >= 1 && d.bug_line <= lines.length))
    issues.push(`bug_line ${d.bug_line} 超出範圍`)
  if (d.options.length !== 3) issues.push(`選項有 ${d.options.length} 個`)
  if (d.options.filter((o) => o.correct).length !== 1) issues.push('正確選項不是剛好 1 個')
  const texts = d.options.map((o) => o.text.trim())
  if (new Set(texts).size !== texts.length) issues.push('選項重複')
  if (d.options.some((o) => o.text.includes('\n'))) issues.push('選項不能換行')
  const bugText = (lines[d.bug_line - 1] ?? '').trim()
  if (texts.includes(bugText)) issues.push('有選項跟原本那一行一模一樣')
  const parts = ['【哪裡出錯】', '【用生活例子想】', '【一句話記住】', '【容易選錯】', '【小字典】']
  const pos = parts.map((p) => d.explanation.indexOf(p))
  if (pos.some((p) => p < 0) || pos.some((p, i) => i > 0 && p < pos[i - 1]))
    issues.push('解說五段不齊或順序不對')
  if (d.explanation.split('\n').length !== 5) issues.push('解說要剛好五行')
  if ([d.explanation, d.symptom_zh].some((s) => DASH.test(s))) issues.push('有破折號')
  if (!d.symptom_zh || d.symptom_zh.length > 255 || !CJK.test(d.symptom_zh))
    issues.push('symptom_zh 要是中文且不超過 255 字')
  if (!d.error_message || CJK.test(d.error_message) || d.error_message.length > 300)
    issues.push('error_message 要是英文且不超過 300 字')
  if (d.check.runner === 'tsc' && (d.check.before || d.check.after))
    issues.push('tsc 題不能有 before/after')
  if (d.check.runner !== 'review' && !d.check.expect_buggy) issues.push('沒有 expect_buggy')
  return issues
}

export type Verified = {
  mode: 'run' | 'review'
  issues: string[]
  buggy?: RunResult
  fixed?: RunResult
  wrong?: RunResult[]
}

function passesFixed(check: Check, r: RunResult) {
  if (r.timedOut || r.failed) return false
  if (check.expect_buggy !== 'TIMEOUT' && has(r.out, check.expect_buggy)) return false
  if (check.expect_fixed && !has(r.out, check.expect_fixed)) return false
  return true
}

export async function verify(d: Draft): Promise<Verified> {
  const issues = formatIssues(d)
  if (issues.length || d.check.runner === 'review') return { mode: 'review', issues }

  const check = d.check
  const buggy = await runVariant(check, d.code)
  const buggyOk =
    check.expect_buggy === 'TIMEOUT' ? buggy.timedOut : has(buggy.out, check.expect_buggy)
  if (!buggyOk) issues.push('有 bug 的版本沒有出現預期的錯誤')
  if (check.message_from_run && !has(buggy.out, d.error_message))
    issues.push('error_message 跟實際印出來的不一樣')

  const correct = d.options.find((o) => o.correct)!
  const fixed = await runVariant(check, applyOption(d.code, d.bug_line, correct.text))
  if (!passesFixed(check, fixed)) issues.push('換上正確選項後還是有問題')

  const wrong: RunResult[] = []
  for (const o of d.options.filter((o) => !o.correct)) {
    const r = await runVariant(check, applyOption(d.code, d.bug_line, o.text))
    wrong.push(r)
    if (passesFixed(check, r)) issues.push(`錯誤選項也能修好：${o.text.trim()}`)
  }
  return { mode: 'run', issues, buggy, fixed, wrong }
}
