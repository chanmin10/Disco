import { useEffect, useState } from 'react'
import type { ChatMessage, Engine, Theme } from '../shared/types'
import { useThemes } from '../shared/hooks/useThemes'
import { useVocab } from '../shared/hooks/useVocab'
import { runTranslate } from '../shared/translateFlow'
import { TitleBar } from './components/TitleBar'
import { LeftSidebar } from './components/LeftSidebar'
import { ChatPanel } from './components/ChatPanel'
import { RightSidebar } from './components/RightSidebar'
import { NewThemeModal } from './components/NewThemeModal'

function App(): React.JSX.Element {
  const { themes, addTheme, removeTheme } = useThemes()
  const [activeThemeId, setActiveThemeId] = useState<string | null>(null)
  const { vocab, refetch: refetchVocab, removeVocab } = useVocab(activeThemeId)

  const [messagesByTheme, setMessagesByTheme] = useState<Record<string, ChatMessage[]>>({})
  const [engine, setEngine] = useState<Engine>('general')
  const [leftSidebarOpen, setLeftSidebarOpen] = useState(true)
  const [rightSidebarOpen, setRightSidebarOpen] = useState(true)
  const [isTranslating, setIsTranslating] = useState(false)
  const [createRoomOpen, setCreateRoomOpen] = useState(false)
  const [justSavedId, setJustSavedId] = useState<string | null>(null)

  // Select the first theme once the list loads, without a setState-in-effect round trip.
  const [themesSnapshot, setThemesSnapshot] = useState<Theme[]>(themes)
  if (themes !== themesSnapshot) {
    setThemesSnapshot(themes)
    if (!activeThemeId && themes.length > 0) {
      setActiveThemeId(themes[0].id)
    }
  }

  const activeTheme = themes.find((t) => t.id === activeThemeId) ?? null

  // Tab is a local shortcut for toggling the translate engine, same as the popup window —
  // explicitly not a global shortcut, only active while this window is focused.
  useEffect(() => {
    const handler = (e: KeyboardEvent): void => {
      if (e.key === 'Tab') {
        e.preventDefault()
        setEngine((prev) => (prev === 'general' ? 'quick' : 'general'))
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [])

  const handleSend = async (text: string): Promise<void> => {
    if (!activeThemeId) return
    const themeId = activeThemeId

    const userMessage: ChatMessage = { id: `u${Date.now()}`, role: 'user', text }
    setMessagesByTheme((prev) => ({ ...prev, [themeId]: [...(prev[themeId] ?? []), userMessage] }))
    setIsTranslating(true)

    try {
      const result = await runTranslate({ engine, themeId, text })
      const botMessage: ChatMessage = {
        id: `b${Date.now()}`,
        role: 'bot',
        text: result.displayText
      }
      setMessagesByTheme((prev) => ({ ...prev, [themeId]: [...(prev[themeId] ?? []), botMessage] }))

      if (result.saved) {
        const prevIds = new Set(vocab.map((v) => v.id))
        const nextVocab = await refetchVocab()
        const newEntry = nextVocab.find((v) => !prevIds.has(v.id))
        if (newEntry) {
          setJustSavedId(newEntry.id)
          setTimeout(() => setJustSavedId((id) => (id === newEntry.id ? null : id)), 1500)
        }
      }
    } catch {
      const errorMessage: ChatMessage = {
        id: `b${Date.now()}`,
        role: 'bot',
        text: '번역에 실패했어요. 다시 시도해주세요.'
      }
      setMessagesByTheme((prev) => ({
        ...prev,
        [themeId]: [...(prev[themeId] ?? []), errorMessage]
      }))
    } finally {
      setIsTranslating(false)
    }
  }

  const handleDeleteTheme = async (themeId: string): Promise<void> => {
    await removeTheme(themeId)
    if (themeId === activeThemeId) {
      const remaining = themes.filter((t) => t.id !== themeId)
      setActiveThemeId(remaining[0]?.id ?? null)
    }
  }

  const handleCreateRoom = async (name: string, targetLanguage: string): Promise<void> => {
    const theme = await addTheme(name, targetLanguage)
    setActiveThemeId(theme.id)
    setCreateRoomOpen(false)
  }

  return (
    <div style={{ width: '100%', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <TitleBar
        roomName={activeTheme?.name ?? ''}
        engine={engine}
        onEngineChange={setEngine}
        rightSidebarOpen={rightSidebarOpen}
        onToggleLeftSidebar={() => setLeftSidebarOpen((o) => !o)}
        onToggleRightSidebar={() => setRightSidebarOpen((o) => !o)}
      />
      <div style={{ flex: 1, display: 'flex', minHeight: 0, position: 'relative' }}>
        <LeftSidebar
          open={leftSidebarOpen}
          themes={themes}
          activeThemeId={activeThemeId}
          onSelect={setActiveThemeId}
          onDelete={handleDeleteTheme}
          onOpenCreateRoom={() => setCreateRoomOpen(true)}
        />
        <ChatPanel
          messages={activeThemeId ? (messagesByTheme[activeThemeId] ?? []) : []}
          isTranslating={isTranslating}
          inputDisabled={isTranslating || !activeThemeId}
          onSend={handleSend}
        />
        <RightSidebar
          open={rightSidebarOpen}
          vocab={vocab}
          justSavedId={justSavedId}
          onDelete={removeVocab}
        />
        {createRoomOpen && (
          <NewThemeModal onClose={() => setCreateRoomOpen(false)} onCreate={handleCreateRoom} />
        )}
      </div>
    </div>
  )
}

export default App
