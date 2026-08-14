import { useState } from 'react'
import type { VocabEntry } from '../../shared/types'

interface VocabCardProps {
  entry: VocabEntry
  isNew: boolean
  onDelete: () => void
}

export function VocabCard({ entry, isNew, onDelete }: VocabCardProps): React.JSX.Element {
  const [flipped, setFlipped] = useState(false)
  const [hovered, setHovered] = useState(false)

  return (
    <div
      style={{ position: 'relative' }}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      <div style={{ perspective: 700 }}>
        <div
          onClick={() => setFlipped((f) => !f)}
          style={{
            position: 'relative',
            height: 34,
            cursor: 'pointer',
            transformStyle: 'preserve-3d',
            transition: 'transform 0.45s cubic-bezier(0.4,0.2,0.2,1)',
            transform: flipped ? 'rotateY(180deg)' : 'rotateY(0deg)'
          }}
        >
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backfaceVisibility: 'hidden',
              borderRadius: 8,
              background: isNew ? 'color-mix(in srgb, var(--accent) 11%, white)' : '#ffffff',
              boxShadow: '0 0 0 1px rgba(0,0,0,0.07)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '2px 8px',
              textAlign: 'center',
              transition: 'background 1.2s ease'
            }}
          >
            <span style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--text-primary)' }}>
              {entry.word_target}
            </span>
          </div>
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backfaceVisibility: 'hidden',
              borderRadius: 8,
              background: 'var(--accent)',
              transform: 'rotateY(180deg)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '2px 8px',
              textAlign: 'center'
            }}
          >
            <span style={{ fontSize: 12, fontWeight: 600, color: '#ffffff' }}>
              {entry.word_native}
            </span>
          </div>
        </div>
      </div>
      {hovered && (
        <div
          onClick={(e) => {
            e.stopPropagation()
            onDelete()
          }}
          style={{
            position: 'absolute',
            top: '50%',
            right: 6,
            transform: 'translateY(-50%)',
            width: 20,
            height: 20,
            borderRadius: 5,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            background: 'rgba(255,255,255,0.85)',
            boxShadow: '0 0 0 1px rgba(0,0,0,0.06)'
          }}
        >
          <svg width="12" height="12" viewBox="0 0 16 16" fill="none">
            <path
              d="M2 4h12M6.5 4V2.5a1 1 0 011-1h1a1 1 0 011 1V4M3.5 4l.6 9a1 1 0 001 .9h5.8a1 1 0 001-.9l.6-9"
              stroke="#9a9aa0"
              strokeWidth="1.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </div>
      )}
    </div>
  )
}
