import { windowRegistry } from './windows/windowRegistry'
import { createMainWindow } from './windows/mainWindow'
import { createPopupWindow } from './windows/popupWindow'
import { createLoginWindow } from './windows/loginWindow'
import { registerGlobalShortcut, unregisterGlobalShortcut } from './shortcuts'
import { getShortcut } from './store'

export function handleLoginSuccess(): void {
  windowRegistry.login?.close()
  createMainWindow()
  createPopupWindow()
  registerGlobalShortcut(getShortcut())
}

export function handleLogout(): void {
  unregisterGlobalShortcut()
  windowRegistry.settings?.close()
  windowRegistry.popup?.close()
  // destroy() (not close()) so the main window's 'close' hide-intercept is bypassed.
  windowRegistry.main?.destroy()
  createLoginWindow()
}
