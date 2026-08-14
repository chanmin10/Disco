import { useCallback, useEffect, useState } from 'react'
import * as api from '../apiClient'
import type { VocabEntry } from '../types'

export function useVocab(themeId: string | null): {
  vocab: VocabEntry[]
  refetch: () => Promise<VocabEntry[]>
  removeVocab: (entryId: string) => Promise<void>
} {
  const [vocab, setVocab] = useState<VocabEntry[]>([])

  const refetch = useCallback(async () => {
    if (!themeId) {
      setVocab([])
      return []
    }
    const data = await api.getVocab(themeId)
    setVocab(data)
    return data
  }, [themeId])

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- fetching on themeId change, not derivable state
    void refetch()
  }, [refetch])

  const removeVocab = useCallback(
    async (entryId: string) => {
      await api.deleteVocab(entryId)
      await refetch()
    },
    [refetch]
  )

  return { vocab, refetch, removeVocab }
}
