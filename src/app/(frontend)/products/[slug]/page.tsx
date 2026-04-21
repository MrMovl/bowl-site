export const dynamic = 'force-dynamic'

import { notFound } from 'next/navigation'
import Link from 'next/link'
import { getPayload } from 'payload'
import config from '@payload-config'
import type { Metadata } from 'next'

import { ImageCarousel } from '@/components/ImageCarousel'
import { RichText } from '@/components/RichText'

type Props = { params: Promise<{ slug: string }> }

async function fetchProduct(slug: string) {
  const payload = await getPayload({ config })
  const result = await payload.find({
    collection: 'products',
    where: { slug: { equals: slug } },
    limit: 1,
    depth: 2,
  })
  return result.docs[0] ?? null
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params
  const product = await fetchProduct(slug)
  if (!product) return {}
  return { title: `${product.title} — Handmade Woodwork` }
}

function formatPrice(price: number, currency: string) {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency }).format(price)
}

type Dimensions = {
  height?: number | null
  diameter?: number | null
  unit?: string | null
} | null | undefined

function formatDimensions(dimensions: Dimensions) {
  if (!dimensions) return null
  const { height, diameter, unit } = dimensions
  const parts: string[] = []
  if (height != null) parts.push(`H ${height}${unit ?? 'cm'}`)
  if (diameter != null) parts.push(`Ø ${diameter}${unit ?? 'cm'}`)
  return parts.length > 0 ? parts.join(' · ') : null
}

export default async function ProductPage({ params }: Props) {
  const { slug } = await params
  const product = await fetchProduct(slug)
  if (!product) notFound()

  type CarouselImage = { url: string; alt: string; width?: number | null; height?: number | null }

  const images: CarouselImage[] = ((product.images ?? []) as { image: unknown }[])
    .reduce<CarouselImage[]>((acc, item) => {
      const img = item.image
      if (!img || typeof img !== 'object') return acc
      const url = 'url' in img ? (img.url as string | null) : null
      if (!url) return acc
      acc.push({
        url,
        alt: ('alt' in img ? (img.alt as string | undefined) : undefined) ?? product.title,
        width: 'width' in img ? (img.width as number | undefined) : undefined,
        height: 'height' in img ? (img.height as number | undefined) : undefined,
      })
      return acc
    }, [])

  const dims = formatDimensions(
    product.dimensions as Dimensions,
  )

  return (
    <div className="container page-content">
      <Link href="/" className="back-link">
        ← Back to gallery
      </Link>

      <div className="product-detail">
        <ImageCarousel images={images} />

        <div className="product-info">
          <div className="product-info__category">{product.category as string}</div>
          <h1 className="product-info__title">{product.title}</h1>

          <div className="product-info__price-row">
            <span className="product-info__price">
              {formatPrice(product.price, (product.currency as string) ?? 'EUR')}
            </span>
            {!product.available && (
              <span className="product-info__sold-badge">Sold</span>
            )}
          </div>

          {dims && <p className="product-info__dimensions">{dims}</p>}

          {product.description && (
            <div className="product-info__description">
              <RichText content={product.description as never} />
            </div>
          )}
        </div>
      </div>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'Product',
            name: product.title,
            offers: {
              '@type': 'Offer',
              price: product.price,
              priceCurrency: product.currency,
              availability: product.available
                ? 'https://schema.org/InStock'
                : 'https://schema.org/SoldOut',
            },
          }),
        }}
      />
    </div>
  )
}
