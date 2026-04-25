#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Configuring APT sources and installing base packages..."

# ── APT sources ───────────────────────────────────────────────────────────────
SOURCES_DIR="/etc/apt/sources.list.d"

# Back up the original sources.list if not already done
if [[ -f /etc/apt/sources.list && ! -f /etc/apt/sources.list.bak ]]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    log_info "Backed up /etc/apt/sources.list → /etc/apt/sources.list.bak"
fi

# Write deb822 format sources (Trixie + backports, non-free + firmware)
sudo tee "${SOURCES_DIR}/debian-trixie.sources" > /dev/null <<'EOF'
Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie trixie-updates trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

sudo tee "${SOURCES_DIR}/debian-security.sources" > /dev/null <<'EOF'
Types: deb
URIs: http://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# Replace the old sources.list with a stub to avoid duplication
sudo tee /etc/apt/sources.list > /dev/null <<'EOF'
# Managed by rice-setup. Actual sources are in /etc/apt/sources.list.d/
EOF

log_ok "APT sources configured for Debian Trixie (non-free + backports enabled)"

sudo apt-get update -qq
sudo apt-get upgrade -y
log_ok "System updated"

# ── Base packages ─────────────────────────────────────────────────────────────
apt_install \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    xdg-utils \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    libssl-dev \
    pkg-config \
    cmake \
    meson \
    ninja-build \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    zip \
    tar \
    gzip \
    jq \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    pciutils \
    lsb-release \
    sudo

log_ok "Base system ready."
