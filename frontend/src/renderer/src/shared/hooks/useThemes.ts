import { useCallback, useEffect, useState } from 'react'
import * as api from '../apiClient'
import type { Theme } from '../types'

export function useThemes(): {
  themes: Theme[]
  refetch: () => Promise<void>
  addTheme: (name: string, targetLanguage: string) => Promise<Theme>
  removeTheme: (themeId: string) => Promise<void>
} {
  const [themes, setThemes] = useState<Theme[]>([])

  const refetch = useCallback(async () => {
    const data = await api.getThemes()
    setThemes(data)
  }, [])

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- fetching on mount, not derivable state
    void refetch()
  }, [refetch])

  const addTheme = useCallback(async (name: string, targetLanguage: string) => {
    const theme = await api.createTheme(name, targetLanguage)
    setThemes((prev) => [...prev, theme])
    return theme
  }, [])

  const removeTheme = useCallback(async (themeId: string) => {
    await api.deleteTheme(themeId)
    setThemes((prev) => prev.filter((t) => t.id !== themeId))
  }, [])

  return { themes, refetch, addTheme, removeTheme }
}
