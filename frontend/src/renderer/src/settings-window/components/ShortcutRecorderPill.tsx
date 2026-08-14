import { useEffect, useRef, useState } from 'react'
import { acceleratorToDisplay, keyEventToAccelerator } from '../acceleratorKey'

interface ShortcutRecorderPillProps {
  shortcut: string
  onChange: (accelerator: string) => Promise<{ success: boolean; error?: string }>
}

export function ShortcutRecorderPill({
  shortcut,
  onChange
}: ShortcutRecorderPillProps): React.JSX.Element {
  const [recording, setRecording] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const handlerRef = useRef<((e: KeyboardEvent) => void) | undefined>(undefined)

  useEffect(() => {
    return () => {
      if (handlerRef.current) document.removeEventListener('keydown', handlerRef.current, true)
    }
  }, [])

  const startRecording = (): void => {
    if (recording) return
    setError(null)
    setRecording(true)

    const handler = async (e: KeyboardEvent): Promise<void> => {
      e.preventDefault()
      const accelerator = keyEventToAccelerator(e)
      if (!accelerator) return

      document.removeEventListener('keydown', handler, true)
      setRecording(false)

      const result = await onChange(accelerator)
      if (!result.success) {
        setError(result.error ?? '단축키를 등록할 수 없습니다.')
      }
    }

    handlerRef.current = handler
    document.addEventListener('keydown', handler, true)
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
      <div
        onClick={startRecording}
        style={{
          padding: '5px 10px',
          background: 'var(--surface-subtle-fill)',
          borderRadius: 6,
          fontSize: 12.5,
          fontWeight: 600,
          color: recording ? 'var(--accent)' : 'var(--text-primary)',
          minWidth: 52,
          textAlign: 'center',
          cursor: 'pointer'
        }}
      >
        {recording ? '키를 누르세요…' : acceleratorToDisplay(shortcut)}
      </div>
      {error && <span style={{ fontSize: 10.5, color: 'var(--danger)' }}>{error}</span>}
    </div>
  )
}
