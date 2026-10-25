# 把 sprites.py 的格子轉成 SVG，外框自動描邊
import os
from sprites import PAL, SPR, BEASTS, ICONS

SIZE = 16
OUTLINE = '#4a3426'
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'public', 'pixel')


def grid(txt):
    rows = [(r + '.' * SIZE)[:SIZE] for r in txt.strip('\n').split('\n')][:SIZE]
    while len(rows) < SIZE:
        rows.append('.' * SIZE)
    g = [list(r) for r in rows]
    out = [row[:] for row in g]
    # 透明格子旁邊有顏色，就畫成外框
    for y in range(SIZE):
        for x in range(SIZE):
            if g[y][x] != '.':
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < SIZE and 0 <= ny < SIZE and g[ny][nx] != '.':
                    out[y][x] = '#'
                    break
    return out


def svg(txt):
    rects = []
    for y, row in enumerate(grid(txt)):
        x = 0
        while x < SIZE:
            c = row[x]
            if c == '.':
                x += 1
                continue
            # 同一列連續同色的格子合成一個長方形，檔案比較小
            end = x
            while end < SIZE and row[end] == c:
                end += 1
            color = OUTLINE if c == '#' else PAL[c]
            rects.append(f'<rect x="{x}" y="{y}" width="{end - x}" height="1" fill="{color}"/>')
            x = end
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" '
        f'shape-rendering="crispEdges">{"".join(rects)}</svg>\n'
    )


def fills(txt):
    """把設計稿轉成顏色格子，None 是透明"""
    rows = [(r + '.' * SIZE)[:SIZE] for r in txt.strip('\n').split('\n')][:SIZE]
    while len(rows) < SIZE:
        rows.append('.' * SIZE)
    return [[None if c == '.' else PAL[c] for c in r] for r in rows]


def blend(color, target, t):
    """把顏色往 target 混合 t 的比例，用來做虛弱、昏迷的褪色"""
    a = [int(color[i:i + 2], 16) for i in (1, 3, 5)]
    b = [int(target[i:i + 2], 16) for i in (1, 3, 5)]
    return '#' + ''.join(f'{round(x + (y - x) * t):02x}' for x, y in zip(a, b))


def to_svg(cells, extra=()):
    """顏色格子描外框後轉成 SVG，extra 是不描框的裝飾（汗滴、Z）"""
    out = [row[:] for row in cells]
    for y in range(SIZE):
        for x in range(SIZE):
            if cells[y][x] is not None:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < SIZE and 0 <= ny < SIZE and cells[ny][nx] is not None:
                    out[y][x] = OUTLINE
                    break
    for x, y, color in extra:
        out[y][x] = color
    rects = []
    for y, row in enumerate(out):
        x = 0
        while x < SIZE:
            c = row[x]
            if c is None:
                x += 1
                continue
            end = x
            while end < SIZE and row[end] == c:
                end += 1
            rects.append(f'<rect x="{x}" y="{y}" width="{end - x}" height="1" fill="{c}"/>')
            x = end
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" '
        f'shape-rendering="crispEdges">{"".join(rects)}</svg>\n'
    )


EYE = PAL['k']


def dark_groups(cells):
    """找出相連的深色格子群（眼睛、嘴巴、耳朵）"""
    seen, groups = set(), []
    for y in range(SIZE):
        for x in range(SIZE):
            if cells[y][x] != EYE or (x, y) in seen:
                continue
            group, stack = [], [(x, y)]
            seen.add((x, y))
            while stack:
                cx, cy = stack.pop()
                group.append((cx, cy))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < SIZE and 0 <= ny < SIZE and (nx, ny) not in seen and cells[ny][nx] == EYE:
                        seen.add((nx, ny))
                        stack.append((nx, ny))
            groups.append(group)
    return groups


def find_eyes(cells):
    """眼睛：小塊的深色、不在頭頂（排除耳朵），而且是最上面那一排"""
    small = [g for g in dark_groups(cells) if len(g) <= 9 and min(y for _, y in g) >= 4]
    if not small:
        return []
    top = min(min(y for _, y in g) for g in small)
    return [g for g in small if min(y for _, y in g) <= top + 1]


def skin_around(cells, group):
    """眼睛旁邊最常見的顏色，用來把原本的眼睛蓋掉"""
    around = [cells[y + dy][x + dx] for x, y in group for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
              if 0 <= x + dx < SIZE and 0 <= y + dy < SIZE and cells[y + dy][x + dx] not in (None, EYE)]
    return max(set(around), key=around.count) if around else None


def redraw_eyes(cells, style):
    """把眼睛換成別的表情：tired 半閉、sleep 閉成 U 字"""
    for group in find_eyes(cells):
        skin = skin_around(cells, group)
        xs = [x for x, _ in group]
        ys = [y for _, y in group]
        left, right, top, bottom = min(xs), max(xs), min(ys), max(ys)
        for x in range(left, right + 1):
            for y in range(top, bottom + 1):
                cells[y][x] = skin
        if right - left < 2:
            left -= 1 if left > 0 else 0
            right = left + 2
        if style == 'tired':
            # 眼皮垂下來：上面一條線，下面只剩一點眼珠
            for x in range(left, right + 1):
                cells[top][x] = EYE
            cells[top + 1][(left + right) // 2] = EYE
        else:
            # 閉眼睡著：U 字形
            for x in range(left + 1, right):
                cells[bottom][x] = EYE
            cells[bottom - 1][left] = EYE
            cells[bottom - 1][right] = EYE
    return cells


def gloom(cells):
    """頭上的藍色直線，漫畫裡「很不舒服」的符號"""
    eyes = find_eyes(cells)
    if not eyes:
        return cells
    top = min(y for g in eyes for _, y in g)
    xs = [x for g in eyes for x, _ in g]
    # 畫在眼睛上方兩排，頭比較小的（像烏龜）就往下靠近眼睛
    rows = [y for y in (top - 3, top - 2, top - 1) if 0 <= y < SIZE and any(cells[y][min(xs):max(xs) + 1])][:2]
    marks = []
    for x in range(min(xs), max(xs) + 1, 2):
        for y in rows:
            if cells[y][x] is not None:
                marks.append((x, y))
    for x, y in marks:
        cells[y][x] = '#7f9cc4'
    return cells


def weak(txt):
    """虛弱：臉色發青、眼皮垂下、頭上有不舒服的藍線、冒大顆汗、身體往下垂"""
    cells = fills(txt)
    cells = [[c if c in (None, EYE) else blend(c, '#c3cfdb', 0.35) for c in row] for row in cells]
    cells = redraw_eyes(gloom(cells), 'tired')
    drooped = [[None] * SIZE] + cells[:-1]
    drop = '#5b8fd0'
    sweat = [(14, 1, drop), (13, 2, drop), (14, 2, '#cfe3f7'), (15, 2, drop), (13, 3, drop), (14, 3, drop), (15, 3, drop)]
    return to_svg(drooped, sweat)


def coma(txt):
    """昏迷：閉眼睡著、顏色變灰、頭上飄大大的 Zz（睡著，不是死掉）"""
    cells = redraw_eyes(fills(txt), 'sleep')
    grey = [[c if c in (None, EYE) else blend(c, '#b9b4ab', 0.6) for c in row] for row in cells]
    z = '#4f74a8'
    zs = [(10, 0, z), (11, 0, z), (12, 0, z), (13, 0, z), (12, 1, z), (11, 2, z), (10, 3, z), (11, 3, z), (12, 3, z), (13, 3, z),
          (14, 4, z), (15, 4, z), (15, 5, z), (14, 6, z), (15, 6, z)]
    return to_svg(grey, zs)


if __name__ == '__main__':
    os.makedirs(OUT_DIR, exist_ok=True)
    count = 0
    for group in (SPR, BEASTS, ICONS):
        for name, txt in group.items():
            with open(os.path.join(OUT_DIR, f'{name}.svg'), 'w') as f:
                f.write(svg(txt))
            count += 1
    # 每隻病患多兩種狀態：虛弱、昏迷
    for name, txt in SPR.items():
        if name == 'doctor':
            continue
        for mood, make in (('weak', weak), ('coma', coma)):
            with open(os.path.join(OUT_DIR, f'{name}-{mood}.svg'), 'w') as f:
                f.write(make(txt))
            count += 1
    print(f'產生了 {count} 張像素圖')
