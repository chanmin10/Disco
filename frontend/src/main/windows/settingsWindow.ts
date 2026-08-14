import { join } from 'path'
import { BrowserWindow } from 'electron'
import { windowRegistry, loadRenderer } from './windowRegistry'

export function createSettingsWindow(): BrowserWindow {
  if (windowRegistry.settings && !windowRegistry.settings.isDestroyed()) {
    windowRegistry.settings.show()
    windowRegistry.settings.focus()
    return windowRegistry.settings
  }

  const win = new BrowserWindow({
    width: 600,
    height: 640,
    show: false,
    resizable: false,
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 20, y: 16 },
    backgroundColor: '#ededf0',
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  win.on('ready-to-show', () => win.show())
  win.on('closed', () => {
    windowRegistry.settings = null
  })

  loadRenderer(win, 'settings')
  windowRegistry.settings = win
  return win
}
