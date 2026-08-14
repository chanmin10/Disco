import { SettingsRow } from './SettingsRow'
import { ShortcutRecorderPill } from './ShortcutRecorderPill'

interface ShortcutRowProps {
  shortcut: string
  onChange: (accelerator: string) => Promise<{ success: boolean; error?: string }>
}

export function ShortcutRow({ shortcut, onChange }: ShortcutRowProps): React.JSX.Element {
  return (
    <SettingsRow
      iconBg="#5E5CE6"
      icon={<span style={{ color: '#fff', fontSize: 15, fontWeight: 600 }}>⌘</span>}
      title="전역 단축키"
      subtitle="번역 팝업 열기"
      trailing={<ShortcutRecorderPill shortcut={shortcut} onChange={onChange} />}
    />
  )
}
