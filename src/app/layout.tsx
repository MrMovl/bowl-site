import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Handmade Woodwork',
  description: 'Handcrafted bowls and woodwork, made on the lathe.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
