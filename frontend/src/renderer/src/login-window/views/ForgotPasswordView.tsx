import { useState, type FormEvent } from 'react'
import { supabase } from '../../shared/supabaseClient'
import { BannerError } from '../components/FormError'

interface ForgotPasswordViewProps {
  onSwitchToLogin: () => void
}

export function ForgotPasswordView({
  onSwitchToLogin
}: ForgotPasswordViewProps): React.JSX.Element {
  const [email, setEmail] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [sent, setSent] = useState(false)

  const handleSubmit = async (e: FormEvent): Promise<void> => {
    e.preventDefault()
    if (submitting) return
    setError(null)
    setSubmitting(true)
    const { error: resetError } = await supabase.auth.resetPasswordForEmail(email)
    setSubmitting(false)
    if (resetError) {
      setError(resetError.message)
      return
    }
    setSent(true)
  }

  return (
    <div
      style={{
        width: '100%',
        maxWidth: 392,
        display: 'flex',
        flexDirection: 'column',
        gap: 5,
        marginBottom: 16
      }}
    >
      <span style={{ fontSize: 19, fontWeight: 700, color: 'var(--text-primary)' }}>
        비밀번호 재설정
      </span>
      <span style={{ fontSize: 12.5, color: '#86868b', lineHeight: 1.5 }}>
        가입한 이메일로 재설정 링크를 보내드릴게요
      </span>

      {error && (
        <div style={{ marginTop: 12 }}>
          <BannerError message={error} />
        </div>
      )}

      {sent ? (
        <div
          role="status"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            background: '#eaf9ee',
            border: '1px solid rgba(52,199,89,0.3)',
            borderRadius: 9,
            padding: '11px 13px',
            marginTop: 12
          }}
        >
          <svg width="14" height="14" viewBox="0 0 12 12" fill="none">
            <path
              d="M2 6.5l2.5 2.5L10 3"
              stroke="#248A3D"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
          <span style={{ fontSize: 12.5, color: '#1c5a30' }}>
            {email}로 재설정 링크를 보냈습니다
          </span>
        </div>
      ) : (
        <form
          onSubmit={handleSubmit}
          noValidate
          style={{
            width: '100%',
            display: 'flex',
            flexDirection: 'column',
            gap: 13,
            marginTop: 12
          }}
        >
          <div>
            <label
              htmlFor="forgot-email"
              style={{
                display: 'block',
                fontSize: 12.5,
                fontWeight: 600,
                color: '#3a3a3c',
                marginBottom: 6
              }}
            >
              이메일
            </label>
            <input
              id="forgot-email"
              type="email"
              inputMode="email"
              autoCapitalize="off"
              autoCorrect="off"
              autoComplete="username"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={{
                width: '100%',
                height: 44,
                border: '1.5px solid rgba(0,0,0,0.14)',
                borderRadius: 9,
                padding: '0 13px',
                fontSize: 14,
                outline: 'none',
                background: '#f7f7f8',
                color: 'var(--text-primary)'
              }}
            />
          </div>

          <button
            type="submit"
            disabled={submitting}
            style={{
              height: 44,
              borderRadius: 10,
              background: 'var(--accent)',
              color: '#fff',
              border: 'none',
              fontSize: 14.5,
              fontWeight: 700,
              cursor: submitting ? 'default' : 'pointer',
              opacity: submitting ? 0.7 : 1
            }}
          >
            재설정 링크 보내기
          </button>
        </form>
      )}

      <div style={{ textAlign: 'center', fontSize: 12.5, color: '#86868b', marginTop: 13 }}>
        <button
          type="button"
          onClick={onSwitchToLogin}
          style={{
            background: 'none',
            border: 'none',
            padding: '2px 4px',
            fontSize: 12.5,
            fontWeight: 700,
            color: 'var(--accent)',
            cursor: 'pointer'
          }}
        >
          로그인으로 돌아가기
        </button>
      </div>
    </div>
  )
}
