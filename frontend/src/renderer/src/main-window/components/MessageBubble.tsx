import Markdown from 'react-markdown'
import type { ChatMessage } from '../../shared/types'

export function MessageBubble({ message }: { message: ChatMessage }): React.JSX.Element {
  const isUser = message.role === 'user'

  return (
    <div style={{ display: 'flex', justifyContent: isUser ? 'flex-end' : 'flex-start' }}>
      <div
        style={{
          maxWidth: '70%',
          padding: '9px 14px',
          borderRadius: isUser ? '15px 15px 4px 15px' : '15px 15px 15px 4px',
          background: isUser ? 'var(--accent)' : 'var(--surface-subtle-fill)',
          color: isUser ? '#ffffff' : 'var(--text-primary)',
          fontSize: 14,
          lineHeight: 1.4,
          wordBreak: 'break-word'
        }}
      >
        {isUser ? (
          message.text
        ) : (
          <div className="markdown-content">
            <Markdown>{message.text}</Markdown>
          </div>
        )}
      </div>
    </div>
  )
}
