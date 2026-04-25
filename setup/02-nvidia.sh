#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing NVIDIA drivers for GTX 1650 Ti..."

# Already installed if nvidia-smi responds
if cmd_exists nvidia-smi && nvidia-smi &>/dev/null; then
    log_info "[skip] NVIDIA driver already active (nvidia-smi OK)"
    exit 0
fi

# Trixie ships a recent nvidia-driver in main — no backports pin needed
apt_install \
    nvidia-driver \
    nvidia-driver-libs \
    firmware-misc-nonfree \
    nvidia-settings \
    libvulkan1 \
    vulkan-tools

# Enable DRM kernel mode setting — required for Wayland
sudo tee /etc/modprobe.d/nvidia-drm.conf > /dev/null <<'EOF'
options nvidia-drm modeset=1 fbdev=1
EOF

sudo tee /etc/modules-load.d/nvidia-drm.conf > /dev/null <<'EOF'
nvidia-drm
EOF

# Rebuild initramfs so the modeset option is active at boot
sudo update-initramfs -u

log_ok "NVIDIA drivers installed."
log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_warn "  REBOOT REQUIRED before Wayland/Hyprland will work."
log_warn "  After rebooting, re-run:  ./install.sh --resume"
log_warn "  Completed modules will be skipped automatically."
log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
