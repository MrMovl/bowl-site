export const dynamic = 'force-dynamic'

import { Suspense } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { getPayload } from 'payload'
import type { Where } from 'payload'
import config from '@payload-config'

import { FilterBar } from '@/components/FilterBar'

type SearchParams = Promise<{ category?: string; available?: string }>

async function fetchProducts(category?: string, available?: string) {
  const payload = await getPayload({ config })

  const and: Where[] = []
  if (category) and.push({ category: { equals: category } })
  if (available === 'true') and.push({ available: { equals: true } })

  const where: Where = and.length > 0 ? { and } : {}

  const result = await payload.find({
    collection: 'products',
    where,
    sort: '-createdAt',
    limit: 100,
    depth: 1,
  })
  return result.docs
}

function formatPrice(price: number, currency: string) {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency }).format(price)
}

type ProductDoc = Awaited<ReturnType<typeof fetchProducts>>[number]

function ProductCard({ product }: { product: ProductDoc }) {
  const firstImageItem = product.images?.[0]
  const firstImage =
    firstImageItem && typeof firstImageItem.image === 'object' && firstImageItem.image !== null
      ? firstImageItem.image
      : null

  const imageUrl = firstImage && 'url' in firstImage ? (firstImage.url as string | null) : null
  const imageAlt = firstImage && 'alt' in firstImage ? (firstImage.alt as string) : product.title

  return (
    <Link href={`/products/${product.slug}`} className="product-card">
      <div className="product-card__image">
        {imageUrl ? (
          <Image src={imageUrl} alt={imageAlt} width={600} height={600} />
        ) : (
          <div style={{ width: '100%', height: '100%', background: 'var(--color-border)' }} />
        )}
        {!product.available && (
          <span className="product-card__sold-badge">Sold</span>
        )}
      </div>
      <div className="product-card__body">
        <div className="product-card__title">{product.title}</div>
        <div className="product-card__meta">
          <span className="product-card__price">
            {formatPrice(product.price, product.currency ?? 'EUR')}
          </span>
          <span className="product-card__category">{product.category}</span>
        </div>
      </div>
    </Link>
  )
}

export default async function GalleryPage({ searchParams }: { searchParams: SearchParams }) {
  const { category, available } = await searchParams
  const products = await fetchProducts(category, available)

  return (
    <div className="container page-content">
      <div className="gallery-header">
        <h1>Gallery</h1>
        <p>Handcrafted pieces, made on the lathe.</p>
      </div>

      <Suspense>
        <FilterBar />
      </Suspense>

      {products.length === 0 ? (
        <div className="empty-state">
          <p>No pieces found. Try adjusting the filters.</p>
        </div>
      ) : (
        <div className="product-grid">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      )}
    </div>
  )
}
