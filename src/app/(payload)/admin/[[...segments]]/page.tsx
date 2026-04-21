/* eslint-disable @typescript-eslint/no-explicit-any */
import { RootPage, generatePageMetadata } from '@payloadcms/next/views'

type Args = {
  params: Promise<{ segments: string[] }>
  searchParams: Promise<{ [key: string]: string | string[] }>
}

export const generateMetadata = ({ params, searchParams }: Args) =>
  generatePageMetadata({
    config: import('@payload-config') as any,
    params,
    searchParams,
  })

export default function Page({ params, searchParams }: Args) {
  return RootPage({
    config: import('@payload-config') as any,
    params,
    searchParams,
    importMap: {},
  })
}
