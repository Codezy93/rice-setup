#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"

log_info "Deploying dotfiles..."

# Deploy a config file only if it does not already exist at the destination.
deploy() {
    local src="$1" dest="$2"
    if [[ -e "$dest" ]]; then
        log_info "  [skip] $dest already exists"
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        log_ok "  Deployed: $dest"
    fi
}

# ── Hyprland ──────────────────────────────────────────────────────────────────
HYPR_SRC="${REPO_DIR}/config/hypr"
HYPR_DEST="${HOME}/.config/hypr"

deploy "${HYPR_SRC}/hyprland.conf"  "${HYPR_DEST}/hyprland.conf"
deploy "${HYPR_SRC}/hyprpaper.conf" "${HYPR_DEST}/hyprpaper.conf"
deploy "${HYPR_SRC}/hyprlock.conf"  "${HYPR_DEST}/hyprlock.conf"
deploy "${HYPR_SRC}/hypridle.conf"  "${HYPR_DEST}/hypridle.conf"

# ── Kitty ─────────────────────────────────────────────────────────────────────
deploy "${REPO_DIR}/config/kitty/kitty.conf" "${HOME}/.config/kitty/kitty.conf"

# ── Waybar ────────────────────────────────────────────────────────────────────
WAYBAR_SRC="${REPO_DIR}/config/waybar"
WAYBAR_DEST="${HOME}/.config/waybar"
deploy "${WAYBAR_SRC}/config.jsonc" "${WAYBAR_DEST}/config.jsonc"
deploy "${WAYBAR_SRC}/style.css"    "${WAYBAR_DEST}/style.css"

# ── AGS ───────────────────────────────────────────────────────────────────────
AGS_SRC="${REPO_DIR}/config/ags"
AGS_DEST="${HOME}/.config/ags"
find "$AGS_SRC" -type f | while read -r src_file; do
    rel="${src_file#${AGS_SRC}/}"
    deploy "$src_file" "${AGS_DEST}/${rel}"
done

# ── tmux ─────────────────────────────────────────────────────────────────────
TMUX_DEST="${HOME}/.config/tmux/tmux.conf"
deploy "${REPO_DIR}/config/tmux/tmux.conf" "$TMUX_DEST"

# ── Neovim ────────────────────────────────────────────────────────────────────
# Deploy the entire nvim config tree (only missing files are created)
NVIM_SRC="${REPO_DIR}/config/nvim"
NVIM_DEST="${HOME}/.config/nvim"

find "$NVIM_SRC" -type f | while read -r src_file; do
    rel="${src_file#${NVIM_SRC}/}"
    deploy "$src_file" "${NVIM_DEST}/${rel}"
done

# ── Starship ──────────────────────────────────────────────────────────────────
deploy "${REPO_DIR}/config/starship/starship.toml" "${HOME}/.config/starship/starship.toml"

log_ok "Dotfiles deployed."
log_warn "Edit ~/.config/hypr/hyprland.conf to set your keyboard layout and monitors."
log_info "Run nvim to trigger lazy.nvim bootstrap and plugin install on first launch."
log_info "Run tmux then press prefix + I (Ctrl-a I) to install tmux plugins via TPM."
