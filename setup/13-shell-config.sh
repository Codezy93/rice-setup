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


# ── Kitty config stub ─────────────────────────────────────────────────────────
KITTY_DIR="${HOME}/.config/kitty"
mkdir -p "$KITTY_DIR"

if [[ ! -f "${KITTY_DIR}/kitty.conf" ]]; then
    cat > "${KITTY_DIR}/kitty.conf" <<'EOF'
# Kitty terminal configuration
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        12.0

# 144Hz-friendly cursor blink
cursor_blink_interval     0.5
cursor_stop_blinking_after 15.0

# Color scheme (project dark palette)
background            #0B0F14
foreground            #E6EDF3
selection_background  #3A8DFF33
selection_foreground  #E6EDF3

color0  #263241
color1  #EF4444
color2  #22C55E
color3  #F59E0B
color4  #3A8DFF
color5  #a78bfa
color6  #22D3EE
color7  #E6EDF3
color8  #6B7785
color9  #EF4444
color10 #22C55E
color11 #F59E0B
color12 #3A8DFF
color13 #a78bfa
color14 #22D3EE
color15 #E6EDF3

# Window
window_padding_width    8
hide_window_decorations yes
background_opacity      0.92

# Performance
sync_to_monitor yes
repaint_delay   4
input_delay     1
EOF
    log_ok "Kitty config written"
else
    log_info "[skip] kitty.conf already exists"
fi

# ── Starship prompt ───────────────────────────────────────────────────────────
if ! cmd_exists starship; then
    log_info "Installing Starship prompt..."
    tmpfile="$(mktemp /tmp/starship-install-XXXXXX.sh)"
    trap 'rm -f "$tmpfile"' EXIT INT TERM
    curl --fail --show-error --silent --location \
        "https://starship.rs/install.sh" -o "$tmpfile"
    # Install to ~/.local/bin (no sudo needed, already in PATH)
    sh "$tmpfile" --yes --bin-dir "${HOME}/.local/bin"
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
