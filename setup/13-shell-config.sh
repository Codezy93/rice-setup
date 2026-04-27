#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Configuring shell and terminal environment..."

ZSHRC="${HOME}/.zshrc"
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# ── Zsh plugins (clone into OMZ custom) ───────────────────────────────────────
PLUGINS_DIR="${ZSH_CUSTOM}/plugins"

clone_plugin() {
    local name="$1" url="$2"
    local dest="${PLUGINS_DIR}/${name}"
    if [[ -d "$dest" ]]; then
        log_info "  [skip] $name already present"
    else
        git clone --depth=1 "$url" "$dest"
        log_ok "  Cloned $name"
    fi
}

clone_plugin "zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting"

# ── Patch .zshrc ──────────────────────────────────────────────────────────────
# Replace or set the plugins line
if [[ -f "$ZSHRC" ]]; then
    if grep -q "^plugins=" "$ZSHRC"; then
        sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)/' "$ZSHRC"
        log_ok ".zshrc plugins line updated"
    else
        echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)' >> "$ZSHRC"
        log_ok "plugins line added to .zshrc"
    fi
else
    log_warn ".zshrc not found — Oh-my-zsh may not be installed yet"
fi

# Add ~/.local/bin to PATH (idempotent)
if ! grep -q '\.local/bin' "${ZSHRC}" 2>/dev/null; then
    printf '\nexport PATH="${HOME}/.local/bin:${PATH}"\n' >> "$ZSHRC"
    log_ok "~/.local/bin added to PATH in .zshrc"
fi


# Kitty config is deployed by 14-dotfiles.sh (config/kitty/kitty.conf).

# ── Starship prompt ───────────────────────────────────────────────────────────
if ! cmd_exists starship; then
    log_info "Installing Starship prompt..."
    starship_script="$(fetch_script "https://starship.rs/install.sh" "starship-install")"
    trap 'rm -f "$starship_script"' EXIT INT TERM
    # Install to ~/.local/bin (no sudo needed, already in PATH)
    sh "$starship_script" --yes --bin-dir "${HOME}/.local/bin"
    log_ok "Starship installed → ${HOME}/.local/bin/starship"
else
    log_info "[skip] starship already installed"
fi

# Wire Starship into .zshrc (replaces the OMZ theme so it doesn't conflict)
if [[ -f "$ZSHRC" ]]; then
    # Disable OMZ theme to let Starship take over
    if grep -q '^ZSH_THEME=' "$ZSHRC"; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$ZSHRC"
        log_ok "OMZ theme disabled (Starship will handle the prompt)"
    fi
    # Add Starship init (idempotent)
    if ! grep -q 'starship init zsh' "$ZSHRC"; then
        printf '\n# Starship prompt\nexport STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"\neval "$(starship init zsh)"\n' \
            >> "$ZSHRC"
        log_ok "Starship init added to .zshrc"
    fi
fi

log_ok "Shell and terminal configured."
