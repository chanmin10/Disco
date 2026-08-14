import { useRef, useState } from 'react'
import { LANGUAGE_OPTIONS } from '../../shared/types'

interface NewThemeModalProps {
  onClose: () => void
  onCreate: (name: string, targetLanguage: string) => void
}

export function NewThemeModal({ onClose, onCreate }: NewThemeModalProps): React.JSX.Element {
  const [name, setName] = useState('')
  const [language, setLanguage] = useState(LANGUAGE_OPTIONS[0].code)
  const nameRef = useRef<HTMLInputElement>(null)

  const submit = (): void => {
    const trimmed = name.trim()
    if (!trimmed) {
      nameRef.current?.focus()
      return
    }
    onCreate(trimmed, language)
  }

  return (
    <div
      onClick={onClose}
      style={{
        position: 'absolute',
        inset: 0,
        background: 'rgba(0,0,0,0.22)',
        zIndex: 50,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          width: 320,
          background: '#ffffff',
          borderRadius: 14,
          boxShadow: '0 20px 50px rgba(0,0,0,0.35)',
          overflow: 'hidden',
          animation: 'discoPopIn 0.15s ease-out'
        }}
      >
        <div style={{ padding: '14px 18px', borderBottom: '1px solid var(--border)' }}>
          <span style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--text-primary)' }}>
            새 테마 만들기
          </span>
        </div>
        <div style={{ padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <label
              style={{
                display: 'block',
                fontSize: 12,
                fontWeight: 600,
                color: 'var(--text-secondary)',
                marginBottom: 6
              }}
            >
              테마 이름
            </label>
            <input
              ref={nameRef}
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') submit()
              }}
              placeholder="예: 여행, 운동, 요리"
              style={{
                width: '100%',
                height: 36,
                border: '1px solid rgba(0,0,0,0.14)',
                borderRadius: 8,
                padding: '0 11px',
                fontSize: 13,
                outline: 'none',
                background: 'var(--surface-titlebar)',
                color: 'var(--text-primary)'
              }}
            />
          </div>
          <div>
            <label
              style={{
                display: 'block',
                fontSize: 12,
                fontWeight: 600,
                color: 'var(--text-secondary)',
                marginBottom: 6
              }}
            >
              번역 언어
            </label>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 1,
                background: 'var(--surface-titlebar)',
                borderRadius: 8,
                padding: 4
              }}
            >
              {LANGUAGE_OPTIONS.map((opt) => {
                const selected = opt.code === language
                return (
                  <div
                    key={opt.code}
                    onClick={() => setLanguage(opt.code)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '7px 9px',
                      borderRadius: 6,
                      cursor: 'pointer',
                      background: selected ? 'rgba(0,0,0,0.05)' : 'transparent'
                    }}
                  >
                    <span style={{ fontSize: 12.5, color: 'var(--text-primary)' }}>
                      {opt.label}
                    </span>
                    {selected && (
                      <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                        <path
                          d="M2 6.5l2.5 2.5L10 3"
                          stroke="var(--accent)"
                          strokeWidth="2"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    )}
                  </div>
                )
              })}
            </div>
          </div>
        </div>
        <div
          style={{
            padding: '12px 16px',
            borderTop: '1px solid var(--border)',
            display: 'flex',
            justifyContent: 'flex-end',
            gap: 8
          }}
        >
          <button
            type="button"
            onClick={onClose}
            style={{
              height: 32,
              padding: '0 14px',
              borderRadius: 7,
              background: 'none',
              border: '1px solid rgba(0,0,0,0.14)',
              color: '#3a3a3c',
              fontSize: 12.5,
              fontWeight: 600,
              cursor: 'pointer'
            }}
          >
            취소
          </button>
          <button
            type="button"
            onClick={submit}
            style={{
              height: 32,
              padding: '0 14px',
              borderRadius: 7,
              background: 'var(--accent)',
              border: 'none',
              color: '#fff',
              fontSize: 12.5,
              fontWeight: 600,
              cursor: 'pointer'
            }}
          >
            만들기
          </button>
        </div>
      </div>
    </div>
  )
}
