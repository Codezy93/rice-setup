#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing APT applications..."

# ── Standard Debian repo apps ─────────────────────────────────────────────────
apt_install \
    firefox-esr \
    thunderbird \
    thunar \
    tumbler \
    gvfs \
    gvfs-backends \
    kitty \
    tmux \
    btop \
    gcc \
    glow \
    zsh

log_ok "Core APT apps installed"

# ── GitHub CLI (official repo) ────────────────────────────────────────────────
if ! cmd_exists gh; then
    log_info "Adding GitHub CLI repository..."

    KEYRING="/etc/apt/keyrings/githubcli-archive-keyring.gpg"
    sudo mkdir -p /etc/apt/keyrings
    curl --fail --show-error --silent --location \
        "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
        | sudo dd of="$KEYRING"
    sudo chmod go+r "$KEYRING"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING}] \
https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt-get update -qq
    apt_install gh
else
    log_info "[skip] gh already installed"
fi

log_ok "APT applications installed."
