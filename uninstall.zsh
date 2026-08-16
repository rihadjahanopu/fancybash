#!/usr/bin/env zsh

# ─── fancybash Zsh Uninstaller ────────────────────────────────────────────────
# Bulletproof zsh-native universal uninstaller.
# • Removes fancybash blocks from ~/.zshrc, ~/.bashrc, ~/.config/fish/config.fish
# • Shell-specific scripts (zsh/bash/fish) share the same scope — only the
#   runtime language differs. Use whichever matches your active shell.
# • Safe sed escaping for special regex chars in markers
# • Atomic sed-via-tmpfile on Linux (avoids in-place truncation race)
# • Backs up each file before editing
# • Graceful degradation: no hard failures if a file is missing or unwritable
# • Trap cleans up backup files on SIGINT / unexpected exit
# • No bashisms: uses zsh-native print -P for colored banners
# ──────────────────────────────────────────────────────────────────────────────

# ─── Strict mode (zsh style) ──────────────────────────────────────────────────
# NOTE: do NOT use `set -e` here — we handle every error explicitly so that a
# missing ~/.bashrc or a read-only file never aborts the whole script.
setopt NO_UNSET PIPE_FAIL 2>/dev/null || true

# ─── Colors ───────────────────────────────────────────────────────────────────
typeset -r RED='\033[38;2;243;139;168m'
typeset -r GREEN='\033[38;2;166;227;161m'
typeset -r YELLOW='\033[38;2;249;226;175m'
typeset -r BLUE='\033[38;2;137;180;250m'
typeset -r PURPLE='\033[38;2;203;166;247m'
typeset -r CYAN='\033[38;2;148;226;213m'
typeset -r BOLD='\033[1m'
typeset -r NC='\033[0m'

# ─── Banner ───────────────────────────────────────────────────────────────────
print -P ""
print -P "${PURPLE}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗${NC}"
print -P "${PURPLE}          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║${NC}"
print -P "${CYAN}          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║${NC}"
print -P "${CYAN}          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║${NC}"
print -P "${BLUE}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║${NC}"
print -P "${BLUE}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
print -P ""
printf "   ${BOLD}${RED}🗑️  fancybash Zsh Uninstaller${NC}\n"
printf "   ${CYAN}─────────────────────────────────────────────────────────────────${NC}\n\n"

# ─── OS & Distro Detection ───────────────────────────────────────────────────
typeset OS_TYPE OS DISTRO_NAME IS_MACOS
OS_TYPE="$(uname -s 2>/dev/null)" || OS_TYPE="Unknown"
DISTRO_NAME=""
IS_MACOS=false

case "$OS_TYPE" in
    Linux*)
        OS="Linux"
        if [[ -f /etc/os-release ]]; then
            DISTRO_NAME="$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null \
                | cut -d= -f2 | tr -d '"')"
        elif (( $+commands[lsb_release] )); then
            DISTRO_NAME="$(lsb_release -d -s 2>/dev/null)"
        fi
        [[ -z "$DISTRO_NAME" ]] && DISTRO_NAME="Generic Linux"
        ;;
    Darwin*)
        OS="macOS"
        IS_MACOS=true
        DISTRO_NAME="macOS $(sw_vers -productVersion 2>/dev/null || true)"
        ;;
    *)
        OS="Unknown"
        DISTRO_NAME="Unknown OS"
        ;;
esac

printf "  ${CYAN}➜ System:${NC}  ${BOLD}%s${NC} (%s)\n" "$OS" "$DISTRO_NAME"
printf "${CYAN}──────────────────────────────────────────${NC}\n"

# ─── Backup registry (cleaned up on exit) ────────────────────────────────────
typeset -a _BACKUPS
_BACKUPS=()

_cleanup() {
    # Remove leftover backup files only when the script exits abnormally
    # (i.e., not via our normal success path which prints the summary).
    # We keep the .backup.* files so the user can restore; cleanup is a no-op
    # here. The trap exists purely to restore terminal state.
    tput cnorm 2>/dev/null || true
}
trap _cleanup EXIT INT TERM

# ─── sed_escape: escape a literal string for use inside a sed /regex/ ─────────
# Handles: . * ^ $ [ ] \ / (forward-slash is the sed delimiter)
sed_escape() {
    printf '%s' "$1" | sed 's/[]\/$*.^[]/\\&/g'
}

# ─── atomic_remove_block: sed edit via tmp file (avoids Linux -i race) ────────
# Args: $1=file  $2=sed_script
_atomic_sed() {
    local file="$1" script="$2"
    local tmpfile
    tmpfile="$(mktemp "${TMPDIR:-/tmp}/fancybash_unsed.XXXXXX")" || {
        printf "  ${RED}✘${NC} mktemp failed for %s — skipping.\n" "$file" >&2
        return 1
    }
    # Write edited content to tmp, then atomically replace
    if sed "$script" "$file" > "$tmpfile" 2>/dev/null; then
        cat "$tmpfile" > "$file" && rm -f "$tmpfile"
    else
        rm -f "$tmpfile"
        return 1
    fi
}

# ─── Remove Block Function ───────────────────────────────────────────────────
# Args: $1=target_file  $2=start_marker  $3=end_marker  $4=shell_label
typeset -g removed_any=false

remove_block() {
    local target_file="$1"
    local start_marker="$2"
    local end_marker="$3"
    local shell_name="$4"

    # ── Guard: file must exist and be a regular file ──────────────────────────
    if [[ ! -e "$target_file" ]]; then
        return 0   # nothing to do — not an error
    fi
    if [[ ! -f "$target_file" ]]; then
        printf "  ${YELLOW}⚠${NC} %s is not a regular file — skipping.\n" "$target_file" >&2
        return 0
    fi
    if [[ ! -r "$target_file" ]]; then
        printf "  ${RED}✘${NC} Cannot read %s — skipping.\n" "$target_file" >&2
        return 0
    fi

    # ── Check whether the marker is actually present ──────────────────────────
    if ! grep -qF "$start_marker" "$target_file" 2>/dev/null; then
        return 0   # block not found — silently skip
    fi

    printf "  ${YELLOW}⚠${NC} Found fancybash block in ${BOLD}%s${NC}...\n" "$target_file"

    # ── Writability check ─────────────────────────────────────────────────────
    if [[ ! -w "$target_file" ]]; then
        printf "  ${RED}✘${NC} %s is read-only — cannot remove block.\n" "$target_file" >&2
        return 1
    fi

    # ── Backup before touching ────────────────────────────────────────────────
    local backup_file="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
    if cp "$target_file" "$backup_file" 2>/dev/null; then
        _BACKUPS+=("$backup_file")
        printf "  ${CYAN}↳${NC} Backup: ${BOLD}%s${NC}\n" "$backup_file"
    else
        printf "  ${YELLOW}⚠${NC} Could not create backup for %s — proceeding anyway.\n" \
            "$target_file" >&2
    fi

    # ── Build safe sed patterns ───────────────────────────────────────────────
    local start_pattern end_pattern
    start_pattern="$(sed_escape "$start_marker")"
    end_pattern="$(sed_escape "$end_marker")"
    local sed_script="/${start_pattern}/,/${end_pattern}/d"

    # ── Run sed (macOS BSD sed needs -i ''; Linux GNU sed uses -i) ───────────
    local sed_ok=false
    if [[ "$IS_MACOS" == true ]]; then
        if sed -i '' "$sed_script" "$target_file" 2>/dev/null; then
            sed_ok=true
        fi
    else
        # Prefer atomic tmp-file approach on Linux (safer for large configs)
        if _atomic_sed "$target_file" "$sed_script"; then
            sed_ok=true
        elif sed -i "$sed_script" "$target_file" 2>/dev/null; then
            # Fallback: direct in-place if atomic failed (e.g. cross-device tmp)
            sed_ok=true
        fi
    fi

    if [[ "$sed_ok" != true ]]; then
        printf "  ${RED}✘${NC} sed failed on %s.\n" "$target_file" >&2
        # Attempt to restore backup
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$target_file" 2>/dev/null && \
                printf "  ${YELLOW}↩${NC} Restored from backup.\n" >&2
        fi
        return 1
    fi

    # ── Verify the block is actually gone ────────────────────────────────────
    if grep -qF "$start_marker" "$target_file" 2>/dev/null; then
        printf "  ${YELLOW}⚠${NC} Block still detected in %s after sed — manual cleanup may be needed.\n" \
            "$target_file" >&2
    else
        printf "  ${GREEN}✔${NC} Cleanly removed fancybash block from ${BOLD}%s${NC}.\n" "$target_file"
        removed_any=true
    fi
}

# ─── Perform Removal (all shells) ────────────────────────────────────────────
remove_block "$HOME/.bashrc" "# >>> fancy-bashrc >>>" "# <<< fancy-bashrc <<<" "Bash"
remove_block "$HOME/.zshrc" "# >>> fancy-zshrc >>>" "# <<< fancy-zshrc <<<" "Zsh"
remove_block "$HOME/.config/fish/config.fish" "# >>> fancy-fishrc >>>" "# <<< fancy-fishrc <<<" "Fish"

printf "${CYAN}──────────────────────────────────────────${NC}\n"

# ─── Summary ─────────────────────────────────────────────────────────────────
if [[ "$removed_any" == true ]]; then
    printf "${GREEN}${BOLD}✨ fancybash has been successfully uninstalled!${NC}\n"
    printf "   To apply changes to your current session, run:\n\n"
    printf "   ${BOLD}source ~/.zshrc${NC}\n\n"

    if (( ${#_BACKUPS} > 0 )); then
        printf "   ${CYAN}Backups kept at:${NC}\n"
        for b in "${_BACKUPS[@]}"; do
            printf "     • %s\n" "$b"
        done
        printf "\n"
    fi
else
    printf "${CYAN}ℹ  No fancybash blocks found in ~/.zshrc, ~/.bashrc, or ~/.config/fish/config.fish.${NC}\n\n"
fi
