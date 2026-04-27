#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing Flatpak and Flathub applications..."

apt_install flatpak

# Add Flathub remote
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    log_ok "Flathub remote added"
else
    log_info "[skip] Flathub remote already present"
fi

# ── Flatpak apps ──────────────────────────────────────────────────────────────
declare -A FLATPAK_APPS=(
    ["app.zen_browser.zen"]="Zen Browser"
    ["md.obsidian.Obsidian"]="Obsidian"
    ["io.podman_desktop.PodmanDesktop"]="Podman Desktop"
)

for app_id in "${!FLATPAK_APPS[@]}"; do
    app_name="${FLATPAK_APPS[$app_id]}"
    if flatpak list --app --columns=application 2>/dev/null | grep -q "^${app_id}$"; then
        log_info "  [skip] ${app_name} already installed"
    else
        log_info "  Installing ${app_name}..."
        flatpak install -y --noninteractive flathub "${app_id}" \
            && log_ok "  ${app_name} installed"
    fi
done

log_ok "Flatpak applications installed."
