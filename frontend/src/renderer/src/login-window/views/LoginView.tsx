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

        {/* TODO: Social login - add after deployment (needs Supabase OAuth provider setup first)
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, color: '#c7c7cc', fontSize: 11.5 }}>
          <div style={{ flex: 1, height: 1, background: 'rgba(0,0,0,0.1)' }} />
          간편 로그인
          <div style={{ flex: 1, height: 1, background: 'rgba(0,0,0,0.1)' }} />
        </div>

        <div style={{ display: 'flex', gap: 10 }}>
          <button
            type="button"
            onClick={handleSocialGoogle}
            style={{
              flex: 1,
              height: 44,
              borderRadius: 10,
              border: '1px solid rgba(0,0,0,0.14)',
              background: '#fff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              cursor: 'pointer',
              color: '#3a3a3c',
              fontSize: 12.5,
              fontWeight: 600
            }}
          >
            <svg width="18" height="18" viewBox="0 0 18 18">
              <path fill="#4285F4" d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844a4.14 4.14 0 0 1-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615z" />
              <path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.184l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332C2.438 15.983 5.482 18 9 18z" />
              <path fill="#FBBC05" d="M3.964 10.706A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.706V4.962H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.038l3.007-2.332z" />
              <path fill="#EA4335" d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0 5.482 0 2.438 2.017.957 4.962L3.964 7.294C4.672 5.167 6.656 3.58 9 3.58z" />
            </svg>
            Google
          </button>
          <button
            type="button"
            onClick={handleSocialApple}
            style={{
              flex: 1,
              height: 44,
              borderRadius: 10,
              border: '1px solid rgba(0,0,0,0.14)',
              background: '#fff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              cursor: 'pointer',
              color: '#3a3a3c',
              fontSize: 12.5,
              fontWeight: 600
            }}
          >
            <svg width="16" height="18" viewBox="0 0 384 512" fill="#1d1d1f">
              <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1-2 49.9-15.2 69.5-34.3z" />
            </svg>
            Apple
          </button>
        </div>
        */}

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
