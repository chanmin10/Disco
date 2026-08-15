import { useState } from 'react'
import type { Theme } from '../../shared/types'

interface DestinationTriggerProps {
  selected: Theme | null
  open: boolean
  onToggle: () => void
}

export function DestinationTrigger({
  selected,
  open,
  onToggle
}: DestinationTriggerProps): React.JSX.Element {
  const [hovered, setHovered] = useState(false)

  return (
    <div
      onClick={onToggle}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'flex-end',
        gap: 5,
        padding: '6px 10px',
        borderRadius: 8,
        flexShrink: 0,
        marginTop: 2,
        background: open || hovered ? 'rgba(0,0,0,0.07)' : 'rgba(0,0,0,0.045)',
        cursor: 'pointer',
        transition: 'background 0.12s ease'
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
      <svg
        width="9"
        height="6"
        viewBox="0 0 10 6"
        fill="none"
        style={{
          flexShrink: 0,
          transition: 'transform 0.2s cubic-bezier(0.4,0.2,0.2,1)',
          transform: open ? 'rotate(180deg)' : 'rotate(0deg)'
        }}
      >
        <path
          d="M1 1l4 4 4-4"
          stroke="var(--text-secondary)"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  )
}

function ThemeOptionRow({
  theme,
  selected,
  onPick
}: {
  theme: Theme
  selected: boolean
  onPick: () => void
}): React.JSX.Element {
  const [hovered, setHovered] = useState(false)

  return (
    <div
      onClick={onPick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: 8,
        padding: '7px 10px',
        borderRadius: 7,
        cursor: 'pointer',
        background: selected
          ? 'rgba(10,132,255,0.12)'
          : hovered
            ? 'rgba(0,0,0,0.05)'
            : 'transparent',
        transition: 'background 0.1s ease'
      }}
    >
      <span
        style={{
          fontSize: 12.5,
          fontWeight: selected ? 600 : 400,
          color: 'var(--text-primary)',
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis'
        }}
      >
        {theme.name}
      </span>
      {selected && (
        <svg width="11" height="11" viewBox="0 0 12 12" fill="none" style={{ flexShrink: 0 }}>
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
}

interface DestinationOptionsMenuProps {
  themes: Theme[]
  selectedThemeId: string | null
  onSelect: (themeId: string) => void
}

/**
 * Renders as a normal sibling below the frosted card (see popup-window/App.tsx), inside window
 * height reserved up front for exactly this purpose — so opening/closing it never changes the
 * popup's window size, and it can never get clipped by the card's own rounded-corner overflow.
 */
export function DestinationOptionsMenu({
  themes,
  selectedThemeId,
  onSelect
}: DestinationOptionsMenuProps): React.JSX.Element {
  return (
    <div style={{ display: 'flex', justifyContent: 'flex-end', paddingRight: 20, marginTop: 8 }}>
      <div
        style={{
          width: 170,
          maxHeight: 190,
          overflowY: 'auto',
          padding: 6,
          borderRadius: 12,
          background: 'rgba(255,255,255,0.85)',
          backdropFilter: 'blur(24px) saturate(180%)',
          WebkitBackdropFilter: 'blur(24px) saturate(180%)',
          boxShadow: '0 12px 30px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.06)',
          display: 'flex',
          flexDirection: 'column',
          gap: 1,
          animation: 'discoPopIn 0.15s ease-out'
        }}
      >
        {themes.map((theme) => (
          <ThemeOptionRow
            key={theme.id}
            theme={theme}
            selected={theme.id === selectedThemeId}
            onPick={() => onSelect(theme.id)}
          />
        ))}
      </div>
    </div>
  )
}
