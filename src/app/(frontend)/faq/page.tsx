export const dynamic = 'force-dynamic'

import { notFound } from 'next/navigation'
import { getPayload } from 'payload'
import config from '@payload-config'
import type { Metadata } from 'next'

import { RichText } from '@/components/RichText'

export const metadata: Metadata = { title: 'FAQ — Handmade Woodwork' }

export default async function FaqPage() {
  const payload = await getPayload({ config })
  const result = await payload.find({
    collection: 'pages',
    where: { slug: { equals: 'faq' } },
    limit: 1,
  })
  const page = result.docs[0]
  if (!page) notFound()

  return (
    <div className="container page-content">
      <div className="static-page">
        <h1>{page.title}</h1>
        <div className="rich-text">
          <RichText content={page.content} />
        </div>
      </div>
    </div>
  )
}
