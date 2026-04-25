#!/usr/bin/env bash
# Builds and installs AGS from source following the official installation docs:
# https://aylur.github.io/ags-docs/config/installation/
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing AGS (Aylur's GTK Shell) from source..."

# ── Skip if already installed ─────────────────────────────────────────────────
if cmd_exists ags; then
    log_info "[skip] ags already installed ($(ags --version 2>/dev/null || echo 'unknown version'))"
    exit 0
fi

# ── APT dependencies (from official docs, adapted for Debian Bookworm) ────────
log_info "Installing AGS build dependencies..."
apt_install \
    npm \
    meson \
    ninja-build \
    libgjs-dev \
    gjs \
    libgtk-layer-shell-dev \
    libgtk-3-dev \
    libpulse-dev \
    libnm-dev \
    libgnome-bluetooth-3.0-dev \
    libdbusmenu-gtk3-dev \
    libsoup-3.0-dev \
    gobject-introspection \
    libgirepository1.0-dev

# node-typescript is installed globally via npm (NodeJS module handles this)
if ! npm list -g typescript &>/dev/null; then
    npm install -g typescript
fi

log_ok "Build dependencies installed"

# ── Clone and build ───────────────────────────────────────────────────────────
BUILD_DIR="${HOME}/.local/src/ags"

if [[ ! -d "$BUILD_DIR" ]]; then
    log_info "Cloning AGS repository..."
    mkdir -p "$(dirname "$BUILD_DIR")"
    git clone --recursive https://github.com/Aylur/ags.git "$BUILD_DIR"
else
    log_info "AGS source already cloned — pulling latest..."
    git -C "$BUILD_DIR" pull --ff-only
    git -C "$BUILD_DIR" submodule update --init --recursive
fi

cd "$BUILD_DIR"

log_info "Installing npm dependencies..."
npm install

log_info "Configuring build with Meson..."
meson setup build

log_info "Installing AGS (sudo required for /usr/local)..."
sudo meson install -C build

log_ok "AGS installed: $(ags --version 2>/dev/null || echo 'ok')"
log_info "AGS config will be deployed by module 14-dotfiles."
