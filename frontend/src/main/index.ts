import { app, BrowserWindow } from 'electron'
import { electronApp, optimizer } from '@electron-toolkit/utils'
import { buildAppMenu } from './menu'
import { registerIpcHandlers } from './ipcHandlers'
import { createLoginWindow } from './windows/loginWindow'

app.whenReady().then(() => {
  electronApp.setAppUserModelId('com.disco.app')

  app.on('browser-window-created', (_, window) => {
    optimizer.watchWindowShortcuts(window)
  })

  buildAppMenu()
  registerIpcHandlers()

  // No main-process Supabase client: the Login window's own renderer checks
  // supabase.auth.getSession() on mount and bounces itself to Main via
  // auth:notifyLoginSuccess if a session already exists.
  createLoginWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createLoginWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})
