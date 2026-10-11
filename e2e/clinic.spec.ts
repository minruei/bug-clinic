import { test, expect } from '@playwright/test'

test('找到 bug 並選對藥，寵物會康復並打卡', async ({ page }) => {
  await page.goto('/clinic')
  await page.getByRole('button', { name: /id: number/ }).click()
  await expect(page.getByText('第二步：選擇正確的藥')).toBeVisible()
  await page.getByRole('button', { name: /id: string/ }).click()
  await expect(page.getByText('小橘 康復了！')).toBeVisible()
  await expect(page.getByText(/打卡成功/)).toBeVisible()
})

test('點錯行會扣生命值', async ({ page }) => {
  await page.goto('/clinic')
  await page.getByRole('button', { name: /type Item/ }).click()
  await expect(page.getByText(/生命值 5\d 秒/)).toBeVisible()
  await expect(page.getByText('第一步：點出 bug 躲在哪一行')).toBeVisible()
})
