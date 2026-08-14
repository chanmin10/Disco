import { useEffect, useState } from 'react'
import { supabase } from '../shared/supabaseClient'
import { WindowTitleBar } from '../shared/components/WindowTitleBar'
import { SettingsSection } from './components/SettingsSection'
import { AccountRow } from './components/AccountRow'
import { ShortcutRow } from './components/ShortcutRow'
import { LanguageRow } from './components/LanguageRow'
import { VersionRow, ContactRow } from './components/InfoRows'

function App(): React.JSX.Element {
  const [email, setEmail] = useState('')
  const [shortcut, setShortcut] = useState('Shift+Alt+Space')
  const [nativeLanguage, setNativeLanguage] = useState('한국어')

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setEmail(data.session?.user.email ?? '')
    })
    window.api.getShortcut().then(setShortcut)
    window.api.getNativeLanguagePref().then(setNativeLanguage)
  }, [])

  const handleShortcutChange = async (
    accelerator: string
  ): Promise<{ success: boolean; error?: string }> => {
    const result = await window.api.setShortcut(accelerator)
    if (result.success) setShortcut(accelerator)
    return result
  }

  const handleLanguageChange = (lang: string): void => {
    setNativeLanguage(lang)
    window.api.setNativeLanguagePref(lang)
  }

  return (
    <div style={{ width: '100%', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <WindowTitleBar title="환경설정" height={52} trafficLightZoneWidth={160} />
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '20px 0',
          background: 'var(--surface-window)'
        }}
      >
        <SettingsSection header="계정">
          <AccountRow email={email} />
        </SettingsSection>
        <SettingsSection header="단축키">
          <ShortcutRow shortcut={shortcut} onChange={handleShortcutChange} />
        </SettingsSection>
        <SettingsSection header="언어">
          <LanguageRow value={nativeLanguage} onChange={handleLanguageChange} />
        </SettingsSection>
        <SettingsSection header="정보">
          <VersionRow />
          <ContactRow />
        </SettingsSection>
      </div>
    </div>
  )
}

export default App
