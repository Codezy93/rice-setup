#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing Podman (rootless container engine)..."

# Trixie ships a recent Podman in main — no backports pin needed
apt_install \
    podman \
    podman-compose \
    buildah \
    slirp4netns \
    fuse-overlayfs \
    containers-common \
    uidmap

log_ok "Podman packages installed"

# ── Rootless configuration ────────────────────────────────────────────────────
# Check and set subuid/subgid mappings for the current user
SUBUID_FILE="/etc/subuid"
SUBGID_FILE="/etc/subgid"

if ! grep -q "^${USER}:" "$SUBUID_FILE" 2>/dev/null; then
    sudo usermod --add-subuids 100000-165535 "$USER"
    log_ok "subuid range set for ${USER}"
else
    log_info "[skip] subuid already set for ${USER}"
fi

if ! grep -q "^${USER}:" "$SUBGID_FILE" 2>/dev/null; then
    sudo usermod --add-subgids 100000-165535 "$USER"
    log_ok "subgid range set for ${USER}"
else
    log_info "[skip] subgid already set for ${USER}"
fi

# ── Container registry configuration ─────────────────────────────────────────
REGISTRIES_CONF="/etc/containers/registries.conf"
if [[ ! -f "$REGISTRIES_CONF" ]] || ! grep -q "docker.io" "$REGISTRIES_CONF" 2>/dev/null; then
    sudo mkdir -p /etc/containers
    sudo tee "$REGISTRIES_CONF" > /dev/null <<'EOF'
[registries.search]
registries = ["docker.io", "quay.io", "ghcr.io"]

[registries.insecure]
registries = []

[registries.block]
registries = []
EOF
    log_ok "Container registries configured"
fi

# ── Podman user socket (needed by Podman Desktop) ────────────────────────────
systemctl --user enable --now podman.socket 2>/dev/null \
    && log_ok "Podman user socket enabled" \
    || log_warn "Could not enable podman.socket (expected on headless/chroot)"

log_ok "Podman setup complete."
log_info "Podman Desktop is installed via Flatpak (module 07)."
log_info "Verify: podman info && podman run --rm hello-world"
