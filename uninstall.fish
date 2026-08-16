#!/usr/bin/env fish

# ─── fancybash Bulletproof Fish Uninstaller (uninstall.fish) ──────────────────
# Automatically detects OS (Linux / macOS) and cleanly removes fancybash
# configuration blocks from ~/.config/fish/config.fish, ~/.bashrc, and ~/.zshrc.
# ──────────────────────────────────────────────────────────────────────────────

# ─── Colors ───────────────────────────────────────────────────────────────────
set -l RED "\033[38;2;243;139;168m"
set -l GREEN "\033[38;2;166;227;161m"
set -l YELLOW "\033[38;2;249;226;175m"
set -l BLUE "\033[38;2;137;180;250m"
set -l PURPLE "\033[38;2;203;166;247m"
set -l CYAN "\033[38;2;148;226;213m"
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
printf "   {$BOLD}{$RED}🗑️  fancybash Universal Uninstaller (Fish){$NC}\n"
printf "   {$CYAN}─────────────────────────────────────────────────────────────────{$NC}\n\n"

# ─── OS & Distro Detection ───────────────────────────────────────────────────
set -l os_type (uname -s 2>/dev/null; or echo "Unknown")
set -l distro_name ""
set -l is_macos false

switch "$os_type"
    case "Linux*"
        set os_name "Linux"
        if test -f /etc/os-release
            set distro_name (grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
        else if command -v lsb_release >/dev/null 2>&1
            set distro_name (lsb_release -d -s 2>/dev/null)
        end
        test -z "$distro_name"; and set distro_name "Generic Linux"
    case "Darwin*"
        set os_name "macOS"
        set is_macos true
        set distro_name "macOS "(sw_vers -productVersion 2>/dev/null; or echo "")
    case "*"
        set os_name "Unknown"
        set distro_name "Unknown OS"
end

printf "  {$CYAN}➜ System:{$NC}  {$BOLD}%s{$NC} (%s)\n" "$os_name" "$distro_name"
printf "{$CYAN}──────────────────────────────────────────{$NC}\n"

set -g removed_any false

# ─── Remove Block Function ───────────────────────────────────────────────────
function remove_block
    set -l target_file $argv[1]
    set -l start_marker $argv[2]
    set -l end_marker $argv[3]
    set -l shell_name $argv[4]

    if test -f "$target_file"; and grep -qF "$start_marker" "$target_file" 2>/dev/null
        printf "  {$YELLOW}⚠{$NC} Found fancybash block in {$BOLD}%s{$NC}...\n" "$target_file"
        
        set -l start_pattern (printf '%s' "$start_marker" | sed 's/[]\/\$*.^[]/\\&/g')
        set -l end_pattern (printf '%s' "$end_marker" | sed 's/[]\/\$*.^[]/\\&/g')

        if test (uname -s 2>/dev/null) = "Darwin"
            sed -i '' "/$start_pattern/,/$end_pattern/d" "$target_file" 2>/dev/null; or true
        else
            sed -i "/$start_pattern/,/$end_pattern/d" "$target_file" 2>/dev/null; or true
        end

        printf "  {$GREEN}✔{$NC} Cleanly removed fancybash from {$BOLD}%s{$NC}.\n" "$target_file"
        set -g removed_any true
    end
end

# ─── Perform Removal ──────────────────────────────────────────────────────────
remove_block "$HOME/.config/fish/config.fish" "# >>> fancy-fishrc >>>" "# <<< fancy-fishrc <<<" "Fish"
remove_block "$HOME/.bashrc" "# >>> fancy-bashrc >>>" "# <<< fancy-bashrc <<<" "Bash"
remove_block "$HOME/.zshrc" "# >>> fancy-zshrc >>>" "# <<< fancy-zshrc <<<" "Zsh"

printf "{$CYAN}──────────────────────────────────────────{$NC}\n"

if test "$removed_any" = "true"
    printf "{$GREEN}{$BOLD}✨ fancybash has been successfully uninstalled!{$NC}\n"
    printf "   To apply changes to your current session, run:\n\n"
    printf "   {$BOLD}source ~/.config/fish/config.fish{$NC}\n\n"
else
    printf "{$CYAN}ℹ No fancybash installation blocks were found in ~/.config/fish/config.fish, ~/.bashrc, or ~/.zshrc.{$NC}\n\n"
end
