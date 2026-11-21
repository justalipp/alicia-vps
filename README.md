# Alicia-VPS

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/u0uXyx?referralCode=FFuTVa&utm_medium=integration&utm_source=template&utm_campaign=generic)

Container **Ubuntu 24.04** dengan **SSH**, **Node.js 26**, dan **PM2** untuk Railway.
Cepat, ringan, dan siap dipakai sebagai "VPS mini" untuk menjalankan bot atau app Node.

## Fitur
- Login root lewat SSH (password atau key)
- `ROOT_PASSWORD` wajib; container berhenti jika kosong
- Hostname kustom (opsional)
- User tambahan dengan sudo (opsional)
- Node.js 26.x, npm, PM2, neofetch, git, curl, wget, vim, nano, htop, tmux
- Banner login **Alicia** berisi info sistem, disk, dan jumlah app PM2
- Batas percobaan login (3x) dan waktu tunggu login 30 detik
- Koneksi SSH dijaga tetap hidup (keepalive 60 detik)
- Zona waktu bisa diatur lewat `TZ`
- PM2 otomatis memulihkan proses yang sudah di-`pm2 save` saat restart

## Cara deploy
1. Deploy repo ini ke Railway.
2. Tab **Variables**, tambahkan `ROOT_PASSWORD`.
3. **Settings → Networking → TCP Proxy**, port `22`.
4. Sambungkan:

```bash
ssh root@<domain-railway> -p <port>
```

## Variabel

| Nama | Wajib | Fungsi |
|------|:-----:|--------|
| `ROOT_PASSWORD` | Ya | Password root |
| `HOSTNAME` | Tidak | Nama host |
| `SSH_USERNAME` | Tidak | User tambahan (sudo) |
| `SSH_PASSWORD` | Tidak | Password user tambahan |
| `TZ` | Tidak | Zona waktu, mis. `Asia/Jakarta` |
| `AUTHORIZED_KEYS` | Tidak | Public key untuk root |

## Contoh PM2

```bash
pm2 start app.js --name mybot
pm2 save
pm2 list
```

## Auto-restore PM2
Setelah `pm2 save`, proses akan dipulihkan otomatis saat container restart.
Supaya dump tidak hilang saat redeploy, pasang **Volume** di `/root`.

## Catatan
- Ini container, bukan VPS penuh. Data hilang saat redeploy kecuali memakai Volume.
- Pakai password kuat dan jangan dibagikan.

## Kontak
- Telegram: [t.me/akuTonyStark](https://t.me/akuTonyStark)
- Channel: [t.me/aboutAlicia](https://t.me/aboutAlicia)

© Alicia-VPS
