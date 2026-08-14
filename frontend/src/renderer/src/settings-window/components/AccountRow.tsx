import { supabase } from '../../shared/supabaseClient'
import { SettingsRow } from './SettingsRow'

export function AccountRow({ email }: { email: string }): React.JSX.Element {
  const handleLogout = async (): Promise<void> => {
    await supabase.auth.signOut()
    await window.api.notifyLogout()
  }

  return (
    <SettingsRow
      iconBg="#FF9F0A"
      icon={
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
          <circle cx="8" cy="5.5" r="3" fill="white" />
          <path d="M2 14c0-3 2.7-5 6-5s6 2 6 5" fill="white" />
        </svg>
      }
      title={email}
      trailing={
        <button
          type="button"
          onClick={handleLogout}
          style={{
            height: 30,
            padding: '0 12px',
            borderRadius: 7,
            border: '1px solid rgba(255,59,48,0.35)',
            background: '#fff',
            color: 'var(--danger)',
            fontSize: 12,
            fontWeight: 600,
            cursor: 'pointer',
            flexShrink: 0
          }}
        >
          로그아웃
        </button>
      }
    />
  )
}
