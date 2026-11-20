#  Alicia-VPS · Ubuntu 24.04 SSH Container
#  Ringan, siap pakai, dan dibuat khusus untuk Railway.
#
#  Telegram : https://t.me/akuTonyStark
#  Channel  : https://t.me/aboutAlicia

FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

RUN userdel -r ubuntu 2>/dev/null || true

RUN sed -i 's/^Components: .*/Components: main restricted universe multiverse/' \
        /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true \
    && printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "30";' \
        'Acquire::https::Timeout "30";' \
        > /etc/apt/apt.conf.d/80-alicia-retries

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gnupg \
        locales \
        openssh-server \
        sudo \
        git \
        vim \
        nano \
        procps \
        net-tools \
        iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update || true; \
    apt-get install -y --no-install-recommends htop tmux neofetch \
    || apt-get install -y --no-install-recommends htop tmux \
    || echo "[Alicia-VPS] tools tambahan dilewati"; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd /etc/ssh/sshd_config.d \
    && chmod 755 /run/sshd \
    && printf '%s\n' \
        'PasswordAuthentication yes' \
        'PermitRootLogin yes' \
        'PubkeyAuthentication yes' \
        'ClientAliveInterval 60' \
        'ClientAliveCountMax 5' \
        > /etc/ssh/sshd_config.d/10-alicia.conf \
    && sed -i 's/^session\s\+required\s\+pam_loginuid\.so/session optional pam_loginuid.so/' /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8

RUN curl -fsSL https://deb.nodesource.com/setup_26.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest pm2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.npm \
    && node -v && npm -v && pm2 -v

COPY alicia-welcome.sh /etc/profile.d/alicia-welcome.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /etc/profile.d/alicia-welcome.sh /usr/local/bin/entrypoint.sh

EXPOSE 22

CMD ["/usr/local/bin/entrypoint.sh"]
