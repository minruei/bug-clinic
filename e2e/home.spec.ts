import { test, expect } from '@playwright/test'

test('首頁顯示診所名稱和今日病患', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading', { name: '除蟲動物診所' })).toBeVisible()
  await expect(page.getByText('今日病患 #42')).toBeVisible()
  await expect(page.getByText('連續打卡 5 天')).toBeVisible()
})

test('點開始看診會進入看診頁', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('link', { name: '開始看診' }).click()
  await expect(page).toHaveURL('/clinic')
  await expect(page.getByText('第一步：點出 bug 躲在哪一行')).toBeVisible()
})
