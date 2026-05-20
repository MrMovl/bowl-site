import Link from 'next/link'

export function Footer() {
  return (
    <footer className="site-footer">
      <div className="container">
        <p>
          Handmade with care &mdash;{' '}
          <Link href="/legal">Legal notice</Link>
          {' · '}
          <Link href="/faq">FAQ</Link>
        </p>
      </div>
    </footer>
  )
}
