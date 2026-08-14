import { useState } from 'react'
import type { Theme } from '../../shared/types'

interface DestinationDropdownProps {
  themes: Theme[]
  selectedThemeId: string | null
  onSelect: (themeId: string) => void
}

export function DestinationDropdown({
  themes,
  selectedThemeId,
  onSelect
}: DestinationDropdownProps): React.JSX.Element {
  const [open, setOpen] = useState(false)
  const selected = themes.find((t) => t.id === selectedThemeId) ?? null

  return (
    <div style={{ position: 'relative', flexShrink: 0, marginTop: 2 }}>
      {open && (
        <>
          <div style={{ position: 'fixed', inset: 0, zIndex: 10 }} onClick={() => setOpen(false)} />
          <div
            style={{
              position: 'absolute',
              right: 0,
              bottom: '100%',
              marginBottom: 8,
              background: '#ffffff',
              borderRadius: 10,
              boxShadow: '0 10px 26px rgba(0,0,0,0.2), 0 0 0 1px rgba(0,0,0,0.06)',
              overflow: 'hidden',
              zIndex: 11,
              width: 140,
              animation: 'discoPopIn 0.15s ease-out'
            }}
          >
            {themes.map((theme) => (
              <div
                key={theme.id}
                onClick={() => {
                  onSelect(theme.id)
                  setOpen(false)
                }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                  padding: '8px 12px',
                  cursor: 'pointer',
                  background: theme.id === selectedThemeId ? 'rgba(0,0,0,0.045)' : 'transparent'
                }}
              >
                <span style={{ fontSize: 12.5, color: 'var(--text-primary)' }}>{theme.name}</span>
              </div>
            ))}
          </div>
        </>
      )}
      <div
        onClick={() => setOpen((o) => !o)}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 5,
          padding: '6px 10px',
          borderRadius: 8,
          background: 'rgba(0,0,0,0.045)',
          cursor: 'pointer'
        }}
      >
        <span
          style={{
            fontSize: 12,
            fontWeight: 600,
            color: 'var(--text-primary)',
            whiteSpace: 'nowrap'
          }}
        >
          {selected?.name ?? '테마 선택'}
        </span>
        <svg width="9" height="6" viewBox="0 0 10 6" fill="none" style={{ flexShrink: 0 }}>
          <path
            d="M1 1l4 4 4-4"
            stroke="#86868b"
            strokeWidth="1.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
    </div>
  )
}
