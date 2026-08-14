import { useEffect, useRef } from 'react'
import type { ChatMessage } from '../../shared/types'
import { MessageBubble } from './MessageBubble'
import { TypingIndicator } from './TypingIndicator'
import { ChatInput } from './ChatInput'

interface ChatPanelProps {
  messages: ChatMessage[]
  isTranslating: boolean
  inputDisabled: boolean
  onSend: (text: string) => void
}

export function ChatPanel({
  messages,
  isTranslating,
  inputDisabled,
  onSend
}: ChatPanelProps): React.JSX.Element {
  const messagesRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = messagesRef.current
    if (el) el.scrollTop = el.scrollHeight
  }, [messages.length, isTranslating])

  return (
    <div
      style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        minWidth: 0,
        background: 'var(--surface-content)'
      }}
    >
      <div
        ref={messagesRef}
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: 20,
          display: 'flex',
          flexDirection: 'column',
          gap: 10,
          minHeight: 0
        }}
      >
        {messages.map((msg) => (
          <MessageBubble key={msg.id} message={msg} />
        ))}
        {isTranslating && <TypingIndicator />}
      </div>
      <ChatInput disabled={inputDisabled} onSend={onSend} />
    </div>
  )
}
