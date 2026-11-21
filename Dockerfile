# syntax=docker/dockerfile:1
# =====================================================
# Alicia-VPS | Ubuntu 24.04 + OpenSSH + Node.js + PM2
# Telegram: t.me/akuTonyStark | t.me/aboutAlicia
# =====================================================
FROM ubuntu:24.04

ARG NODE_MAJOR=26

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# Bebaskan UID 1000 + apt lebih tahan jaringan putus-putus
RUN userdel -r ubuntu 2>/dev/null || true; \
    sed -i 's/^Components: .*/Components: main restricted universe multiverse/' \
        /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true; \
    printf 'Acquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::https::Timeout "30";\n' \
        > /etc/apt/apt.conf.d/80-alicia-retry

# Paket inti
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg locales tzdata sudo git \
        openssh-server vim nano net-tools iputils-ping \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Paket tambahan (layer terpisah, boleh gagal sebagian)
RUN apt-get update \
    && ( apt-get install -y --no-install-recommends htop tmux neofetch \
         || apt-get install -y --no-install-recommends htop tmux \
         || true ) \
    && rm -rf /var/lib/apt/lists/*

# Node.js (NodeSource) + npm terbaru + PM2
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest pm2 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && node -v && npm -v && pm2 -v

# Konfigurasi SSH lewat drop-in (tidak menyentuh sshd_config utama)
RUN mkdir -p /run/sshd /etc/ssh/sshd_config.d \
    && ssh-keygen -A \
    && printf '%s\n' \
        'PermitRootLogin yes' \
        'PasswordAuthentication yes' \
        'PubkeyAuthentication yes' \
        'MaxAuthTries 3' \
        'LoginGraceTime 30' \
        'ClientAliveInterval 60' \
        'ClientAliveCountMax 5' \
        'TCPKeepAlive yes' \
        > /etc/ssh/sshd_config.d/00-alicia.conf

COPY scripts/alicia-banner.sh /etc/profile.d/alicia-banner.sh
COPY scripts/alicia-start.sh  /usr/local/bin/alicia-start
RUN chmod 755 /etc/profile.d/alicia-banner.sh /usr/local/bin/alicia-start

EXPOSE 22
CMD ["/usr/local/bin/alicia-start"]
