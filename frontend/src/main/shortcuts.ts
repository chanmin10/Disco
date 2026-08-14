import { app, globalShortcut } from 'electron'
import { togglePopup } from './windows/popupWindow'

let currentAccelerator: string | null = null

export function registerGlobalShortcut(accelerator: string): { success: boolean; error?: string } {
  if (currentAccelerator) {
    globalShortcut.unregister(currentAccelerator)
    currentAccelerator = null
  }

  const ok = globalShortcut.register(accelerator, togglePopup)
  if (!ok) {
    return {
      success: false,
      error: '단축키를 등록할 수 없습니다. 다른 앱에서 이미 사용 중일 수 있어요.'
    }
  }

  currentAccelerator = accelerator
  return { success: true }
}

export function unregisterGlobalShortcut(): void {
  if (currentAccelerator) {
    globalShortcut.unregister(currentAccelerator)
    currentAccelerator = null
  }
}

app.on('will-quit', () => {
  globalShortcut.unregisterAll()
})
