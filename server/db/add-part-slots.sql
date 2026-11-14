-- 零件加上部位（slot），同部位的零件裝上時會互相替換
-- 只要執行一次，重複執行 ALTER TABLE 會報錯（欄位已存在）
-- 跑完再跑 seed-parts-v2.sql 補上每個零件的部位
SET NAMES utf8mb4;
USE bug_clinic;

ALTER TABLE parts ADD COLUMN slot VARCHAR(20) NOT NULL DEFAULT 'other' AFTER category;

SHOW COLUMNS FROM parts;
