#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing script-based applications (Miniconda, Oh-my-zsh)..."

# ── Miniconda ─────────────────────────────────────────────────────────────────
CONDA_DIR="${HOME}/miniconda3"
if [[ ! -d "$CONDA_DIR" ]]; then
    log_info "Installing Miniconda3..."

    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    MINICONDA_SHA_URL="${MINICONDA_URL}.sha256sum"

    tmpfile="$(mktemp /tmp/miniconda-XXXXXX.sh)"
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    curl --fail --show-error --silent --location -o "$tmpfile" "$MINICONDA_URL"

    EXPECTED_SHA="$(curl --fail --silent --location "$MINICONDA_SHA_URL" | awk '{print $1}')"
    ACTUAL_SHA="$(sha256sum "$tmpfile" | awk '{print $1}')"
    [[ "$EXPECTED_SHA" == "$ACTUAL_SHA" ]] \
        || die "Miniconda checksum mismatch. Aborting."

    bash "$tmpfile" -b -p "$CONDA_DIR"
    log_ok "Miniconda installed → ${CONDA_DIR}"

    "${CONDA_DIR}/bin/conda" init zsh bash 2>/dev/null || true
    "${CONDA_DIR}/bin/conda" config --set auto_activate_base false
    log_ok "conda init completed"
else
    log_info "[skip] Miniconda already present at ${CONDA_DIR}"
fi

# ── Oh-my-zsh ─────────────────────────────────────────────────────────────────
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    log_info "Installing Oh-my-zsh..."

    tmpfile="$(mktemp /tmp/omz-install-XXXXXX.sh)"
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    curl --fail --show-error --silent --location \
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
        -o "$tmpfile"

    # RUNZSH=no prevents the installer from immediately exec'ing zsh and
    # exiting our script; CHSH=no because we handle shell switching ourselves.
    RUNZSH=no CHSH=no bash "$tmpfile"
    log_ok "Oh-my-zsh installed"
else
    log_info "[skip] Oh-my-zsh already installed"
fi

# ── Set Zsh as default shell ──────────────────────────────────────────────────
ZSH_BIN="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$ZSH_BIN" ]]; then
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
    if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
        sudo chsh -s "$ZSH_BIN" "$USER"
        log_ok "Default shell changed to zsh"
    else
        log_info "[skip] zsh already the default shell"
    fi
else
    log_warn "zsh binary not found — cannot set as default shell"
fi

log_ok "Script-based applications installed."
