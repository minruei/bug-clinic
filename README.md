# Bug Clinic 除蟲動物診所

![CI](https://github.com/minruei/bug-clinic/actions/workflows/ci.yml/badge.svg)

幫受傷的寵物抓出程式裡的 bug。玩家是寵物醫生，在時間內找出 bug 並選出正確的修法，治好的病患收進病歷本，賺到的診療費和經驗值用來擴建診所。每天一題、連續打卡，就會有神獸來診所求診。

## 開發

```bash
npm install
npm run dev
```

打開 http://localhost:3000

## 指令

| 指令                   | 用途                        |
| ---------------------- | --------------------------- |
| `npm run format`       | 用 Prettier 統一格式        |
| `npm run format:check` | 檢查格式                    |
| `npm run lint`         | ESLint 檢查                 |
| `npm run typecheck`    | TypeScript 型別檢查         |
| `npm run build`        | 建置正式版                  |
| `npm run test:e2e`     | Playwright 測試（先 build） |

## CI 與安全

- **CI**：每次 push 和 PR 都會跑格式、Lint、型別檢查、相依套件安全掃描、建置，通過後再跑電腦版和手機版的 E2E 測試
- **CodeQL**：GitHub 的程式碼安全掃描，每週也會自動跑一次
- **Dependabot**：每週檢查套件更新，自動開 PR
- **安全標頭**：在 `next.config.ts` 設定，防止網站被嵌入其他頁面、限制瀏覽器權限

## 目前狀態

期初 Demo，資料皆為假資料（`lib/cases.ts`、`lib/clinic.ts`），插畫繪製中。
