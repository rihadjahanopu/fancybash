#!/usr/bin/env fish

# ─── fancybash Fish Installer ──────────────────────────────────────────────────
# Installs config.fish into ~/.config/fish/config.fish idempotently
# ──────────────────────────────────────────────────────────────────────────────

set -l FISHCONFIG "$HOME/.config/fish/config.fish"
set -l URL "https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main/config.fish"
set -l START "# >>> fancy-fishrc >>>"
set -l END "# <<< fancy-fishrc <<<"
set -l SCRIPT_DIR (cd (dirname (status filename)) 2>/dev/null; and pwd; or echo "$PWD")
set -l LOCAL_CONFIG "$SCRIPT_DIR/config.fish"

# Colors & Formatting
set -l RED "\033[38;2;243;139;168m"
set -l GREEN "\033[38;2;166;227;161m"
set -l YELLOW "\033[38;2;249;226;175m"
set -l BLUE "\033[38;2;137;180;250m"
set -l PURPLE "\033[38;2;203;166;247m"
set -l CYAN "\033[38;2;148;226;213m"
set -l GRAY "\033[38;2;147;153;178m"
set -l BOLD "\033[1m"
set -l NC "\033[0m"

echo ""
echo -e "{$PURPLE}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗{$NC}"
echo -e "{$PURPLE}          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║{$NC}"
echo -e "{$CYAN}          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║{$NC}"
echo -e "{$CYAN}          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██║╚════██║██╔══██║╚════██║{$NC}"
echo -e "{$BLUE}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║{$NC}"
echo -e "{$BLUE}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝{$NC}"
echo ""
echo -e "   ✨ {$BOLD}{$CYAN}F A N C Y B A S H{$NC}  •  {$BOLD}Fish Config Installer{$NC}"
echo ""

# Ensure ~/.config/fish directory exists
mkdir -p "$HOME/.config/fish"
touch "$FISHCONFIG"

# Step 1: Backup existing config.fish
set -l timestamp (date +%Y%m%d_%H%M%S)
set -l backup_file "$FISHCONFIG.bak.$timestamp"
cp "$FISHCONFIG" "$backup_file"
echo -e "  {$GREEN}✔{$NC} Created backup: {$CYAN}$backup_file{$NC}"

# Step 2: Clean old fancybash block if present
if grep -q "$START" "$FISHCONFIG"
    echo -e "  {$YELLOW}⚡ Updating existing fancybash installation...{$NC}"
    sed -i.tmp "/$START/,/$END/d" "$FISHCONFIG" 2>/dev/null; or sed -i "/$START/,/$END/d" "$FISHCONFIG"
    rm -f "$FISHCONFIG.tmp"
end

# Step 3: Fetch / Obtain config content
set -l tmpfile (mktemp)
if test -f "$LOCAL_CONFIG"
    echo -e "  {$GREEN}✔{$NC} Using local config: {$CYAN}$LOCAL_CONFIG{$NC}"
    cp "$LOCAL_CONFIG" "$tmpfile"
else
    echo -e "  {$CYAN}🌐 Downloading config from GitHub...{$NC}"
    if command -v curl >/dev/null 2>&1
        curl -fsSL "$URL" -o "$tmpfile"
    else if command -v wget >/dev/null 2>&1
        wget -qO "$tmpfile" "$URL"
    else
        echo -e "  {$RED}❌ Neither curl nor wget was found. Installation failed.{$NC}"
        exit 1
    end
end

# Validate downloaded file (Guard against HTML 404 response)
if grep -q "<html" "$tmpfile" 2>/dev/null
    echo -e "  {$RED}❌ Download failed: Received HTML response.{$NC}"
    rm -f "$tmpfile"
    exit 1
end

# Step 4: Append fancybash block to config.fish
echo "" >> "$FISHCONFIG"
echo "$START" >> "$FISHCONFIG"
cat "$tmpfile" >> "$FISHCONFIG"
echo "" >> "$FISHCONFIG"
echo "$END" >> "$FISHCONFIG"
rm -f "$tmpfile"

echo -e "  {$GREEN}✔{$NC} Added fancybash block to {$CYAN}$FISHCONFIG{$NC}"
echo -e "\n  🎉 {$BOLD}Fish installation complete! Reloading configuration...{$NC}\n"

# Reload configuration in current shell session
source "$FISHCONFIG"
