import type { Engine } from '../types'

interface SegmentedControlProps {
  value: Engine
  onChange: (engine: Engine) => void
  variant?: 'default' | 'compact'
}

const OPTIONS: { value: Engine; label: string }[] = [
  { value: 'general', label: 'General' },
  { value: 'quick', label: 'Quick' }
]

export function SegmentedControl({
  value,
  onChange,
  variant = 'default'
}: SegmentedControlProps): React.JSX.Element {
  const compact = variant === 'compact'

  return (
    <div
      style={{
        display: 'inline-flex',
        padding: 2,
        background: 'rgba(0,0,0,0.06)',
        borderRadius: 8,
        gap: 2
      }}
    >
      {OPTIONS.map((opt) => {
        const selected = opt.value === value
        return (
          <div
            key={opt.value}
            onClick={() => onChange(opt.value)}
            style={{
              padding: compact ? '4px 10px' : '4px 12px',
              borderRadius: 6,
              fontSize: compact ? 10.5 : 12,
              fontWeight: compact ? 600 : 500,
              cursor: 'pointer',
              textAlign: 'center',
              userSelect: 'none',
              background: selected
                ? compact
                  ? 'rgba(255,255,255,0.55)'
                  : '#ffffff'
                : 'transparent',
              color: selected
                ? 'var(--text-primary)'
                : compact
                  ? '#54545a'
                  : 'var(--text-secondary)',
              boxShadow: selected && !compact ? '0 1px 3px rgba(0,0,0,0.18)' : 'none'
            }}
          >
            {opt.label}
          </div>
        )
      })}
    </div>
  )
}
