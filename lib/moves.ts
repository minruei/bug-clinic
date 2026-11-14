// 動作參考的 20 招，畫面從這份資料產生，之後每日任務可以用 id 指到某一招
// 規則跟新手教程一樣：動作寫在 CSS（@keyframes 加上一個 class），JS 只負責加上、拿掉 class 或改 CSS 變數
// 每招的 JS 用 { } 包起來，裡面的 const body 不會跟預設程式碼的 const body 撞名
// 說明文字裡的程式碼用反引號包起來，畫面會顯示成行內程式碼
import { buildPage, installPart, SPEECH_CSS, starterChimera, type ChimeraCode } from '@/lib/chimera'

export type MoveLevel = 1 | 2 | 3 | 4

// 需要特定零件的招式：選擇器用 class 開頭比對，同部位不管裝哪一款都抓得到
// 例如 [class^="eye"] 抓得到 eye、eye-round、eye-star
export type MoveNeed = 'eyes' | 'tail'

export type Move = {
  id: string
  level: MoveLevel
  name: string
  // 這招學到的觀念，一句話
  concept: string
  // 效果說明
  effect: string
  needs?: MoveNeed
  // 鍵盤類的招式，要先點一下預覽區才收得到按鍵
  keyboard?: boolean
  css: string
  js: string
  // 逐行白話解釋
  explain: string[]
}

export const moveLevels: { level: MoveLevel; label: string }[] = [
  { level: 1, label: '第一級 事件入門' },
  { level: 2, label: '第二級 時間' },
  { level: 3, label: '第三級 變數' },
  { level: 4, label: '第四級 鍵盤與進階' },
]

export const needLabel: Record<MoveNeed, string> = {
  eyes: '眼睛',
  tail: '尾巴',
}

export const moves: Move[] = [
  {
    id: 'click-hop',
    level: 1,
    name: '點一下跳',
    concept: '事件：瀏覽器發生某件事（被點了），就執行你交給它的函式。',
    effect:
      '點一下身體，往上跳再落下。預設合成獸本來就會跳，加了這招會換成跳得更高的版本：同一個元素同時只能播一個動畫，後寫的贏。',
    css: `/* 跳多高改 -40px，跳多快改 0.5s */
.body.hop {
  animation: hop 0.5s ease-out;
}

@keyframes hop {
  50% {
    translate: 0 -40px;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('click', () => {
      body.classList.add('hop');
    });

    body.addEventListener('animationend', () => {
      body.classList.remove('hop');
    });
  }
}`,
    explain: [
      '最外面的 `{` 和 `}`：把這招包成一個小房間，裡面取的名字（像 `body`）不會跟外面已經有的撞名。',
      "`document.querySelector('.body')`：在網頁裡找到 class 是 body 的元素，也就是合成獸的身體。",
      '`if (body)`：確定真的找到身體才往下做；找不到（例如身體被刪掉了）就什麼都不做，不會報錯。',
      "`body.addEventListener('click', () => { … })`：跟身體說「有人點你的時候，做大括號裡的事」。",
      "`body.classList.add('hop')`：幫身體加上 hop 這個 class，CSS 的 `.body.hop` 就套上去，開始播跳的動畫。",
      "`animationend`：動畫播完時觸發，這時用 `classList.remove('hop')` 把 class 拿掉，下次點才能再跳。",
      '`@keyframes hop`：寫跳的過程，播到一半（`50%`）往上移 40px，開頭和結尾自動回到原位。',
    ],
  },
  {
    id: 'hover-shiver',
    level: 1,
    name: '滑鼠移上去發抖',
    concept: '一個動作可以拆成「開始」和「結束」兩個事件，各自處理。',
    effect: '滑鼠移到身體上會一直發抖，移開就停。手機沒有滑鼠，用手指點一下也會開始抖。',
    css: `/* 抖多大改 3px，抖多快改 0.1s */
.body.shiver {
  animation: shiver 0.1s linear infinite;
}

@keyframes shiver {
  25% {
    translate: -3px 0;
  }
  75% {
    translate: 3px 0;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('mouseenter', () => {
      body.classList.add('shiver');
    });

    body.addEventListener('mouseleave', () => {
      body.classList.remove('shiver');
    });
  }
}`,
    explain: [
      '`{ }`、`querySelector`、`if (body)`：跟「點一下跳」一樣，找到身體才做事。',
      '`mouseenter`：滑鼠「進入」身體的範圍時觸發，這時加上 `shiver`，開始抖。',
      '`mouseleave`：滑鼠「離開」身體時觸發，把 `shiver` 拿掉，就停下來。',
      '`infinite`：動畫一直重複播，所以只要 class 還在就會一直抖。',
      '`25%` 往左 3px、`75%` 往右 3px：左右來回，看起來就像在發抖。',
    ],
  },
  {
    id: 'dblclick-squint',
    level: 1,
    name: '點兩下換表情',
    concept: '`classList.toggle`：有就拿掉、沒有就加上，一個按鈕切換兩種狀態。',
    effect: '點兩下身體，眼睛瞇起來；再點兩下，眼睛張開。',
    needs: 'eyes',
    css: `/* 瞇眼：把眼睛壓扁，改 0.2 調瞇多細 */
.body.squint [class^="eye"] {
  scale: 1 0.2;
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('dblclick', () => {
      body.classList.toggle('squint');
    });
  }
}`,
    explain: [
      '`dblclick`：連續快速點兩下才觸發；點兩下也會算到兩次 click，所以身體會先跳兩下。',
      "`body.classList.toggle('squint')`：身體沒有 squint 就加上，有就拿掉，所以點兩下切換一次表情。",
      '`.body.squint [class^="eye"]`：身體有 squint 時，裡面所有 class 開頭是 eye 的元素，不管裝的是哪一款眼睛都抓得到。',
      '`scale: 1 0.2`：寬度不變、高度剩兩成，眼睛就瞇成一條線。',
    ],
  },
  {
    id: 'press-grow',
    level: 1,
    name: '按住變大放開變回',
    concept: '按下和放開是兩個不同的事件，中間這段時間就是「按住」。',
    effect: '在身體上按住滑鼠，身體慢慢變大；放開或滑鼠移出去就變回原本大小。',
    css: `/* 變多大改 1.3，變多快改 0.2s */
.body.pressed {
  animation: grow 0.2s ease-out forwards;
}

@keyframes grow {
  to {
    scale: 1.3;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('mousedown', () => {
      body.classList.add('pressed');
    });

    body.addEventListener('mouseup', () => {
      body.classList.remove('pressed');
    });

    body.addEventListener('mouseleave', () => {
      body.classList.remove('pressed');
    });
  }
}`,
    explain: [
      '`mousedown`：滑鼠按鈕「按下去」那一刻觸發，加上 `pressed` 開始變大。',
      '`mouseup`：按鈕「放開」那一刻觸發，拿掉 `pressed` 變回原本大小。',
      '`mouseleave`：按著拖出身體外面再放開，身體收不到 mouseup，所以離開時也要拿掉。',
      '`forwards`：動畫播完停在最後一格，所以按住的時候會一直維持變大的樣子。',
      '`to { scale: 1.3; }`：`to` 是動畫的最後一格，放大到 1.3 倍。',
    ],
  },
  {
    id: 'click-spin',
    level: 1,
    name: '點一下轉一圈',
    concept: '同一個事件可以接不同的動畫，換掉 class 和 @keyframes 就是新動作。',
    effect:
      '點一下身體，轉一圈。跟點一下跳都寫在身體上，同時只能播一個，後寫的贏，所以加了這招會改成轉圈。',
    css: `/* 轉幾圈改 360deg（720deg 是兩圈），轉多快改 0.6s */
.body.spin {
  animation: spin 0.6s ease-in-out;
}

@keyframes spin {
  to {
    rotate: 360deg;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('click', () => {
      body.classList.add('spin');
    });

    body.addEventListener('animationend', () => {
      body.classList.remove('spin');
    });
  }
}`,
    explain: [
      '`click` 加上 `spin`、`animationend` 拿掉：跟「點一下跳」一模一樣，只是 class 名字換了。',
      '`rotate: 360deg`：轉 360 度，剛好一整圈；`deg` 是角度的單位。',
      '`ease-in-out`：開頭和結尾慢、中間快，轉起來比較自然。',
    ],
  },
  {
    id: 'blink-interval',
    level: 2,
    name: '定時眨眼',
    concept: '`setInterval`：每隔一段時間就重複做一次同一件事。',
    effect: '每 3 秒眨一次眼，不用點，打開就會自己眨。',
    needs: 'eyes',
    css: `/* 眨眼：眼睛壓扁再張開 */
.body.blink [class^="eye"] {
  animation: blink 0.2s ease-in-out;
}

@keyframes blink {
  50% {
    scale: 1 0.1;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    setInterval(() => {
      body.classList.add('blink');
      setTimeout(() => {
        body.classList.remove('blink');
      }, 200);
    }, 3000);
  }
}`,
    explain: [
      '`setInterval(() => { … }, 3000)`：每 3000 毫秒（3 秒）做一次大括號裡的事，一直重複。',
      "`body.classList.add('blink')`：加上 blink，眼睛開始播眨眼動畫。",
      '`setTimeout(() => { … }, 200)`：等 200 毫秒（動畫播完）再把 blink 拿掉，下一次才眨得起來；下一招會細講 setTimeout。',
      '`[class^="eye"]`：抓所有 class 開頭是 eye 的元素，哪一款眼睛都能眨。',
    ],
  },
  {
    id: 'wave-timeout',
    level: 2,
    name: '打開後揮手打招呼',
    concept: '`setTimeout`：等一段時間之後，只做一次。',
    effect:
      '打開頁面 1 秒後，身體左右搖兩下，像在揮手打招呼。按存檔或改程式碼後預覽重新整理，也會再打一次招呼。',
    css: `/* 左右搖兩下，改 2 調搖幾次 */
.body.wave {
  animation: wave 0.6s ease-in-out 2;
}

@keyframes wave {
  25% {
    rotate: -10deg;
  }
  75% {
    rotate: 10deg;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    setTimeout(() => {
      body.classList.add('wave');
    }, 1000);

    body.addEventListener('animationend', () => {
      body.classList.remove('wave');
    });
  }
}`,
    explain: [
      '`setTimeout(() => { … }, 1000)`：等 1000 毫秒（1 秒）後做一次，做完就結束，不會重複。',
      "`body.classList.add('wave')`：時間到了加上 wave，開始搖。",
      '`animationend` 拿掉 wave：不拿掉的話，wave 一直留在身體上，會蓋掉之後點一下跳的動畫。',
      '`animation: wave 0.6s ease-in-out 2`：最後的 `2` 是播兩次。',
      '`rotate: -10deg` 和 `10deg`：往左歪、往右歪，搖來搖去。',
    ],
  },
  {
    id: 'random-yawn',
    level: 2,
    name: '隨機時間打哈欠',
    concept: '`Math.random()` 產生 0 到 1 之間的亂數，拿來決定「要等多久」。',
    effect: '每隔 3 到 8 秒（每次不一樣）伸個懶腰打哈欠，身體往上拉長再縮回來。',
    css: `/* 打哈欠：往上拉長再縮回來 */
.body.yawn {
  animation: yawn 1.2s ease-in-out;
}

@keyframes yawn {
  40%,
  60% {
    scale: 0.95 1.15;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    const yawnLater = () => {
      const wait = 3000 + Math.random() * 5000;
      setTimeout(() => {
        body.classList.add('yawn');
        yawnLater();
      }, wait);
    };

    body.addEventListener('animationend', () => {
      body.classList.remove('yawn');
    });

    yawnLater();
  }
}`,
    explain: [
      '`const yawnLater = () => { … }`：把「等一下再打哈欠」包成一個函式，取名 yawnLater，要用的時候叫它。',
      '`Math.random() * 5000`：`Math.random()` 是 0～1 的亂數，乘 5000 就是 0～5000，再加 3000，等的時間落在 3～8 秒。',
      '`setTimeout(() => { … }, wait)`：等 wait 毫秒之後，加上 yawn 開始打哈欠。',
      '裡面又呼叫一次 `yawnLater()`：打完這次就排下一次，每次等的時間都重新抽，所以不會很規律。',
      '最後一行 `yawnLater()`：一打開就先排第一次。',
      '`40%, 60%` 寫在一起：這兩格的樣子一樣，中間會停一下，像哈欠打很長。',
    ],
  },
  {
    id: 'sleep-timeout',
    level: 2,
    name: '10 秒沒點就睡著',
    concept: '`clearTimeout`：取消還沒發生的 setTimeout，重新開始計時。',
    effect: '10 秒沒有點牠，就會變暗、慢慢起伏睡著；點一下會醒來，再重新數 10 秒。',
    css: `/* 睡著：變暗、慢慢起伏 */
.body.asleep {
  filter: brightness(0.7);
  animation: snooze 3s ease-in-out infinite;
}

@keyframes snooze {
  50% {
    scale: 1.05 0.92;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    let timer;

    const sleepLater = () => {
      clearTimeout(timer);
      timer = setTimeout(() => {
        body.classList.add('asleep');
      }, 10000);
    };

    body.addEventListener('click', () => {
      body.classList.remove('asleep');
      sleepLater();
    });

    sleepLater();
  }
}`,
    explain: [
      '`let timer`：準備一個變數記住「目前排好的那個 setTimeout」，用 `let` 是因為之後會換成新的。',
      '`clearTimeout(timer)`：把還沒到時間的那個取消，不然舊的計時還在跑，時間一到照樣睡著。',
      '`timer = setTimeout(…, 10000)`：重新排一個 10 秒後睡著，並記在 timer 裡，下次才取消得到。',
      '點一下：先拿掉 `asleep` 醒過來，再呼叫 `sleepLater()` 從頭數 10 秒。',
      '`filter: brightness(0.7)`：亮度剩七成，看起來暗暗的像睡著了。',
    ],
  },
  {
    id: 'tail-interval',
    level: 2,
    name: '一直搖尾巴、點一下停',
    concept: '`clearInterval`：讓 setInterval 停下來，不再重複。',
    effect: '尾巴一直左右甩，點一下身體就停住。',
    needs: 'tail',
    css: `/* 甩一下尾巴：往上再往下 */
.body.tail-flick [class^="tail"] {
  animation: tail-flick 0.4s ease-in-out;
}

@keyframes tail-flick {
  25% {
    rotate: -20deg;
  }
  75% {
    rotate: 20deg;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    const timer = setInterval(() => {
      body.classList.add('tail-flick');
      setTimeout(() => {
        body.classList.remove('tail-flick');
      }, 400);
    }, 500);

    body.addEventListener('click', () => {
      clearInterval(timer);
    });
  }
}`,
    explain: [
      '`const timer = setInterval(…, 500)`：每 0.5 秒甩一次尾巴；setInterval 會回傳一個編號，存在 timer 裡。',
      '甩完 400 毫秒後拿掉 `tail-flick`：下一次加上去才會重新播。',
      '`clearInterval(timer)`：點一下身體，用剛剛存的編號叫它停，之後就不會再甩。',
      '`[class^="tail"]`：抓所有 class 開頭是 tail 的元素，哪一款尾巴都能甩。',
    ],
  },
  {
    id: 'poke-count',
    level: 3,
    name: '被戳計數',
    concept: '變數可以記住數字，每次加一，再把結果寫回畫面上。',
    effect:
      '每點一下，對話框就顯示「被戳了 N 下」，數字一直往上加。合成獸沒有對話框的話，JS 會先生一個出來。',
    css: `${SPEECH_CSS}

/* 數字變了，對話框彈一下 */
.speech.pop {
  animation: pop 0.2s ease-out;
}

@keyframes pop {
  50% {
    scale: 1.2;
  }
}`,
    js: `{
  const body = document.querySelector('.body');
  const chimera = document.querySelector('.chimera');
  let speech = document.querySelector('.speech');

  if (!speech && chimera) {
    speech = document.createElement('div');
    speech.className = 'speech';
    chimera.append(speech);
  }

  if (body && speech) {
    let count = 0;

    body.addEventListener('click', () => {
      count = count + 1;
      speech.textContent = '被戳了 ' + count + ' 下';
      speech.classList.add('pop');
    });

    speech.addEventListener('animationend', () => {
      speech.classList.remove('pop');
    });
  }
}`,
    explain: [
      "`let speech = document.querySelector('.speech')`：先找找看有沒有對話框；用 `let` 是因為等一下可能要換成新生出來的那個。",
      '`if (!speech && chimera)`：`!speech` 是「沒有找到對話框」，沒有的話就自己生一個，放進外層的 .chimera。',
      "`document.createElement('div')`：JS 也能生出新的元素，這行做出一個新的 `<div>`，這時候還沒放進網頁。",
      "`speech.className = 'speech'`：幫它取名叫 speech，CSS 寫好的對話框樣式就會套上去。",
      '`chimera.append(speech)`：放進 .chimera 裡面，畫面上就出現了；本來就有對話框的合成獸會直接用原本那個，不會多生一個。',
      '`.chimera > .speech`：CSS 只管放在 .chimera 底下那一層的對話框；`:empty` 是還沒有字的時候先藏起來。',
      '`let count = 0`：做一個叫 count 的變數，從 0 開始。',
      '`count = count + 1`：每點一下，拿原本的數字加 1 再存回去。',
      "`speech.textContent = '被戳了 ' + count + ' 下'`：用 `+` 把文字和數字接起來，換掉對話框裡的字。",
      "`speech.classList.add('pop')`：對話框加上 pop，彈一下提醒你數字變了。",
    ],
  },
  {
    id: 'higher-hop',
    level: 3,
    name: '越點跳越高',
    concept: 'JS 改 CSS 變數：CSS 先寫好怎麼跳，JS 只改「跳多高」這個數字。',
    effect: '每點一下就比上一次跳高一點，最高到 120px。會蓋掉原本點一下跳的動畫。',
    css: `/* 跳多高看 --hop-height，JS 每點一下就把它調高 */
.body.leap {
  animation: leap 0.5s ease-out;
}

@keyframes leap {
  50% {
    translate: 0 calc(var(--hop-height, 20px) * -1);
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    let height = 20;

    body.addEventListener('click', () => {
      height = Math.min(height + 15, 120);
      body.style.setProperty('--hop-height', height + 'px');
      body.classList.add('leap');
    });

    body.addEventListener('animationend', () => {
      body.classList.remove('leap');
    });
  }
}`,
    explain: [
      '`let height = 20`：記住現在跳多高，一開始 20。',
      '`Math.min(height + 15, 120)`：每次加 15，但最多 120；`Math.min` 會選兩個數字裡比較小的那個。',
      "`body.style.setProperty('--hop-height', height + 'px')`：把 CSS 變數 `--hop-height` 改成新的高度，例如 35px。",
      '`var(--hop-height, 20px)`：CSS 讀這個變數，還沒設過就用 20px。',
      '`calc(… * -1)`：往上是負的，所以乘上 -1。',
    ],
  },
  {
    id: 'random-color',
    level: 3,
    name: '每次點換隨機顏色',
    concept: '亂數加上變數，每次都算出一個新顏色。',
    effect: '每點一下，毛色就換成隨機的一個顏色，慢慢變過去。',
    css: `/* 換顏色的時候慢慢變過去，不要一下子跳色 */
.body {
  transition: background-color 0.4s;
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    body.addEventListener('click', () => {
      const hue = Math.floor(Math.random() * 360);
      body.style.setProperty('--fur-color', 'hsl(' + hue + ' 70% 65%)');
    });
  }
}`,
    explain: [
      '`Math.random() * 360`：0～360 之間的亂數，`Math.floor` 把小數點拿掉。',
      '`hsl(色相 70% 65%)`：另一種寫顏色的方法，第一個數字是色相，0 紅、120 綠、240 藍，轉一圈 360。',
      "`setProperty('--fur-color', …)`：改掉毛色變數，身體的 `background: var(--fur-color)` 就跟著變。",
      '`transition: background-color 0.4s`：顏色改變時花 0.4 秒慢慢變，不是一下子跳過去。',
    ],
  },
  {
    id: 'random-line',
    level: 3,
    name: '點一下隨機說一句話',
    concept: '陣列：把好幾個東西排成一列，用編號拿出其中一個。',
    effect:
      '每點一下，對話框隨機換成一句話。合成獸沒有對話框的話，JS 會先生一個出來。想讓牠說別的，就改陣列裡的句子。',
    css: `${SPEECH_CSS}

/* 換句子的時候，對話框搖一下 */
.speech.chat {
  animation: chat 0.3s ease-in-out;
}

@keyframes chat {
  25% {
    rotate: -5deg;
  }
  75% {
    rotate: 5deg;
  }
}`,
    js: `{
  const body = document.querySelector('.body');
  const chimera = document.querySelector('.chimera');
  let speech = document.querySelector('.speech');

  if (!speech && chimera) {
    speech = document.createElement('div');
    speech.className = 'speech';
    chimera.append(speech);
  }

  if (body && speech) {
    const lines = ['你好！', '肚子餓了', '再點一下嘛', '我會跳喔', '今天天氣真好'];

    body.addEventListener('click', () => {
      const index = Math.floor(Math.random() * lines.length);
      speech.textContent = lines[index];
      speech.classList.add('chat');
    });

    speech.addEventListener('animationend', () => {
      speech.classList.remove('chat');
    });
  }
}`,
    explain: [
      "`document.querySelector('.speech')`：先找找看有沒有對話框，找到就直接用，例如新手教程的怪物本來就有。",
      "`document.createElement('div')`：找不到的話，JS 也能生出新的元素：做一個新的 `<div>`，取名 speech，再用 `chimera.append(speech)` 放進 .chimera；第 11 招「被戳計數」也是同樣的做法。",
      '`.chimera > .speech` 那一大段 CSS：對話框的白底、圓角和小尾巴，跟著身體的 `--speech-y` 擺在頭上；`:empty` 是還沒有字的時候先藏起來。',
      "`const lines = ['你好！', …]`：方括號是陣列，裡面五句話，用逗號隔開。",
      '`lines.length`：陣列有幾個東西，這裡是 5。',
      '`Math.floor(Math.random() * lines.length)`：抽一個 0～4 的整數，當作編號。',
      '`lines[index]`：拿出第 index 句；編號從 0 開始，`lines[0]` 是第一句。',
      '`speech.textContent = …`：把那一句放進對話框。',
    ],
  },
  {
    id: 'mood',
    level: 3,
    name: '心情值',
    concept: '`if` 判斷：看數字落在哪個範圍，決定要做什麼。',
    effect: '常點牠心情會變好，顏色變鮮豔；放著不管心情會慢慢變差，變灰、垂下來。',
    css: `/* 開心：顏色鮮豔；難過：變灰、垂下來 */
.body.happy {
  filter: saturate(1.6) brightness(1.1);
}

.body.sad {
  filter: grayscale(0.8);
  scale: 1 0.9;
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    let mood = 50;

    const showMood = () => {
      body.classList.remove('happy', 'sad');
      if (mood > 70) {
        body.classList.add('happy');
      } else if (mood < 30) {
        body.classList.add('sad');
      }
    };

    body.addEventListener('click', () => {
      mood = Math.min(mood + 10, 100);
      showMood();
    });

    setInterval(() => {
      mood = Math.max(mood - 2, 0);
      showMood();
    }, 1000);
  }
}`,
    explain: [
      '`let mood = 50`：心情值從 50 開始，最低 0、最高 100。',
      '`Math.min(mood + 10, 100)`：點一下加 10，最多 100；`Math.max(mood - 2, 0)` 每秒減 2，最少 0。',
      "`classList.remove('happy', 'sad')`：先把兩種心情都拿掉，等一下再決定要加哪一個。",
      '`if (mood > 70)`：大於 70 加上 happy；`else if (mood < 30)`：小於 30 加上 sad；都不是就保持原樣。',
      '`setInterval(…, 1000)`：每秒算一次，放著不管心情就會往下掉。',
    ],
  },
  {
    id: 'arrow-walk',
    level: 4,
    name: '方向鍵左右走',
    concept: '`keydown`：按下鍵盤時觸發，`event.key` 告訴你按的是哪一個鍵。',
    effect: '按左右方向鍵，合成獸往左、往右走，走到邊邊就停。對話框跟著一起走。',
    keyboard: true,
    css: `/* 走路：移動外層的 .chimera，身體和對話框一起走；0.2s 是走一步花的時間 */
.chimera {
  translate: var(--walk-x, 0px) 0;
  transition: translate 0.2s;
}`,
    js: `{
  const chimera = document.querySelector('.chimera');

  if (chimera) {
    document.addEventListener('keydown', (event) => {
      let x = parseFloat(chimera.style.getPropertyValue('--walk-x')) || 0;
      if (event.key === 'ArrowLeft') {
        x = x - 20;
      } else if (event.key === 'ArrowRight') {
        x = x + 20;
      } else {
        return;
      }
      const edge = window.innerWidth / 2 - 70;
      x = Math.max(-edge, Math.min(x, edge));
      chimera.style.setProperty('--walk-x', x + 'px');
    });
  }
}`,
    explain: [
      "`document.querySelector('.chimera')`：找到最外層的 .chimera，身體和對話框都在它裡面，移動它就會一起走。",
      "`document.addEventListener('keydown', …)`：整個頁面收鍵盤，不用先點到身體。",
      "`parseFloat(chimera.style.getPropertyValue('--walk-x')) || 0`：讀出現在走到哪；還沒走過是空的，就當作 0。",
      "`event.key === 'ArrowLeft'`：按的是左方向鍵，x 減 20 往左；`ArrowRight` 加 20 往右。",
      '`else { return; }`：按的是別的鍵，後面就不做了。',
      '`window.innerWidth / 2 - 70`：預覽框寬度的一半再少一點，就是最遠能走到哪。',
      '`Math.max(-edge, Math.min(x, edge))`：把 x 夾在左右兩邊之間，不會走出畫面。',
      '`translate: var(--walk-x, 0px) 0`：用 translate 移動，跟會呼吸的身體用的 scale 是不同的屬性，兩個不會互相蓋掉。',
    ],
  },
  {
    id: 'space-hop',
    level: 4,
    name: '空白鍵跳',
    concept: '判斷按鍵：只在按下特定按鍵時才做事。',
    effect: '按空白鍵，合成獸跳一下。',
    keyboard: true,
    css: `/* 按空白鍵跳一下 */
.body.space-hop {
  animation: space-hop 0.4s ease-out;
}

@keyframes space-hop {
  50% {
    translate: 0 -35px;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    document.addEventListener('keydown', (event) => {
      if (event.code === 'Space') {
        event.preventDefault();
        body.classList.add('space-hop');
      }
    });

    body.addEventListener('animationend', () => {
      body.classList.remove('space-hop');
    });
  }
}`,
    explain: [
      "`event.code === 'Space'`：按的是空白鍵才往下做，其他鍵都不理。",
      '`event.preventDefault()`：空白鍵本來會讓網頁往下捲，這行把它擋掉。',
      "`classList.add('space-hop')`：加上 class 開始跳，`animationend` 再拿掉，下次才能再跳。",
    ],
  },
  {
    id: 'eyes-follow',
    level: 4,
    name: '眼睛跟著滑鼠看',
    concept: '`mousemove` 的 `clientX`、`clientY` 是滑鼠的座標，拿來算要往哪邊看。',
    effect: '滑鼠在預覽區移動，眼睛會往滑鼠的方向看。',
    needs: 'eyes',
    css: `/* 眼睛往 --look-x、--look-y 的方向移一點 */
.body [class^="eye"] {
  translate: var(--look-x, 0px) var(--look-y, 0px);
  transition: translate 0.1s;
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    document.addEventListener('mousemove', (event) => {
      const box = body.getBoundingClientRect();
      const dx = event.clientX - (box.left + box.width / 2);
      const dy = event.clientY - (box.top + box.height / 2);
      const x = Math.max(-4, Math.min(dx / 20, 4));
      const y = Math.max(-4, Math.min(dy / 20, 4));
      body.style.setProperty('--look-x', x + 'px');
      body.style.setProperty('--look-y', y + 'px');
    });
  }
}`,
    explain: [
      '`mousemove`：滑鼠一移動就觸發，`event.clientX`、`event.clientY` 是滑鼠離預覽框左邊、上面多遠。',
      '`body.getBoundingClientRect()`：量身體現在在哪、多大，`box.left + box.width / 2` 是身體中心的 x。',
      '`dx`、`dy`：滑鼠減掉身體中心，正的是在右邊（下面），負的是在左邊（上面）。',
      '`dx / 20` 再夾在 -4 到 4 之間：滑鼠再遠，眼睛最多也只移 4px，不會跑出臉。',
      '`translate: var(--look-x) var(--look-y)`：CSS 照 JS 算好的數字移動眼睛。',
    ],
  },
  {
    id: 'click-walk',
    level: 4,
    name: '點哪裡走過去',
    concept: '點擊位置換算：滑鼠座標從左邊算起，合成獸從中間出發，要先換算成同一個基準。',
    effect:
      '點預覽區的任何地方，合成獸就左右走到那個位置，對話框跟著一起走。可以跟方向鍵左右走一起用。',
    css: `/* 走路：移動外層的 .chimera，身體和對話框一起走；0.6s 是走過去花的時間 */
.chimera {
  translate: var(--walk-x, 0px) 0;
  transition: translate 0.6s ease-in-out;
}`,
    js: `{
  const chimera = document.querySelector('.chimera');

  if (chimera) {
    document.addEventListener('click', (event) => {
      const x = event.clientX - window.innerWidth / 2;
      chimera.style.setProperty('--walk-x', x + 'px');
    });
  }
}`,
    explain: [
      "`document.querySelector('.chimera')`：找到最外層的 .chimera，移動它，身體和對話框就一起走。",
      "`document.addEventListener('click', …)`：點整個頁面的任何地方都收得到，不只身體。",
      '`event.clientX`：點的位置離預覽框左邊多遠。',
      '`- window.innerWidth / 2`：合成獸一開始在正中間，減掉一半寬度，就變成「離中間多遠」，左邊是負的、右邊是正的。',
      "`setProperty('--walk-x', x + 'px')`：跟方向鍵左右走用同一個變數，兩招可以一起用。",
    ],
  },
  {
    id: 'triple-combo',
    level: 4,
    name: '連點三下放大招',
    concept: '計數加上計時：在一小段時間內點滿三下才算數。',
    effect: '0.6 秒內連點三下，合成獸放大轉一圈再變回來。點太慢會重新數。',
    css: `/* 大招：放大轉一圈，顏色閃一下 */
.body.combo {
  animation: combo 1s ease-in-out;
}

@keyframes combo {
  40% {
    scale: 1.4;
    filter: hue-rotate(180deg);
  }
  100% {
    rotate: 360deg;
  }
}`,
    js: `{
  const body = document.querySelector('.body');

  if (body) {
    let clicks = 0;
    let timer;

    body.addEventListener('click', () => {
      clicks = clicks + 1;
      clearTimeout(timer);
      timer = setTimeout(() => {
        clicks = 0;
      }, 600);

      if (clicks === 3) {
        clicks = 0;
        body.classList.add('combo');
      }
    });

    body.addEventListener('animationend', () => {
      body.classList.remove('combo');
    });
  }
}`,
    explain: [
      '`let clicks = 0`：記住連點了幾下。',
      '`clearTimeout(timer)` 再重新 `setTimeout(…, 600)`：每點一下就重新數 0.6 秒，0.6 秒內沒再點，clicks 就歸零。',
      '`if (clicks === 3)`：剛好點滿三下，`===` 是「完全等於」。',
      '`clicks = 0` 再加上 `combo`：放大招，數字歸零，下次要重新點三下。',
      '`hue-rotate(180deg)`：把顏色轉到色環的另一邊，閃一下不一樣的顏色。',
    ],
  },
]

// 招式在玩家程式碼裡的標記，例如 /* [move:click-hop] 點一下跳 開始 */
function markers(move: Move) {
  return {
    cssStart: `/* [move:${move.id}] ${move.name} 開始 */`,
    cssEnd: `/* [move:${move.id}] 結束 */`,
    jsStart: `// [move:${move.id}] ${move.name} 開始`,
    jsEnd: `// [move:${move.id}] 結束`,
  }
}

// 這招加過了沒：CSS 或 JS 任一格找得到開始標記就算加過
export function hasMove(code: ChimeraCode, move: Move) {
  const { cssStart, jsStart } = markers(move)
  return code.css.includes(cssStart) || code.js.includes(jsStart)
}

// 把這招接在 CSS 和 JS 最後面，原本的程式碼不動；已經加過就原樣回傳
export function addMove(code: ChimeraCode, move: Move): ChimeraCode {
  if (hasMove(code, move)) return code
  const m = markers(move)
  const css = code.css.trimEnd()
  const js = code.js.trimEnd()
  return {
    html: code.html,
    css: `${css ? `${css}\n\n` : ''}${m.cssStart}\n${move.css}\n${m.cssEnd}\n`,
    js: `${js ? `${js}\n\n` : ''}${m.jsStart}\n${move.js}\n${m.jsEnd}\n`,
  }
}

// 需要的零件有沒有裝：跟 CSS 一樣看 class 開頭，例如 class="eye-round left"
export function hasNeededPart(code: ChimeraCode, move: Move) {
  if (!move.needs) return true
  const prefix = move.needs === 'eyes' ? 'eye' : 'tail'
  return new RegExp(`class\\s*=\\s*["']${prefix}`).test(code.html)
}

// 示範預覽用的簡單眼睛和尾巴，需要零件的招式才看得到效果
const demoParts = {
  eyes: {
    html: `<div class="eye left"></div>
<div class="eye right"></div>`,
    css: `.eye {
  position: absolute;
  top: calc(50% - 20px);
  width: 14px;
  height: 14px;
  background: #2b1d14;
}

.eye.left {
  left: calc(50% - 32px);
}

.eye.right {
  left: calc(50% + 18px);
}`,
  },
  tail: {
    html: '<div class="tail-demo"></div>',
    css: `.tail-demo {
  position: absolute;
  top: calc(50% + 10px);
  left: calc(50% + 64px);
  width: 44px;
  height: 12px;
  background: #4a3426;
  transform-origin: left center;
}`,
  },
}

// 動作參考的示範預覽：預設合成獸加上這一招，需要零件的先裝上示範用的零件
export function moveDemoPage(move: Move) {
  let code = starterChimera
  if (move.needs) {
    const part = demoParts[move.needs]
    code = installPart(code, {
      id: 0,
      slot: move.needs,
      name: `示範用${needLabel[move.needs]}`,
      code: { html: part.html, css: part.css, js: '' },
    })
  }
  return buildPage(addMove(code, move))
}
