import { useLayoutEffect, useRef } from 'react'

const LINE_HEIGHT = 18 * 1.4
const MAX_LINES = 4
const MAX_HEIGHT = Math.round(LINE_HEIGHT * MAX_LINES)

export const POPUP_TEXTAREA_ID = 'popup-textarea'

interface PopupTextareaProps {
  value: string
  onChange: (value: string) => void
  onToggleEngine: () => void
  onEnter: () => void
}

export function PopupTextarea({
  value,
  onChange,
  onToggleEngine,
  onEnter
}: PopupTextareaProps): React.JSX.Element {
  const ref = useRef<HTMLTextAreaElement>(null)

  useLayoutEffect(() => {
    const el = ref.current
    if (!el) return
    el.style.height = 'auto'
    const h = Math.min(MAX_HEIGHT, Math.max(25, el.scrollHeight))
    el.style.height = `${h}px`
    el.style.overflowY = el.scrollHeight > MAX_HEIGHT ? 'auto' : 'hidden'
  }, [value])

  return (
    <textarea
      id={POPUP_TEXTAREA_ID}
      ref={ref}
      rows={1}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      onKeyDown={(e) => {
        if (e.key === 'Enter') {
          e.preventDefault()
          // Guard against IME composition (Korean/Japanese/Chinese input) firing an extra
          // Enter keydown when confirming a composed character, which would submit twice.
          if (!e.nativeEvent.isComposing) onEnter()
          return
        }
        if (e.key === 'Tab') {
          e.preventDefault()
          onToggleEngine()
          return
        }
        if (e.key === 'Escape') {
          window.api.hidePopup()
        }
      }}
      placeholder="번역할 텍스트 입력"
      style={{
        flex: 1,
        border: 'none',
        outline: 'none',
        background: 'transparent',
        fontSize: 18,
        color: 'var(--text-primary)',
        minWidth: 0,
        resize: 'none',
        overflow: 'hidden',
        lineHeight: 1.4,
        padding: 0
      }}
    />
  )
}
