import { useState } from 'react'
import { SettingsRow } from './SettingsRow'

const LANGUAGE_DISPLAY_OPTIONS = ['영어', '스페인어', '일본어', '한국어']

interface LanguageRowProps {
  value: string
  onChange: (lang: string) => void
}

export function LanguageRow({ value, onChange }: LanguageRowProps): React.JSX.Element {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <SettingsRow
        iconBg="#34C759"
        icon={
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="8" cy="8" r="6.5" stroke="white" strokeWidth="1.3" />
            <ellipse cx="8" cy="8" rx="2.7" ry="6.5" stroke="white" strokeWidth="1.2" />
            <line x1="1.5" y1="8" x2="14.5" y2="8" stroke="white" strokeWidth="1.2" />
            <path d="M2.6 5h10.8M2.6 11h10.8" stroke="white" strokeWidth="1.1" />
          </svg>
        }
        title="언어"
        onClick={() => setOpen((o) => !o)}
        trailing={
          !open && <span style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>{value}</span>
        }
      />
      {open && (
        <div
          style={{
            padding: '2px 16px 10px 56px',
            display: 'flex',
            flexDirection: 'column',
            gap: 1,
            animation: 'discoPopIn 0.15s ease-out'
          }}
        >
          {LANGUAGE_DISPLAY_OPTIONS.map((lang) => {
            const selected = lang === value
            return (
              <div
                key={lang}
                onClick={(e) => {
                  e.stopPropagation()
                  onChange(lang)
                  setOpen(false)
                }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '7px 10px',
                  borderRadius: 7,
                  cursor: 'pointer'
                }}
              >
                <span style={{ fontSize: 13, color: 'var(--text-primary)' }}>{lang}</span>
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
      )}
    </div>
  )
}
