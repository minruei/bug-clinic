-- 付款功能：用 TapPay 測試環境買金幣
-- 只要執行一次，重複執行 ALTER TABLE 那幾行會報錯（欄位已存在）
SET NAMES utf8mb4;
USE bug_clinic;

-- 訂單：先建立 UNPAID，向 TapPay 收款成功才改 PAID，失敗改 FAILED
-- 金額和金幣數由後端依方案決定，不相信前端送來的數字
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  number VARCHAR(30) NOT NULL UNIQUE,
  user_id INT NOT NULL,
  amount INT NOT NULL,
  coins INT NOT NULL,
  status VARCHAR(10) NOT NULL DEFAULT 'UNPAID',
  rec_trade_id VARCHAR(50) NULL,
  message VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 金幣明細多一個 order_id：付款買的金幣記是哪一筆訂單
ALTER TABLE coin_transactions ADD COLUMN order_id INT NULL AFTER part_id;
ALTER TABLE coin_transactions ADD FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL;

SHOW TABLES;
