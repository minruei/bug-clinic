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

  const editor = page.locator('.editor-cm:visible')
  await page.getByRole('button', { name: '零件形狀' }).click()
  await expect(editor).toContainText('.body::before')
  await page.getByRole('button', { name: 'CSS 烤漆' }).click()
  await expect(editor).toContainText('--fur-color')
  await expect(editor).not.toContainText('::before')
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

// 每一格有自己的內容和復原紀錄：切分頁後馬上打字、按復原，都只影響目前這一格
test('切分頁後馬上打字和復原，不會動到別的分頁', async ({ page }) => {
  await fakeApi(page, true)
  await page.goto('/lab')

  const editor = page.locator('.editor-cm:visible').locator('.cm-content')
  const cssTab = page.getByRole('button', { name: 'CSS 烤漆' })
  const htmlTab = page.getByRole('button', { name: 'HTML 骨架' })

  // 實驗室一打開就在 CSS 格，先記下原本的內容
  await expect(cssTab).toHaveClass(/active/)
  const cssBefore = await editor.innerText()

  // 在 HTML 格的最前面打字，切到 CSS 格馬上接著打
  await htmlTab.click()
  await editor.click()
  await page.keyboard.press('ControlOrMeta+Home')
  await page.keyboard.type('htmlMark')
  await cssTab.click()
  await editor.click()
  await page.keyboard.press('ControlOrMeta+Home')
  await page.keyboard.type('cssMark')

  await expect(editor).toContainText('cssMark')
  await expect(editor).toContainText('--fur-color')
  await expect(editor).not.toContainText('htmlMark')

  // 多按幾次復原，CSS 格只會回到原本的樣子，不會變成 HTML 格的內容
  await page.keyboard.press('ControlOrMeta+z')
  await page.keyboard.press('ControlOrMeta+z')
  await page.keyboard.press('ControlOrMeta+z')
  await expect.poll(() => editor.innerText()).toBe(cssBefore)

  // HTML 格打的字還在
  await htmlTab.click()
  await expect(editor).toContainText('htmlMark')
})
