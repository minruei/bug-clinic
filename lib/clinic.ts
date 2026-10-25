// 診所的房間：tag 是一句話說明功能，有 href 的可以點進去
// locked 是規劃中、之後用金幣解鎖的功能；pixel 是 public/pixel 裡的像素圖檔名
export const rooms = [
  {
    name: '小診療室',
    tag: '選主題練習',
    pixel: 'clinic',
    desc: '挑一個想練的觀念，或隨機抽一位',
    href: '/clinic',
  },
  {
    name: '住院部',
    tag: '錯題區',
    pixel: 'ward',
    desc: '沒治好的動物留院，複習後治好才出院',
    href: '/review',
  },
  { name: '圖鑑', tag: '收集', pixel: 'dex', desc: '治好動物、達成里程碑來收集', href: '/dex' },
  {
    name: '病歷本',
    tag: '練習紀錄',
    pixel: 'records',
    desc: '每一次看診的結果和花費時間',
    href: '/records',
  },
  { name: '合成獸實驗室', tag: '即將開放', pixel: 'lock', desc: '之後用金幣解鎖', locked: true },
]
