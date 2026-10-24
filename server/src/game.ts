// 遊戲規則，調整難度改這裡就好
export const TIME_LIMIT = 60
export const MISTAKE_PENALTY = 5
export const EXP_REWARD = 20
export const MIN_COINS = 5

// 剩餘生命值 = 時間限制 − 經過秒數 − 點錯次數 × 扣血
export function remainingLife(secondsUsed: number, mistakes: number) {
  return TIME_LIMIT - secondsUsed - mistakes * MISTAKE_PENALTY
}

// 答對的金幣：剩餘生命值的一半，最少 MIN_COINS
export function coinsFor(life: number) {
  return Math.max(MIN_COINS, Math.floor(life / 2))
}