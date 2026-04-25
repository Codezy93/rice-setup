#!/usr/bin/env bash
# Rice-Setup: automated Debian Bookworm → Hyprland workbench installer.
# Run as a normal user with sudo access. Do NOT run as root.
#
# Usage:
#   ./install.sh                      # run all modules
#   ./install.sh --skip-nvidia        # skip NVIDIA driver install
#   ./install.sh --only 03            # run only module 03-wayland-desktop
#   ./install.sh --resume             # skip modules that already have a stamp

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly LOG_FILE="${HOME}/rice-setup-install.log"

source "${SCRIPT_DIR}/setup/lib.sh"

SKIP_NVIDIA=false
ONLY_MODULE=""
RESUME=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-nvidia) SKIP_NVIDIA=true; shift ;;
        --only)        ONLY_MODULE="$2"; shift 2 ;;
        --resume)      RESUME=true; shift ;;
        *) die "Unknown argument: $1" ;;
    esac
done

[[ $EUID -eq 0 ]] && die "Do not run this script as root. Run as your normal user account."

readonly MODULES=(
    "00-preflight"
    "01-base-system"
    "02-nvidia"
    "03-wayland-desktop"
    "04-display-manager"
    "05-audio"
    "06-apps-apt"
    "07-apps-flatpak"
    "08-apps-deb"
    "09-apps-script"
    "10-apps-appimage"
    "11-nodejs"
    "12-ags"
    "13-shell-config"
    "14-dotfiles"
    "15-podman"
)

run_module() {
    local name="$1"
    local script="${SCRIPT_DIR}/setup/${name}.sh"

    [[ -f "$script" ]] || { log_warn "Module script not found: $script — skipping"; return 0; }

    if $RESUME && module_ran "$name"; then
        log_info "==> [skip] ${name} (already completed)"
        return 0
    fi

    log_info ""
    log_info "════════════════════════════════════════════"
    log_info "==> Module: ${name}"
    log_info "════════════════════════════════════════════"

    bash "$script"
    module_done "$name"
    log_ok "==> ${name} complete"
}

mkdir -p "$(dirname "$LOG_FILE")"

{
    log_info "Rice-Setup installer started: $(date)"
    log_info "Logging to: ${LOG_FILE}"

    for module in "${MODULES[@]}"; do
        [[ -n "$ONLY_MODULE" && "$module" != *"${ONLY_MODULE}"* ]] && continue
        [[ "$module" == "02-nvidia" && $SKIP_NVIDIA == true ]] && {
            log_warn "==> Skipping 02-nvidia (--skip-nvidia)"
            continue
        }
        run_module "$module"
    done

    log_ok ""
    log_ok "════════════════════════════════════════════"
    log_ok "Installation complete!"
    log_ok "If this was your first run, reboot now:"
    log_ok "  sudo reboot"
    log_ok "Then log in via SDDM and select Hyprland."
    log_ok "════════════════════════════════════════════"

} 2>&1 | tee -a "$LOG_FILE"

echo "Install - Spotify, Localsend, Discord"