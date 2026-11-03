-- 合成獸實驗室需要的資料表
-- 只要執行一次，重複執行 ALTER TABLE 那行會報錯（欄位已存在）
SET NAMES utf8mb4;
USE bug_clinic;

-- users 加欄位：新手教程做完了沒
ALTER TABLE users ADD COLUMN tutorial_done BOOLEAN NOT NULL DEFAULT FALSE AFTER exp;

-- 零件商店：每個零件的名稱、分類、價格、像素圖、起始程式碼
CREATE TABLE IF NOT EXISTS parts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  category VARCHAR(10) NOT NULL,
  price INT NOT NULL DEFAULT 0,
  sprite VARCHAR(100) NOT NULL,
  starter_code TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 玩家買過的零件，同一個玩家同一個零件只能有一筆
CREATE TABLE IF NOT EXISTS user_parts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  part_id INT NOT NULL,
  purchased_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_user_part (user_id, part_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (part_id) REFERENCES parts(id)
);

-- 金幣明細：賺是正數，花是負數
-- 答題賺的記 attempt_id，買零件花的記 part_id，另一個留 NULL
CREATE TABLE IF NOT EXISTS coin_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount INT NOT NULL,
  reason VARCHAR(20) NOT NULL,
  attempt_id INT NULL,
  part_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON DELETE SET NULL,
  FOREIGN KEY (part_id) REFERENCES parts(id)
);

-- 合成獸存檔：一個玩家一隻，存玩家改好的整段程式碼
CREATE TABLE IF NOT EXISTS chimeras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL DEFAULT '我的合成獸',
  code TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

SHOW TABLES;
