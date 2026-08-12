#!/bin/bash

# ─── fancybash Shortcut Uninstaller (u.sh) ───────────────────────────────────
# Shortcut entrypoint delegating to uninstall.sh
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_BASE_URL="https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "$PWD")"
LOCAL_UNINSTALLER="$SCRIPT_DIR/uninstall.sh"

if [ -f "$LOCAL_UNINSTALLER" ]; then
    exec bash "$LOCAL_UNINSTALLER" "$@"
else
    tmp_uninstaller="$(mktemp "${TMPDIR:-/tmp}/fancybash_uninstall.XXXXXX")"
    trap 'rm -f "$tmp_uninstaller"' EXIT SIGINT SIGTERM

    if command -v curl &>/dev/null; then
        curl -fsSL "$REPO_BASE_URL/uninstall.sh" -o "$tmp_uninstaller"
    elif command -v wget &>/dev/null; then
        wget -qO "$tmp_uninstaller" "$REPO_BASE_URL/uninstall.sh"
    else
        echo "Error: Neither curl nor wget found." >&2
        exit 1
    fi

    exec bash "$tmp_uninstaller" "$@"
fi
