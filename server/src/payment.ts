// 金幣方案：價格和金幣數只寫在後端，前端只能送方案編號
export const coinPackages = [
  { id: 1, name: '一小袋金幣', amount: 30, coins: 100 },
  { id: 2, name: '一大袋金幣', amount: 90, coins: 350 },
]

type TapPayResult = { status: number; msg: string; rec_trade_id?: string }

// 拿前端給的 prime 向 TapPay 收款
// PARTNER_KEY 是秘密，只放在後端的 .env；status 是 0 才代表付款成功
export async function payByPrime(options: {
  prime: string
  amount: number
  details: string
  orderNumber: string
  cardholder: { name: string; email: string; phone_number: string }
}): Promise<TapPayResult> {
  const url = process.env.TAPPAY_URL ?? 'https://sandbox.tappaysdk.com/tpc/payment/pay-by-prime'

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.TAPPAY_PARTNER_KEY ?? '',
      },
      body: JSON.stringify({
        prime: options.prime,
        partner_key: process.env.TAPPAY_PARTNER_KEY,
        merchant_id: process.env.TAPPAY_MERCHANT_ID,
        amount: options.amount,
        currency: 'TWD',
        details: options.details,
        order_number: options.orderNumber,
        cardholder: options.cardholder,
      }),
      // TapPay 太久沒回就放棄，不要讓玩家一直等
      signal: AbortSignal.timeout(15000),
    })
    return (await res.json()) as TapPayResult
  } catch {
    return { status: -1, msg: '連不到付款服務' }
  }
}
