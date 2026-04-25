#!/usr/bin/env bash
# Installs Hyprland and the full hypr ecosystem via apt.
# Hyprland is packaged in Debian Trixie (13) main repos — no Nix required.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing Hyprland and the hypr ecosystem via apt..."

apt_install \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    xdg-desktop-portal-hyprland \
    hyprutils \
    hyprcursor \
    waybar \
    fuzzel \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl \
    network-manager-gnome \
    polkit-gnome

log_ok "Hyprland ecosystem (incl. waybar/fuzzel) installed"

# ── Wayland session entry for SDDM ───────────────────────────────────────────
SESSIONS_DIR="/usr/share/wayland-sessions"
sudo mkdir -p "$SESSIONS_DIR"

sudo tee "${SESSIONS_DIR}/hyprland.desktop" > /dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

log_ok "Wayland session entry written: ${SESSIONS_DIR}/hyprland.desktop"
log_ok "Wayland desktop setup complete."
