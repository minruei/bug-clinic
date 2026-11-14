-- 每日任務：每個玩家每天完成一題、領一次金幣
-- 重複執行沒關係：CREATE TABLE IF NOT EXISTS 已經有表就跳過
-- 金幣明細的 reason 是 VARCHAR(20)，直接寫 'daily' 就好，不用改 coin_transactions
SET NAMES utf8mb4;
USE bug_clinic;

-- claim_date 是台灣日期，由後端用 Asia/Taipei 算好再存，不用 MySQL 的 CURDATE()（那是伺服器時區）
-- UNIQUE (user_id, claim_date)：同一個玩家同一天只能有一筆
-- 同時送很多次領取，只有第一次 INSERT 得進去，其他次撞到 UNIQUE，資料庫層級保證只能領一次
CREATE TABLE IF NOT EXISTS daily_claims (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  claim_date DATE NOT NULL,
  challenge_key VARCHAR(30) NOT NULL,
  reward INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_user_day (user_id, claim_date),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

SHOW COLUMNS FROM daily_claims;
