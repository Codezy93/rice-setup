#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing and configuring SDDM display manager..."

apt_install sddm

# Disable any conflicting display managers
for dm in gdm3 lightdm xdm wdm slim; do
    if pkg_installed "$dm"; then
        log_warn "Disabling conflicting display manager: $dm"
        sudo systemctl disable --now "$dm" 2>/dev/null || true
    fi
done

sudo systemctl enable sddm
log_ok "SDDM enabled"

# Configure SDDM for Wayland + NVIDIA
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/wayland.conf > /dev/null <<'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --no-lockscreen
EOF

# Environment file passed to the session (important for NVIDIA EGL)
sudo tee /etc/sddm.conf.d/nvidia-env.conf > /dev/null <<'EOF'
[General]
GreeterEnvironment=GBM_BACKEND=nvidia-drm,__GLX_VENDOR_LIBRARY_NAME=nvidia,WLR_NO_HARDWARE_CURSORS=1
EOF

log_ok "SDDM configured for Wayland + NVIDIA."
