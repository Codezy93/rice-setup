#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing AppImage applications..."

# ── Neovim ────────────────────────────────────────────────────────────────────
if ! cmd_exists nvim; then
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
    install_appimage "Neovim" "$NVIM_URL" "nvim" "Utility;TextEditor;"
else
    log_info "[skip] nvim already installed"
fi

# ── Bitwarden ─────────────────────────────────────────────────────────────────
BW_BIN="${HOME}/.local/bin/bitwarden"
if [[ ! -x "$BW_BIN" ]]; then
    log_info "Fetching Bitwarden latest AppImage..."
    BW_URL="$(gh_latest_asset "bitwarden/clients" "Bitwarden-.*\\.AppImage$")"
    if [[ -n "$BW_URL" ]]; then
        install_appimage "Bitwarden" "$BW_URL" "bitwarden" "Security;Utility;"
    else
        log_warn "Could not resolve Bitwarden AppImage URL — skipping"
    fi
else
    log_info "[skip] Bitwarden already present"
fi

# ── Ente Auth ─────────────────────────────────────────────────────────────────
ENTE_BIN="${HOME}/.local/bin/enteauth"
if [[ ! -x "$ENTE_BIN" ]]; then
    log_info "Fetching Ente Auth latest AppImage..."
    ENTE_URL="$(gh_latest_asset "ente-io/ente" "ente.*auth.*\\.AppImage$")"
    if [[ -n "$ENTE_URL" ]]; then
        install_appimage "Ente Auth" "$ENTE_URL" "enteauth" "Security;Utility;"
    else
        log_warn "Could not resolve Ente Auth AppImage URL — skipping"
    fi
else
    log_info "[skip] Ente Auth already present"
fi

# ── Skipped: Yay ─────────────────────────────────────────────────────────────
log_warn "Yay: AUR helper is specific to Arch Linux and does not apply to Debian."
log_warn "  Packages are managed here via apt, Flatpak, Nix, and AppImage."

# ── Skipped: Twos App ────────────────────────────────────────────────────────
log_warn "Twos App: No verified Linux desktop application exists."
log_warn "  Use the web app at https://www.twosapp.com in your browser."

log_ok "AppImage applications installed."
