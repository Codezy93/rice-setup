#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing NodeJS LTS (22.x) via NodeSource..."

readonly NODE_MAJOR=22
KEYRING="/etc/apt/keyrings/nodesource.gpg"

# Skip if a sufficiently new Node is already present
if cmd_exists node; then
    CURRENT_MAJOR="$(node --version | cut -d. -f1 | tr -d v)"
    if (( CURRENT_MAJOR >= NODE_MAJOR )); then
        log_info "[skip] node $(node --version) already installed (≥${NODE_MAJOR})"
        exit 0
    fi
    log_warn "Found node v${CURRENT_MAJOR} < ${NODE_MAJOR} — upgrading via NodeSource"
fi

sudo mkdir -p /etc/apt/keyrings

curl --fail --show-error --silent --location \
    "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
    | sudo gpg --dearmor -o "$KEYRING"
sudo chmod a+r "$KEYRING"

echo "deb [signed-by=${KEYRING}] \
https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
    | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null

sudo apt-get update -qq
apt_install nodejs

log_ok "NodeJS $(node --version) installed"

# Global tools needed by AGS / general development
npm install -g typescript tsx 2>/dev/null \
    && log_ok "Global npm packages installed: typescript, tsx" \
    || log_warn "npm global install failed — may require manual fix"

log_ok "NodeJS setup complete."
