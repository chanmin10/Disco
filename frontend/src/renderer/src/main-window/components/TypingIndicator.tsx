export function TypingIndicator(): React.JSX.Element {
  return (
    <div style={{ display: 'flex', justifyContent: 'flex-start' }}>
      <div
        style={{
          padding: '11px 16px',
          borderRadius: '15px 15px 15px 4px',
          background: 'var(--surface-subtle-fill)',
          display: 'flex',
          gap: 4,
          alignItems: 'center'
        }}
      >
        {[0, 0.15, 0.3].map((delay) => (
          <span
            key={delay}
            style={{
              width: 6,
              height: 6,
              borderRadius: '50%',
              background: '#9a9aa0',
              display: 'inline-block',
              animation: `discoDotPulse 1.1s infinite ${delay}s`
            }}
          />
        ))}
      </div>
    </div>
  )
}
