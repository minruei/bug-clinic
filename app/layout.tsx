import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Bug Clinic 除蟲動物診所',
  description: '幫受傷的寵物抓出程式裡的 bug',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="zh-Hant" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  )
}
