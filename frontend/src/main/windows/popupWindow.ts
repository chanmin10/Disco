import { join } from 'path'
import { app, BrowserWindow, screen } from 'electron'
import { windowRegistry, loadRenderer } from './windowRegistry'

const WIDTH = 420
const INITIAL_HEIGHT = 150
const MIN_HEIGHT = 120
// The renderer always adds a fixed reserve on top of the card's own content height so the theme
// dropdown menu has room without ever resizing the window itself (see popup-window/App.tsx).
const MAX_HEIGHT = 620
const MARGIN_TOP = 10
const MARGIN_RIGHT = 16

function topRightBounds(): { x: number; y: number } {
  const { workArea } = screen.getPrimaryDisplay()
  return {
    x: Math.round(workArea.x + workArea.width - WIDTH - MARGIN_RIGHT),
    y: workArea.y + MARGIN_TOP
  }
}

export function createPopupWindow(): BrowserWindow {
  if (windowRegistry.popup && !windowRegistry.popup.isDestroyed()) {
    return windowRegistry.popup
  }

  const { x, y } = topRightBounds()

  // Native `vibrancy` combined with `transparent: true` renders this window fully invisible
  // on this Electron version — the frosted-glass look is done with CSS backdrop-filter in the
  // popup's own App.tsx instead, same technique the source design prototype used.
  const win = new BrowserWindow({
    width: WIDTH,
    height: INITIAL_HEIGHT,
    x,
    y,
    show: false,
    frame: false,
    transparent: true,
    // The window's real bounds are taller than the visible card (extra headroom reserved for
    // the theme dropdown — see App.tsx), so a native OS shadow would trace that whole invisible
    // rectangle and look like a stray border. The card draws its own CSS box-shadow instead.
    hasShadow: false,
    alwaysOnTop: true,
    resizable: false,
    skipTaskbar: true,
    backgroundColor: '#00000000',
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  win.setAlwaysOnTop(true, 'floating')
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })

  win.on('closed', () => {
    windowRegistry.popup = null
  })

  loadRenderer(win, 'popup')
  windowRegistry.popup = win
  return win
}

export function showPopup(): void {
  const win = windowRegistry.popup ?? createPopupWindow()
  const { x, y } = topRightBounds()
  win.setPosition(x, y)
  win.show()
  app.focus({ steal: true })
  win.focus()
  win.webContents.send('popup:onShow')
}

export function hidePopup(): void {
  windowRegistry.popup?.hide()
}

export function togglePopup(): void {
  const win = windowRegistry.popup
  if (win && win.isVisible()) {
    hidePopup()
  } else {
    showPopup()
  }
}

/** Resizes the popup to fit its content, keeping its top-right corner fixed. */
export function resizePopupHeight(height: number): void {
  const win = windowRegistry.popup
  if (!win || win.isDestroyed()) return

  const clamped = Math.round(Math.min(MAX_HEIGHT, Math.max(MIN_HEIGHT, height)))
  const bounds = win.getBounds()
  win.setBounds({ x: bounds.x, y: bounds.y, width: WIDTH, height: clamped })
}
