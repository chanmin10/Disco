import { join } from 'path'
import { BrowserWindow, shell } from 'electron'
import { windowRegistry, loadRenderer } from './windowRegistry'

export function createMainWindow(): BrowserWindow {
  if (windowRegistry.main && !windowRegistry.main.isDestroyed()) {
    windowRegistry.main.show()
    windowRegistry.main.focus()
    return windowRegistry.main
  }

  const win = new BrowserWindow({
    width: 1080,
    height: 700,
    minWidth: 800,
    minHeight: 560,
    show: false,
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 20, y: 16 },
    backgroundColor: '#ffffff',
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  win.on('ready-to-show', () => win.show())
  win.on('closed', () => {
    windowRegistry.main = null
  })
  win.webContents.setWindowOpenHandler((details) => {
    shell.openExternal(details.url)
    return { action: 'deny' }
  })

  loadRenderer(win, 'index')
  windowRegistry.main = win
  return win
}
