'use server'

import { handleServerFunctions } from '@payloadcms/next/layouts'
import config from '@payload-config'
import type { ServerFunctionClientArgs } from 'payload'
import { importMap } from '../importMap'

export const serverFunction = async (args: ServerFunctionClientArgs) =>
  handleServerFunctions({ ...args, config, importMap })
