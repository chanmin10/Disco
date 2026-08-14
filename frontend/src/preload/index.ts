import { contextBridge, ipcRenderer } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

const api = {
  getShortcut: (): Promise<string> => ipcRenderer.invoke('settings:getShortcut'),
  setShortcut: (accelerator: string): Promise<{ success: boolean; error?: string }> =>
    ipcRenderer.invoke('settings:setShortcut', accelerator),
  getNativeLanguagePref: (): Promise<string> =>
    ipcRenderer.invoke('settings:getNativeLanguagePref'),
  setNativeLanguagePref: (lang: string): Promise<void> =>
    ipcRenderer.invoke('settings:setNativeLanguagePref', lang),
  hidePopup: (): Promise<void> => ipcRenderer.invoke('popup:hide'),
  resizePopup: (height: number): Promise<void> => ipcRenderer.invoke('popup:resize', height),
  notifyLoginSuccess: (): Promise<void> => ipcRenderer.invoke('auth:notifyLoginSuccess'),
  notifyLogout: (): Promise<void> => ipcRenderer.invoke('auth:notifyLogout'),
  onPopupShow: (callback: () => void): (() => void) => {
    const handler = (): void => callback()
    ipcRenderer.on('popup:onShow', handler)
    return () => ipcRenderer.removeListener('popup:onShow', handler)
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
