import { useState } from 'react'
import type { Theme } from '../../shared/types'

interface RoomRowProps {
  theme: Theme
  active: boolean
  onSelect: () => void
  onDelete: () => void
}

export function RoomRow({ theme, active, onSelect, onDelete }: RoomRowProps): React.JSX.Element {
  const [hovered, setHovered] = useState(false)

  return (
    <div
      onClick={onSelect}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        padding: '9px 12px',
        borderRadius: 7,
        cursor: 'pointer',
        background: active ? 'var(--accent)' : 'var(--surface-sidebar-left)'
      }}
    >
      <span
        style={{
          fontSize: 13,
          color: active ? '#ffffff' : 'var(--text-primary)',
          fontWeight: active ? 600 : 500,
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          flex: 1,
          minWidth: 0
        }}
      >
        {theme.name}
      </span>
      <div
        onClick={(e) => {
          e.stopPropagation()
          onDelete()
        }}
        style={{
          width: 22,
          height: 22,
          borderRadius: 5,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          opacity: hovered ? 1 : 0,
          pointerEvents: hovered ? 'auto' : 'none'
        }}
      >
        <svg width="13" height="13" viewBox="0 0 16 16" fill="none">
          <path
            d="M2 4h12M6.5 4V2.5a1 1 0 011-1h1a1 1 0 011 1V4M3.5 4l.6 9a1 1 0 001 .9h5.8a1 1 0 001-.9l.6-9"
            stroke={active ? 'rgba(255,255,255,0.8)' : '#9a9aa0'}
            strokeWidth="1.4"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
    </div>
  )
}
