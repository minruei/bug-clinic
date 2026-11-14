import { test, expect } from '@playwright/test'

// 手機寬度（375px）打開頁面，整頁不能出現左右捲動
// CI 沒有後端，所以只測不需要登入的首頁和登入頁
for (const path of ['/', '/login']) {
  test(`${path} 在 375px 寬沒有左右捲動`, async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    await page.goto(path)
    await page.waitForLoadState('networkidle')

    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - window.innerWidth,
    )
    expect(overflow).toBeLessThanOrEqual(0)
  })
}
