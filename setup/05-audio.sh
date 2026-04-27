#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Setting up PipeWire audio stack and Wayland utilities..."

# Remove PulseAudio if present (conflicts with pipewire-pulse)
for pkg in pulseaudio pulseaudio-utils pulseaudio-module-bluetooth; do
    if pkg_installed "$pkg"; then
        log_info "Removing $pkg..."
        sudo apt-get remove -y "$pkg"
    fi
done

# ── PipeWire + WirePlumber ────────────────────────────────────────────────────
apt_install \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    libspa-0.2-bluetooth \
    pavucontrol

# Enable as user services (may fail on a headless system without systemd --user)
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
    || log_warn "Could not enable PipeWire user services (expected on headless/chroot)"

log_ok "PipeWire audio stack installed"

# ── XDG portals ──────────────────────────────────────────────────────────────
apt_install \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk

log_ok "XDG portals installed"

# ── Wayland tooling ───────────────────────────────────────────────────────────
apt_install \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl \
    network-manager \
    network-manager-gnome

# mako notification daemon
apt_install mako-notifier 2>/dev/null || apt_install mako 2>/dev/null \
    || log_warn "mako notification daemon not found in apt — may be installed via Nix later"

# Launcher (fuzzel) is installed in 03-wayland-desktop.sh.

log_ok "Audio and Wayland utilities ready."
