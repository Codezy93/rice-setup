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
    ["app.zen_browser.zen"]=""
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

# ── Wayland flags for Electron apps ──────────────────────────────────────────
# Chrome
CHROME_CFG="${HOME}/.var/app/com.google.Chrome/config"
mkdir -p "$CHROME_CFG"
if [[ ! -f "${CHROME_CFG}/chrome-flags.conf" ]]; then
    cat > "${CHROME_CFG}/chrome-flags.conf" <<'EOF'
--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-wayland-ime
EOF
    log_ok "Chrome Wayland flags written"
fi

# Discord
DISCORD_CFG="${HOME}/.var/app/com.discordapp.Discord/config/discord"
mkdir -p "$DISCORD_CFG"
if [[ ! -f "${DISCORD_CFG}/settings.json" ]]; then
    cat > "${DISCORD_CFG}/settings.json" <<'EOF'
{
  "SKIP_HOST_UPDATE": true,
  "IS_MAXIMIZED": false,
  "IS_MINIMIZED": false,
  "tray": false
}
EOF
fi
DISCORD_FLAGS="${HOME}/.var/app/com.discordapp.Discord/config/discord-flags.conf"
if [[ ! -f "$DISCORD_FLAGS" ]]; then
    echo "--enable-features=UseOzonePlatform --ozone-platform=wayland" > "$DISCORD_FLAGS"
    log_ok "Discord Wayland flags written"
fi

log_ok "Flatpak applications installed."
