// 每隻病患的物種特性，對應牠負責的程式觀念，幫助記憶
export const pets: Record<string, { pixel: string; species: string; hint: string }> = {
  小橘: { pixel: 'cat', species: '橘貓', hint: '貓很挑食，型別不對就不吃' },
  慢慢: { pixel: 'turtle', species: '烏龜', hint: '烏龜走很慢，要 await 等牠' },
  跳跳: { pixel: 'rabbit', species: '兔子', hint: '兔子會跳到別的檔案，路徑要寫對' },
  嚕嚕: { pixel: 'hamster', species: '倉鼠', hint: '倉鼠長得都很像，要靠 key 名牌分辨' },
  阿福: { pixel: 'dog', species: '小狗', hint: '狗會記住主人，像 state 會記住值' },
  企企: { pixel: 'penguin', species: '企鵝', hint: '企鵝排隊走，走過頭就掉進海裡' },
  狐狐: { pixel: 'fox', species: '狐狸', hint: '狐狸會變身，型別也會偷偷轉換' },
  圓圓: { pixel: 'panda', species: '熊貓', hint: '熊貓黑白兩色，資料也要轉成 JSON' },
  熊熊: { pixel: 'bear', species: '棕熊', hint: '熊把食物存進倉庫，就像資料庫' },
  咕咕: { pixel: 'owl', species: '貓頭鷹', hint: '貓頭鷹負責送信，回應一定要送回去' },
}

// 顯示用的名字：物種加名字，例如「烏龜 慢慢」
export function petLabel(name: string) {
  const pet = pets[name]
  return pet ? `${pet.species} ${name}` : name
}

// 每隻動物底下有很多題，這個函式把題目清單變成「每隻動物只留第一題」，用在選主題和圖鑑
export function onePerPet<T extends { pet_name: string }>(list: T[]): T[] {
  const seen = new Set<string>()
  return list.filter((p) => {
    if (seen.has(p.pet_name)) return false
    seen.add(p.pet_name)
    return true
  })
}
