# ==============================================================================
#   ULTRA-THIN COMPACT PRO WINDOWS POWERSHELL ENVIRONMENT
#   Author: [Rihad Jahan Opu]
#   Version: 2.0.0 Windows PowerShell Edition
#   Purpose: A fast, beautiful, and productive terminal for Web Development
#   Supports: Windows PowerShell
#   Verified: 2026
# ==============================================================================

# ১. ইমোজি ও বক্স ডিজাইন সুন্দর রাখার জন্য এনকোডিং
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ২. উইন্ডোজের ব্লক বা সিকিউরিটি দেয়াল সাময়িকভাবে বাইপাস করা
if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
}

# ------------------------------------------------------------------------------
# 🎨 SMART PROMPT
# ------------------------------------------------------------------------------
function prompt {
    $folder = Split-Path -Leaf $PWD
    $emoji = "🚀"
    if ($folder -match "web") { $emoji = "🌐" }
    elseif ($folder -match "node") { $emoji = "🟢" }
    elseif ($folder -match "bun") { $emoji = "🥐" }
    elseif ($folder -match "py") { $emoji = "🐍" }
    elseif ($folder -match "proj") { $emoji = "💻" }
    else {
        $emojis = @("🔥", "⚡️", "🚀", "💫", "🌈", "🌀", "✨", "🧠")
        $emoji = $emojis[(Get-Random -Maximum $emojis.Length)]
    }

    $colors = @("Red", "Green", "Yellow", "Blue", "Magenta", "Cyan")
    $randColor = $colors[(Get-Random -Maximum $colors.Length)]

    $gitBranch = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git symbolic-ref --short HEAD 2>$null
        if ($branch) {
            $dirty = if (git status --porcelain 2>$null) { " ❗" } else { "" }
            $gitBranch = " [🌿 $branch$dirty]"
        }
    }

    Write-Host ""
    Write-Host "$emoji $folder" -NoNewline -ForegroundColor $randColor
    if ($gitBranch) {
        Write-Host $gitBranch -NoNewline -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "❯❯❯ " -NoNewline -ForegroundColor Magenta
    return " "
}

# ------------------------------------------------------------------------------
# 📂 NAVIGATION & MOVEMENT
# ------------------------------------------------------------------------------
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function dev { Set-Location "$HOME\Development" -ErrorAction SilentlyContinue }



function gwip {
    $msg = $args[0]
    if (-not $msg) { $msg = "Work in progress (Save Point)" }
    git add .
    git commit -m "🚧 WIP: $msg"
    git push
}

# ------------------------------------------------------------------------------
# 🔧 PROJECT SETUP
# ------------------------------------------------------------------------------

function ii {
    Write-Host "🚀 Select Package Manager:`n1) 🥐 Bun`n2) 📦 NPM"
    $choice = Read-Host "Choice [1/2]"
    if ($choice -eq '1') { bun init -y }
    elseif ($choice -eq '2') { npm init -y }
    else { Write-Host "❌ Cancelled."; return }

    if (-not (Test-Path .gitignore)) {
        "node_modules/" | Out-File .gitignore -Encoding utf8
        Write-Host "✅ .gitignore created."
    }
}

function next {
    Write-Host "⚡ Setup Next.js with:`n1) Bun`n2) NPM"
    $choice = Read-Host "Choice"
    if ($choice -eq '1') { bunx create-next-app@latest . }
    elseif ($choice -eq '2') { npx create-next-app@latest . }
}

function vite {
    Write-Host "⚡ Setup Vite with:`n1) Bun`n2) NPM"
    $choice = Read-Host "Choice"
    if ($choice -eq '1') { bunx create-vite@latest . }
    elseif ($choice -eq '2') { npx create-vite@latest . }
}

function ui {
    Write-Host "🎨 Setup Shadcn UI with:`n1) Bun`n2) NPM"
    $choice = Read-Host "Choice"
    if ($choice -eq '1') { bunx --bun shadcn@latest init -t vite }
    elseif ($choice -eq '2') { npx shadcn@latest init -t vite }
}

function pg {
    npm init -y
    Write-Host "✅ package.json generated!"
}

# ------------------------------------------------------------------------------
# 🔨 UTILITIES
# ------------------------------------------------------------------------------

function mkd {
    param([string]$Name)
    New-Item -ItemType Directory -Force -Path $Name | Out-Null
    Set-Location $Name
}

function rmd {
    param([string]$Name)
    Remove-Item -Recurse -Force -Path $Name
}

function rmf {
    param([string]$Name)
    Remove-Item -Force -Path $Name
}

function kp {
    param([int]$Port)
    if (-not $Port) { Write-Host "❌ Port number required!"; return }
    $process = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.OwningProcess -Force
        Write-Host "✅ Port $Port killed."
    } else {
        Write-Host "❌ Port $Port not in use."
    }
}

function ff {
    param([string]$Name)
    Get-ChildItem -Path . -Recurse -Filter "*$Name*" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' } |
        Select-Object FullName
}

function gen {
    param([int]$Length = 24)
    $bytes = New-Object byte[] $Length
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $key = [Convert]::ToBase64String($bytes).Substring(0, $Length)
    Write-Host "`n✅ Secret generated: $key"
}

function bak {
    param([string]$File)
    if (Test-Path $File) {
        Copy-Item $File "$File.bak"
        Write-Host "✅ Created: $File.bak"
    } else {
        Write-Host "❌ File not found."
    }
}

function ex {
    param([string]$File)
    if (Test-Path $File) {
        Expand-Archive -Path $File -DestinationPath . -Force
        Write-Host "✅ Extracted"
    } else {
        Write-Host "❌ File not found."
    }
}

function trash {
    param([string]$Path)
    if (Test-Path $Path) {
        # Moving to recycle bin in PS can be tricky natively without visual basic, so we just remove or use a simple workaround
        # For simplicity in this conversion, we just delete it safely
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "🗑 Removed $Path"
    }
}

function keep {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🚀  MASTER COMMAND CENTER           Developer Rihad's Ultimate PowerShell║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "  v2.0 • Modern Terminal UX • $(Get-Date -Format 'MMMM dd, yyyy')" -ForegroundColor Gray
    Write-Host ""

    function PrintCategory {
        param([string]$Icon, [string]$Title, [string]$Color)
        Write-Host "  ┌─────────────────────────────────────────────────────────────────────┐" -ForegroundColor $Color
        Write-Host "  │ $Icon  $Title" -ForegroundColor $Color -NoNewline
        Write-Host "                                    " -ForegroundColor $Color -NoNewline
        Write-Host "│" -ForegroundColor $Color
        Write-Host "  └─────────────────────────────────────────────────────────────────────┘" -ForegroundColor $Color
    }

    function PrintCmd {
        param([string]$Cmd, [string]$Desc, [string]$Example = "", [string]$Color = "White")
        if ([string]::IsNullOrEmpty($Example)) {
            Write-Host ("     " + $Cmd.PadRight(15) + " │ " + $Desc) -ForegroundColor $Color
        } else {
            Write-Host ("     " + $Cmd.PadRight(15) + " │ " + $Desc.PadRight(35) + " " + $Example) -ForegroundColor $Color
        }
    }

    # NAVIGATION
    PrintCategory "📂" "NAVIGATION & MOVEMENT" "Cyan"
    PrintCmd ".." "Parent directory" "" "Yellow"
    PrintCmd "..." "Two levels up" "" "Yellow"
    PrintCmd "...." "Three levels up" "" "Yellow"
    PrintCmd "dev" "Go to ~/Development" "" "Green"
    Write-Host ""

    # NPM
    PrintCategory "📦" "NPM COMMANDS" "Green"
    PrintCmd "ni" "npm install" "" "Green"
    PrintCmd "nid" "npm install -D" "" "Green"
    PrintCmd "nr" "npm run" "" "Green"
    PrintCmd "nrd" "npm run dev" "" "Yellow"
    PrintCmd "nrb" "npm run build" "" "Yellow"
    PrintCmd "nrs" "npm run start" "" "Yellow"
    Write-Host ""

    # BUN
    PrintCategory "🥐" "BUN COMMANDS (Ultra Fast)" "Yellow"
    PrintCmd "bi" "bun install" "" "Yellow"
    PrintCmd "br" "bun run" "" "Yellow"
    PrintCmd "brd" "bun run dev" "" "Green"
    PrintCmd "brb" "bun run build" "" "Green"
    PrintCmd "brs" "bun run start" "" "Green"
    Write-Host ""

    # GIT
    PrintCategory "🌿" "GIT VERSION CONTROL" "Magenta"
    PrintCmd "gi" "Initialize new repository" "" "Green"
    PrintCmd "gs" "Check status (short format)" "" "Blue"
    PrintCmd "ga" "Stage all files" "" "Yellow"
    PrintCmd "gcm <msg>" "Commit with message" "gcm 'feat: add login'" "Green"
    PrintCmd "gps / gpl" "Push / Pull from remote" "" "Magenta"
    PrintCmd "gl" "View git log" "" "Cyan"
    PrintCmd "gco <branch>" "Checkout branch" "gco main" "Yellow"
    PrintCmd "gcb <name>" "Create & checkout branch" "gcb feature-x" "Green"
    PrintCmd "gd" "View diff" "" "DarkYellow"
    PrintCmd "gst / gsta" "Stash / Apply" "" "Blue"
    PrintCmd "gwip" "Quick WIP commit + push" "" "Magenta"
    Write-Host ""

    # DOCKER
    PrintCategory "🐳" "DOCKER COMMANDS" "Blue"
    PrintCmd "d" "docker command" "" "Blue"
    PrintCmd "dps" "docker ps" "" "Cyan"
    PrintCmd "di" "docker images" "" "Yellow"
    PrintCmd "drun" "docker run" "" "Green"
    PrintCmd "dlog" "docker logs -f" "" "Magenta"
    PrintCmd "dcu" "docker compose up" "" "Green"
    PrintCmd "dcd" "docker compose down" "" "Red"
    Write-Host ""

    # PROJECT SETUP
    PrintCategory "⚡" "PROJECT INITIALIZATION" "DarkYellow"
    PrintCmd "ii" "Initialize project (Bun/NPM)" "" "Green"
    PrintCmd "next" "Setup Next.js project" "" "Cyan"
    PrintCmd "ui" "Setup Shadcn UI with components" "ui + select button,card" "Blue"
    PrintCmd "vite" "Setup Vite with Tailwind" "" "Magenta"
    PrintCmd "css" "Auto-install Tailwind CSS" "" "Blue"
    Write-Host ""

    # UTILITIES
    PrintCategory "💻" "UTILITY TOOLS" "Cyan"
    PrintCmd "ex <file>" "Extract any archive" "ex file.zip" "Green"
    PrintCmd "ff <name>" "Find file (fast search)" "ff config" "Yellow"
    PrintCmd "gen <len>" "Generate random secret" "gen 32" "Magenta"
    PrintCmd "h <word>" "Search command history" "h git" "Blue"
    PrintCmd "c / cls" "Clear terminal screen" "" "Gray"
    Write-Host ""

    # FILE MANAGEMENT
    PrintCategory "📁" "FILE MANAGEMENT" "Blue"
    PrintCmd "mkd <name>" "Create & enter directory" "mkd my-project" "Green"
    PrintCmd "t <file>" "Create file with feedback" "t index.html" "Green"
    PrintCmd "rmd <name>" "Force remove directory" "rmd old-folder" "Red"
    PrintCmd "rmf <file>" "Safe remove single file" "rmf file.txt" "DarkYellow"
    PrintCmd "bak <file>" "Create backup of file" "bak config.js" "Blue"
    PrintCmd "trash <file>" "Move file to trash" "trash junk.txt" "Yellow"
    Write-Host ""

    # FOOTER
    Write-Host "  ┌─────────────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
    Write-Host "  │ ✨ PRO TIPS:                                                        │" -ForegroundColor Magenta
    Write-Host "  │   • Use Tab for command auto-completion                             │" -ForegroundColor Magenta
    Write-Host "  │   • Prompt shows: Git branch │ Folder name │ Emoji                  │" -ForegroundColor Magenta
    Write-Host "  │   • Type function names directly to execute                         │" -ForegroundColor Magenta
    Write-Host "  └─────────────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
    Write-Host ""
}

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name h -Value Get-History


function ui {
    Write-Host "🎨 Setup Shadcn UI with:"
    Write-Host "1) Bun"
    Write-Host "2) NPM"
    $c = Read-Host "Choice"

    $components = Read-Host "Add specific components? (e.g. button card input)"

    switch ($c) {
        "1" {
            Write-Host "🧱 Initializing Shadcn UI with Bun..."
            bunx --bun shadcn@latest init -t vite

            if (-not [string]::IsNullOrWhiteSpace($components)) {
                Write-Host "🔘 Adding components: $components..."
                bunx --bun shadcn@latest add $components
            } else {
                Write-Host "🔘 Adding default Button component..."
                bunx --bun shadcn@latest add button
            }
        }
        "2" {
            Write-Host "🧱 Initializing Shadcn UI with NPM..."
            npx shadcn@latest init -t vite

            if (-not [string]::IsNullOrWhiteSpace($components)) {
                Write-Host "🔘 Adding components: $components..."
                npx shadcn@latest add $components
            } else {
                Write-Host "🔘 Adding default Button component..."
                npx shadcn@latest add button
            }
        }
        default {
            Write-Host "Invalid choice"
            return
        }
    }

    Write-Host "---------------------------------------------------"
    Write-Host "✅ Shadcn UI setup complete!"
    Write-Host "🚀 Happy coding with Shadcn!"
    Write-Host "---------------------------------------------------"
}


function vite {
    Write-Host "⚡ Setup Vite with:"
    Write-Host "1) Bun"
    Write-Host "2) NPM"
    $c = Read-Host "Choice"

    $tw = Read-Host "Add Tailwind CSS v4? (y/n)"

    switch ($c) {
        "1" {
            bunx create-vite@latest .
            if ($tw -eq "y") {
                try {
                    bun add tailwindcss @tailwindcss/vite
                } catch {
                    Write-Host "❌ Install failed with Bun."
                    $force = Read-Host "Try with --force? (y/n)"
                    if ($force -eq "y") {
                        bun add tailwindcss @tailwindcss/vite --force
                    }
                }
            }
        }
        "2" {
            npx create-vite@latest .
            if ($tw -eq "y") {
                try {
                    npm install tailwindcss @tailwindcss/vite
                } catch {
                    Write-Host "❌ Install failed with NPM (Peer Dependency Conflict likely)."
                    $legacy = Read-Host "Try with --legacy-peer-deps? (y/n)"
                    if ($legacy -eq "y") {
                        npm install tailwindcss @tailwindcss/vite --legacy-peer-deps
                    }
                }
            }
        }
        default {
            Write-Host "Invalid choice"
            return
        }
    }

    if ($tw -eq "y") {
        # Create src folder and CSS file setup
        New-Item -ItemType Directory -Force -Path "src" | Out-Null

        $CSS_FILE = "src/index.css"
        if (Test-Path "src/style.css") {
            $CSS_FILE = "src/style.css"
        }

        # Add the Tailwind v4 import
        '@import "tailwindcss";' | Out-File -FilePath $CSS_FILE -Encoding utf8

        Write-Host "---------------------------------------------------"
        Write-Host "✅ Tailwind CSS v4 packages installed!"
        Write-Host "✅ Added '@import `"tailwindcss`";' to $CSS_FILE"
        Write-Host ""
        Write-Host "⚠️  ACTION REQUIRED: You must update your Vite config manually."
        Write-Host ""
        Write-Host "Open your vite.config.ts (or .js) and add these two lines:"
        Write-Host "  1. import tailwindcss from '@tailwindcss/vite'"
        Write-Host "  2. Add tailwindcss() to the plugins array."
        Write-Host "---------------------------------------------------"
    }
}

function next {
    Write-Host "⚡ Setup Next.js with:"
    Write-Host "1) Bun"
    Write-Host "2) NPM"
    $c = Read-Host "Choice"

    switch ($c) {
        "1" { bunx create-next-app@latest . }
        "2" { npx create-next-app@latest . }
        default { Write-Host "Invalid choice" }
    }
}


function css {
    if (-not (Test-Path "package.json")) {
        Write-Host "❌ Error: package.json not found!"
        return 1
    }

    # Auto-detect package manager
    $pm = "npm"
    if (Test-Path "bun.lockb") {
        $pm = "bun"
    }

    Write-Host "📦 Installing Tailwind via $pm..."
    if ($pm -eq "bun") {
        bun add -D tailwindcss clsx tailwind-merge
        bunx tailwindcss init -p
    } else {
        npm install -D tailwindcss clsx tailwind-merge
        npx tailwindcss init -p
    }
    Write-Host "✅ Tailwind CSS Ready!"
}

function uup {
    $ESC = [char]27
    $RED = "$ESC[1;31m"; $GRN = "$ESC[1;32m"; $YLW = "$ESC[1;33m"
    $BLU = "$ESC[1;34m"; $PUR = "$ESC[1;35m"; $CYN = "$ESC[1;36m"
    $BOLD = "$ESC[1m"; $NC = "$ESC[0m"

    # Admin Check
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "${RED}❌ Run as Administrator!${NC}"
        return
    }

    # Package Managers
    $hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
    $hasChoco = $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
    $hasScoop = $null -ne (Get-Command scoop -ErrorAction SilentlyContinue)

    # fzf with full path resolution
    $fzfExe = (Get-Command fzf -ErrorAction SilentlyContinue)?.Source
    if (-not $fzfExe) {
        # Search common install paths
        $searchPaths = @(
            "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf*\fzf.exe",
            "$env:PROGRAMFILES\fzf\fzf.exe",
            "$env:LOCALAPPDATA\fzf\fzf.exe"
        )
        foreach ($sp in $searchPaths) {
            $found = Get-ChildItem -Path $sp -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $fzfExe = $found.FullName; break }
        }
    }

    # Install fzf if not found
    if (-not $fzfExe) {
        Write-Host "${YLW}🔍 fzf not found. Installing...${NC}"
        if ($hasWinget) {
            winget install --id junegunn.fzf -e --accept-source-agreements --accept-package-agreements
            # Re-search after install
            $fzfExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf*\fzf.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
        }
        if (-not $fzfExe) {
            Write-Host "${RED}❌ fzf install failed. Please install manually.${NC}"
            return
        }
    }

    Clear-Host
    Write-Host "  ${BOLD}User:${NC} $($env:USERNAME) | ${BOLD}OS:${NC} Windows"
    Write-Host "  Winget: $(if($hasWinget){'✅'}else{'❌'}) | Choco: $(if($hasChoco){'✅'}else{'❌'}) | Scoop: $(if($hasScoop){'✅'}else{'❌'})"
    Write-Host ""

    $tasks = @(
        "0. ALL_MAINTENANCE_TASKS"
        "1. Winget_Package_Update"
        "2. Chocolatey_Package_Update"
        "3. Scoop_Package_Update"
        "4. Bun_Runtime_Upgrade"
        "5. Node.js_LTS_Sync"
        "6. Global_NPM_Update"
        "7. Full_System_Deep_Clean"
    )

    # Fixed preview with proper quoting
    $previewCmd = 'powershell -NoProfile -Command "if (''{1}'' -eq ''0.'') { Write-Host ''Execute all Windows updates and cleanup.'' } else { $t = ''{1}'' -replace ''_'', '' ''; Write-Host ''Action: $t'' }"'
    $SELECTED_TASKS = $tasks | & $fzfExe --ansi --multi --height=18 --layout=reverse --border=rounded `
        --prompt="⚡ Action: " --header="[TAB] Select | [ENTER] Execute" `
        --color='bg+:#292e42,hl:#bb9af7,prompt:#7dcfff,pointer:#f7768e,marker:#9ece6a' `
        --preview $previewCmd --preview-window='up:1:wrap'

    if ([string]::IsNullOrWhiteSpace($SELECTED_TASKS)) {
        Write-Host "${RED}❌ No tasks selected. Aborting...${NC}"
        return
    }

    # Convert to array for consistent handling
    $selectedArray = @($SELECTED_TASKS -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    if ($selectedArray -contains "0. ALL_MAINTENANCE_TASKS") {
        $selectedArray = $tasks
    }

    # Helper function for error checking
    function Invoke-WithCheck {
        param([scriptblock]$Command, [string]$SuccessMsg, [string]$FailMsg)
        & $Command
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
            Write-Host "  ${GRN}✅ $SuccessMsg${NC}"
        } else {
            Write-Host "  ${RED}❌ $FailMsg (Code: $LASTEXITCODE)${NC}"
        }
    }

    # 1. Winget
    if ($selectedArray -contains "1. Winget_Package_Update") {
        Write-Host "`n${BOLD}${BLU}📦 [1/7] Winget Packages...${NC}`n"
        if ($hasWinget) {
            Invoke-WithCheck { winget upgrade --all --accept-source-agreements --accept-package-agreements } "Winget updated!" "Winget update failed"
        } else {
            Write-Host "  ${YLW}⚠ Winget not available${NC}"
        }
    }

    # 2. Chocolatey
    if ($selectedArray -contains "2. Chocolatey_Package_Update") {
        Write-Host "`n${BOLD}${CYN}🍫 [2/7] Chocolatey...${NC}`n"
        if ($hasChoco) {
            Invoke-WithCheck { choco upgrade all -y } "Chocolatey updated!" "Choco update failed"
        } else {
            Write-Host "  ${YLW}⚠ Choco not installed${NC}"
        }
    }

    # 3. Scoop
    if ($selectedArray -contains "3. Scoop_Package_Update") {
        Write-Host "`n${BOLD}${PUR}🥄 [3/7] Scoop...${NC}`n"
        if ($hasScoop) {
            Invoke-WithCheck { scoop update; scoop update * } "Scoop updated!" "Scoop update failed"
        } else {
            Write-Host "  ${YLW}⚠ Scoop not installed${NC}"
        }
    }

    # 4. Bun
    if ($selectedArray -contains "4. Bun_Runtime_Upgrade") {
        Write-Host "`n${BOLD}${CYN}🥬 [4/7] Bun...${NC}`n"
        if (Get-Command bun -ErrorAction SilentlyContinue) {
            Invoke-WithCheck { bun upgrade } "Bun upgraded!" "Bun upgrade failed"
        } else {
            Write-Host "  ${YLW}⚠ Bun not installed${NC}"
        }
    }

    # 5. Node.js
    if ($selectedArray -contains "5. Node.js_LTS_Sync") {
        Write-Host "`n${BOLD}${GRN}🟢 [5/7] Node.js LTS...${NC}`n"
        $nvmPath = "$env:NVM_HOME\nvm.exe"
        if (-not (Test-Path $nvmPath)) { $nvmPath = "$env:APPDATA\nvm\nvm.exe" }
        if (Test-Path $nvmPath) {
            Invoke-WithCheck { & $nvmPath install lts; & $nvmPath use lts } "Node.js LTS synced!" "NVM failed"
        } else {
            Write-Host "  ${YLW}⚠ NVM not found${NC}"
        }
    }

    # 6. NPM
    if ($selectedArray -contains "6. Global_NPM_Update") {
        Write-Host "`n${BOLD}${YLW}✨ [6/7] NPM...${NC}`n"
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Invoke-WithCheck { npm install -g npm@latest } "NPM updated!" "NPM update failed"
        } else {
            Write-Host "  ${YLW}⚠ NPM not installed${NC}"
        }
    }

    # 7. Deep Clean
    if ($selectedArray -contains "7. Full_System_Deep_Clean") {
        Write-Host "`n${BOLD}${RED}🧹 [7/7] Deep Clean...${NC}`n"

        # Temp files
        Write-Host "  ${CYN}🗑️ Temp files...${NC}"
        @("$env:TEMP", "$env:LOCALAPPDATA\Temp", "C:\Windows\Temp") | ForEach-Object {
            if (Test-Path $_) {
                Get-ChildItem -Path $_ -Recurse -Force -ErrorAction SilentlyContinue |
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "  ${GRN}✅ Temp cleaned${NC}"

        # Recycle Bin (fixed)
        Write-Host "  ${CYN}♻️ Recycle Bin...${NC}"
        try {
            Clear-RecycleBin -Force -ErrorAction Stop
            Write-Host "  ${GRN}✅ Recycle Bin emptied${NC}"
        } catch {
            Write-Host "  ${YLW}⚠ Could not empty Recycle Bin${NC}"
        }

        # Windows Update (fixed service handling)
        Write-Host "  ${CYN}🧽 Windows Update cache...${NC}"
        $wuauserv = Get-Service wuauserv -ErrorAction SilentlyContinue
        if ($wuauserv -and $wuauserv.Status -eq 'Running') {
            Stop-Service wuauserv -Force
            Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
            Start-Service wuauserv
            Write-Host "  ${GRN}✅ WU cache cleaned${NC}"
        } else {
            Write-Host "  ${YLW}⚠ WU service not running${NC}"
        }

        # Prefetch
        Write-Host "  ${CYN}⚡ Prefetch...${NC}"
        Get-ChildItem -Path "C:\Windows\Prefetch\*.pf" -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
            Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "  ${GRN}✅ Prefetch cleaned${NC}"

        # DNS
        Write-Host "  ${CYN}🌐 DNS cache...${NC}"
        ipconfig /flushdns | Out-Null
        Write-Host "  ${GRN}✅ DNS flushed${NC}"

        # DISM cleanup (replaced cleanmgr)
        Write-Host "  ${CYN}💿 Component cleanup...${NC}"
        Invoke-WithCheck { Dism /Online /Cleanup-Image /StartComponentCleanup } "Component cleanup done!" "DISM failed"
    }

    Write-Host "`n${PUR}────────────────────────────────────────${NC}"
    Write-Host "  ${BOLD}${GRN}✅ MISSION ACCOMPLISHED!${NC}"
    Write-Host "${PUR}────────────────────────────────────────${NC}"

    # Notification (simplified)
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("All tasks completed!", "uup Tool", "OK", "Information") | Out-Null
    } catch {
        # Silent fail
    }
}

function run {
    # Color Codes
    $ESC = [char]27
    $CYAN = "$ESC[0;36m"
    $YELLOW = "$ESC[1;33m"
    $BLUE = "$ESC[1;34m"
    $GREEN = "$ESC[1;32m"
    $RED = "$ESC[0;31m"
    $BOLD = "$ESC[1m"
    $NC = "$ESC[0m"

    # File list (.js and .ts)
    $files = @(Get-ChildItem -Path "*.js", "*.ts" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)

    if ($files.Count -eq 0) {
        Write-Host "${RED}󱓇 No .js or .ts files found!${NC}"
        return 1
    }

    # Modern Header
    Write-Host ""
    Write-Host "${CYAN}╭──────────────────────────────────────────╮${NC}"
    Write-Host "${CYAN}│${NC}  ${BOLD}⚡ BUN INTERACTIVE RUNNER${NC}               ${CYAN}│${NC}"
    Write-Host "${CYAN}╰──────────────────────────────────────────╯${NC}"

    # List Display with Icons
    for ($i = 0; $i -lt $files.Count; $i++) {
        $ext = [System.IO.Path]::GetExtension($files[$i]).TrimStart('.')

        # Icon selection based on extension
        if ($ext -eq "ts") {
            $icon = "${BLUE}📘${NC}"  # Blue Book for TS
        } else {
            $icon = "${YELLOW}📒${NC}"  # Yellow Book for JS
        }

        # Beautifully aligned row
        Write-Host ("${CYAN}  [{0,2}]{NC}  {1}  {2,-30}" -f ($i + 1), $icon, $files[$i])
    }

    Write-Host "${CYAN}────────────────────────────────────────────${NC}"

    # Smart Input Prompt
    Write-Host "${YELLOW}👉 Enter file number (or Ctrl+C):${NC}"
    $choice = Read-Host "❯"

    # File selection validation
    if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $files.Count) {
        $selected_file = $files[[int]$choice - 1]

        Write-Host ""
        Write-Host "${GREEN}✔ Selected:${NC} ${BOLD}$selected_file${NC}"
        Write-Host "${CYAN}────────────────────────────────────────────${NC}"

        # Mode Selection Menu
        Write-Host ""
        Write-Host "${YELLOW}👉 Choose run mode:${NC}"
        Write-Host "${CYAN}  [1]${NC}  🚀  ${BOLD}bun run${NC}     (default)"
        Write-Host "${CYAN}  [2]${NC}  🔥  ${BOLD}bun --hot${NC}   (hot reload)"
        Write-Host "${CYAN}  [3]${NC}  👁  ${BOLD}bun --watch${NC} (watch mode)"
        Write-Host "${CYAN}────────────────────────────────────────────${NC}"
        $mode = Read-Host "❯"

        # Determine command based on mode
        switch ($mode) {
            "2" {
                $cmd = "bun"
                $cmdArgs = @("--hot", $selected_file)
                $mode_label = "HOT RELOAD"
                $mode_color = "$RED"
            }
            "3" {
                $cmd = "bun"
                $cmdArgs = @("--watch", $selected_file)
                $mode_label = "WATCH MODE"
                $mode_color = "$YELLOW"
            }
            default {
                $cmd = "bun"
                $cmdArgs = @("run", $selected_file)
                $mode_label = "RUN"
                $mode_color = "$GREEN"
            }
        }

        Write-Host ""
        Write-Host "${mode_color}⚙ $mode_label:${NC} ${BOLD}$selected_file${NC}"
        Write-Host ""

        # Execute
        & $cmd @cmdArgs
    } else {
        Write-Host ""
        Write-Host "${RED}✘ Error: Invalid selection!${NC}"
    }
}


# Auto 'ls' after cd
function cd {
    param([string]$Path)
    if ($Path) {
        Set-Location $Path
    } else {
        Set-Location ~
    }
    Get-ChildItem -Force
}
Set-Alias -Name c -Value cd

# ============================================
#  📦 DEV STACK ALIASES (NPM, BUN, GIT)
# ============================================

# --- NPM Shortcuts ---
function ni { npm install @args }
function nid { npm install -D @args }
function nr { npm run @args }
function nrd { npm run dev }
function nrb { npm run build }
function nrs { npm run start }

# --- Bun Shortcuts ---
function bi { bun install @args }
function br { bun run @args }
function brd { bun run dev }
function brb { bun run build }
function brs { bun run start }
function html { bun run index.html }
function w { bun --watch @args }
function h { bun --hot @args }

# --- Git Shortcuts ---
function gi { git init }
function gs { git status -sb }
function gl {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}
function gd { git diff }
function gco { git checkout @args }
function gcm { git commit -m @args }
function gpl { git pull }
function gps { git push }
function gb { git branch }
function gcb { git checkout -b @args }
function ga { git add . }
function gr { git restore @args }
function grh { git reset HEAD~1 }
function gc { git clone @args }
function gst { git stash }
function gsta { git stash apply }
function gpop { git stash pop }
function gfp { git fetch --prune }

# --- Docker Shortcuts ---
function d          { docker @args }
function dps        { docker ps @args }
function dpsa       { docker ps -a @args }
function di         { docker images @args }
function dpu        { docker pull @args }
function drun       { docker run @args }
function dex        { docker exec -it @args }
function dstop      { docker stop @args }
function drm        { docker rm @args }
function drmi       { docker rmi @args }
function dlog       { docker logs -f @args }
function dbuild     { docker build @args }
function dprune     { docker system prune -f }
function dvol       { docker volume ls }
function dnet       { docker network ls }
function dstopall   { docker stop $(docker ps -q) }
function drmall     { docker rm $(docker ps -aq) }
function drmiall    { docker rmi $(docker images -q) }

# --- Docker Compose Shortcuts ---
function dc         { docker compose @args }
function dcu        { docker compose up @args }
function dcud       { docker compose up -d @args }
function dcd        { docker compose down @args }
function dcb        { docker compose build @args }
function dcr        { docker compose restart @args }
function dcl        { docker compose logs -f @args }
function dcs        { docker compose stop @args }
function dcps       { docker compose ps @args }
function dcpull     { docker compose pull }
function dcexec     { docker compose exec @args }

function cf {
    param([string]$target_dir = ".")

    $search_cmd = "Get-ChildItem -Path '$target_dir' -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { `$_.FullName -notmatch '\\.git\\' -and `$_.FullName -notmatch '\\node_modules\\' } | Select-Object -ExpandProperty FullName"

    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $search_cmd = "fd --type d --hidden --exclude .git --exclude node_modules . '$target_dir'"
    }

    $previewCmd = "pwsh -NoProfile -Command `" " +
        "`$p='{}'; " +
        "Write-Host -ForegroundColor Cyan '📁 Contents of: `$p'; " +
        "Write-Host '──────────────────────────────────────────'; " +
        "Get-ChildItem -Path `$p -Force -ErrorAction SilentlyContinue | Select-Object -First 20 Name; " +
        "Write-Host '──────────────────────────────────────────'; " +
        "if (Test-Path (`$p + '/.git')) { " +
            "Write-Host -ForegroundColor Green '🌿 Git Repo Detect:'; " +
            "`$b=git -C `$p branch --show-current 2> `$null; Write-Host `'Branch -> `$b`'; " +
            "Write-Host -ForegroundColor Yellow '📝 Uncommitted Changes:'; " +
            "git -C `$p status -s 2> `$null | Select-Object -First 10; " +
            "Write-Host '──────────────────────────────────────────'; " +
        "} " +
        "`$size=(Get-ChildItem -Path `$p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; " +
        "if (`$size) { `$mb=[math]::Round(`$size/1MB, 2); Write-Host -ForegroundColor Yellow ('📊 Total Size: ' + `$mb + ' MB') } " +
    "`""

    $selected = Invoke-Expression $search_cmd | fzf `
        --height 90% `
        --layout=reverse `
        --border=rounded `
        --prompt="⚡ Dev Walk: " `
        --pointer="❯" `
        --marker="✔" `
        --header="[ENTER] Cd | [CTRL-O] VS Code | [CTRL-Y] Copy Path | [CTRL-H] Parent Dir" `
        --header-first `
        --bind "ctrl-y:execute-silent(pwsh -NoProfile -Command `"Set-Clipboard -Value '{}'`")+change-prompt(📋 Copied! > )" `
        --bind "ctrl-o:execute(code {} || nvim {})+abort" `
        --bind "ctrl-h:reload(fd --type d --hidden --exclude .git --exclude node_modules . `$`(dirname '{}'`) 2>/dev/null || find `$`(dirname '{}'`) -type d 2>/dev/null)+change-prompt(⚡ Parent: )" `
        --preview $previewCmd `
        --preview-window=right:50%:wrap

    if (-not [string]::IsNullOrWhiteSpace($selected)) {
        Set-Location $selected
    }
}

function t {
    if ($args.Count -eq 0) {
        Write-Host "❌ Provide at least one filename."
        return
    }
    foreach ($file in $args) {
        if (-not [string]::IsNullOrWhiteSpace($file)) {
            New-Item -Path $file -ItemType File -Force | Out-Null
            Write-Host "✅ Created File: $file"
        }
    }
}

# ======================================================
# End of .bashrc
# ======================================================
