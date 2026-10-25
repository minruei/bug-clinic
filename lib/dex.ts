// 神獸圖鑑：每隻神獸綁一個學習里程碑，條件都從看診紀錄算出來
// rank 是稀有度，用幾顆星星表示

export type DexAttempt = {
  pet_name: string
  is_correct: number
  mistakes: number
  seconds_used: number
  finished_at: string
}

export type Beast = {
  key: string
  name: string
  rank: number
  tier: string
  story: string
  goal: string
}

export const beasts: Beast[] = [
  {
    key: 'dodo',
    name: '渡渡鳥',
    rank: 1,
    tier: '絕種動物',
    story: '已經消失的模里西斯鳥',
    goal: '第一次治好病患',
  },
  {
    key: 'leopard',
    name: '台灣雲豹',
    rank: 1,
    tier: '絕種動物',
    story: '台灣山林的傳說貓科',
    goal: '治好 3 隻不同的病患',
  },
  {
    key: 'mammoth',
    name: '長毛象',
    rank: 2,
    tier: '遠古巨獸',
    story: '冰河時期的大象',
    goal: '一次都沒點錯就治好',
  },
  {
    key: 'sabertooth',
    name: '劍齒虎',
    rank: 2,
    tier: '遠古巨獸',
    story: '有超長牙齒的遠古貓',
    goal: '30 秒內治好',
  },
  {
    key: 'tapir',
    name: '貘',
    rank: 3,
    tier: '民間傳說',
    story: '傳說會吃掉惡夢',
    goal: '治好一隻曾經沒治好的病患',
  },
  {
    key: 'xiezhi',
    name: '獬豸',
    rank: 3,
    tier: '民間傳說',
    story: '能分辨對錯的神獸',
    goal: '連續 3 次看診都治好',
  },
  {
    key: 'windlion',
    name: '風獅爺',
    rank: 3,
    tier: '民間傳說',
    story: '金門守護村子的石獅',
    goal: '治好 6 隻不同的病患',
  },
  {
    key: 'martian',
    name: '火星人',
    rank: 4,
    tier: '外星訪客',
    story: '聽說火星也有 bug',
    goal: '累積看診 20 次',
  },
  {
    key: 'lizard',
    name: '蜥蜴人',
    rank: 4,
    tier: '外星訪客',
    story: '來地球偷學寫程式',
    goal: '同一隻病患治好 3 次',
  },
  {
    key: 'bugspirit',
    name: '除蟲精靈',
    rank: 5,
    tier: '傳說',
    story: 'Bug Clinic 的守護精靈',
    goal: '所有病患全部治好',
  },
]

// 回傳已經解鎖的神獸 key
export function unlockedBeasts(attempts: DexAttempt[], totalPets: number): Set<string> {
  // 照時間從舊排到新，才能判斷「先失敗後治好」和「連續」
  const list = [...attempts].sort(
    (a, b) => new Date(a.finished_at).getTime() - new Date(b.finished_at).getTime(),
  )
  const cured = list.filter((a) => a.is_correct)
  const curedPets = new Set(cured.map((a) => a.pet_name))
  const unlocked = new Set<string>()

  if (cured.length >= 1) unlocked.add('dodo')
  if (curedPets.size >= 3) unlocked.add('leopard')
  if (cured.some((a) => a.mistakes === 0)) unlocked.add('mammoth')
  if (cured.some((a) => a.seconds_used <= 30)) unlocked.add('sabertooth')

  // 貘：某隻病患先失敗過，之後又治好
  const failed = new Set<string>()
  for (const a of list) {
    if (!a.is_correct) failed.add(a.pet_name)
    else if (failed.has(a.pet_name)) unlocked.add('tapir')
  }

  // 獬豸：連續 3 次治好
  let streak = 0
  for (const a of list) {
    streak = a.is_correct ? streak + 1 : 0
    if (streak >= 3) unlocked.add('xiezhi')
  }

  if (curedPets.size >= 6) unlocked.add('windlion')
  if (list.length >= 20) unlocked.add('martian')

  // 蜥蜴人：同一隻病患治好 3 次
  const curedCount: Record<string, number> = {}
  for (const a of cured) {
    curedCount[a.pet_name] = (curedCount[a.pet_name] ?? 0) + 1
    if (curedCount[a.pet_name] >= 3) unlocked.add('lizard')
  }

  if (totalPets > 0 && curedPets.size >= totalPets) unlocked.add('bugspirit')
  return unlocked
}
