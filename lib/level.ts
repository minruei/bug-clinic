// 等級不存在資料庫，用經驗值算出來
// 每 100 經驗升一級，之後想調整升級速度只要改這裡
export const EXP_PER_LEVEL = 100

export function levelFromExp(exp: number) {
  return Math.floor(exp / EXP_PER_LEVEL) + 1
}

// 這一級已經累積多少經驗，用來畫經驗條
export function expInLevel(exp: number) {
  return exp % EXP_PER_LEVEL
}