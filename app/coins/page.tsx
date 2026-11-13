'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import Script from 'next/script'
import { api } from '@/lib/api'
import { Pixel } from '@/components/Pixel'

type CoinPackage = { id: number; name: string; amount: number; coins: number }

// TapPay SDK 載入後會掛在 window.TPDirect，這裡只寫用得到的部分
type TPDirectType = {
  setupSDK: (appId: number, appKey: string, serverType: 'sandbox' | 'production') => void
  card: {
    setup: (config: object) => void
    onUpdate: (callback: (update: { canGetPrime: boolean }) => void) => void
    getPrime: (
      callback: (result: { status: number; msg: string; card: { prime: string } }) => void,
    ) => void
  }
}

declare global {
  interface Window {
    TPDirect?: TPDirectType
  }
}

// 買金幣：選方案、輸入卡號，TapPay 把卡號換成 prime，後端再拿 prime 收款
// 卡號只會在 TapPay 的欄位裡，不會經過我們的伺服器
export default function CoinsPage() {
  const [packages, setPackages] = useState<CoinPackage[]>([])
  const [selected, setSelected] = useState(1)
  const [coins, setCoins] = useState(0)
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null)
  const [sdkReady, setSdkReady] = useState(false)
  const [canPay, setCanPay] = useState(false)
  const [paying, setPaying] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    async function load() {
      const [userRes, packRes] = await Promise.all([
        api('/api/user/auth'),
        api('/api/coin-packages'),
      ])
      setLoggedIn(!!userRes.data)
      setCoins(userRes.data?.coins ?? 0)
      setPackages(packRes.data ?? [])
    }
    load()
  }, [])

  // SDK 載入完成、而且畫面上有卡號欄位之後，才設定 TapPay
  useEffect(() => {
    const TPDirect = window.TPDirect
    if (!sdkReady || !loggedIn || !TPDirect) return

    TPDirect.setupSDK(
      Number(process.env.NEXT_PUBLIC_TAPPAY_APP_ID),
      process.env.NEXT_PUBLIC_TAPPAY_APP_KEY ?? '',
      'sandbox',
    )
    TPDirect.card.setup({
      fields: {
        number: { element: '#card-number', placeholder: '**** **** **** ****' },
        expirationDate: { element: '#card-expiration-date', placeholder: 'MM / YY' },
        ccv: { element: '#card-ccv', placeholder: 'CCV' },
      },
      styles: { input: { 'font-size': '16px', color: '#4a3426' } },
    })
    // 卡號、日期、CCV 都填對了，付款按鈕才能按
    TPDirect.card.onUpdate((update) => setCanPay(update.canGetPrime))
  }, [sdkReady, loggedIn])

  function pay() {
    const TPDirect = window.TPDirect
    if (!TPDirect) return
    setPaying(true)
    setMessage('')

    TPDirect.card.getPrime(async (result) => {
      if (result.status !== 0) {
        setPaying(false)
        setMessage(`卡片資料有誤：${result.msg}`)
        return
      }

      // 只送 prime 和方案編號，價格由後端決定
      const res = await api('/api/orders', 'POST', {
        prime: result.card.prime,
        packageId: selected,
      })
      setPaying(false)

      if (res.error) {
        setMessage(res.message)
        return
      }
      setCoins(res.data.coins)
      setMessage(`付款成功！拿到 ${res.data.added} 金幣，訂單編號 ${res.data.number}`)
    })
  }

  return (
    <main className="wrap">
      <Script
        src="https://js.tappaysdk.com/sdk/tpdirect/v5.14.0"
        onReady={() => setSdkReady(true)}
        onError={() => setMessage('付款元件載入失敗，請重新整理再試一次')}
      />

      <header className="top">
        <Link href="/lab" className="back">
          ← 回實驗室
        </Link>
        {loggedIn && (
          <span className="muted">
            <Pixel name="coin" size={18} /> {coins}
          </span>
        )}
      </header>

      <div>
        <p className="eyebrow">Coins</p>
        <h1>買金幣</h1>
        <p className="muted">
          金幣不夠買零件的話，可以在這裡補充。目前是 TapPay 測試環境，不會真的扣款
        </p>
      </div>

      {loggedIn === false && (
        <section className="card">
          <p>登入之後才能買金幣</p>
          <Link href="/login" className="btn">
            去登入
          </Link>
        </section>
      )}

      {loggedIn && (
        <>
          <h2>選擇方案</h2>
          <section className="parts">
            {packages.map((p) => (
              <button
                key={p.id}
                className={`part coin-pack ${selected === p.id ? 'owned' : ''}`}
                onClick={() => setSelected(p.id)}
              >
                <p className="name">{p.name}</p>
                <p className="price">
                  <Pixel name="coin" size={18} /> {p.coins}
                </p>
                <p className="muted">NT$ {p.amount}</p>
              </button>
            ))}
          </section>

          <h2>信用卡</h2>
          <section className="card pay-form">
            <label>
              卡號
              <div id="card-number" className="tpfield" />
            </label>
            <div className="pay-row">
              <label>
                到期日
                <div id="card-expiration-date" className="tpfield" />
              </label>
              <label>
                CCV
                <div id="card-ccv" className="tpfield" />
              </label>
            </div>
            <p className="muted">測試卡號 4242 4242 4242 4242，到期日填未來的月份，CCV 123</p>
            <button className="btn" onClick={pay} disabled={!canPay || paying}>
              {paying ? '付款中…' : '付款'}
            </button>
          </section>
        </>
      )}

      {message && <p className="lab-message">{message}</p>}
    </main>
  )
}
