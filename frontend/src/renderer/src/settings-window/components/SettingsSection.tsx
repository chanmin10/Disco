import { Children } from 'react'

interface SettingsSectionProps {
  header: string
  children: React.ReactNode
}

export function SettingsSection({ header, children }: SettingsSectionProps): React.JSX.Element {
  const rows = Children.toArray(children)

  return (
    <div style={{ margin: '0 20px 22px 20px' }}>
      <div
        style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-muted)', padding: '0 6px 6px' }}
      >
        {header}
      </div>
      <div
        style={{
          background: '#ffffff',
          borderRadius: 10,
          overflow: 'hidden',
          boxShadow: '0 0 0 1px rgba(0,0,0,0.045)'
        }}
      >
        {rows.map((row, i) => (
          <div
            key={i}
            style={{ borderBottom: i === rows.length - 1 ? 'none' : '1px solid rgba(0,0,0,0.07)' }}
          >
            {row}
          </div>
        ))}
      </div>
    </div>
  )
}
