import Link from 'next/link'

export function Nav() {
  return (
    <nav className="site-nav">
      <div className="container site-nav__inner">
        <Link href="/" className="site-nav__brand">
          Handmade Woodwork
        </Link>
        <ul className="site-nav__links">
          <li><Link href="/">Gallery</Link></li>
          <li><Link href="/faq">FAQ</Link></li>
          <li><Link href="/legal">Legal</Link></li>
        </ul>
      </div>
    </nav>
  )
}
