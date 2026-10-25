-- 重新配對病患：烏龜負責 await（要等），小狗負責 React 狀態（會記住）
-- 只改名字和頭像，練習紀錄是跟著題目 id 存的，不會受影響
SET NAMES utf8mb4;

UPDATE problems SET pet_name = '慢慢', emoji = '🐢' WHERE id = 2;
UPDATE problems SET pet_name = '阿福', emoji = '🐶' WHERE id = 5;

SELECT id, pet_name, emoji, topic FROM problems;
