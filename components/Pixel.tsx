import Image from 'next/image'
import { pets } from '@/lib/pets'

type PixelProps = {
  name: string
  size?: number
  alt?: string
  locked?: boolean
}

// 像素圖：locked 會變成灰色剪影
export function Pixel({ name, size = 48, alt = '', locked = false }: PixelProps) {
  return (
    <Image
      src={`/pixel/${name}.svg`}
      width={size}
      height={size}
      alt={alt}
      className={`pixel ${locked ? 'silhouette' : ''}`}
      unoptimized
    />
  )
}

type PetProps = {
  pet: string
  emoji: string
  size?: number
  locked?: boolean
  mood?: 'normal' | 'weak' | 'coma'
}

// 病患頭像：有畫好的就用像素圖，新題目還沒畫就先用 emoji
// mood：normal 正常、weak 虛弱（血量剩不到一半）、coma 昏迷（時間到或失敗）
export function PetIcon({ pet, emoji, size = 48, locked = false, mood = 'normal' }: PetProps) {
  const name = pets[pet]?.pixel
  if (!name) return <span style={{ fontSize: size * 0.8 }}>{emoji}</span>
  const file = mood === 'normal' ? name : `${name}-${mood}`
  return <Pixel name={file} size={size} alt={pet} locked={locked} />
}

// 稀有度：幾顆像素星星加上分類名稱
export function Rarity({ rank, tier }: { rank: number; tier: string }) {
  return (
    <span className="rarity">
      {Array.from({ length: rank }, (_, i) => (
        <Pixel key={i} name="star" size={14} />
      ))}
      {tier}
    </span>
  )
}
