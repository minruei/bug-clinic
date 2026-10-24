import { test, expect } from '@playwright/test'

// CI 沒有後端，所以只測不需要後端的部分：首頁標題、登入頁表單
test('首頁顯示診所名稱', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading', { name: '除蟲動物診所' })).toBeVisible()
})

test('登入頁可以切換到註冊', async ({ page }) => {
  await page.goto('/login')
  await expect(page.getByRole('button', { name: '打卡上班' })).toBeVisible()
  await page.getByRole('button', { name: '還不是除蟲獸醫？來報到' }).click()
  await expect(page.getByText('怎麼稱呼你？')).toBeVisible()
  await expect(page.getByRole('button', { name: '報到並上班' })).toBeVisible()
})
