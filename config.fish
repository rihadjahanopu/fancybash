# ==============================================================================
#   ULTRA-THIN COMPACT PRO FISH SHELL ENVIRONMENT
#   Author: Rihad Jahan Opu
#   Version: 2.0.0 Complete Multi-Distro Edition (Fish Shell)
#   Purpose: A fast, beautiful, and productive terminal for Web Development
#   Supports: Ubuntu/Debian, Fedora/RHEL/CentOS, Arch, macOS, Alpine, openSUSE
#   Verified: 2026 - Cross-platform compatibility
# ==============================================================================

# Disable default Fish greeting
set -g fish_greeting ""

# ======================================================
# 🎨 RAINBOW COLOR & EMOJI SETUP
# ======================================================

set -g rainbow_colors 31 32 33 34 35 36 91 92 93 94 95 96

function rand_color
    set -l idx (random 1 (count $rainbow_colors))
    echo $rainbow_colors[$idx]
end

function rand_emoji
    set -l folder (basename (pwd))
    switch $folder
        case "*web*"
            echo "🌐"
        case "*node*"
            echo "🟢"
        case "*bun*"
            echo "🥐"
        case "*py*"
            echo "🐍"
        case "*proj*"
            echo "💻"
        case "*"
            set -l emojis 🔥 ⚡️ 🚀 💫 🌈 🌀 ✨ 🧠
            set -l idx (random 1 (count $emojis))
            echo $emojis[$idx]
    end
end

# ======================================================
# HELPERS
# ======================================================

function _fb_ensure_dep
    set -l cmd $argv[1]
    set -l apt_pkg $argv[2]
    test -z "$apt_pkg"; and set apt_pkg $cmd
    set -l pac_pkg $argv[3]
    test -z "$pac_pkg"; and set pac_pkg $cmd
    set -l dnf_pkg $argv[4]
    test -z "$dnf_pkg"; and set dnf_pkg $cmd

    if command -v $cmd >/dev/null 2>&1
        return 0
    end

    if test "$cmd" = "fd"; and command -v fdfind >/dev/null 2>&1
        return 0
    end
    if test "$cmd" = "bat"; and command -v batcat >/dev/null 2>&1
        return 0
    end
    if test "$cmd" = "exa"; and command -v eza >/dev/null 2>&1
        return 0
    end

    echo -e "\033[1;33m⚡ Missing tool '$cmd'. Auto-installing for your Linux distro...\033[0m"

    if command -v apt-get >/dev/null 2>&1
        sudo apt-get update -qq; and sudo apt-get install -y $apt_pkg
    else if command -v pacman >/dev/null 2>&1
        sudo pacman -S --noconfirm --needed $pac_pkg
    else if command -v dnf >/dev/null 2>&1
        sudo dnf install -y $dnf_pkg
    else if command -v zypper >/dev/null 2>&1
        sudo zypper install -y $pac_pkg
    else if command -v apk >/dev/null 2>&1
        sudo apk add $pac_pkg
    else if command -v brew >/dev/null 2>&1
        brew install $pac_pkg
    else
        echo -e "\033[1;31m❌ Package manager not found. Please install '$cmd' manually.\033[0m"
        return 1
    end
end

function parse_git_branch
    set -l branch (git branch --show-current 2>/dev/null)
    if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
        test -n "$branch"; and set branch "➦ $branch"
    end
    test -z "$branch"; and return
    set -l dirty ""
    test -n "(git status --porcelain --untracked-files=no 2>/dev/null)"; and set dirty " ❗"
    echo "$branch$dirty"
end

function node_version
    command -v node >/dev/null 2>&1; and echo "🟢 "(node -v)
end

function npm_version
    command -v npm >/dev/null 2>&1; and echo "📦 "(npm -v)
end

function bun_version
    command -v bun >/dev/null 2>&1; and echo "🥐 "(bun -v)
end

function time_date
    echo "📅 "(date +'%b %d')
end

function sys_info
    if test -f /proc/meminfo
        set -l mem_total (awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
        set -l mem_avail (awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null)
        if test -n "$mem_total" -a -n "$mem_avail"
            set -l mem_used (math "($mem_total - $mem_avail) / 1024")
            set -l mem_total_mb (math "$mem_total / 1024")
            echo "🧠 {$mem_used}M/{$mem_total_mb}M"
            return
        end
    end
    if command -v free >/dev/null 2>&1
        set -l RAM (free -h 2>/dev/null | awk '/^Mem/ {print $3 "/" $2}')
        test -n "$RAM"; and echo "🧠 $RAM"
    end
end

function battery_info
    test -f /sys/class/power_supply/BAT0/capacity; and echo "🔋"(cat /sys/class/power_supply/BAT0/capacity)"%"
end

function kernel_version
    echo "🐧 "(uname -r | cut -d'-' -f1)
end

function cpu_temp
    set -l temp ""
    if test -f /sys/class/thermal/thermal_zone0/temp
        set -l raw (cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        test -n "$raw" -a "$raw" -gt 0; and set temp (math "$raw / 1000")
    end
    if test -z "$temp"; and command -v sensors >/dev/null 2>&1
        set temp (sensors 2>/dev/null | grep -iE 'Package id 0|Core 0|temp1' | head -n1 | grep -oP '\+\K[0-9.]+' | head -n1 | cut -d. -f1)
    end
    if test -n "$temp"
        if test "$temp" -gt 70
            echo -e " \e[91m🌡️ {$temp}°C\e[0m"
        else if test "$temp" -gt 55
            echo -e " \e[93m🌡️ {$temp}°C\e[0m"
        else
            echo -e " \e[92m🌡️ {$temp}°C\e[0m"
        end
    end
end

function folder_size
    test -d . ; and echo "📁 "(du -sh . 2>/dev/null | cut -f1)
end

# ======================================================
# 🚀 SMART FISH PROMPT SYSTEM
# ======================================================

function fish_prompt
    set -l last_status $status
    set -l color_code (rand_color)
    set -l emoji_symbol (rand_emoji)
    set -l dir_name (basename (pwd))
    test "$dir_name" = "$USER"; and set dir_name "~"
    test -z "$dir_name"; and set dir_name "/"

    # Line 1: Directory + Git + Status Indicator
    set -l prompt_color "\033[1;{$color_code}m"
    set -l reset "\033[0m"

    echo -n -e "{$emoji_symbol} {$prompt_color}{$dir_name}{$reset}"

    set -l git_b (parse_git_branch)
    if test -n "$git_b"
        echo -n -e " \033[1;33m($git_b)$reset"
    end

    echo ""

    # Line 2: Prompt Arrow
    if test $last_status -eq 0
        echo -n -e "\033[1;36m❯❯❯ \033[0m"
    else
        echo -n -e "\033[1;31m❯❯❯ \033[0m"
    end
end

# ======================================================
# 📁 CORE NAVIGATION & SYSTEM ALIASES
# ======================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias cd..='cd ..'

if command -v eza >/dev/null 2>&1
    alias ls='eza --icons'
    alias ll='eza -la --icons'
    alias la='eza -a --icons'
    alias l='eza -1 --icons'
else if command -v exa >/dev/null 2>&1
    alias ls='exa --icons'
    alias ll='exa -la --icons'
    alias la='exa -a --icons'
    alias l='exa -1 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
end

alias cls='clear'
alias c='clear'
alias h='history'
alias path='echo $PATH | tr " " "\n"'

# File operations
alias md='mkdir -p'
alias rd='rmdir'
alias rmrf='rm -rf'
alias cpv='cp -iv'
alias mvv='mv -iv'

function cx
    chmod +x $argv
end

# ======================================================
# 📦 PACKAGE MANAGERS (NPM / YARN / PNPM / BUN)
# ======================================================

alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nrd='npm run dev'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'

alias bi='bun install'
alias brid='bun add -d'
alias brd='bun run dev'
alias bs='bun start'
alias bt='bun test'

# ======================================================
# 🐙 GIT WORKFLOW SHORTCUTS
# ======================================================

alias gs='git status -s'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gcm='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate -n 15'
alias glog='git log --oneline --graph --decorate -n 15'
alias gps='git push'
alias gpl='git pull'
alias gd='git diff'

function gwip
    git add -A
    git rm (git ls-files --deleted) 2>/dev/null
    git commit -m "wip [skip ci]" --no-verify
end

function gunwip
    git log -n 1 | grep -q -c "wip \[skip ci\]"
    if test $status -eq 0
        git reset HEAD~1
    else
        echo "❌ Last commit is not a WIP commit."
    end
end

# ======================================================
# 🐳 DOCKER & CONTAINER ALIASES
# ======================================================

alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dsh='docker exec -it'
alias dcup='docker compose up -d'
alias dcdn='docker compose down'
alias dclog='docker compose logs -f'

function dclean
    docker system prune -af --volumes
end

function droot
    set -l container $argv[1]
    docker exec -it -u root $container bash; or docker exec -it -u root $container sh; or docker exec -it -u root $container powershell
end

# ======================================================
# 🛠️ INTERACTIVE HELPER FUNCTIONS
# ======================================================

function rel
    source ~/.config/fish/config.fish
    echo -e "\033[1;32m✅ Fish configuration reloaded successfully!\033[0m"
end

function keep
    echo -e "\n\033[1;36m⚡ F A N C Y B A S H  •  Fish Quick Command Reference\033[0m\n"
    echo -e "  \033[1;33mNavigation:\033[0m    ..   ...   ....   ~   cls"
    echo -e "  \033[1;33mGit:\033[0m           gs   ga   gaa   gcm \"msg\"   gps   gpl   gwip   gunwip"
    echo -e "  \033[1;33mNPM/Bun:\033[0m       ni   nid   nrd   nb   bi   brd"
    echo -e "  \033[1;33mDocker:\033[0m        dps   dpsa   dsh   dcup   dcdn   dclean"
    echo -e "  \033[1;33mUtilities:\033[0m     rel   init   vite   next   ex <archive>   sys   uup\n"
end

function sys
    echo -e "\n\033[1;36m🖥️  SYSTEM INFORMATION TELEMETRY\033[0m"
    echo -e "   OS:           "(uname -s)" ("(uname -m)")"
    echo -e "   Kernel:       "(uname -r)
    echo -e "   Shell:        Fish "(fish --version | cut -d' ' -f3)
    echo -e "   Uptime:       "(uptime -p 2>/dev/null; or uptime)
    sys_info
    battery_info
    cpu_temp
    echo ""
end

function myip
    echo -n "Public IP: "
    curl -s https://api.ipify.org; or curl -s https://ifconfig.me
    echo ""
end

function ex
    if test -f $argv[1]
        switch $argv[1]
            case "*.tar.bz2"
                tar xjf $argv[1]
            case "*.tar.gz"
                tar xzf $argv[1]
            case "*.bz2"
                bunzip2 $argv[1]
            case "*.rar"
                unrar x $argv[1]
            case "*.gz"
                gunzip $argv[1]
            case "*.tar"
                tar xf $argv[1]
            case "*.tbz2"
                tar xjf $argv[1]
            case "*.tgz"
                tar xzf $argv[1]
            case "*.zip"
                unzip $argv[1]
            case "*.Z"
                uncompress $argv[1]
            case "*.7z"
                7z x $argv[1]
            case "*"
                echo "❌ '$argv[1]' cannot be extracted via ex()"
        end
    else
        echo "❌ '$argv[1]' is not a valid file"
    end
end

function init
    echo -e "\033[1;36m🚀 Project Initializer Menu\033[0m"
    echo "1) Node.js (npm init -y)"
    echo "2) Bun (bun init)"
    echo "3) Vite App (npm create vite@latest)"
    echo "4) Next.js App (npx create-next-app@latest)"
    read -P "Choose template [1-4]: " choice
    switch $choice
        case 1
            npm init -y
        case 2
            bun init
        case 3
            npm create vite@latest
        case 4
            npx create-next-app@latest
        case "*"
            echo "Cancelled."
    end
end

function vite
    npm create vite@latest
end

function next
    npx create-next-app@latest
end

function uup
    set -l OS_TYPE (uname -s)
    if test "$OS_TYPE" = "Linux"
        if command -v apt >/dev/null 2>&1
            echo -e "\033[1;36m🧽 Running apt update & upgrade...\033[0m"
            sudo apt update; and sudo apt upgrade -y; and sudo apt autoremove -y
        else if command -v pacman >/dev/null 2>&1
            echo -e "\033[1;36m🧽 Running pacman system update...\033[0m"
            sudo pacman -Syu --noconfirm
        else if command -v dnf >/dev/null 2>&1
            echo -e "\033[1;36m🧽 Running dnf system update...\033[0m"
            sudo dnf upgrade -y
        end
    else if test "$OS_TYPE" = "Darwin"; and command -v brew >/dev/null 2>&1
        echo -e "\033[1;36m🧽 Running Homebrew update & cleanup...\033[0m"
        brew update; and brew upgrade; and brew cleanup
    end
end

function uu
    uup
end

# ======================================================
# 🏁 FOOTER & INITIALIZATION
# ======================================================

# Welcome tip on shell start
echo -e "\033[1;36m⚡ fancybash loaded! Type \033[1;33mkeep\033[1;36m for quick shortcuts.\033[0m"
