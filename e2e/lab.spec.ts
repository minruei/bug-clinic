import { test, expect, type Page } from '@playwright/test'

// 實驗室的編輯器分頁：CI 沒有後端，用 page.route 假裝後端回應，只看畫面排版
// tutorialDone 決定是不是新手教程中：教程中不顯示「零件形狀」
async function fakeApi(page: Page, tutorialDone: boolean) {
  await page.addInitScript(() => localStorage.setItem('token', 'e2e'))
  await page.route('**/api/**', (route) => {
    const url = route.request().url()
    if (url.endsWith('/api/user/auth')) {
      return route.fulfill({
        json: { data: { id: 1, name: '測試', coins: 0, tutorial_done: tutorialDone } },
      })
    }
    if (url.endsWith('/api/chimera')) return route.fulfill({ json: { data: null } })
    if (url.includes('/api/daily')) return route.fulfill({ json: { error: true, message: '' } })
    return route.fulfill({ json: { data: [] } })
  })
}

// 每個分頁的字都放得下：沒有被切掉，也沒有折成兩行
async function tabsFit(page: Page) {
  return page.evaluate(() =>
    [...document.querySelectorAll<HTMLElement>('.editor-tabs.main .editor-tab')].every(
      (tab) => tab.scrollWidth <= tab.clientWidth && tab.getBoundingClientRect().height <= 48,
    ),
  )
}

test('編輯器有四個等寬的分頁，375px 寬也放得下', async ({ page }) => {
  await fakeApi(page, true)
  await page.setViewportSize({ width: 375, height: 812 })
  await page.goto('/lab')

  const tabs = page.locator('.editor-tabs.main .editor-tab')
  await expect(tabs).toHaveText(['HTML 骨架', 'CSS 烤漆', 'JS 引擎', '零件形狀'])
  const widths = await tabs.evaluateAll((els) =>
    els.map((el) => Math.round(el.getBoundingClientRect().width)),
  )
  expect(new Set(widths).size).toBe(1)
  expect(await tabsFit(page)).toBe(true)
  await expect(page.getByRole('button', { name: '收起程式碼區' })).toBeVisible()

  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth - window.innerWidth,
  )
  expect(overflow).toBeLessThanOrEqual(0)
})

test('零件形狀那一格放著畫身體的程式，CSS 烤漆只留毛色和尺寸', async ({ page }) => {
  await fakeApi(page, true)
  await page.goto('/lab')

  await page.getByRole('button', { name: '零件形狀' }).click()
  await expect(page.locator('.editor-cm')).toContainText('.body::before')
  await page.getByRole('button', { name: 'CSS 烤漆' }).click()
  await expect(page.locator('.editor-cm')).toContainText('--fur-color')
  await expect(page.locator('.editor-cm')).not.toContainText('::before')
})

test('新手教程中不顯示零件形狀那一格', async ({ page }) => {
  await fakeApi(page, false)
  await page.goto('/lab')

  await expect(page.locator('.editor-tabs.main .editor-tab')).toHaveText([
    'HTML 骨架',
    'CSS 烤漆',
    'JS 引擎',
  ])
})
