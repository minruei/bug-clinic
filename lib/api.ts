// 呼叫後端 API 的共用工具
// 後端網址從 .env.local 讀，部署後只要改設定，不用改程式
const API_URL = process.env.NEXT_PUBLIC_API_URL

// 登入後拿到的 token 存在 localStorage，重新整理也不會不見
export function getToken() {
  return localStorage.getItem('token')
}

export function saveToken(token: string) {
  localStorage.setItem('token', token)
}

export function clearToken() {
  localStorage.removeItem('token')
}

// 自動帶上 JSON 格式和 token，回傳後端的 JSON
// 跟 curl 測試時加的 -H 是一樣的東西
export async function api(path: string, method = 'GET', body?: unknown) {
  const token = getToken()
  const res = await fetch(`${API_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  })
  return res.json()
}