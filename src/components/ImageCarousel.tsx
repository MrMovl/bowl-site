'use client'

import Image from 'next/image'
import { useState } from 'react'

type CarouselImage = {
  url: string
  alt: string
  width?: number | null
  height?: number | null
}

export function ImageCarousel({ images }: { images: CarouselImage[] }) {
  const [active, setActive] = useState(0)

  if (images.length === 0) return null

  const current = images[active]

  return (
    <div>
      <div className="product-gallery__main">
        <Image
          src={current.url}
          alt={current.alt}
          width={current.width ?? 800}
          height={current.height ?? 800}
          priority={active === 0}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      </div>
      {images.length > 1 && (
        <div className="product-gallery__thumbs">
          {images.map((img, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setActive(i)}
              className={`product-gallery__thumb${i === active ? ' product-gallery__thumb--active' : ''}`}
              aria-label={`View image ${i + 1}`}
            >
              <Image src={img.url} alt={img.alt} width={72} height={72} />
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
