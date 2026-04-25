#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Running preflight checks..."

# OS check
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    [[ "${ID:-}" == "debian" ]] || die "This installer requires Debian. Detected: ${ID:-unknown}"
    [[ "${VERSION_CODENAME:-}" == "trixie" ]] \
        || log_warn "Expected Debian Trixie (13); detected: ${VERSION_CODENAME:-unknown}. Continuing anyway."
else
    die "/etc/os-release not found — cannot confirm Debian Trixie."
fi
log_ok "OS: Debian ${VERSION_CODENAME}"

# Architecture
ARCH="$(dpkg --print-architecture)"
[[ "$ARCH" == "amd64" ]] || die "This installer requires amd64. Detected: ${ARCH}"
log_ok "Architecture: ${ARCH}"

# Not root
[[ $EUID -ne 0 ]] || die "Run as your normal user, not root."
log_ok "Running as non-root user: ${USER}"

# sudo available
sudo -v 2>/dev/null || die "sudo is not available or password not accepted."
log_ok "sudo access confirmed"

# Internet
log_info "Checking internet connectivity..."
curl --fail --silent --head "https://deb.debian.org" -o /dev/null \
    || die "No internet connection (cannot reach deb.debian.org)."
log_ok "Internet connectivity OK"

# Disk space (≥20 GB free on /)
FREE_GB="$(df -BG / | awk 'NR==2 {gsub("G",""); print $4}')"
if (( FREE_GB < 20 )); then
    die "Not enough free disk space. Need ≥20 GB on /; found ${FREE_GB} GB."
fi
log_ok "Disk space: ${FREE_GB} GB free"

# NVIDIA GPU (advisory only)
if lspci 2>/dev/null | grep -qi nvidia; then
    log_ok "NVIDIA GPU detected"
else
    log_warn "No NVIDIA GPU detected via lspci. NVIDIA module will still run but may not be needed."
fi

log_ok "Preflight checks passed."
