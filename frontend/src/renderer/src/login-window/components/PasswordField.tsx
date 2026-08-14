import { useState } from 'react'

interface PasswordFieldProps {
  id: string
  label: string
  placeholder: string
  value: string
  onChange: (value: string) => void
  autoComplete: string
  invalid?: boolean
}

export function PasswordField({
  id,
  label,
  placeholder,
  value,
  onChange,
  autoComplete,
  invalid
}: PasswordFieldProps): React.JSX.Element {
  const [visible, setVisible] = useState(false)

  return (
    <div>
      <label
        htmlFor={id}
        style={{
          display: 'block',
          fontSize: 12.5,
          fontWeight: 600,
          color: '#3a3a3c',
          marginBottom: 6
        }}
      >
        {label}
      </label>
      <div style={{ position: 'relative' }}>
        <input
          id={id}
          type={visible ? 'text' : 'password'}
          autoComplete={autoComplete}
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          aria-invalid={invalid}
          style={{
            width: '100%',
            height: 44,
            border: `1.5px solid ${invalid ? 'var(--danger)' : 'rgba(0,0,0,0.14)'}`,
            borderRadius: 9,
            padding: '0 50px 0 13px',
            fontSize: 14,
            outline: 'none',
            background: '#f7f7f8',
            color: 'var(--text-primary)'
          }}
        />
        <button
          type="button"
          aria-label={visible ? '비밀번호 숨기기' : '비밀번호 표시'}
          onClick={() => setVisible((v) => !v)}
          style={{
            position: 'absolute',
            right: 0,
            top: 0,
            bottom: 0,
            width: 44,
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#86868b'
          }}
        >
          <svg width="18" height="18" viewBox="0 0 16 16" fill="none">
            <path
              d="M1 8s2.5-4.5 7-4.5S15 8 15 8s-2.5 4.5-7 4.5S1 8 1 8z"
              stroke="currentColor"
              strokeWidth="1.3"
            />
            <circle cx="8" cy="8" r="2" stroke="currentColor" strokeWidth="1.3" />
          </svg>
        </button>
      </div>
    </div>
  )
}
