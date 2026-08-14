import { useState } from 'react'
import { useAuthSession } from '../shared/hooks/useAuthSession'
import { WindowTitleBar } from '../shared/components/WindowTitleBar'
import { LoginView } from './views/LoginView'
import { SignupView } from './views/SignupView'
import { ForgotPasswordView } from './views/ForgotPasswordView'

type View = 'login' | 'signup' | 'forgot'

function App(): React.JSX.Element {
  const { session, loading } = useAuthSession()
  const [view, setView] = useState<View>('login')

  if (loading) {
    return <div style={{ width: '100%', height: '100vh', background: 'var(--surface-window)' }} />
  }

  if (session) {
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
        {view === 'login' && (
          <LoginView
            onSwitchToSignup={() => setView('signup')}
            onSwitchToForgot={() => setView('forgot')}
          />
        )}
        {view === 'signup' && <SignupView onSwitchToLogin={() => setView('login')} />}
        {view === 'forgot' && <ForgotPasswordView onSwitchToLogin={() => setView('login')} />}
      </div>
    </div>
  )
}

export default App
