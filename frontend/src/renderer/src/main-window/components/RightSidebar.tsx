import type { VocabEntry } from '../../shared/types'
import { VocabCard } from './VocabCard'
import { VocabEmptyState } from './VocabEmptyState'

interface RightSidebarProps {
  open: boolean
  vocab: VocabEntry[]
  justSavedId: string | null
  onDelete: (entryId: string) => void
}

export function RightSidebar({
  open,
  vocab,
  justSavedId,
  onDelete
}: RightSidebarProps): React.JSX.Element {
  return (
    <div
      style={{
        width: open ? 200 : 0,
        flexShrink: 0,
        overflow: 'hidden',
        background: 'var(--surface-sidebar-right)',
        borderLeft: open ? '1px solid var(--border)' : 'none',
        display: 'flex',
        flexDirection: 'column',
        minHeight: 0,
        transition: 'width 0.2s ease'
      }}
    >
      {vocab.length > 0 ? (
        <div
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: 8,
            display: 'flex',
            flexDirection: 'column',
            gap: 5
          }}
        >
          {vocab.map((entry) => (
            <VocabCard
              key={entry.id}
              entry={entry}
              isNew={entry.id === justSavedId}
              onDelete={() => onDelete(entry.id)}
            />
          ))}
        </div>
      ) : (
        <VocabEmptyState />
      )}
    </div>
  )
}
