import { join } from 'path'
import { BrowserWindow } from 'electron'
import { windowRegistry, loadRenderer } from './windowRegistry'

export function createLoginWindow(): BrowserWindow {
  if (windowRegistry.login && !windowRegistry.login.isDestroyed()) {
    windowRegistry.login.show()
    windowRegistry.login.focus()
    return windowRegistry.login
  }

  const win = new BrowserWindow({
    width: 460,
    height: 600,
    show: false,
    resizable: false,
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 20, y: 12 },
    backgroundColor: '#ededf0',
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  win.on('ready-to-show', () => win.show())
  win.on('closed', () => {
    windowRegistry.login = null
  })

  loadRenderer(win, 'login')
  windowRegistry.login = win
  return win
}
