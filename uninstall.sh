#!/bin/bash

# ─── fancybash Universal Uninstaller ──────────────────────────────────────────
# Automatically detects OS (Linux / macOS) and cleans fancybash configuration
# blocks from ~/.bashrc and ~/.zshrc.
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
BLUE='\033[38;2;137;180;250m'
PURPLE='\033[38;2;203;166;247m'
CYAN='\033[38;2;148;226;213m'
BOLD='\033[1m'
NC='\033[0m'

echo -e ""
echo -e "${PURPLE}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗${NC}"
echo -e "${PURPLE}          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║${NC}"
echo -e "${CYAN}          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║${NC}"
echo -e "${CYAN}          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║${NC}"
echo -e "${BLUE}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║${NC}"
echo -e "${BLUE}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
echo -e ""
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

# ─── Remove Block Function ───────────────────────────────────────────────────
remove_block() {
    local target_file="$1"
    local start_marker="$2"
    local end_marker="$3"
    local shell_name="$4"

    if [ -f "$target_file" ] && grep -qF "$start_marker" "$target_file" 2>/dev/null; then
        printf "  ${YELLOW}⚠${NC} Found fancybash block in ${BOLD}%s${NC}...\n" "$target_file"
        
        local start_pattern end_pattern
        start_pattern="$(printf '%s' "$start_marker" | sed 's/[]\/\$*.^[]/\\&/g')"
        end_pattern="$(printf '%s' "$end_marker" | sed 's/[]\/\$*.^[]/\\&/g')"

        if [ "$IS_MACOS" = true ]; then
            sed -i '' "/${start_pattern}/,/${end_pattern}/d" "$target_file"
        else
            sed -i "/${start_pattern}/,/${end_pattern}/d" "$target_file"
        fi

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
    if [ -n "${ZSH_VERSION:-}" ] || [ "${SHELL:-}" = "*/zsh" ]; then
        printf "   ${BOLD}source ~/.zshrc${NC}\n\n"
    elif [ -n "${FISH_VERSION:-}" ] || [ "${SHELL:-}" = "*/fish" ]; then
        printf "   ${BOLD}source ~/.config/fish/config.fish${NC}\n\n"
    else
        printf "   ${BOLD}source ~/.bashrc${NC}\n\n"
    fi
else
    printf "${CYAN}ℹ No fancybash installation blocks were found in ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish.${NC}\n\n"
fi
