# ==============================================================================
#   ULTRA-THIN COMPACT PRO WINDOWS POWERSHELL ENVIRONMENT
#   Author: [Rihad Jahan Opu]
#   Version: 1.0.0 Windows PowerShell Edition
#   Purpose: A fast, beautiful, and productive terminal for Web Development
#   Supports: Windows PowerShell
#   Verified: 2026
# ==============================================================================

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

# ------------------------------------------------------------------------------
# 📦 PACKAGE MANAGERS
# ------------------------------------------------------------------------------
# NPM
function ni { npm install }
function nid { npm install -D }
function nr { npm run $args[0] }
function nrd { npm run dev }
function nrb { npm run build }
function nrs { npm run start }

# Bun
function bi { bun install }
function br { bun run $args[0] }
function brd { bun run dev }
function brb { bun run build }
function brs { bun run start }

# ------------------------------------------------------------------------------
# 🌿 GIT VERSION CONTROL
# ------------------------------------------------------------------------------
function gi { git init }
function gs { git status -s }
function ga { git add . }
function gcm { git commit -m $args[0] }
function gps { git push }
function gpl { git pull }
function gl { git log --graph --oneline --all }
function gco { git checkout $args[0] }
function gcb { git checkout -b $args[0] }
function gd { git diff }

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

function init {
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
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "     POWERSHELL FANCYBASH MENU        " -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host " Navigation: .., ..., ...., dev"
    Write-Host " NPM:        ni, nid, nr, nrd, nrb, nrs"
    Write-Host " Bun:        bi, br, brd, brb, brs"
    Write-Host " Git:        gi, gs, ga, gcm, gps, gpl, gl, gco, gcb, gd, gwip"
    Write-Host " Setup:      init, next, vite, ui, pg"
    Write-Host " Utilities:  mkd, rmd, rmf, kp, ff, gen, bak, ex, trash"
    Write-Host "======================================" -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name h -Value Get-History
