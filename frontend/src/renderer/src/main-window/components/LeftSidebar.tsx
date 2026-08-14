import type { Theme } from '../../shared/types'
import { RoomRow } from './RoomRow'

interface LeftSidebarProps {
  open: boolean
  themes: Theme[]
  activeThemeId: string | null
  onSelect: (themeId: string) => void
  onDelete: (themeId: string) => void
  onOpenCreateRoom: () => void
}

export function LeftSidebar({
  open,
  themes,
  activeThemeId,
  onSelect,
  onDelete,
  onOpenCreateRoom
}: LeftSidebarProps): React.JSX.Element {
  return (
    <div
      style={{
        width: open ? 200 : 0,
        flexShrink: 0,
        overflow: 'hidden',
        background: 'var(--surface-sidebar-left)',
        borderRight: open ? '1px solid var(--border)' : 'none',
        display: 'flex',
        flexDirection: 'column',
        minHeight: 0,
        transition: 'width 0.2s ease'
      }}
    >
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: 8,
          display: 'flex',
          flexDirection: 'column',
          gap: 2
        }}
      >
        {themes.map((theme) => (
          <RoomRow
            key={theme.id}
            theme={theme}
            active={theme.id === activeThemeId}
            onSelect={() => onSelect(theme.id)}
            onDelete={() => onDelete(theme.id)}
          />
        ))}
      </div>
      <div style={{ position: 'relative', flexShrink: 0, borderTop: '1px solid var(--border)' }}>
        <div
          onClick={onOpenCreateRoom}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '9px 12px',
            cursor: 'pointer'
          }}
        >
          <div
            style={{
              width: 22,
              height: 22,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <svg width="15" height="15" viewBox="0 0 16 16" fill="none">
              <circle cx="8" cy="8" r="6.5" stroke="#a1a1a6" strokeWidth="1.3" />
              <path d="M8 5v6M5 8h6" stroke="#a1a1a6" strokeWidth="1.3" strokeLinecap="round" />
            </svg>
          </div>
          <span style={{ fontSize: 12.5, color: '#a1a1a6', fontWeight: 500 }}>새 테마</span>
        </div>
      </div>
    </div>
  )
}
