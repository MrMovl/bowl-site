import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="not-found">
      <h1>Page not found</h1>
      <p>
        <Link href="/">Back to gallery</Link>
      </p>
    </div>
  )
}
