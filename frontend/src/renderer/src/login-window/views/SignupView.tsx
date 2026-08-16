import { useState, type FormEvent } from 'react'
import { supabase } from '../../shared/supabaseClient'
import { PasswordField } from '../components/PasswordField'
import { PasswordStrengthBar } from '../components/PasswordStrengthBar'
import { BannerError } from '../components/FormError'
import { AUTH_CALLBACK_URL } from '../authCallbackUrl'

interface SignupViewProps {
  onSwitchToLogin: () => void
}

export function SignupView({ onSwitchToLogin }: SignupViewProps): React.JSX.Element {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [signedUp, setSignedUp] = useState(false)

  const mismatch = confirmPassword.length > 0 && password !== confirmPassword

  const handleSubmit = async (e: FormEvent): Promise<void> => {
    e.preventDefault()
    if (submitting) return
    setError(null)

    if (password !== confirmPassword) {
      setError('비밀번호가 일치하지 않습니다')
      return
    }

    setSubmitting(true)
    const { data, error: signUpError } = await supabase.auth.signUp({
      email,
      password,
      options: { emailRedirectTo: AUTH_CALLBACK_URL }
    })
    setSubmitting(false)

    if (signUpError) {
      setError(signUpError.message)
      return
    }

    if (data.session) {
      await window.api.notifyLoginSuccess()
      return
    }

    setSignedUp(true)
  }

  if (signedUp) {
    return (
      <div
        style={{ width: '100%', maxWidth: 392, display: 'flex', flexDirection: 'column', gap: 5 }}
      >
        <span style={{ fontSize: 19, fontWeight: 700, color: 'var(--text-primary)' }}>
          이메일을 확인해주세요
        </span>
        <span style={{ fontSize: 12.5, color: '#86868b', lineHeight: 1.5, marginBottom: 16 }}>
          {email}로 인증 메일을 보냈습니다. 메일의 링크를 확인한 뒤 로그인해주세요.
        </span>
        <button
          type="button"
          onClick={onSwitchToLogin}
          style={{
            height: 44,
            borderRadius: 10,
            background: 'var(--accent)',
            color: '#fff',
            border: 'none',
            fontSize: 14.5,
            fontWeight: 700,
            cursor: 'pointer'
          }}
        >
          로그인으로 돌아가기
        </button>
      </div>
    )
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
      <span style={{ fontSize: 19, fontWeight: 700, color: 'var(--text-primary)' }}>회원가입</span>
      <span style={{ fontSize: 12.5, color: '#86868b', lineHeight: 1.5 }}>
        DISCO 계정을 만들어보세요
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
            htmlFor="signup-email"
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
            id="signup-email"
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
            id="signup-password"
            label="비밀번호"
            placeholder="8자 이상, 영문/숫자/특수문자 조합"
            value={password}
            onChange={setPassword}
            autoComplete="new-password"
          />
          <PasswordStrengthBar password={password} />
        </div>

        <PasswordField
          id="signup-confirm-password"
          label="비밀번호 확인"
          placeholder="비밀번호를 다시 입력해주세요"
          value={confirmPassword}
          onChange={setConfirmPassword}
          autoComplete="new-password"
          invalid={mismatch}
        />

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
          회원가입
        </button>

        <div style={{ textAlign: 'center', fontSize: 12.5, color: '#86868b' }}>
          이미 계정이 있으신가요?{' '}
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
            로그인
          </button>
        </div>
      </form>
    </div>
  )
}
