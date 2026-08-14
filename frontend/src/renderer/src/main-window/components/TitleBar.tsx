import type { Engine } from '../../shared/types'
import { SegmentedControl } from '../../shared/components/SegmentedControl'

interface TitleBarProps {
  roomName: string
  engine: Engine
  onEngineChange: (engine: Engine) => void
  rightSidebarOpen: boolean
  onToggleLeftSidebar: () => void
  onToggleRightSidebar: () => void
}

function ToggleButton({
  onClick,
  children
}: {
  onClick: () => void
  children: React.ReactNode
}): React.JSX.Element {
  return (
    <div
      onClick={onClick}
      style={{
        width: 28,
        height: 28,
        borderRadius: 6,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        cursor: 'pointer',
        flexShrink: 0
      }}
    >
      {children}
    </div>
  )
}

function LeftSidebarIcon(): React.JSX.Element {
  return (
    <svg width="16" height="14" viewBox="0 0 16 14" fill="none">
      <rect x="1" y="1" width="14" height="12" rx="2.5" stroke="#6e6e73" strokeWidth="1.3" />
      <line x1="5.5" y1="1.3" x2="5.5" y2="12.7" stroke="#6e6e73" strokeWidth="1.3" />
      <rect x="1.8" y="1.8" width="3" height="10.4" rx="1" fill="#6e6e73" fillOpacity="0.55" />
    </svg>
  )
}

function RightSidebarIcon(): React.JSX.Element {
  return (
    <svg width="16" height="14" viewBox="0 0 16 14" fill="none">
      <rect x="1" y="1" width="14" height="12" rx="2.5" stroke="#6e6e73" strokeWidth="1.3" />
      <line x1="10.5" y1="1.3" x2="10.5" y2="12.7" stroke="#6e6e73" strokeWidth="1.3" />
      <rect x="11.2" y="1.8" width="3" height="10.4" rx="1" fill="#6e6e73" fillOpacity="0.55" />
    </svg>
  )
}

export function TitleBar({
  roomName,
  engine,
  onEngineChange,
  rightSidebarOpen,
  onToggleLeftSidebar,
  onToggleRightSidebar
}: TitleBarProps): React.JSX.Element {
  return (
    <div
      style={
        {
          height: 52,
          flexShrink: 0,
          display: 'flex',
          alignItems: 'center',
          borderBottom: '1px solid var(--border)',
          background: 'var(--surface-titlebar)',
          WebkitAppRegion: 'drag'
        } as React.CSSProperties
      }
    >
      <div
        style={{
          width: 200,
          flexShrink: 0,
          height: '100%',
          borderRight: '1px solid var(--border)'
        }}
      />
      <div
        style={
          {
            flex: 1,
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '0 16px',
            minWidth: 0,
            WebkitAppRegion: 'no-drag'
          } as React.CSSProperties
        }
      >
        <ToggleButton onClick={onToggleLeftSidebar}>
          <LeftSidebarIcon />
        </ToggleButton>
        <div
          style={{
            fontSize: 15,
            fontWeight: 600,
            color: 'var(--text-primary)',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis'
          }}
        >
          {roomName}
        </div>
        <div style={{ flex: 1 }} />
        <SegmentedControl value={engine} onChange={onEngineChange} />
        <ToggleButton onClick={onToggleRightSidebar}>
          <RightSidebarIcon />
        </ToggleButton>
      </div>
      <div
        style={{
          width: rightSidebarOpen ? 200 : 0,
          flexShrink: 0,
          height: '100%',
          paddingLeft: rightSidebarOpen ? 16 : 0,
          borderLeft: rightSidebarOpen ? '1px solid var(--border)' : 'none',
          display: 'flex',
          alignItems: 'center',
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          transition: 'width 0.2s ease'
        }}
      >
        <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-secondary)' }}>
          단어장
        </span>
      </div>
    </div>
  )
}
