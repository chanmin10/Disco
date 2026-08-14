import { join } from 'path'
import { BrowserWindow } from 'electron'

export type RendererEntry = 'index' | 'popup' | 'settings' | 'login'

/**
 * electron-vite serves all renderer HTML entries off the same dev server URL in dev,
 * differentiated by filename (index.html at the root, the rest by their own name).
 */
export function loadRenderer(win: BrowserWindow, entry: RendererEntry): void {
  const devServerUrl = process.env['ELECTRON_RENDERER_URL']
  if (devServerUrl) {
    const path = entry === 'index' ? '/' : `/${entry}.html`
    win.loadURL(devServerUrl + path)
  } else {
    const file = entry === 'index' ? 'index.html' : `${entry}.html`
    win.loadFile(join(__dirname, `../renderer/${file}`))
  }
}

let mainWin: BrowserWindow | null = null
let popupWin: BrowserWindow | null = null
let settingsWin: BrowserWindow | null = null
let loginWin: BrowserWindow | null = null

export const windowRegistry = {
  get main(): BrowserWindow | null {
    return mainWin
  },
  set main(win: BrowserWindow | null) {
    mainWin = win
  },
  get popup(): BrowserWindow | null {
    return popupWin
  },
  set popup(win: BrowserWindow | null) {
    popupWin = win
  },
  get settings(): BrowserWindow | null {
    return settingsWin
  },
  set settings(win: BrowserWindow | null) {
    settingsWin = win
  },
  get login(): BrowserWindow | null {
    return loginWin
  },
  set login(win: BrowserWindow | null) {
    loginWin = win
  },
  /** Whether the app currently believes the user is authenticated (Main window exists). */
  get isAuthenticated(): boolean {
    return mainWin !== null && !mainWin.isDestroyed()
  }
}
