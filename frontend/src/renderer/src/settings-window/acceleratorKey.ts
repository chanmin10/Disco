const KEY_NAME_MAP: Record<string, string> = {
  ' ': 'Space',
  Escape: 'Escape',
  Tab: 'Tab',
  Backspace: 'Backspace',
  Delete: 'Delete',
  Enter: 'Return',
  ArrowUp: 'Up',
  ArrowDown: 'Down',
  ArrowLeft: 'Left',
  ArrowRight: 'Right',
  Home: 'Home',
  End: 'End',
  PageUp: 'PageUp',
  PageDown: 'PageDown'
}

const MODIFIER_KEYS = new Set(['Control', 'Shift', 'Alt', 'Meta'])

/** Converts a captured keydown into an Electron accelerator string, or null if only a modifier was pressed. */
export function keyEventToAccelerator(e: KeyboardEvent): string | null {
  if (MODIFIER_KEYS.has(e.key)) return null

  const modifiers: string[] = []
  if (e.metaKey) modifiers.push('Cmd')
  if (e.ctrlKey) modifiers.push('Ctrl')
  if (e.altKey) modifiers.push('Alt')
  if (e.shiftKey) modifiers.push('Shift')

  let keyPart = KEY_NAME_MAP[e.key]
  if (!keyPart) {
    if (/^F\d{1,2}$/.test(e.key)) {
      keyPart = e.key
    } else if (e.key.length === 1) {
      keyPart = /[a-zA-Z]/.test(e.key) ? e.key.toUpperCase() : e.key
    } else {
      keyPart = e.key
    }
  }

  return [...modifiers, keyPart].join('+')
}

/** Renders an Electron accelerator string with macOS symbols for display (e.g. "Shift+Alt+Space" -> "⇧⌥Space"). */
export function acceleratorToDisplay(accelerator: string): string {
  const symbolMap: Record<string, string> = {
    Cmd: '⌘',
    Ctrl: '⌃',
    Alt: '⌥',
    Shift: '⇧'
  }
  return accelerator
    .split('+')
    .map((part) => symbolMap[part] ?? part)
    .join('')
}
