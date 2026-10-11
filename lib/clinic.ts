// demo 用的玩家假資料
export const player = {
  name: '醫師',
  level: 2,
  exp: 60,
  nextExp: 100,
  coins: 120,
  cured: 7,
  streak: 5,
  leaveTickets: 1,
}

export const daily = {
  no: 42,
  caseIndex: 0,
}

// 這週的打卡紀錄，true 代表有看診
export const week = [
  { day: '一', done: true },
  { day: '二', done: true },
  { day: '三', done: true },
  { day: '四', done: true },
  { day: '五', done: true },
  { day: '六', done: false },
  { day: '日', done: false },
]

export const beasts = [
  { name: '貘', icon: '🐾', days: 3, desc: '會吃掉 bug 的夢獸，住在候診區' },
  { name: '麒麟', icon: '🦌', days: 7, desc: '帶來好運，治好後診所升級' },
  { name: '九尾狐', icon: '🦊', days: 14, desc: 'bug 藏得特別深' },
  { name: '白澤', icon: '🐐', days: 30, desc: '知道天下所有的病' },
  { name: '龍', icon: '🐉', days: 100, desc: '最終 Boss' },
]

export const rooms = [
  { name: '小診療室', icon: '🩺', unlock: 1, desc: '基本看診' },
  { name: '掛號櫃台', icon: '📋', unlock: 2, desc: '每天接更多病患' },
  { name: 'X 光室', icon: '🩻', unlock: 3, desc: '看錯誤訊息找病因' },
  { name: '手術室', icon: '🔪', unlock: 4, desc: '一隻寵物多個 bug' },
  { name: '住院部', icon: '🛏️', unlock: 5, desc: '答錯的病例回診' },
  { name: '研究室', icon: '🔬', unlock: 6, desc: '每週 Boss 疑難雜症' },
]

export const records = [
  { pet: '🐢 慢慢', topic: '非同步', note: '忘了 await', date: '10/10' },
  { pet: '🐱 咪咪', topic: 'React', note: 'key 重複', date: '10/09' },
  { pet: '🐶 小黑', topic: 'Firebase', note: '安全規則擋住讀取', date: '10/08' },
]
