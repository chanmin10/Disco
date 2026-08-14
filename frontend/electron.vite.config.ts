import { resolve } from 'path'
import { defineConfig } from 'electron-vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  main: {},
  preload: {},
  renderer: {
    resolve: {
      alias: {
        '@renderer': resolve('src/renderer/src'),
        '@shared': resolve('src/renderer/src/shared')
      }
    },
    build: {
      rollupOptions: {
        input: {
          main: resolve(__dirname, 'src/renderer/index.html'),
          popup: resolve(__dirname, 'src/renderer/popup.html'),
          settings: resolve(__dirname, 'src/renderer/settings.html'),
          login: resolve(__dirname, 'src/renderer/login.html')
        }
      }
    },
    plugins: [react()]
  }
})
