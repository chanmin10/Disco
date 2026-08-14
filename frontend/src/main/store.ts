import Store from 'electron-store'

interface StoreSchema {
  shortcut: string
  nativeLanguagePref: string
}

const store = new Store<StoreSchema>({
  defaults: {
    shortcut: 'Shift+Alt+Space',
    nativeLanguagePref: '한국어'
  }
})

export function getShortcut(): string {
  return store.get('shortcut')
}

export function setShortcutValue(accelerator: string): void {
  store.set('shortcut', accelerator)
}

export function getNativeLanguagePref(): string {
  return store.get('nativeLanguagePref')
}

export function setNativeLanguagePref(lang: string): void {
  store.set('nativeLanguagePref', lang)
}
