export type Engine = 'general' | 'quick'

export interface Theme {
  id: string
  name: string
  target_language: string
}

export interface VocabEntry {
  id: string
  theme_id: string
  word_native: string
  word_target: string
  example_sentence?: string
}

export interface ChatMessage {
  id: string
  role: 'user' | 'bot'
  text: string
}

export interface QuickTranslateResponse {
  response: string
  text_native: string
  text_target: string
}

export interface ClassifyResponse {
  is_vocab: boolean
}

export interface AiTranslateResponse {
  text: string
}

export const LANGUAGE_OPTIONS: { label: string; code: string }[] = [
  { label: '영어', code: 'en' },
  { label: '스페인어', code: 'es' },
  { label: '일본어', code: 'ja' },
  { label: '중국어', code: 'zh' },
  { label: '불어', code: 'fr' }
]
