import { useState, type FormEvent } from 'react'
import { supabase } from '../../shared/supabaseClient'
import { PasswordField } from '../components/PasswordField'
import { BannerError } from '../components/FormError'

interface LoginViewProps {
  onSwitchToSignup: () => void
  onSwitchToForgot: () => void
}

export function LoginView({
  onSwitchToSignup,
  onSwitchToForgot
}: LoginViewProps): React.JSX.Element {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: FormEvent): Promise<void> => {
    e.preventDefault()
    if (submitting) return
    setError(null)
    setSubmitting(true)
    const { error: signInError } = await supabase.auth.signInWithPassword({ email, password })
    setSubmitting(false)
    if (signInError) {
      setError(signInError.message)
      return
    }
    await window.api.notifyLoginSuccess()
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
      <span style={{ fontSize: 19, fontWeight: 700, color: 'var(--text-primary)' }}>로그인</span>
      <span style={{ fontSize: 12.5, color: '#86868b', lineHeight: 1.5 }}>
        DISCO 계정으로 로그인하세요
      </span>

      {error && (
        <div style={{ marginTop: 12 }}>
          <BannerError message={error} />
        </div>
      )}

      <form
        onSubmit={handleSubmit}
        noValidate
        style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 13, marginTop: 12 }}
      >
        <div>
          <label
            htmlFor="login-email"
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
            id="login-email"
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

        <div>
          <PasswordField
            id="login-password"
            label="비밀번호"
            placeholder="비밀번호"
            value={password}
            onChange={setPassword}
            autoComplete="current-password"
          />
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 4 }}>
            <button
              type="button"
              onClick={onSwitchToForgot}
              style={{
                background: 'none',
                border: 'none',
                padding: '0 2px',
                height: 28,
                display: 'inline-flex',
                alignItems: 'center',
                fontSize: 12,
                fontWeight: 600,
                color: 'var(--accent)',
                cursor: 'pointer'
              }}
            >
              비밀번호를 잊으셨나요?
            </button>
          </div>
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
            opacity: submitting ? 0.7 : 1,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 8
          }}
        >
          {submitting && (
            <svg
              width="16"
              height="16"
              viewBox="0 0 16 16"
              style={{ animation: 'discoSpin 0.7s linear infinite', color: '#fff' }}
            >
              <circle
                cx="8"
                cy="8"
                r="6.5"
                stroke="currentColor"
                strokeWidth="2"
                fill="none"
                strokeLinecap="round"
                strokeDasharray="30 40"
              />
            </svg>
          )}
          로그인
        </button>

        <div style={{ textAlign: 'center', fontSize: 12.5, color: '#86868b', paddingTop: 4 }}>
          계정이 없으신가요?{' '}
          <button
            type="button"
            onClick={onSwitchToSignup}
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
            회원가입
          </button>
        </div>
      </form>
    </div>
  )
}
