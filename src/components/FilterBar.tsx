'use client'

import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import { useCallback } from 'react'

const CATEGORIES = [
  { label: 'All', value: '' },
  { label: 'Bowl', value: 'bowl' },
  { label: 'Vase', value: 'vase' },
  { label: 'Plate', value: 'plate' },
  { label: 'Other', value: 'other' },
]

export function FilterBar() {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  const category = searchParams.get('category') ?? ''
  const onlyAvailable = searchParams.get('available') === 'true'

  const update = useCallback(
    (key: string, value: string) => {
      const params = new URLSearchParams(searchParams.toString())
      if (value) {
        params.set(key, value)
      } else {
        params.delete(key)
      }
      router.push(`${pathname}?${params.toString()}`)
    },
    [router, pathname, searchParams],
  )

  return (
    <div className="filter-bar">
      <label htmlFor="category-filter">Category</label>
      <select
        id="category-filter"
        value={category}
        onChange={(e) => update('category', e.target.value)}
      >
        {CATEGORIES.map((c) => (
          <option key={c.value} value={c.value}>
            {c.label}
          </option>
        ))}
      </select>

      <label className="filter-bar__toggle">
        <input
          type="checkbox"
          checked={onlyAvailable}
          onChange={(e) => update('available', e.target.checked ? 'true' : '')}
        />
        Available only
      </label>
    </div>
  )
}
