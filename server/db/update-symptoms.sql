-- 英文錯誤訊息下面加一行中文白話，初學者看得懂，也能練習讀真正的錯誤訊息
-- 本來就是中文描述的題目不用加，留 NULL
SET NAMES utf8mb4;

ALTER TABLE problems ADD COLUMN symptom_zh VARCHAR(255) NULL AFTER error_message;

UPDATE problems SET symptom_zh = '型別不合：這裡要放數字，你卻給了文字' WHERE id = 1;
UPDATE problems SET symptom_zh = '找不到檔案：照這個路徑找不到 @/lib/firebse' WHERE id = 3;
UPDATE problems SET symptom_zh = '警告：列表裡每一個項目都要有不重複的 key' WHERE id = 4;
UPDATE problems SET symptom_zh = '型別錯誤：用 const 宣告的變數，不能再重新指定值' WHERE id = 5;

SELECT id, pet_name, error_message, symptom_zh FROM problems;
