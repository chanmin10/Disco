import Store from 'electron-store'

interface StoreSchema {
  shortcut: string
}

const store = new Store<StoreSchema>({
  defaults: {
    shortcut: 'Shift+Alt+Space'
  }
})

export function getShortcut(): string {
  return store.get('shortcut')
}

export function setShortcutValue(accelerator: string): void {
  store.set('shortcut', accelerator)
}
