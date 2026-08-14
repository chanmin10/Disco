import { useEffect, useRef, useState } from 'react'
import type { Engine, Theme } from '../shared/types'
import { useThemes } from '../shared/hooks/useThemes'
import { runTranslate, type TranslateResult } from '../shared/translateFlow'
import { EngineBadge } from './components/EngineBadge'
import { PopupTextarea, POPUP_TEXTAREA_ID } from './components/PopupTextarea'
import { ResultArea } from './components/ResultArea'
import { DestinationDropdown } from './components/DestinationDropdown'

const DEBOUNCE_MS = 350
const SAVE_CONFIRM_MS = 450
const WIDTH = 420

function App(): React.JSX.Element {
  const { themes } = useThemes()
  const [destinationThemeId, setDestinationThemeId] = useState<string | null>(null)
  const [text, setText] = useState('')
  const [result, setResult] = useState<TranslateResult | null>(null)
  const [showSaved, setShowSaved] = useState(false)
  const [engine, setEngine] = useState<Engine>('general')

  const requestIdRef = useRef(0)
  const saveTimerRef = useRef<ReturnType<typeof setTimeout> | undefined>(undefined)
  const rootRef = useRef<HTMLDivElement>(null)

  // Content-driven window height: the popup BrowserWindow is resized to fit whatever
  // this root element actually renders (see main/windows/popupWindow.ts).
  useEffect(() => {
    const el = rootRef.current
    if (!el) return
    const observer = new ResizeObserver((entries) => {
      const height = entries[0]?.contentRect.height
      if (height) window.api.resizePopup(height)
    })
    observer.observe(el)
    return () => observer.disconnect()
  }, [])

  // Select the first theme once the list loads, without a setState-in-effect round trip.
  const [themesSnapshot, setThemesSnapshot] = useState<Theme[]>(themes)
  if (themes !== themesSnapshot) {
    setThemesSnapshot(themes)
    if (!destinationThemeId && themes.length > 0) {
      setDestinationThemeId(themes[0].id)
    }
  }

  const runFor = async (themeId: string, value: string, currentEngine: Engine): Promise<void> => {
    const requestId = ++requestIdRef.current
    clearTimeout(saveTimerRef.current)
    setShowSaved(false)

    try {
      const translated = await runTranslate({ engine: currentEngine, themeId, text: value })
      if (requestId !== requestIdRef.current) return
      setResult(translated)
      if (translated.saved) {
        saveTimerRef.current = setTimeout(() => {
          if (requestId === requestIdRef.current) setShowSaved(true)
        }, SAVE_CONFIRM_MS)
      }
    } catch {
      if (requestId !== requestIdRef.current) return
      setResult(null)
    }
  }

  // Debounced trigger while the user is typing. Clearing result/showSaved here is tied to the
  // async translate request this effect owns (aborted via requestIdRef), not derivable state.
  useEffect(() => {
    if (!text.trim()) {
      requestIdRef.current++
      clearTimeout(saveTimerRef.current)
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setResult(null)

      setShowSaved(false)
      return
    }
    if (!destinationThemeId) return

    const timer = setTimeout(() => {
      void runFor(destinationThemeId, text, engine)
    }, DEBOUNCE_MS)

    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [text])

  // Switching destination theme or engine re-translates immediately (no debounce) if there's text.
  useEffect(() => {
    if (text.trim() && destinationThemeId) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      void runFor(destinationThemeId, text, engine)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [destinationThemeId, engine])

  useEffect(() => {
    const unsubscribe = window.api.onPopupShow(() => {
      setText('')
      setResult(null)
      setShowSaved(false)
      requestIdRef.current++
      requestAnimationFrame(() => {
        document.getElementById(POPUP_TEXTAREA_ID)?.focus()
      })
    })
    requestAnimationFrame(() => {
      document.getElementById(POPUP_TEXTAREA_ID)?.focus()
    })
    return unsubscribe
  }, [])

  return (
    <div
      ref={rootRef}
      style={{
        width: WIDTH,
        borderRadius: 16,
        overflow: 'hidden',
        background: 'rgba(255,255,255,0.5)',
        backdropFilter: 'blur(34px) saturate(180%)',
        WebkitBackdropFilter: 'blur(34px) saturate(180%)',
        boxShadow: '0 25px 70px rgba(0,0,0,0.32), 0 0 0 1px rgba(255,255,255,0.5)',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column'
      }}
    >
      <EngineBadge engine={engine} onChange={setEngine} />

      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          gap: 12,
          padding: '20px 150px 16px 20px'
        }}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 16 16"
          fill="none"
          style={{ flexShrink: 0, marginTop: 2 }}
        >
          <circle cx="8" cy="8" r="6.25" stroke="#5a5a60" strokeWidth="1.3" />
          <path
            d="M1.75 8h12.5M8 1.75c1.7 1.8 1.7 10.7 0 12.5M8 1.75c-1.7 1.8-1.7 10.7 0 12.5"
            stroke="#5a5a60"
            strokeWidth="1.1"
            fill="none"
          />
        </svg>
        <PopupTextarea
          value={text}
          onChange={setText}
          onToggleEngine={() => setEngine((e) => (e === 'general' ? 'quick' : 'general'))}
        />
      </div>

      <div style={{ height: 1, background: 'var(--border)', margin: '0 20px' }} />

      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          justifyContent: 'space-between',
          gap: 12,
          padding: '14px 20px 18px',
          minHeight: 34
        }}
      >
        <ResultArea resultText={result?.displayText ?? null} showSaved={showSaved} />
        <DestinationDropdown
          themes={themes}
          selectedThemeId={destinationThemeId}
          onSelect={setDestinationThemeId}
        />
      </div>
    </div>
  )
}

export default App
