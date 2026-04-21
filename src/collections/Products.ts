import type { CollectionConfig } from 'payload'

export const Products: CollectionConfig = {
  slug: 'products',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'category', 'price', 'available', 'updatedAt'],
  },
  access: {
    read: () => true,
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      required: true,
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      admin: {
        description: 'URL-friendly identifier, e.g. "walnut-bowl-01"',
      },
    },
    {
      name: 'description',
      type: 'richText',
    },
    {
      name: 'price',
      type: 'number',
      required: true,
      min: 0,
    },
    {
      name: 'currency',
      type: 'select',
      defaultValue: 'EUR',
      options: [
        { label: 'EUR (€)', value: 'EUR' },
        { label: 'USD ($)', value: 'USD' },
      ],
      required: true,
    },
    {
      name: 'dimensions',
      type: 'group',
      fields: [
        {
          name: 'height',
          type: 'number',
          min: 0,
          admin: { description: 'Height in selected unit' },
        },
        {
          name: 'diameter',
          type: 'number',
          min: 0,
          admin: { description: 'Diameter in selected unit' },
        },
        {
          name: 'unit',
          type: 'select',
          defaultValue: 'cm',
          options: [
            { label: 'cm', value: 'cm' },
            { label: 'mm', value: 'mm' },
            { label: 'in', value: 'in' },
          ],
        },
      ],
    },
    {
      name: 'category',
      type: 'select',
      required: true,
      options: [
        { label: 'Bowl', value: 'bowl' },
        { label: 'Vase', value: 'vase' },
        { label: 'Plate', value: 'plate' },
        { label: 'Other', value: 'other' },
      ],
    },
    {
      name: 'available',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Uncheck to mark as sold (still visible as portfolio)',
      },
    },
    {
      name: 'images',
      type: 'array',
      minRows: 1,
      fields: [
        {
          name: 'image',
          type: 'upload',
          relationTo: 'media',
          required: true,
        },
      ],
    },
    {
      name: 'featured',
      type: 'checkbox',
      defaultValue: false,
      admin: {
        description: 'Show prominently on the gallery page',
      },
    },
  ],
}
