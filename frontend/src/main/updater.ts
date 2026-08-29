import { app, dialog } from 'electron'
import { autoUpdater } from 'electron-updater'

/**
 * Checks GitHub Releases (owner/repo from electron-builder.yml's `publish` config) once at
 * startup. On finding a newer version it downloads it in the background and shows a native
 * dialog; on finding it already downloaded, offers an immediate restart. If the user declines,
 * electron-updater installs it automatically the next time the app quits (autoInstallOnAppQuit).
 */
export function initAutoUpdater(): void {
  // Unpackaged (npm run dev / npm run start) has no packaged app-update.yml for electron-updater
  // to read, so checking there just throws — only run this against real installed builds.
  if (!app.isPackaged) return

  autoUpdater.autoDownload = true
  autoUpdater.autoInstallOnAppQuit = true

  autoUpdater.on('update-available', (info) => {
    void dialog.showMessageBox({
      type: 'info',
      title: '업데이트 확인',
      message: `새 버전(${info.version})을 다운로드하고 있어요.`,
      detail: '다운로드가 끝나면 다시 알려드릴게요.',
      buttons: ['확인']
    })
  })

  autoUpdater.on('update-downloaded', (info) => {
    void dialog
      .showMessageBox({
        type: 'info',
        title: '업데이트 준비 완료',
        message: `새 버전(${info.version}) 다운로드가 완료됐어요.`,
        detail:
          '지금 재시작해서 적용할까요? 나중에를 선택하면 앱을 다음에 종료할 때 자동으로 적용돼요.',
        buttons: ['지금 재시작', '나중에'],
        defaultId: 0,
        cancelId: 1
      })
      .then(({ response }) => {
        if (response === 0) autoUpdater.quitAndInstall()
      })
  })

  autoUpdater.on('error', (err) => {
    console.error('[auto-updater]', err)
  })

  autoUpdater.checkForUpdates().catch((err) => {
    console.error('[auto-updater] checkForUpdates failed', err)
  })
}
