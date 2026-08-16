#!/bin/bash

# ─── fancybash Universal Uninstaller ──────────────────────────────────────────
# Automatically detects OS (Linux / macOS) and cleans fancybash configuration
# blocks from ~/.bashrc, ~/.zshrc, and ~/.config/fish/config.fish.
# NOTE: set -e is intentionally NOT used — errors are handled per-call so that
# a missing or read-only config file never aborts the whole uninstall.
# ──────────────────────────────────────────────────────────────────────────────

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
BLUE='\033[38;2;137;180;250m'
PURPLE='\033[38;2;203;166;247m'
CYAN='\033[38;2;148;226;213m'
BOLD='\033[1m'
NC='\033[0m'

printf "\n"
printf "${PURPLE}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗${NC}\n"
printf "${PURPLE}          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║${NC}\n"
printf "${CYAN}          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║${NC}\n"
printf "${CYAN}          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║${NC}\n"
printf "${BLUE}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║${NC}\n"
printf "${BLUE}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}\n"
printf "\n"
printf "   ${BOLD}${RED}🗑️  fancybash Universal Uninstaller${NC}\n"
printf "   ${CYAN}─────────────────────────────────────────────────────────────────${NC}\n\n"

# ─── OS & Distro Detection ───────────────────────────────────────────────────
OS_TYPE="$(uname -s 2>/dev/null || echo "Unknown")"
DISTRO_NAME=""
IS_MACOS=false

case "$OS_TYPE" in
    Linux*)
        OS="Linux"
        if [ -f /etc/os-release ]; then
            DISTRO_NAME="$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')"
        elif command -v lsb_release &>/dev/null; then
            DISTRO_NAME="$(lsb_release -d -s)"
        fi
        [ -z "$DISTRO_NAME" ] && DISTRO_NAME="Generic Linux"
        ;;
    Darwin*)
        OS="macOS"
        IS_MACOS=true
        DISTRO_NAME="macOS $(sw_vers -productVersion 2>/dev/null || echo "")"
        ;;
    *)
        OS="Unknown"
        DISTRO_NAME="Unknown OS"
        ;;
esac

printf "  ${CYAN}➜ System:${NC}  ${BOLD}%s${NC} (%s)\n" "$OS" "$DISTRO_NAME"
printf "${CYAN}──────────────────────────────────────────${NC}\n"

removed_any=false
_BACKUPS=()

# ─── sed_escape: escape a literal string for use inside a sed /regex/ ─────────
sed_escape() {
    printf '%s' "$1" | sed 's/[]\/$*.^[]/\\&/g'
}

# ─── _atomic_sed: sed via tmpfile to avoid Linux in-place truncation race ─────
# Args: $1=file  $2=sed_script
_atomic_sed() {
    local file="$1" script="$2"
    local tmpfile
    tmpfile="$(mktemp "${TMPDIR:-/tmp}/fancybash_unsed.XXXXXX")" || {
        printf "  ${RED}✘${NC} mktemp failed for %s — skipping.\n" "$file" >&2
        return 1
    }
    if sed "$script" "$file" > "$tmpfile" 2>/dev/null; then
        cat "$tmpfile" > "$file" && rm -f "$tmpfile"
    else
        rm -f "$tmpfile"
        return 1
    fi
}

# ─── Remove Block Function ───────────────────────────────────────────────────
# Args: $1=target_file  $2=start_marker  $3=end_marker  $4=shell_label
remove_block() {
    local target_file="$1"
    local start_marker="$2"
    local end_marker="$3"
    local shell_name="$4"

    # ── Guard: file must exist and be a regular file ──────────────────────────
    if [ ! -e "$target_file" ]; then
        return 0   # nothing to do — not an error
    fi
    if [ ! -f "$target_file" ]; then
        printf "  ${YELLOW}⚠${NC} %s is not a regular file — skipping.\n" "$target_file" >&2
        return 0
    fi
    if [ ! -r "$target_file" ]; then
        printf "  ${RED}✘${NC} Cannot read %s — skipping.\n" "$target_file" >&2
        return 0
    fi

    # ── Check whether the marker is actually present ──────────────────────────
    if ! grep -qF "$start_marker" "$target_file" 2>/dev/null; then
        return 0   # block not found — silently skip
    fi

    printf "  ${YELLOW}⚠${NC} Found fancybash block in ${BOLD}%s${NC}...\n" "$target_file"

    # ── Writability check ─────────────────────────────────────────────────────
    if [ ! -w "$target_file" ]; then
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
    if [ "$IS_MACOS" = true ]; then
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

    if [ "$sed_ok" != true ]; then
        printf "  ${RED}✘${NC} sed failed on %s.\n" "$target_file" >&2
        # Attempt to restore backup
        if [ -f "$backup_file" ]; then
            cp "$backup_file" "$target_file" 2>/dev/null && \
                printf "  ${YELLOW}↩${NC} Restored from backup.\n" >&2
        fi
        return 1
    fi

    # ── Verify the block is actually gone ─────────────────────────────────────
    if grep -qF "$start_marker" "$target_file" 2>/dev/null; then
        printf "  ${YELLOW}⚠${NC} Block still detected in %s after sed — manual cleanup may be needed.\n" \
            "$target_file" >&2
    else
        printf "  ${GREEN}✔${NC} Cleanly removed fancybash from ${BOLD}%s${NC}.\n" "$target_file"
        removed_any=true
    fi
}

# ─── Perform Removal ──────────────────────────────────────────────────────────
remove_block "$HOME/.bashrc" "# >>> fancy-bashrc >>>" "# <<< fancy-bashrc <<<" "Bash"
remove_block "$HOME/.zshrc" "# >>> fancy-zshrc >>>" "# <<< fancy-zshrc <<<" "Zsh"
remove_block "$HOME/.config/fish/config.fish" "# >>> fancy-fishrc >>>" "# <<< fancy-fishrc <<<" "Fish"

printf "${CYAN}──────────────────────────────────────────${NC}\n"

if [ "$removed_any" = true ]; then
    printf "${GREEN}${BOLD}✨ fancybash has been successfully uninstalled!${NC}\n"
    printf "   To apply changes to your current session, run:\n\n"
    # Detect shell from env var (set by u.sh), then ZSH_VERSION/FISH_VERSION, then $SHELL basename
    _detected_shell="${FANCYBASH_SHELL:-}"
    if [ -z "$_detected_shell" ]; then
        if [ -n "${ZSH_VERSION:-}" ]; then
            _detected_shell="zsh"
        elif [ -n "${FISH_VERSION:-}" ]; then
            _detected_shell="fish"
        else
            _detected_shell="$(basename "${SHELL:-bash}")"
        fi
    fi
    case "$_detected_shell" in
        zsh)  printf "   ${BOLD}source ~/.zshrc${NC}\n\n" ;;
        fish) printf "   ${BOLD}source ~/.config/fish/config.fish${NC}\n\n" ;;
        *)    printf "   ${BOLD}source ~/.bashrc${NC}\n\n" ;;
    esac

    if [ "${#_BACKUPS[@]}" -gt 0 ]; then
        printf "   ${CYAN}Backups kept at:${NC}\n"
        for b in "${_BACKUPS[@]}"; do
            printf "     • %s\n" "$b"
        done
        printf "\n"
    fi
else
    printf "${CYAN}ℹ No fancybash installation blocks were found in ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish.${NC}\n\n"
fi
