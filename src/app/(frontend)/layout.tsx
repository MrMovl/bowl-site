import { Nav } from '@/components/Nav'
import { Footer } from '@/components/Footer'

export default function FrontendLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Nav />
      <main>{children}</main>
      <Footer />
    </>
  )
}
