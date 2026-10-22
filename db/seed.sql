USE bug_clinic;

DELETE FROM problems;

INSERT INTO problems (id, pet_name, emoji, topic, error_message, code, bug_line, explanation) VALUES
(1, '小橘', '🐱', 'TypeScript',
 'Type ''string'' is not assignable to type ''number''.',
 'type Item = {\n  id: number\n  title: string\n}\n\nconst ref = await addDoc(collection(db, ''items''), data)\nconst item: Item = { id: ref.id, title }',
 2, 'Firestore 的文件 id 是字串，型別要跟著改成 string。'),
(2, '阿福', '🐶', '非同步',
 '畫面一直顯示載入中，清單永遠是空的。',
 'async function load() {\n  const snap = getDocs(collection(db, ''items''))\n  const list = snap.docs.map((d) => d.data())\n  setItems(list)\n}',
 2, 'getDocs 會回傳 Promise，要加 await 等資料真的回來。'),
(3, '跳跳', '🐰', '模組路徑',
 'Module not found: Can''t resolve ''@/lib/firebse''',
 'import { useState } from ''react''\nimport { db } from ''@/lib/firebse''\nimport List from ''@/components/List''',
 2, '路徑拼錯了，先讀錯誤訊息裡的檔名，再對照真正的檔案。');

INSERT INTO problem_options (problem_id, option_text, is_correct, sort_order) VALUES
(1, 'id: string', TRUE, 1),
(1, 'id: any', FALSE, 2),
(1, 'id?: number', FALSE, 3),
(2, 'const snap = getDoc(collection(db, ''items''))', FALSE, 1),
(2, 'const snap = await getDocs(collection(db, ''items''))', TRUE, 2),
(2, 'let snap = getDocs(collection(db, ''items''))', FALSE, 3),
(3, 'import db from ''@/lib/firebse''', FALSE, 1),
(3, 'import { db } from ''lib/firebse''', FALSE, 2),
(3, 'import { db } from ''@/lib/firebase''', TRUE, 3);