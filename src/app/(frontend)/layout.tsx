import type { Metadata } from 'next'
import { Footer } from '@/components/Footer'
import { Nav } from '@/components/Nav'
import '../globals.css'

export const metadata: Metadata = {
  title: 'Handmade Woodwork',
  description: 'Handcrafted bowls and woodwork, made on the lathe.',
}

export default function FrontendLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Nav />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  )
}
