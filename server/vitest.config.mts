import { defineConfig } from 'vitest/config'

// 有這個檔，vitest 才不會往上找到前端的設定
export default defineConfig({
  test: {
    include: ['src/**/*.test.ts'],
  },
})
