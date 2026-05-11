import { db } from './supabaseClient'
import { dbFallback } from './dbFallback'

export const isSupabaseEnabled = Boolean(import.meta.env.VITE_SUPABASE_URL && import.meta.env.VITE_SUPABASE_ANON_KEY)
export const dataSource = isSupabaseEnabled ? db : dbFallback
