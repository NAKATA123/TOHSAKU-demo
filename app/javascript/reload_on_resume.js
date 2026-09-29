// ホーム画面に追加したアプリ(iOSなど)は、バックグラウンドから復帰する時に
// サーバーへ問い合わせず前回のページをそのまま復元する(bfcache)ことがある。
// 復元されたページを検知したら強制的に再読み込みし、常に最新版を表示させる。
window.addEventListener("pageshow", (event) => {
  if (event.persisted) {
    window.location.reload()
  }
})
