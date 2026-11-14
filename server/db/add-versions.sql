-- 合成獸的版本紀錄：每次存檔留一份，玩家改壞了可以回到之前的樣子
-- 只要執行一次；CREATE TABLE IF NOT EXISTS 重複執行也不會出錯
SET NAMES utf8mb4;
USE bug_clinic;

-- 每個玩家只留最新 20 筆，舊的在存檔時刪掉
-- (user_id, id) 的索引給「列出某個玩家的版本，新的在前」和「刪掉比第 20 筆舊的」用
CREATE TABLE IF NOT EXISTS chimera_versions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  code TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_versions (user_id, id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

SHOW COLUMNS FROM chimera_versions;
