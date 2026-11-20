#!/bin/bash
set -euo pipefail

log()  { echo "[Alicia-VPS] $*"; }
warn() { echo "[Alicia-VPS] PERINGATAN: $*" >&2; }

if [ -z "${ROOT_PASSWORD:-}" ]; then
    {
        echo "============================================================"
        echo " Alicia-VPS tidak bisa start: ROOT_PASSWORD belum diisi."
        echo
        echo " Cara memperbaiki:"
        echo "   1. Buka Railway > service ini > tab Variables"
        echo "   2. Klik + New Variable"
        echo "   3. Name  : ROOT_PASSWORD"
        echo "      Value : password-kuat-kamu"
        echo "   4. Deploy ulang"
        echo "============================================================"
    } >&2
    exit 1
fi
printf 'root:%s\n' "${ROOT_PASSWORD}" | chpasswd
log "password root berhasil diatur"

if [ -n "${VPS_HOSTNAME:-}" ]; then
    if [[ "${VPS_HOSTNAME}" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]; then
        if hostname "${VPS_HOSTNAME}" 2>/dev/null; then
            echo "${VPS_HOSTNAME}" > /etc/hostname 2>/dev/null || true
            log "hostname diubah menjadi ${VPS_HOSTNAME}"
        else
            warn "platform tidak mengizinkan ganti hostname, dilewati"
        fi
    else
        warn "VPS_HOSTNAME tidak valid (hanya huruf, angka, dan tanda -), dilewati"
    fi
fi

if [ -n "${SSH_USERNAME:-}" ] && [ -n "${SSH_PASSWORD:-}" ]; then
    if [[ ! "${SSH_USERNAME}" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        warn "SSH_USERNAME tidak valid (pakai huruf kecil, angka, _ atau -), user tidak dibuat"
    elif id "${SSH_USERNAME}" &>/dev/null; then
        printf '%s:%s\n' "${SSH_USERNAME}" "${SSH_PASSWORD}" | chpasswd
        log "password user ${SSH_USERNAME} diperbarui"
    else
        useradd -m -s /bin/bash "${SSH_USERNAME}"
        printf '%s:%s\n' "${SSH_USERNAME}" "${SSH_PASSWORD}" | chpasswd
        usermod -aG sudo "${SSH_USERNAME}" 2>/dev/null || true
        printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${SSH_USERNAME}" > "/etc/sudoers.d/${SSH_USERNAME}"
        chmod 440 "/etc/sudoers.d/${SSH_USERNAME}"
        log "user ${SSH_USERNAME} dibuat (akses sudo aktif)"
    fi
elif [ -n "${SSH_USERNAME:-}" ] || [ -n "${SSH_PASSWORD:-}" ]; then
    warn "SSH_USERNAME dan SSH_PASSWORD harus diisi keduanya, user tambahan dilewati"
fi

if [ -n "${AUTHORIZED_KEYS:-}" ]; then
    mkdir -p /root/.ssh
    printf '%s\n' "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    log "authorized_keys terpasang untuk root"
fi

mkdir -p /run/sshd
chmod 755 /run/sshd
ssh-keygen -A >/dev/null 2>&1 || true
log "SSH server aktif di port 22"
exec /usr/sbin/sshd -D -e
