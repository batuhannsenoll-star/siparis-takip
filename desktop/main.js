const { app, BrowserWindow, dialog } = require('electron');
const { autoUpdater } = require('electron-updater');

function createWindow () {
  const win = new BrowserWindow({
    width: 1280,
    height: 860,
    minWidth: 900,
    minHeight: 600,
    title: 'Sipariş Takip',
    backgroundColor: '#1E2124',
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  win.setMenuBarVisibility(false); // üst menü çubuğunu (Dosya/Düzen/...) gizler, sade görünüm
  win.loadFile('index.html');
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });

  // Açılışta sessizce güncelleme kontrolü yapar; yeni sürüm bulunursa indirir
  // ve indirme bitince kullanıcıya sorup yeniden başlatır.
  autoUpdater.checkForUpdatesAndNotify().catch(() => { /* internet yoksa sessiz geç */ });
});

autoUpdater.on('update-downloaded', () => {
  dialog.showMessageBox({
    type: 'info',
    title: 'Güncelleme Hazır',
    message: 'Sipariş Takip uygulamasının yeni bir sürümü indirildi. Şimdi yeniden başlatılsın mı?',
    buttons: ['Şimdi Yeniden Başlat', 'Daha Sonra']
  }).then((result) => {
    if (result.response === 0) autoUpdater.quitAndInstall();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

