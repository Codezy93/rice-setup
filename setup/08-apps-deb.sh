#!/usr/bin/env bash
# Vendor .deb installations driven by a URL list.
# Each URL points at a .deb; we fetch them all in parallel-ish, then let
# `apt-get install` resolve dependencies in a single transaction so any
# missing libs are pulled cleanly.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

log_info "Installing vendor .deb applications..."

# ── URL list ──────────────────────────────────────────────────────────────────
# NOTE: The Bitwarden URL is a presigned GitHub release asset and expires
# (see the `se=` query parameter). When it lapses, regenerate it from the
# latest Bitwarden release page or replace the entry with `gh_latest_asset`.
URLS=(
    "https://release-assets.githubusercontent.com/github-production-release-asset/53538899/629b30ab-c446-4c2b-9a13-9c73033b0b95?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-04-26T15%3A14%3A40Z&rscd=attachment%3B+filename%3DBitwarden-2026.3.1-amd64.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-04-26T14%3A14%3A16Z&ske=2026-04-26T15%3A14%3A40Z&sks=b&skv=2018-11-09&sig=s86lyDVexPFskr7oMh07eqRYN%2FRvRf1V6uYSVu2SLbI%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3NzIxNjAwNywibmJmIjoxNzc3MjE0MjA3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.jjImulcq75UjFmEd1XDLLk2JJc2rEjsD1c5kRCqUjm8&response-content-disposition=attachment%3B%20filename%3DBitwarden-2026.3.1-amd64.deb&response-content-type=application%2Foctet-stream"
    "https://github.com/ente-io/ente/releases/download/auth-v4.4.17/ente-auth-v4.4.17-x86_64.deb"
    "https://twos.s3.us-west-2.amazonaws.com/mac/Twos-7.5.0.deb"
    "https://vscode.download.prss.microsoft.com/dbazure/download/stable/10c8e557c8b9f9ed0a87f61f1c9a44bde731c409/code_1.117.0-1776814346_amd64.deb"
    "https://github.com/dbgate/dbgate/releases/latest/download/dbgate-latest.deb"
    "https://stable.dl2.discordapp.net/apps/linux/0.0.134/discord-0.0.134.deb"
    "https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb"
)

# ── Workspace ────────────────────────────────────────────────────────────────
TMPDIR="$(mktemp -d /tmp/rice-deb-XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

# Derive a sensible filename from a URL. Strips the query string and looks for
# a filename in either the path or in `filename=...` content-disposition hints
# embedded in the query (GitHub release-assets do this).
filename_for() {
    local url="$1" name
    # Try ?filename=... or rscd=attachment;+filename=... query hint first
    name="$(printf '%s' "$url" \
        | grep -oE '[?&](response-content-disposition|rscd)=[^&]*filename%3D[^&]+' \
        | head -n1 \
        | sed -E 's/.*filename%3D//;s/%3B.*$//;s/^\+//;s/^"//;s/"$//' \
        | python3 -c 'import sys,urllib.parse;print(urllib.parse.unquote(sys.stdin.read().strip()))')"
    if [[ -z "$name" ]]; then
        # Fallback: last path segment of the URL, minus any query
        name="${url%%\?*}"
        name="${name##*/}"
    fi
    # Last-resort default
    [[ -n "$name" ]] || name="package-$RANDOM.deb"
    printf '%s' "$name"
}

# ── Download ──────────────────────────────────────────────────────────────────
DEB_FILES=()
for url in "${URLS[@]}"; do
    fname="$(filename_for "$url")"
    dest="${TMPDIR}/${fname}"

    # Skip if a matching package is already installed (rough match on filename)
    pkg_guess="${fname%%_*}"           # foo_1.2.3_amd64.deb → foo
    pkg_guess="${pkg_guess%%-[0-9]*}"  # foo-1.2.3.deb       → foo
    pkg_guess="${pkg_guess,,}"         # lowercase
    if pkg_installed "$pkg_guess"; then
        log_info "  [skip] $pkg_guess already installed"
        continue
    fi

    log_info "  Downloading ${fname}..."
    if ! curl --fail --show-error --silent --location -o "$dest" "$url"; then
        log_warn "  Download failed for ${fname} — skipping"
        rm -f "$dest"
        continue
    fi

    # Sanity-check: must be a Debian binary archive (magic = "!<arch>\n")
    if ! head -c 7 "$dest" 2>/dev/null | grep -q '!<arch>'; then
        log_warn "  ${fname} is not a valid .deb (got HTML/error?) — skipping"
        rm -f "$dest"
        continue
    fi

    DEB_FILES+=("$dest")
done

# ── Install ───────────────────────────────────────────────────────────────────
if [[ ${#DEB_FILES[@]} -eq 0 ]]; then
    log_info "Nothing new to install."
else
    log_info "Installing ${#DEB_FILES[@]} package(s) via apt..."
    sudo apt-get install -y "${DEB_FILES[@]}"
    log_ok "  Installed: $(basename -a "${DEB_FILES[@]}" | paste -sd ', ' -)"
fi

log_ok "Vendor .deb applications installed."
