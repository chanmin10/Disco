import { contextBridge, ipcRenderer } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

const api = {
  getShortcut: (): Promise<string> => ipcRenderer.invoke('settings:getShortcut'),
  setShortcut: (accelerator: string): Promise<{ success: boolean; error?: string }> =>
    ipcRenderer.invoke('settings:setShortcut', accelerator),
  hidePopup: (): Promise<void> => ipcRenderer.invoke('popup:hide'),
  resizePopup: (height: number): Promise<void> => ipcRenderer.invoke('popup:resize', height),
  notifyLoginSuccess: (): Promise<void> => ipcRenderer.invoke('auth:notifyLoginSuccess'),
  notifyLogout: (): Promise<void> => ipcRenderer.invoke('auth:notifyLogout'),
  onPopupShow: (callback: () => void): (() => void) => {
    const handler = (): void => callback()
    ipcRenderer.on('popup:onShow', handler)
    return () => ipcRenderer.removeListener('popup:onShow', handler)
  },
  onDeepLink: (callback: (url: string) => void): (() => void) => {
    const handler = (_event: Electron.IpcRendererEvent, url: string): void => callback(url)
    ipcRenderer.on('auth:deepLink', handler)
    return () => ipcRenderer.removeListener('auth:deepLink', handler)
  }
}

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
    contextBridge.exposeInMainWorld('api', api)
  } catch (error) {
    console.error(error)
  }
} else {
  // @ts-ignore (define in dts)
  window.electron = electronAPI
  // @ts-ignore (define in dts)
  window.api = api
}

export type Api = typeof api
