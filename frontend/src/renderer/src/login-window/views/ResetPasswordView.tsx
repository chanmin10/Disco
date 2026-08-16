import { useState, type FormEvent } from 'react'
import { supabase } from '../../shared/supabaseClient'
import { PasswordField } from '../components/PasswordField'
import { PasswordStrengthBar } from '../components/PasswordStrengthBar'
import { BannerError } from '../components/FormError'

export function ResetPasswordView(): React.JSX.Element {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

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
    // The recovery deep link already established a real session (see App.tsx), so updating the
    // password here doesn't need a separate login step afterward.
    const { error: updateError } = await supabase.auth.updateUser({ password })
    setSubmitting(false)

    if (updateError) {
      setError(updateError.message)
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
      <span style={{ fontSize: 19, fontWeight: 700, color: 'var(--text-primary)' }}>
        새 비밀번호 설정
      </span>
      <span style={{ fontSize: 12.5, color: '#86868b', lineHeight: 1.5 }}>
        새로 사용할 비밀번호를 입력해주세요
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
          <PasswordField
            id="reset-password"
            label="새 비밀번호"
            placeholder="8자 이상, 영문/숫자/특수문자 조합"
            value={password}
            onChange={setPassword}
            autoComplete="new-password"
          />
          <PasswordStrengthBar password={password} />
        </div>

        <PasswordField
          id="reset-confirm-password"
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
          비밀번호 변경
        </button>
      </form>
    </div>
  )
}
