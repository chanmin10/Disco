function computeStrength(password: string): 0 | 1 | 2 | 3 {
  if (!password) return 0
  let score = 0
  if (password.length >= 8) score++
  if (/[a-z]/.test(password) && /[A-Z]/.test(password)) score++
  if (/[0-9]/.test(password)) score++
  if (/[^a-zA-Z0-9]/.test(password)) score++
  if (score >= 3) return 3
  if (score === 2) return 2
  return 1
}

const LEVELS = [
  { label: '', color: 'rgba(0,0,0,0.08)' },
  { label: '약함', color: 'var(--danger)' },
  { label: '보통', color: '#FF9F0A' },
  { label: '강함', color: 'var(--success)' }
]

export function PasswordStrengthBar({ password }: { password: string }): React.JSX.Element | null {
  if (!password) return null
  const strength = computeStrength(password)
  const level = LEVELS[strength]

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 8 }}>
      <div style={{ display: 'flex', gap: 4, flex: 1 }}>
        {[1, 2, 3].map((bar) => (
          <div
            key={bar}
            style={{
              flex: 1,
              height: 4,
              borderRadius: 2,
              background: bar <= strength ? level.color : 'rgba(0,0,0,0.08)'
            }}
          />
        ))}
      </div>
      <span style={{ fontSize: 11, fontWeight: 600, color: level.color, flexShrink: 0 }}>
        {level.label}
      </span>
    </div>
  )
}
