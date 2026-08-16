import { useEffect, useState } from 'react'
import { supabase } from '../shared/supabaseClient'
import { useAuthSession } from '../shared/hooks/useAuthSession'
import { WindowTitleBar } from '../shared/components/WindowTitleBar'
import { BannerError } from './components/FormError'
import { LoginView } from './views/LoginView'
import { SignupView } from './views/SignupView'
import { ForgotPasswordView } from './views/ForgotPasswordView'
import { ResetPasswordView } from './views/ResetPasswordView'
import { parseAuthCallbackUrl } from './parseAuthCallbackUrl'

type View = 'login' | 'signup' | 'forgot' | 'reset-password'

function App(): React.JSX.Element {
  const { session, loading } = useAuthSession()
  const [view, setView] = useState<View>('login')
  const [deepLinkError, setDeepLinkError] = useState<string | null>(null)

  useEffect(() => {
    return window.api.onDeepLink((rawUrl) => {
      const parsed = parseAuthCallbackUrl(rawUrl)

      if (parsed.errorDescription) {
        setDeepLinkError(decodeURIComponent(parsed.errorDescription))
        return
      }

      // Set the view before establishing the session so the "already authenticated, bounce to
      // Main" check below never races a recovery session into skipping the reset-password form.
      if (parsed.type === 'recovery') setView('reset-password')

      void (async (): Promise<void> => {
        try {
          if (parsed.code) {
            const { error } = await supabase.auth.exchangeCodeForSession(parsed.code)
            if (error) throw error
          } else if (parsed.accessToken && parsed.refreshToken) {
            const { error } = await supabase.auth.setSession({
              access_token: parsed.accessToken,
              refresh_token: parsed.refreshToken
            })
            if (error) throw error
          } else {
            return
          }

          if (parsed.type !== 'recovery') {
            await window.api.notifyLoginSuccess()
          }
        } catch (e) {
          setDeepLinkError(e instanceof Error ? e.message : '인증 처리 중 오류가 발생했습니다.')
        }
      })()
    })
  }, [])

  if (loading) {
    return <div style={{ width: '100%', height: '100vh', background: 'var(--surface-window)' }} />
  }

  if (session && view !== 'reset-password') {
    // Already authenticated (e.g. this window was recreated via dock activate) — bounce to Main.
    void window.api.notifyLoginSuccess()
    return <div style={{ width: '100%', height: '100vh', background: 'var(--surface-window)' }} />
  }

  return (
    <div style={{ width: '100%', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <WindowTitleBar title="DISCO" height={40} trafficLightZoneWidth={160} />
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          padding: '22px 40px',
          background: 'var(--surface-window)',
          minHeight: 0
        }}
      >
        {deepLinkError && (
          <div style={{ width: '100%', maxWidth: 392, marginBottom: 16 }}>
            <BannerError message={deepLinkError} />
          </div>
        )}
        {view === 'login' && (
          <LoginView
            onSwitchToSignup={() => setView('signup')}
            onSwitchToForgot={() => setView('forgot')}
          />
        )}
        {view === 'signup' && <SignupView onSwitchToLogin={() => setView('login')} />}
        {view === 'forgot' && <ForgotPasswordView onSwitchToLogin={() => setView('login')} />}
        {view === 'reset-password' && <ResetPasswordView />}
      </div>
    </div>
  )
}

export default App
