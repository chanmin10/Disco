export function FormError({ message }: { message: string }): React.JSX.Element {
  return (
    <span
      role="alert"
      aria-live="polite"
      style={{
        fontSize: 11.5,
        color: 'var(--danger)',
        display: 'flex',
        alignItems: 'center',
        gap: 5
      }}
    >
      <span
        style={{
          width: 12,
          height: 12,
          borderRadius: '50%',
          background: 'var(--danger)',
          color: '#fff',
          fontSize: 8,
          fontWeight: 700,
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0
        }}
      >
        !
      </span>
      {message}
    </span>
  )
}

export function BannerError({ message }: { message: string }): React.JSX.Element {
  return (
    <div
      role="alert"
      aria-live="polite"
      style={{
        display: 'flex',
        alignItems: 'flex-start',
        gap: 8,
        background: '#feecec',
        border: '1px solid rgba(255,59,48,0.25)',
        borderRadius: 9,
        padding: '11px 13px',
        marginBottom: 16
      }}
    >
      <span
        style={{
          width: 16,
          height: 16,
          borderRadius: '50%',
          background: 'var(--danger)',
          color: '#fff',
          fontSize: 11,
          fontWeight: 700,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          marginTop: 1
        }}
      >
        !
      </span>
      <span style={{ fontSize: 12.5, color: '#8a2c26', lineHeight: 1.4 }}>{message}</span>
    </div>
  )
}
