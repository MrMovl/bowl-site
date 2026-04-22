/* eslint-disable @typescript-eslint/no-explicit-any */
import { RootLayout } from '@payloadcms/next/layouts'
import config from '@payload-config'
import React from 'react'

import { importMap } from '../importMap'
import { serverFunction } from './actions'

type Args = {
  children: React.ReactNode
}

export default function Layout({ children }: Args) {
  return RootLayout({
    config: config as any,
    importMap,
    children,
    serverFunction,
  })
}
