import axios from 'axios'
import { supabase } from './supabaseClient'
import type {
  AiTranslateResponse,
  ClassifyResponse,
  QuickTranslateResponse,
  Theme,
  VocabEntry
} from './types'

const client = axios.create({
  baseURL: 'http://localhost:8000'
})

client.interceptors.request.use(async (config) => {
  const {
    data: { session }
  } = await supabase.auth.getSession()
  if (session?.access_token) {
    config.headers.Authorization = `Bearer ${session.access_token}`
  }
  return config
})

// A stale/invalid Supabase token means the local session is no longer valid server-side —
// clear it and bounce every window back to Login (same flow as AccountRow's manual logout).
// Guarded so a burst of concurrent 401s only triggers this once.
let handlingUnauthorized = false

client.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401 && !handlingUnauthorized) {
      handlingUnauthorized = true
      try {
        await supabase.auth.signOut()
        await window.api.notifyLogout()
      } finally {
        handlingUnauthorized = false
      }
    }
    return Promise.reject(error)
  }
)

export async function getThemes(): Promise<Theme[]> {
  const { data } = await client.get<Theme[]>('/themes')
  return data
}

export async function createTheme(name: string, target_language: string): Promise<Theme> {
  const { data } = await client.post<Theme>('/themes', { name, target_language })
  return data
}

export async function deleteTheme(themeId: string): Promise<void> {
  await client.delete(`/themes/${themeId}`)
}

export async function getVocab(themeId: string): Promise<VocabEntry[]> {
  const { data } = await client.get<VocabEntry[]>('/vocab', { params: { theme_id: themeId } })
  return data
}

export async function deleteVocab(entryId: string): Promise<void> {
  await client.delete(`/vocab/${entryId}`)
}

export async function translateQuick(
  themeId: string,
  text: string
): Promise<QuickTranslateResponse> {
  const { data } = await client.post<QuickTranslateResponse>('/translate/quick', {
    theme_id: themeId,
    text
  })
  return data
}

export async function translateClassify(
  themeId: string,
  textNative: string,
  textTarget: string
): Promise<ClassifyResponse> {
  const { data } = await client.post<ClassifyResponse>('/translate/classify', {
    theme_id: themeId,
    text_native: textNative,
    text_target: textTarget
  })
  return data
}

export async function translateAi(themeId: string, text: string): Promise<AiTranslateResponse> {
  const { data } = await client.post<AiTranslateResponse>('/translate/ai', {
    theme_id: themeId,
    text
  })
  return data
}
