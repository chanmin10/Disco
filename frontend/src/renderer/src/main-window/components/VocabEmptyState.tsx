export function VocabEmptyState(): React.JSX.Element {
  return (
    <div
      style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 14,
        padding: 20,
        textAlign: 'center'
      }}
    >
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path
          d="M7 4a2 2 0 012-2h6a2 2 0 012 2v16l-5-3.2L7 20V4z"
          stroke="var(--text-faint)"
          strokeWidth="1.6"
          strokeLinejoin="round"
          strokeLinecap="round"
        />
      </svg>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <span style={{ fontSize: 13, fontWeight: 700, color: '#3a3a3c' }}>
          아직 저장된 단어가 없어요
        </span>
        <span style={{ fontSize: 11, color: 'var(--text-muted-2)', lineHeight: 1.5 }}>
          채팅에서 번역한 단어가
          <br />
          자동으로 여기 쌓여요
        </span>
      </div>
    </div>
  )
}
