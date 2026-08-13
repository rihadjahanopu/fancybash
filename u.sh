#!/bin/bash

# ─── fancybash Universal Uninstaller (u.sh) ──────────────────────────────────
# Bulletproof shell detection: PPID → $SHELL → version vars → binary fallback
# Delegates to the correct uninstaller for the active shell.
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_BASE_URL="https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "$PWD")"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
CYAN='\033[38;2;148;226;213m'
PURPLE='\033[38;2;203;166;247m'
BOLD='\033[1m'
NC='\033[0m'

printf "\n${BOLD}${PURPLE}🗑  fancybash Uninstaller${NC}\n"
printf "${CYAN}──────────────────────────────────────────${NC}\n"

# ─── Shell Detection (Bulletproof) ───────────────────────────────────────────
# Bulletproof priority:
#   1. Parent process (PPID) — detects the ACTUAL shell that launched this script
#   2. $SHELL env var        — user's configured login shell (fallback)
#   3. Version vars          — $ZSH_VERSION / $BASH_VERSION
#   4. Binary fallback       — last resort
USER_SHELL=""

# ── 1st: Parent process check ─────────────────────────────────────────────────
# $SHELL can lie (e.g. login shell is zsh but user runs: bash u.sh).
# Checking PPID gives us the real shell that spawned this script.
PARENT_CMD=""
if [ -n "${PPID:-}" ]; then
    # Try `ps` first — most portable across Linux/macOS
    PARENT_CMD=$(ps -p "$PPID" -o comm= 2>/dev/null | sed 's/^-//' | xargs basename 2>/dev/null)
    # Fallback: /proc filesystem (Linux only)
    if [ -z "$PARENT_CMD" ] && [ -f "/proc/$PPID/comm" ]; then
        PARENT_CMD=$(sed 's/^-//' "/proc/$PPID/comm" 2>/dev/null)
    fi
fi

case "${PARENT_CMD:-}" in
    zsh)  USER_SHELL="zsh"  ;;
    bash) USER_SHELL="bash" ;;
esac

# ── 2nd: $SHELL env var ───────────────────────────────────────────────────────
if [ -z "$USER_SHELL" ] && [ -n "${SHELL:-}" ]; then
    case "$(basename "$SHELL")" in
        zsh)  USER_SHELL="zsh"  ;;
        bash) USER_SHELL="bash" ;;
    esac
fi

# ── 3rd: Version vars ─────────────────────────────────────────────────────────
if [ -z "$USER_SHELL" ]; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        USER_SHELL="zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        USER_SHELL="bash"
    fi
fi

# ── 4th: Binary fallback ──────────────────────────────────────────────────────
if [ -z "$USER_SHELL" ]; then
    if command -v zsh &>/dev/null && [ "$(uname -s)" = "Darwin" ]; then
        USER_SHELL="zsh"
    else
        USER_SHELL="bash"
    fi
fi

printf "  ${CYAN}➜ Shell:${NC}  ${BOLD}%s${NC}\n" "$USER_SHELL"
printf "${CYAN}──────────────────────────────────────────${NC}\n\n"

# ─── Run Uninstaller ─────────────────────────────────────────────────────────
# Save original script args BEFORE the function (inside function $@ = func args)
SCRIPT_ARGS=("$@")
export FANCYBASH_SHELL="$USER_SHELL"

run_uninstaller() {
    local target_script="$1"
    local exec_shell="$2"
    local local_file="$SCRIPT_DIR/$target_script"

    if [ -f "$local_file" ]; then
        printf "  ${GREEN}✔${NC} Running local ${BOLD}%s${NC}...\n\n" "$target_script"
        exec "$exec_shell" "$local_file" "${SCRIPT_ARGS[@]}"
    else
        # Running remotely — fetch and exec
        local remote_url="$REPO_BASE_URL/$target_script"
        printf "  ${GREEN}✔${NC} Fetching and running ${BOLD}%s${NC}...\n\n" "$target_script"

        local tmp_file
        tmp_file="$(mktemp "${TMPDIR:-/tmp}/fancybash_uninstall.XXXXXX")"
        trap 'rm -f "$tmp_file"' EXIT SIGINT SIGTERM

        if command -v curl &>/dev/null; then
            curl -fsSL "$remote_url" -o "$tmp_file"
        elif command -v wget &>/dev/null; then
            wget -qO "$tmp_file" "$remote_url"
        else
            printf "${RED}❌ Error: Neither curl nor wget found.${NC}\n" >&2
            exit 1
        fi

        exec "$exec_shell" "$tmp_file" "${SCRIPT_ARGS[@]}"
    fi
}

# ─── Delegate by shell ────────────────────────────────────────────────────────
case "$USER_SHELL" in
    zsh)
        # Prefer uninstall.zsh if it exists locally, otherwise fall back to uninstall.sh via zsh
        if [ -f "$SCRIPT_DIR/uninstall.zsh" ]; then
            run_uninstaller "uninstall.zsh" "zsh"
        else
            run_uninstaller "uninstall.sh" "zsh"
        fi
        ;;
    *)
        run_uninstaller "uninstall.sh" "bash"
        ;;
esac
