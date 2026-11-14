import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vitest/config'

// 單元測試只跑 lib 裡的純函式；e2e 資料夾是 Playwright 的，server 有自己的測試
export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./', import.meta.url)),
    },
  },
  test: {
    include: ['lib/**/*.test.ts'],
  },
})
