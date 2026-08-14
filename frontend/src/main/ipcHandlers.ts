import { ipcMain } from 'electron'
import * as store from './store'
import { registerGlobalShortcut } from './shortcuts'
import { hidePopup, resizePopupHeight } from './windows/popupWindow'
import { handleLoginSuccess, handleLogout } from './authLifecycle'

export function registerIpcHandlers(): void {
  ipcMain.handle('settings:getShortcut', () => store.getShortcut())

  ipcMain.handle('settings:setShortcut', (_event, accelerator: string) => {
    const result = registerGlobalShortcut(accelerator)
    if (result.success) store.setShortcutValue(accelerator)
    return result
  })

  ipcMain.handle('settings:getNativeLanguagePref', () => store.getNativeLanguagePref())

  ipcMain.handle('settings:setNativeLanguagePref', (_event, lang: string) => {
    store.setNativeLanguagePref(lang)
  })

  ipcMain.handle('popup:hide', () => hidePopup())

  ipcMain.handle('popup:resize', (_event, height: number) => resizePopupHeight(height))

  ipcMain.handle('auth:notifyLoginSuccess', () => handleLoginSuccess())

  ipcMain.handle('auth:notifyLogout', () => handleLogout())
}
