import { useState } from 'react'

interface ChatInputProps {
  disabled: boolean
  onSend: (text: string) => void
}

export function ChatInput({ disabled, onSend }: ChatInputProps): React.JSX.Element {
  const [value, setValue] = useState('')

  const send = (): void => {
    const trimmed = value.trim()
    if (!trimmed || disabled) return
    onSend(trimmed)
    setValue('')
  }

  const canSend = value.trim().length > 0 && !disabled

  return (
    <div
      style={{
        flexShrink: 0,
        borderTop: '1px solid var(--border)',
        padding: '12px 16px',
        display: 'flex',
        gap: 10,
        alignItems: 'center'
      }}
    >
      <input
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter') send()
        }}
        placeholder="번역할 텍스트 입력"
        style={{
          flex: 1,
          border: '1px solid rgba(0,0,0,0.12)',
          borderRadius: 9,
          padding: '10px 13px',
          fontSize: 14,
          outline: 'none',
          background: 'var(--surface-sidebar-left)',
          color: 'var(--text-primary)'
        }}
      />
      <div
        onClick={send}
        style={{
          width: 34,
          height: 34,
          borderRadius: '50%',
          background: 'var(--accent)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          cursor: canSend ? 'pointer' : 'default',
          opacity: canSend ? 1 : 0.35
        }}
      >
        <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
          <path
            d="M8 13V3M8 3L3.5 7.5M8 3l4.5 4.5"
            stroke="white"
            strokeWidth="1.8"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
    </div>
  )
}
