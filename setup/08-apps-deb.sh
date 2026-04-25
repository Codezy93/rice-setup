#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing vendor APT repo / .deb applications..."

# ── VSCode (Microsoft APT repo) ───────────────────────────────────────────────
if ! cmd_exists code; then
    log_info "Adding Microsoft APT repository for VSCode..."

    KEYRING="/etc/apt/keyrings/packages.microsoft.gpg"
    sudo mkdir -p /etc/apt/keyrings

    curl --fail --show-error --silent --location \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        | gpg --dearmor \
        | sudo tee "$KEYRING" > /dev/null
    sudo chmod go+r "$KEYRING"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING}] \
https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

    sudo apt-get update -qq
    apt_install code
    log_ok "VSCode installed"
else
    log_info "[skip] code already installed"
fi

# ── DBGate (latest .deb from GitHub releases) ─────────────────────────────────
if ! cmd_exists dbgate && ! pkg_installed dbgate; then
    log_info "Fetching DBGate latest .deb release..."

    DBGATE_URL="$(gh_latest_asset "dbgate/dbgate" "dbgate.*amd64\\.deb$")"
    if [[ -z "$DBGATE_URL" ]]; then
        log_warn "Could not determine DBGate download URL — skipping."
    else
        tmpfile="$(mktemp /tmp/dbgate-XXXXXX.deb)"
        trap 'rm -f "$tmpfile"' EXIT

        log_info "  Downloading: $DBGATE_URL"
        curl --fail --show-error --silent --location -o "$tmpfile" "$DBGATE_URL"
        sudo apt-get install -y "$tmpfile"
        log_ok "DBGate installed"
    fi
else
    log_info "[skip] dbgate already installed"
fi

log_ok "Vendor .deb applications installed."
