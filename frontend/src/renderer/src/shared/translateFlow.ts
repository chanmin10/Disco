import * as api from './apiClient'
import type { Engine } from './types'

export interface TranslateResult {
  displayText: string
  saved: boolean
}

/**
 * The one place General ("/translate/ai") vs Quick ("/translate/quick" + "/translate/classify")
 * branching lives, so Main and Popup windows never duplicate it.
 *
 * `saved` is optimistic (always true) for General mode: /translate/ai does not report whether it
 * actually persisted a vocab entry, unlike /translate/classify which returns a real `is_vocab`.
 */
export async function runTranslate(opts: {
  engine: Engine
  themeId: string
  text: string
}): Promise<TranslateResult> {
  if (opts.engine === 'general') {
    const { text } = await api.translateAi(opts.themeId, opts.text)
    return { displayText: text, saved: true }
  }

  const { response, text_native, text_target } = await api.translateQuick(opts.themeId, opts.text)
  const { is_vocab } = await api.translateClassify(opts.themeId, text_native, text_target)
  return { displayText: response, saved: is_vocab }
}
