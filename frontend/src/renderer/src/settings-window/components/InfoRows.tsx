import { useEffect, useState } from 'react'
import { SettingsRow } from './SettingsRow'

const InfoIcon = (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <circle cx="8" cy="8" r="6.25" stroke="white" strokeWidth="1.4" />
    <rect x="7.25" y="7" width="1.5" height="4.25" rx="0.75" fill="white" />
    <circle cx="8" cy="4.75" r="0.9" fill="white" />
  </svg>
)

export function VersionRow(): React.JSX.Element {
  const [version, setVersion] = useState('')

  useEffect(() => {
    window.api.getAppVersion().then(setVersion)
  }, [])

  return (
    <SettingsRow
      iconBg="#8E8E93"
      icon={InfoIcon}
      title="버전"
      trailing={<span style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>{version}</span>}
    />
  )
}

export function ContactRow(): React.JSX.Element {
  return (
    <SettingsRow
      iconBg="#8E8E93"
      icon={InfoIcon}
      title="문의"
      trailing={
        <span style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>jecham102@gmail.com</span>
      }
    />
  )
}
