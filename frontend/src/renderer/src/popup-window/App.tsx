import { useEffect, useRef, useState } from 'react'
import type { Engine, Theme } from '../shared/types'
import { useThemes } from '../shared/hooks/useThemes'
import { runTranslate, type TranslateResult } from '../shared/translateFlow'
import { EngineBadge } from './components/EngineBadge'
import { PopupTextarea, POPUP_TEXTAREA_ID } from './components/PopupTextarea'
import { ResultArea } from './components/ResultArea'
import { DestinationTrigger, DestinationOptionsMenu } from './components/DestinationDropdown'

const SAVE_CONFIRM_MS = 450
const WIDTH = 420
// Fixed headroom below the card, reserved up front so the theme dropdown always has room to
// render without ever changing the popup window's height when it opens or closes.
const DROPDOWN_RESERVE_PX = 220

function App(): React.JSX.Element {
  const { themes } = useThemes()
  const [destinationThemeId, setDestinationThemeId] = useState<string | null>(null)
  const [text, setText] = useState('')
  const [result, setResult] = useState<TranslateResult | null>(null)
  const [showSaved, setShowSaved] = useState(false)
  const [engine, setEngine] = useState<Engine>('general')
  const [isTranslating, setIsTranslating] = useState(false)
  const [dropdownOpen, setDropdownOpen] = useState(false)

  const requestIdRef = useRef(0)
  const saveTimerRef = useRef<ReturnType<typeof setTimeout> | undefined>(undefined)
  const cardRef = useRef<HTMLDivElement>(null)

  // Content-driven window height: the popup BrowserWindow is resized to fit whatever the card
  // actually renders (see main/windows/popupWindow.ts), plus a constant reserve for the theme
  // dropdown (DestinationOptionsMenu) below it — which is why the dropdown itself is NOT
  // observed here and never triggers a resize when it opens or closes.
  useEffect(() => {
    const el = cardRef.current
    if (!el) return
    const observer = new ResizeObserver((entries) => {
      const height = entries[0]?.contentRect.height
      if (height) window.api.resizePopup(height + DROPDOWN_RESERVE_PX)
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
    setIsTranslating(true)

    try {
      const translated = await runTranslate({ engine: currentEngine, themeId, text: value })
      if (requestId !== requestIdRef.current) return
      setResult(translated)
      setIsTranslating(false)
      if (translated.saved) {
        saveTimerRef.current = setTimeout(() => {
          if (requestId === requestIdRef.current) setShowSaved(true)
        }, SAVE_CONFIRM_MS)
      }
    } catch {
      if (requestId !== requestIdRef.current) return
      setResult(null)
      setIsTranslating(false)
    }
  }

  // Both engines are Enter-gated: typing alone never auto-fires a translate. Enter clears the
  // input and immediately triggers the request (which is what shows the processing motion).
  const handleEnterSubmit = (): void => {
    const trimmed = text.trim()
    if (!trimmed || !destinationThemeId) return
    setText('')
    void runFor(destinationThemeId, trimmed, engine)
  }

  useEffect(() => {
    const unsubscribe = window.api.onPopupShow(() => {
      setText('')
      setResult(null)
      setShowSaved(false)
      setIsTranslating(false)
      setDropdownOpen(false)
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

  const selectedTheme = themes.find((t) => t.id === destinationThemeId) ?? null

  return (
    <div style={{ width: WIDTH, height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <div
        ref={cardRef}
        style={{
          borderRadius: 16,
          overflow: 'hidden',
          background: 'rgba(255,255,255,0.5)',
          backdropFilter: 'blur(34px) saturate(180%)',
          WebkitBackdropFilter: 'blur(34px) saturate(180%)',
          boxShadow: '0 25px 70px rgba(0,0,0,0.32), 0 0 0 1px rgba(255,255,255,0.5)',
          position: 'relative',
          display: 'flex',
          flexDirection: 'column',
          flexShrink: 0
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
            onEnter={handleEnterSubmit}
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
          <ResultArea
            resultText={result?.displayText ?? null}
            showSaved={showSaved}
            isTranslating={isTranslating}
          />
          <DestinationTrigger
            selected={selectedTheme}
            open={dropdownOpen}
            onToggle={() => setDropdownOpen((o) => !o)}
          />
        </div>
      </div>

      {dropdownOpen && (
        <DestinationOptionsMenu
          themes={themes}
          selectedThemeId={destinationThemeId}
          onSelect={(themeId) => {
            setDestinationThemeId(themeId)
            setDropdownOpen(false)
          }}
        />
      )}
    </div>
  )
}

export default App
