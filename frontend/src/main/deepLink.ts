import { app, BrowserWindow } from 'electron'
import { windowRegistry } from './windows/windowRegistry'
import { createLoginWindow } from './windows/loginWindow'

const PROTOCOL = 'disco'

// open-url can fire before app.whenReady() resolves (cold launch via the email link), so a
// window can't be created for it yet — buffer it and flush once startup finishes.
let pendingUrl: string | null = null

export function registerDeepLinkProtocol(): void {
  app.setAsDefaultProtocolClient(PROTOCOL)
}

function deliver(url: string, win: BrowserWindow): void {
  const send = (): void => win.webContents.send('auth:deepLink', url)
  if (win.webContents.isLoading()) {
    win.webContents.once('did-finish-load', send)
  } else {
    send()
  }
  win.show()
  win.focus()
}

/** Routes a disco:// auth callback to the login window, creating/showing it if needed. */
export function handleDeepLink(url: string): void {
  if (!app.isReady()) {
    pendingUrl = url
    return
  }
  const win = windowRegistry.login ?? createLoginWindow()
  deliver(url, win)
}

/** Call once after initial startup window creation to flush a cold-launch deep link. */
export function flushPendingDeepLink(): void {
  if (!pendingUrl) return
  const url = pendingUrl
  pendingUrl = null
  handleDeepLink(url)
}

app.on('open-url', (event, url) => {
  event.preventDefault()
  handleDeepLink(url)
})
