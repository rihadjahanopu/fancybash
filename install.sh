#!/bin/bash

set -euo pipefail

BASHRC="$HOME/.bashrc"
URL="https://gist.githubusercontent.com/rihadjahanopu/a1c286e48b3ecee1a207c759279e352c/raw/config.sh"
START="# >>> fancy-bashrc >>>"
END="# <<< fancy-bashrc <<<"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG="$SCRIPT_DIR/config.sh"

# ─── Colors & Formatting ───────────────────
RED='\033[38;5;203m'
GREEN='\033[38;5;120m'
YELLOW='\033[38;5;221m'
BLUE='\033[38;5;75m'
PURPLE='\033[38;5;141m'
CYAN='\033[38;5;86m'
GRAY='\033[38;5;245m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Spinner ───────────────────────────────
spinner() {
    local pid=$1 msg="$2" delay=0.08
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    while kill -0 "$pid" 2>/dev/null; do
        for char in "${spin[@]}"; do
            printf "\r${CYAN}%s${NC} %s" "$char" "$msg"
            sleep $delay
        done
    done
    printf "\r${GREEN}  ✔${NC} %s\n" "$msg"
}

# ─── Header ────────────────────────────────
show_header() {
    echo ""
    echo -e "${PURPLE}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${PURPLE}│${NC}  ✨ ${BOLD}${CYAN}F A N C Y B A S H${NC}  •  ${BOLD}Bash Config Installer${NC}  ${PURPLE}│${NC}"
    echo -e "${PURPLE}╰──────────────────────────────────────────────────╯${NC}"
    echo ""
}

# ─── OS & Package Manager Detection ────────
detect_pm() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    elif [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID_LIKE:-$ID}" in
            *debian*|*ubuntu*|*mint*|*pop*) echo "apt" ;;
            *arch*|*manjaro*)               echo "pacman" ;;
            *fedora*|*rhel*|*centos*)       echo "dnf" ;;
            *alpine*)                       echo "apk" ;;
            *)
                if command -v apt-get &>/dev/null; then echo "apt"
                elif command -v pacman &>/dev/null; then echo "pacman"
                elif command -v dnf &>/dev/null; then echo "dnf"
                elif command -v apk &>/dev/null; then echo "apk"
                else echo "unknown"; fi
                ;;
        esac
    else
        echo "unknown"
    fi
}

# ─── Check & Install Fonts ──────────────────
check_and_install_fonts() {
    printf "${BLUE}[1/5]${NC} Checking system fonts & dependencies...\n"

    local missing_deps=()
    for cmd in curl grep git fzf; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    local fonts_needed=0
    if command -v fc-list &>/dev/null; then
        if ! fc-list : family | grep -qi "Fira Code\|FiraCode" || ! fc-list : family | grep -qi "Noto Color Emoji\|NotoColorEmoji"; then
            fonts_needed=1
        fi
    else
        fonts_needed=1
    fi

    if [ ${#missing_deps[@]} -eq 0 ] && [ $fonts_needed -eq 0 ]; then
        printf "${GREEN}  ✔${NC} All dependencies & fonts are already installed!\n"
        return 0
    fi

    printf "${YELLOW}  ⚠ Missing components detected. Attempting auto-installation...${NC}\n"
    local pm=$(detect_pm)
    local sudo_cmd=""
    if [ "${EUID:-$(id -u)}" -ne 0 ] && command -v sudo &>/dev/null; then
        sudo_cmd="sudo"
    fi

    case "$pm" in
        apt)
            $sudo_cmd apt update -qq 2>/dev/null || true
            $sudo_cmd apt install -y curl git fzf fonts-noto-color-emoji fonts-firacode fonts-cascadia-code fontconfig 2>/dev/null || true
            ;;
        pacman)
            $sudo_cmd pacman -Sy --noconfirm curl git fzf ttf-noto-emoji ttf-fira-code ttf-cascadia-code fontconfig 2>/dev/null || true
            ;;
        dnf)
            $sudo_cmd dnf install -y curl git fzf google-noto-emoji-fonts fira-code-fonts cascadia-code-fonts fontconfig 2>/dev/null || true
            ;;
        apk)
            $sudo_cmd apk add --no-cache curl git fzf font-noto-emoji font-fira-code fontconfig 2>/dev/null || true
            ;;
        brew)
            brew install curl git fzf font-fira-code font-cascadia-code font-noto-emoji 2>/dev/null || true
            ;;
        *)
            printf "${GRAY}  ℹ Package manager not recognized. Skipping automatic font install.${NC}\n"
            ;;
    esac
    printf "${GREEN}  ✔${NC} Dependencies & fonts process completed.\n"
}

# ─── Configure Fontconfig ──────────────────
setup_fontconfig() {
    printf "${BLUE}[2/5]${NC} Checking font configuration (fonts.conf)...\n"
    local font_dir="$HOME/.config/fontconfig"
    local font_conf="$font_dir/fonts.conf"

    if [ -f "$font_conf" ]; then
        printf "${GREEN}  ✔${NC} Fontconfig already exists (${GRAY}%s${NC})\n" "~/.config/fontconfig/fonts.conf"
        return 0
    fi

    mkdir -p "$font_dir"
    cat << 'EOF' > "$font_conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Fira Code</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
    printf "${GREEN}  ✔${NC} Created ${PURPLE}~/.config/fontconfig/fonts.conf${NC}\n"

    if command -v fc-cache &>/dev/null; then
        fc-cache -f &>/dev/null || true
        printf "${GREEN}  ✔${NC} Font cache refreshed!\n"
    fi
}

# ─── Check Existing Installation ───────────
check_existing_install() {
    printf "${BLUE}[3/5]${NC} Checking existing configuration...\n"
    if [ ! -f "$BASHRC" ]; then
        printf "${YELLOW}  ⚠ Creating $BASHRC...${NC}\n"
        touch "$BASHRC"
    fi

    if grep -qF "$START" "$BASHRC" 2>/dev/null; then
        printf "${GREEN}  ✔${NC} Fancy Bash config is already installed!\n"
        printf "  ${CYAN}💡 Run:${NC} ${BOLD}source $BASHRC${NC} to reload.\n\n"
        exit 0
    fi
    printf "${GREEN}  ✔${NC} Ready for installation.\n"
}

# ─── Backup ────────────────────────────────
backup_bashrc() {
    printf "${BLUE}[4/5]${NC} Creating backup...\n"
    backup_file="$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$BASHRC" "$backup_file"
    printf "${GREEN}  ✔${NC} Backup created: ${PURPLE}%s${NC}\n" "$(basename "$backup_file")"
}

# ─── Fetch & Append Config ─────────────────
install_config() {
    printf "${BLUE}[5/5]${NC} Fetching and applying config...\n"
    tmpfile=$(mktemp)

    if [ -f "$LOCAL_CONFIG" ]; then
        printf "${GREEN}  ✔${NC} Using local config.sh\n"
        cp "$LOCAL_CONFIG" "$tmpfile"
    else
        (
            if ! curl -fsSL --connect-timeout 10 "$URL" > "$tmpfile" 2>/dev/null; then
                rm -f "$tmpfile"
                exit 1
            fi
        ) &
        spinner $! "Fetching from GitHub..."
    fi

    if [ ! -s "$tmpfile" ]; then
        echo -e "${RED}  ✘ Download failed!${NC} Check your internet connection." >&2
        exit 1
    fi

    if head -1 "$tmpfile" | grep -qi "<!doctype\|<html"; then
        echo -e "${RED}  ✘ Invalid response (HTML instead of script)!${NC}" >&2
        rm -f "$tmpfile"
        exit 1
    fi

    {
        echo ""
        echo "$START"
        echo "# Installed: $(date '+%Y-%m-%d %H:%M:%S')"
        cat "$tmpfile"
        echo "$END"
    } >> "$BASHRC"

    rm -f "$tmpfile"
    printf "${GREEN}  ✔${NC} Config successfully added to ~/.bashrc!\n"
}

# ─── Reload & Summary ──────────────────────
show_summary() {
    echo ""
    if source "$BASHRC" 2>/dev/null; then
        printf "${GREEN}✨ Installation & auto-reload successful!${NC}\n\n"
    else
        printf "${YELLOW}⚠ Auto-reload skipped.${NC} Please run: ${BOLD}source ~/.bashrc${NC}\n\n"
    fi

    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}  📋  ${BOLD}INSTALLATION SUMMARY${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  • Backup:   ${GREEN}$(basename "$backup_file")${NC}"
    echo -e "${CYAN}│${NC}  • Config:   ${GREEN}~/.bashrc${NC}"
    echo -e "${CYAN}│${NC}  • Reload:   ${PURPLE}source ~/.bashrc${NC}"
    echo -e "${CYAN}│${NC}  • Uninstall:${YELLOW}sed -i '/$START/,/$END/d' ~/.bashrc${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
    echo ""
}

# ─── Main Execution ────────────────────────
main() {
    show_header
    check_and_install_fonts
    setup_fontconfig
    check_existing_install
    backup_bashrc
    install_config
    show_summary
}

main "$@"
