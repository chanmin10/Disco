interface SettingsRowProps {
  iconBg: string
  icon: React.ReactNode
  title: string
  subtitle?: string
  onClick?: () => void
  trailing?: React.ReactNode
}

export function SettingsRow({
  iconBg,
  icon,
  title,
  subtitle,
  onClick,
  trailing
}: SettingsRowProps): React.JSX.Element {
  return (
    <div
      onClick={onClick}
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        padding: '11px 16px',
        minHeight: 44,
        cursor: onClick ? 'pointer' : 'default'
      }}
    >
      <div
        style={{
          width: 28,
          height: 28,
          borderRadius: 7,
          background: iconBg,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0
        }}
      >
        {icon}
      </div>
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 1 }}>
        <span style={{ fontSize: 13, fontWeight: 500, color: 'var(--text-primary)' }}>{title}</span>
        {subtitle && <span style={{ fontSize: 11.5, color: 'var(--text-muted)' }}>{subtitle}</span>}
      </div>
      {trailing}
    </div>
  )
}
