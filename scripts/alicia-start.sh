#!/bin/bash
# Alicia-VPS | startup script
# Telegram: t.me/akuTonyStark | t.me/aboutAlicia
set -e

log()  { echo "[aboutAlicia] $*"; }
fail() {
    {
        echo "=========================================="
        echo "ERROR: $1"
        echo "Railway -> Variables -> + New Variable"
        echo "Isi nilainya lalu redeploy."
        echo "=========================================="
    } >&2
    exit 1
}

setup_root() {
    [ -n "${ROOT_PASSWORD:-}" ] || fail "ROOT_PASSWORD wajib diisi"
    printf 'root:%s\n' "$ROOT_PASSWORD" | chpasswd
    log "password root diatur"
}

setup_hostname() {
    [ -n "${HOSTNAME:-}" ] || return 0
    printf '%s\n' "$HOSTNAME" > /etc/hostname
    hostname "$HOSTNAME" 2>/dev/null || true
    log "hostname -> $HOSTNAME"
}

setup_extra_user() {
    local u="${SSH_USERNAME:-}" p="${SSH_PASSWORD:-}"
    [ -n "$u" ] && [ -n "$p" ] || return 0

    if id "$u" >/dev/null 2>&1; then
        printf '%s:%s\n' "$u" "$p" | chpasswd
        log "password user $u diperbarui"
        return 0
    fi

    useradd -m -s /bin/bash "$u"
    printf '%s:%s\n' "$u" "$p" | chpasswd
    usermod -aG sudo "$u" 2>/dev/null || true
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$u" > "/etc/sudoers.d/$u"
    chmod 440 "/etc/sudoers.d/$u"
    log "user $u dibuat (sudo aktif)"
}

setup_keys() {
    [ -n "${AUTHORIZED_KEYS:-}" ] || return 0
    install -d -m 700 /root/.ssh
    printf '%s\n' "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    log "authorized_keys root terpasang"
}

setup_timezone() {
    local tz="${TZ:-}"
    [ -n "$tz" ] || return 0
    if [ -f "/usr/share/zoneinfo/$tz" ]; then
        ln -sf "/usr/share/zoneinfo/$tz" /etc/localtime
        printf '%s\n' "$tz" > /etc/timezone
        log "zona waktu -> $tz"
    else
        log "TZ '$tz' tidak dikenal, dilewati (contoh: Asia/Jakarta)"
    fi
}

restore_pm2() {
    export HOME=/root
    [ -f /root/.pm2/dump.pm2 ] || return 0
    log "memulihkan proses PM2 dari dump..."
    pm2 resurrect >/dev/null 2>&1 || log "pm2 resurrect gagal (diabaikan)"
}

setup_root
setup_timezone
setup_hostname
setup_extra_user
setup_keys
restore_pm2

log "menjalankan SSH di port 22..."
ssh-keygen -A 2>/dev/null || true
exec /usr/sbin/sshd -D -e
