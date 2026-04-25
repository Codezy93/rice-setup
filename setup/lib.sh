#!/usr/bin/env bash
# Shared helpers sourced by every setup module.

# ── Colours (match project palette) ──────────────────────────────────────────
readonly CLR_RESET='\033[0m'
readonly CLR_BLUE='\033[0;34m'   # info
readonly CLR_GREEN='\033[0;32m'  # ok
readonly CLR_AMBER='\033[0;33m'  # warn
readonly CLR_RED='\033[0;31m'    # error

# ── Logging ───────────────────────────────────────────────────────────────────
log_info()  { printf "${CLR_BLUE}[INFO]${CLR_RESET}  %s\n" "$*"; }
log_ok()    { printf "${CLR_GREEN}[OK]${CLR_RESET}    %s\n" "$*"; }
log_warn()  { printf "${CLR_AMBER}[WARN]${CLR_RESET}  %s\n" "$*"; }
log_err()   { printf "${CLR_RED}[ERR]${CLR_RESET}   %s\n" "$*" >&2; }
die()       { log_err "$*"; exit 1; }

# ── Idempotency stamps ────────────────────────────────────────────────────────
readonly STAMP_DIR="${HOME}/.cache/rice-setup/stamps"
mkdir -p "${STAMP_DIR}"

module_done() { touch "${STAMP_DIR}/${1}"; }
module_ran()  { [[ -f "${STAMP_DIR}/${1}" ]]; }

# ── APT helpers ───────────────────────────────────────────────────────────────
pkg_installed() { dpkg -s "$1" &>/dev/null 2>&1; }

apt_install() {
    local pkgs=()
    local pkg
    for pkg in "$@"; do
        if pkg_installed "$pkg"; then
            log_info "  [skip] $pkg already installed"
        else
            pkgs+=("$pkg")
        fi
    done
    if [[ ${#pkgs[@]} -gt 0 ]]; then
        sudo apt-get install -y "${pkgs[@]}" \
            && log_ok "  Installed: ${pkgs[*]}"
    fi
}

apt_install_backports() {
    local pkgs=()
    local pkg
    for pkg in "$@"; do
        if pkg_installed "$pkg"; then
            log_info "  [skip] $pkg already installed"
        else
            pkgs+=("$pkg")
        fi
    done
    if [[ ${#pkgs[@]} -gt 0 ]]; then
        sudo apt-get install -y -t trixie-backports "${pkgs[@]}" \
            && log_ok "  Installed (backports): ${pkgs[*]}"
    fi
}

# ── General helpers ───────────────────────────────────────────────────────────
cmd_exists() { command -v "$1" &>/dev/null; }

# Download a file, verifying its SHA-256 checksum.
# Usage: download_verified <url> <expected_sha256> <dest_path>
download_verified() {
    local url="$1" expected_sha="$2" dest="$3"
    curl --fail --show-error --silent --location -o "$dest" "$url"
    local actual_sha
    actual_sha="$(sha256sum "$dest" | awk '{print $1}')"
    if [[ "$actual_sha" != "$expected_sha" ]]; then
        log_err "Checksum mismatch for $url"
        log_err "  expected: $expected_sha"
        log_err "  actual:   $actual_sha"
        rm -f "$dest"
        return 1
    fi
}

# Fetch the browser_download_url of the first asset matching a regex from the
# latest GitHub release.
# Usage: gh_latest_asset <owner/repo> <asset_regex>
gh_latest_asset() {
    local repo="$1" pattern="$2"
    curl --fail --show-error --silent \
        "https://api.github.com/repos/${repo}/releases/latest" \
        | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
for a in data.get('assets', []):
    if re.search(r'${pattern}', a['name']):
        print(a['browser_download_url'])
        break
"
}

# Install an AppImage: download, make executable, write .desktop entry.
# Usage: install_appimage <name> <url> <exec_name> <categories>
install_appimage() {
    local name="$1" url="$2" exec_name="$3" categories="${4:-Utility;}"
    local bin_dir="${HOME}/.local/bin"
    local app_dir="${HOME}/.local/share/applications"
    local dest="${bin_dir}/${exec_name}"
    mkdir -p "$bin_dir" "$app_dir"

    if [[ -x "$dest" ]]; then
        log_info "  [skip] ${name} AppImage already present"
        return 0
    fi

    log_info "  Downloading ${name}..."
    curl --fail --show-error --silent --location -o "$dest" "$url"
    chmod +x "$dest"

    cat > "${app_dir}/${exec_name}.desktop" <<EOF
[Desktop Entry]
Name=${name}
Exec=${dest} %U
Type=Application
Categories=${categories}
MimeType=text/plain;
EOF
    log_ok "  ${name} installed → ${dest}"
}
