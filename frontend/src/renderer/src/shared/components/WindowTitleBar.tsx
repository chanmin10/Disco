interface WindowTitleBarProps {
  title: string
  height: number
  trafficLightZoneWidth: number
}

export function WindowTitleBar({
  title,
  height,
  trafficLightZoneWidth
}: WindowTitleBarProps): React.JSX.Element {
  return (
    <div
      style={
        {
          height,
          flexShrink: 0,
          display: 'flex',
          alignItems: 'center',
          borderBottom: '1px solid var(--border)',
          background: 'var(--surface-titlebar)',
          position: 'relative',
          WebkitAppRegion: 'drag'
        } as React.CSSProperties
      }
    >
      <div style={{ width: trafficLightZoneWidth, flexShrink: 0, height: '100%' }} />
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          textAlign: 'center',
          fontSize: 13.5,
          fontWeight: 600,
          color: 'var(--text-primary)',
          pointerEvents: 'none'
        }}
      >
        {title}
      </div>
    </div>
  )
}
