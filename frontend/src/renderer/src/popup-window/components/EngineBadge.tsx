import type { Engine } from '../../shared/types'
import { SegmentedControl } from '../../shared/components/SegmentedControl'

interface EngineBadgeProps {
  engine: Engine
  onChange: (engine: Engine) => void
}

export function EngineBadge({ engine, onChange }: EngineBadgeProps): React.JSX.Element {
  return (
    <div style={{ position: 'absolute', top: 12, right: 16 }}>
      <SegmentedControl value={engine} onChange={onChange} variant="compact" />
    </div>
  )
}
