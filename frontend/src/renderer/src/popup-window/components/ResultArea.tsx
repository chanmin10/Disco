function SavedCheckmark(): React.JSX.Element {
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 3,
        fontSize: 11,
        color: 'var(--success)',
        fontWeight: 600,
        whiteSpace: 'nowrap'
      }}
    >
      <svg width="10" height="10" viewBox="0 0 12 12" fill="none">
        <path
          d="M2 6.5l2.5 2.5L10 3"
          stroke="var(--success)"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
      저장됨
    </span>
  )
}

interface ResultAreaProps {
  resultText: string | null
  showSaved: boolean
}

export function ResultArea({ resultText, showSaved }: ResultAreaProps): React.JSX.Element {
  if (resultText === null) {
    return (
      <div style={{ flex: 1, minWidth: 0 }}>
        <span style={{ fontSize: 13, color: '#b0b0b6' }}>번역 결과가 여기에 표시됩니다</span>
      </div>
    )
  }

  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8, flexWrap: 'wrap' }}>
        <span
          style={{
            fontSize: 15,
            color: 'var(--text-primary)',
            fontWeight: 500,
            lineHeight: 1.4,
            wordBreak: 'break-word'
          }}
        >
          {resultText}
        </span>
        {showSaved && <SavedCheckmark />}
      </div>
    </div>
  )
}
