export type Case = {
  id: string
  pet: string
  emoji: string
  topic: string
  symptom: string
  code: string[]
  bugLine: number
  options: string[]
  answer: number
  note: string
}

// demo 用的假病例，之後改放資料庫
export const cases: Case[] = [
  {
    id: 'c1',
    pet: '小橘',
    emoji: '🐱',
    topic: 'React',
    symptom: "Type 'string' is not assignable to type 'number'.",
    code: [
      'type Item = {',
      '  id: number',
      '  title: string',
      '}',
      '',
      "const ref = await addDoc(collection(db, 'items'), data)",
      'const item: Item = { id: ref.id, title }',
    ],
    bugLine: 2,
    options: ['id: string', 'id: any', 'id?: number'],
    answer: 0,
    note: 'Firestore 的文件 id 是字串，型別要跟著改成 string。',
  },
  {
    id: 'c2',
    pet: '阿福',
    emoji: '🐶',
    topic: 'Firebase',
    symptom: '畫面一直顯示「載入中」，清單永遠是空的。',
    code: [
      'async function load() {',
      "  const snap = getDocs(collection(db, 'items'))",
      '  const list = snap.docs.map((d) => d.data())',
      '  setItems(list)',
      '}',
    ],
    bugLine: 2,
    options: [
      "const snap = getDoc(collection(db, 'items'))",
      "const snap = await getDocs(collection(db, 'items'))",
      "let snap = getDocs(collection(db, 'items'))",
    ],
    answer: 1,
    note: 'getDocs 會回傳 Promise，要加 await 等資料真的回來。',
  },
  {
    id: 'c3',
    pet: '跳跳',
    emoji: '🐰',
    topic: 'Git',
    symptom: "Module not found: Can't resolve '@/lib/firebase'",
    code: [
      "import { useState } from 'react'",
      "import { db } from '@/lib/firebse'",
      "import List from '@/components/List'",
    ],
    bugLine: 2,
    options: [
      "import db from '@/lib/firebse'",
      "import { db } from 'lib/firebse'",
      "import { db } from '@/lib/firebase'",
    ],
    answer: 2,
    note: '路徑拼錯了，先讀錯誤訊息裡的檔名，再對照真正的檔案。',
  },
]
