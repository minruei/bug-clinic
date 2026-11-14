import { rateLimit } from 'express-rate-limit'

// 同一個 IP 在一段時間內最多打幾次，超過回 429，格式跟其他 API 一樣
// 只限制登入、註冊、付款，答題這些正常玩的 API 不限制
// onlyFailures：只算失敗的次數（狀態碼 400 以上），成功的不計入
function limit(minutes: number, max: number, message: string, onlyFailures = false) {
  return rateLimit({
    windowMs: minutes * 60 * 1000,
    limit: max,
    skipSuccessfulRequests: onlyFailures,
    standardHeaders: 'draft-8',
    legacyHeaders: false,
    message: { error: true, message },
  })
}

// 擋一直試密碼：只算登入失敗，正常重複登入登出不會被擋
export const loginLimit = limit(15, 10, '嘗試太多次，請稍後再試', true)

// 擋大量註冊帳號
export const registerLimit = limit(60, 5, '註冊太多次，請稍後再試')

// 擋狂打付款 API
export const orderLimit = limit(1, 5, '付款太頻繁，請等一分鐘再試')
