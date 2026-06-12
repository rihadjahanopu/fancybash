#!/bin/bash

set -euo pipefail

ZSHRC="$HOME/.zshrc"
URL="https://gist.githubusercontent.com/rihadjahanopu/a1c286e48b3ecee1a207c759279e352c/raw/config.zsh"

START="# >>> fancy-zshrc >>>"
END="# <<< fancy-zshrc <<<"

# ─── Colors ─────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Spinner ────────────────────────────
spinner() {
    local pid=$1 msg="$2" delay=0.08
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 7); do
            printf "\r${CYAN}%s${NC} %s" "${spin:$i:1}" "$msg"
            sleep $delay
        done
    done
    printf "\r${GREEN}✔${NC} %s\n" "$msg"
}

# ─── Check Dependencies ─────────────────
check_deps() {
    local missing=()
    for cmd in curl grep; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}✘ Missing:${NC} ${missing[*]}" >&2
        exit 1
    fi
}

# ─── Header ─────────────────────────────
echo -e "\n${BOLD}${CYAN}╭────────────────────────────────────╮${NC}"
echo -e "${BOLD}${CYAN}│${NC}  🚀      Zsh Config Installer      ${BOLD}${CYAN}│${NC}"
echo -e "${BOLD}${CYAN}╰────────────────────────────────────╯${NC}\n"

check_deps

# ─── Check Already Installed ────────────
echo -e "${BLUE}🔍 Checking existing installation...${NC}"
if [ ! -f "$ZSHRC" ]; then
    echo -e "${YELLOW}⚠ Creating $ZSHRC...${NC}"
    touch "$ZSHRC"
fi

if grep -qF "$START" "$ZSHRC" 2>/dev/null; then
    echo -e "${YELLOW}✅ Already installed!${NC}"
    echo -e "${CYAN}💡 Run:${NC} ${BOLD}source $ZSHRC${NC} to reload if needed."
    exit 0
fi

# ─── Backup ─────────────────────────────
backup_file="$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${BLUE}💾 Backing up to:${NC} $(basename "$backup_file")"
cp "$ZSHRC" "$backup_file"

# ─── Download & Install ─────────────────
echo -e "${BLUE}📥 Downloading config...${NC}"

# Download in background for spinner
tmpfile=$(mktemp)
(
    if ! curl -fsSL --connect-timeout 10 "$URL" > "$tmpfile" 2>/dev/null; then
        rm -f "$tmpfile"
        exit 1
    fi
) &
spinner $! "Fetching from GitHub..."

if [ ! -s "$tmpfile" ]; then
    echo -e "${RED}✘ Download failed!${NC} Check your internet connection." >&2
    exit 1
fi

# Verify it's not HTML error page
if head -1 "$tmpfile" | grep -qi "<!doctype\|<html"; then
    echo -e "${RED}✘ Invalid response (HTML instead of script)!${NC}" >&2
    rm -f "$tmpfile"
    exit 1
fi

# ─── Append to .zshrc ──────────────────
{
    echo ""
    echo "$START"
    echo "# Installed: $(date '+%Y-%m-%d %H:%M:%S')"
    cat "$tmpfile"
    echo "$END"
} >> "$ZSHRC"

rm -f "$tmpfile"

# ─── Reload ─────────────────────────────
echo -e "${BLUE}🔄 Reloading shell...${NC}"
if source "$ZSHRC" 2>/dev/null; then
    echo -e "${GREEN}✅ Installed successfully!${NC}"
else
    echo -e "${YELLOW}⚠ Auto-reload failed.${NC} Run: ${BOLD}source $ZSHRC${NC}"
fi

# ─── Summary ────────────────────────────
echo ""
echo -e "${CYAN}┌────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}  📋 Installation Summary           ${CYAN}│${NC}"
echo -e "${CYAN}├────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  Backup:  ${GREEN}$(basename "$backup_file")${NC}       ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  Config:  ${GREEN}~/.zshrc${NC}                ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  Remove:  ${YELLOW}sed -i '/$START/,/$END/d' ~/.zshrc${NC}  ${CYAN}│${NC}"
echo -e "${CYAN}└────────────────────────────────────┘${NC}"
echo ""
