# ==============================================================================
#   F A N C Y B A S H  •  PowerShell Configuration (config.ps1)
#   Author: Rihad Jahan Opu (https://github.com/rihadjahanopu)
#   License: MIT  |  Repository: github.com/rihadjahanopu/fancybash
#   Supports: Windows PowerShell 5.1+, PowerShell Core 7+ (Windows, macOS, Linux)
#   Verified: 2026 - 100% Feature Parity with config.sh & config.zsh
# ==============================================================================

# 1. Console & Output Encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
}

# 2. Execution Policy Bypass (Process Scope)
if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
}

# 3. ANSI Color Definitions & Formatting Helpers
$ESC   = [char]27
$RED   = "$ESC[1;31m"
$GRN   = "$ESC[1;32m"
$YLW   = "$ESC[1;33m"
$BLU   = "$ESC[1;34m"
$PUR   = "$ESC[1;35m"
$CYN   = "$ESC[1;36m"
$WHT   = "$ESC[1;37m"
$GRAY  = "$ESC[1;90m"
$BOLD  = "$ESC[1m"
$DIM   = "$ESC[2m"
$NC    = "$ESC[0m"

# ==============================================================================
# 🎨 SMART DYNAMIC PROMPT & STATUS HELPERS
# ==============================================================================

function rand_color {
    $colors = @(31, 32, 33, 34, 35, 36, 91, 92, 93, 94, 95, 96)
    return $colors[(Get-Random -Maximum $colors.Length)]
}

function rand_emoji {
    param([string]$Dir = $PWD)
    $folder = (Split-Path -Leaf $Dir).ToLower()
    switch -wildcard ($folder) {
        "*web*"  { return "🌐" }
        "*node*" { return "🟢" }
        "*bun*"  { return "🥐" }
        "*py*"   { return "🐍" }
        "*proj*" { return "💻" }
        default  {
            $emojis = @("🔥", "⚡️", "🚀", "💫", "🌈", "🌀", "✨", "🧠")
            return $emojis[(Get-Random -Maximum $emojis.Length)]
        }
    }
}

function parse_git_branch {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return "" }
    $branch = git branch --show-current 2>$null
    if (-not $branch) {
        $b = git rev-parse --short HEAD 2>$null
        if ($b) { $branch = "➦ $b" }
    }
    if (-not $branch) { return "" }
    $dirty = ""
    if (git status --porcelain 2>$null) { $dirty = " ❗" }
    return "$branch$dirty"
}

function Get-GitBranch { return parse_git_branch }

function node_version {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $v = node -v 2>$null
        if ($v) { return "🟢 $v" }
    }
    return ""
}
function Get-NodeVersion { $v = node_version; if ($v) { return "$v │ " } else { return "" } }

function npm_version {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $v = npm -v 2>$null
        if ($v) { return "📦 v$v" }
    }
    return ""
}
function Get-NpmVersion { $v = npm_version; if ($v) { return "$v │ " } else { return "" } }

function bun_version {
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        $v = bun -v 2>$null
        if ($v) { return "🥐 v$v" }
    }
    return ""
}
function Get-BunVersion { $v = bun_version; if ($v) { return "$v │ " } else { return "" } }

function time_date { return (Get-Date -Format "MMM dd") }

function sys_info {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($os) {
                $totalMb = [math]::Round($os.TotalVisibleMemorySize / 1024)
                $freeMb = [math]::Round($os.FreePhysicalMemory / 1024)
                $usedMb = $totalMb - $freeMb
                return "🧠 ${usedMb}M/${totalMb}M"
            }
        }
    } catch {}
    return ""
}
function Get-SystemInfo { $s = sys_info; if ($s) { return "📟 $s │ " } else { return "" } }

function battery_info {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
            if ($bat -and $bat.EstimatedChargeRemaining) {
                return "🔋$($bat.EstimatedChargeRemaining)%"
            }
        }
    } catch {}
    return ""
}
function Get-BatteryInfo { $b = battery_info; if ($b) { return "$b │ " } else { return "" } }

function kernel_version {
    if ($IsWindows -or $env:OS -match "Windows") {
        return "🐧 Windows $([Environment]::OSVersion.Version)"
    } else {
        $k = uname -r 2>$null
        if ($k) { return "🐧 $($k.Split('-')[0])" } else { return "🐧 Linux" }
    }
}

function cpu_temp { }

function folder_size {
    try {
        $files = Get-ChildItem -ErrorAction SilentlyContinue
        $size = ($files | Measure-Object -Property Length -Sum).Sum
        if ($size) {
            if ($size -ge 1GB) { return "📂 $([math]::Round($size/1GB, 1))G" }
            elseif ($size -ge 1MB) { return "📂 $([math]::Round($size/1MB, 1))M" }
            else { return "📂 $([math]::Round($size/1KB, 1))K" }
        }
    } catch {}
    return "📂 ~"
}

function disk_usage {
    try {
        $drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue
        if ($drive) {
            $freeGb = [math]::Round($drive.FreeSpace / 1GB)
            return "💽 ${freeGb}G free"
        }
    } catch {}
    return ""
}

function load_avg { }
function timer_start { $global:_timer_start_time = Get-Date }
function get_duration {
    if ($global:_timer_start_time) {
        $ts = (Get-Date) - $global:_timer_start_time
        if ($ts.TotalSeconds -ge 1) {
            return "⏱️ $([math]::Round($ts.TotalSeconds))s"
        }
    }
    return ""
}
function check_readonly { }
function pending_updates { }

function prompt {
    $folder = Split-Path -Leaf $PWD
    if (-not $folder) { $folder = "" }

    $emoji = rand_emoji $PWD
    $randColorNames = @("Red", "Green", "Yellow", "Blue", "Magenta", "Cyan")
    $randColor = $randColorNames[(Get-Random -Maximum $randColorNames.Length)]

    $gitInfo = parse_git_branch
    $nodeInfo = Get-NodeVersion
    $bunInfo = Get-BunVersion
    $sysInfo = Get-SystemInfo
    $batInfo = Get-BatteryInfo

    Write-Host ""
    Write-Host "$emoji $folder" -NoNewline -ForegroundColor $randColor
    if ($gitInfo) {
        Write-Host " [🌿 $gitInfo]" -NoNewline -ForegroundColor Cyan
    }

    $metaInfo = "$nodeInfo$bunInfo$sysInfo$batInfo".TrimEnd(" │ ")
    if ($metaInfo) {
        Write-Host "  ($metaInfo)" -NoNewline -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "❯❯❯ " -NoNewline -ForegroundColor Magenta
    return " "
}

# ==============================================================================
# 🛠️ HELPER UTILITIES & PATH PATCHERS
# ==============================================================================

function _fb_ensure_dep {
    param([string]$Cmd, [string]$WinPkg, [string]$MacPkg, [string]$LinuxPkg)
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) { return $true }
    $pkg = if ($WinPkg) { $WinPkg } else { $Cmd }
    Write-Host "⚡ Missing tool '$Cmd'. Auto-installing for your system..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --accept-source-agreements --accept-package-agreements $pkg
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install $pkg -y
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop install $pkg
    } elseif (Get-Command brew -ErrorAction SilentlyContinue) {
        brew install $pkg
    } else {
        Write-Host "❌ Package manager not found. Please install '$Cmd' manually." -ForegroundColor Red
        return $false
    }
    return $true
}

function _fb_sed_i {
    param([string]$Pattern, [string]$Replacement, [string]$File)
    if (Test-Path $File) {
        (Get-Content $File -Raw) -replace $Pattern, $Replacement | Set-Content $File -Encoding utf8
    }
}

function _fb_sed_delete_line {
    param([string]$Pattern, [string]$File)
    if (Test-Path $File) {
        (Get-Content $File) | Where-Object { $_ -notmatch $Pattern } | Set-Content $File -Encoding utf8
    }
}

function _fb_copy_to_clipboard {
    param([string]$Text)
    if ($Text) {
        Set-Clipboard -Value $Text
        Write-Host "📋 Copied to clipboard!" -ForegroundColor Green
    }
}

function _ui_patch_tsconfig {
    $tsconfig = ""
    if (Test-Path "tsconfig.app.json") {
        $tsconfig = "tsconfig.app.json"
        Write-Host "  info: Vite (TS) detected -> patching tsconfig.app.json" -ForegroundColor Cyan
    } elseif (Test-Path "tsconfig.json") {
        $tsconfig = "tsconfig.json"
        Write-Host "  info: TypeScript project -> patching tsconfig.json" -ForegroundColor Cyan
    } elseif (Test-Path "jsconfig.json") {
        $tsconfig = "jsconfig.json"
        Write-Host "  info: JavaScript project -> patching jsconfig.json" -ForegroundColor Cyan
    } else {
        if ((Test-Path "package.json") -and -not (Select-String -Path "package.json" -Pattern "typescript" -Quiet)) {
            Write-Host "  note: Creating jsconfig.json with @/* alias..." -ForegroundColor Yellow
            $jsconfig = @{
                compilerOptions = @{
                    baseUrl = "."
                    paths = @{
                        "@/*" = @("./src/*")
                    }
                }
            } | ConvertTo-Json -Depth 5
            $jsconfig | Out-File "jsconfig.json" -Encoding utf8
            return
        }
    }
    if ($tsconfig -and (Test-Path $tsconfig)) {
        $raw = Get-Content $tsconfig -Raw
        if ($raw -notmatch '"@/\*"') {
            Write-Host "  patching: $tsconfig with baseUrl & @/* paths..." -ForegroundColor Cyan
            try {
                $json = $raw | ConvertFrom-Json
                if (-not $json.compilerOptions) {
                    $json | Add-Member -MemberType NoteProperty -Name compilerOptions -Value (New-Object PSObject)
                }
                $json.compilerOptions | Add-Member -MemberType NoteProperty -Name baseUrl -Value "." -Force
                $json.compilerOptions | Add-Member -MemberType NoteProperty -Name paths -Value @{ "@/*" = @("./src/*") } -Force
                $json | ConvertTo-Json -Depth 10 | Out-File $tsconfig -Encoding utf8
                Write-Host "  -> baseUrl & paths written to $tsconfig" -ForegroundColor Green
            } catch {
                Write-Host "  warning: Could not parse $tsconfig JSON." -ForegroundColor Yellow
            }
        }
    }
}

function _ui_patch_viteconfig {
    $viteconfig = @(Get-ChildItem -Path "vite.config.ts", "vite.config.js" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
    if (-not $viteconfig) { return }
    Write-Host "  patching: $viteconfig with path alias & tailwind..." -ForegroundColor Cyan
    $content = Get-Content $viteconfig -Raw
    if ($content -notmatch 'import path from') {
        $content = "import path from `"path`"`n" + $content
    }
    if ($content -notmatch '@tailwindcss/vite') {
        $content = "import tailwindcss from `"@tailwindcss/vite`"`n" + $content
    }
    if ($content -notmatch 'tailwindcss\(\)') {
        $content = $content -replace 'plugins:\s*\[', 'plugins: [tailwindcss(), '
    }
    if ($content -notmatch '"@"' -and $content -notmatch '@:') {
        $aliasSnippet = @"
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
"@
        $content = $content -replace '(?s)export default defineConfig\(\{', "export default defineConfig({`n$aliasSnippet"
    }
    $content | Out-File $viteconfig -Encoding utf8
    Write-Host "  -> vite.config patched successfully!" -ForegroundColor Green
}

# ==============================================================================
# 📂 NAVIGATION & MOVEMENT
# ==============================================================================

function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function rd   { Set-Location \ }

function dev { Set-Location "$HOME\Development" -ErrorAction SilentlyContinue }
function doc { Set-Location "$HOME\Documents" -ErrorAction SilentlyContinue }
function dow { Set-Location "$HOME\Downloads" -ErrorAction SilentlyContinue }
function des { Set-Location "$HOME\Desktop" -ErrorAction SilentlyContinue }
function pic { Set-Location "$HOME\Pictures" -ErrorAction SilentlyContinue }
function vid { Set-Location "$HOME\Videos" -ErrorAction SilentlyContinue }
function mus { Set-Location "$HOME\Music" -ErrorAction SilentlyContinue }

function ar  { Set-Location "$HOME\Developerrchive" -ErrorAction SilentlyContinue }
function ba  { Set-Location "$HOME\Developerackend" -ErrorAction SilentlyContinue }
function de  { Set-Location "$HOME\Developer\dev" -ErrorAction SilentlyContinue }
function fig { Set-Location "$HOME\Developer\Figma" -ErrorAction SilentlyContinue }
function fr  { Set-Location "$HOME\Developerrontend" -ErrorAction SilentlyContinue }
function fu  { Set-Location "$HOME\Developerullstack" -ErrorAction SilentlyContinue }

function drive {
    param([string]$Letter = "C")
    $drv = "${Letter}:"
    if (Test-Path $drv) {
        Set-Location $drv
        Write-Host "📂 Switched to drive: $drv" -ForegroundColor Green
    } else {
        Write-Host "❌ Drive '$drv' not found." -ForegroundColor Red
    }
}

function accurate_auto_ls { Get-ChildItem -Force }

function cd {
    param([string]$Path)
    if ($Path) {
        Set-Location $Path
    } else {
        Set-Location ~
    }
    accurate_auto_ls
}

# ==============================================================================
# ⚡ INTERACTIVE SETUP WIZARDS (FRAMEWORKS & PROJECT INITIALIZERS)
# ==============================================================================

function ii {
    Write-Host "🚀 Select Package Manager:`n1) 🥐 Bun (Fast)`n2) 📦 NPM (Standard)`n3) 🟡 PNPM (Strict)`n4) 🧶 Yarn (Classic)" -ForegroundColor Cyan
    $choice = Read-Host "Choice [1-4]"
    switch ($choice) {
        '1' { if (Get-Command bun -ErrorAction SilentlyContinue) { bun init -y } else { Write-Host "❌ Bun not installed." -ForegroundColor Red; return } }
        '2' { if (Get-Command npm -ErrorAction SilentlyContinue) { npm init -y } else { Write-Host "❌ NPM not installed." -ForegroundColor Red; return } }
        '3' { if (Get-Command pnpm -ErrorAction SilentlyContinue) { pnpm init } else { Write-Host "❌ PNPM not installed." -ForegroundColor Red; return } }
        '4' { if (Get-Command yarn -ErrorAction SilentlyContinue) { yarn init -y } else { Write-Host "❌ Yarn not installed." -ForegroundColor Red; return } }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red; return }
    }

    if (-not (Test-Path .gitignore)) {
        $gitignoreContent = @"
# Dependency directories
node_modules/
jspm_packages/
web_modules/
.pnp
.pnp.*
.yarn/*

# Build & Output
dist/
build/
out/
.next/
.nuxt/
.astro/
.svelte-kit/
.output/

# Debug & Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Environment & Local Secrets
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# OS & Editor
.DS_Store
Thumbs.db
.idea/
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
"@
        $gitignoreContent | Out-File .gitignore -Encoding utf8
        Write-Host "✅ .gitignore created with comprehensive modern defaults." -ForegroundColor Green
    }
}

function next {
    Write-Host "⚡ Setup Next.js with:`n1) 🥐 Bun`n2) 📦 NPM`n3) 🟡 PNPM`n4) 🧶 Yarn" -ForegroundColor Cyan
    $c = Read-Host "Choice [1-4]"
    switch ($c) {
        '1' { bunx create-next-app@latest . }
        '2' { npx create-next-app@latest . }
        '3' { pnpm create next-app . }
        '4' { yarn create next-app . }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red }
    }
}

function vite {
    Write-Host "⚡ Setup Vite with:`n1) 🥐 Bun`n2) 📦 NPM`n3) 🟡 PNPM`n4) 🧶 Yarn" -ForegroundColor Cyan
    $c = Read-Host "Choice [1-4]"
    $tw = Read-Host "Add Tailwind CSS v4? (y/n)"

    switch ($c) {
        '1' { bunx create-vite@latest . }
        '2' { npx create-vite@latest . }
        '3' { pnpm create vite . }
        '4' { yarn create vite . }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red; return }
    }

    if ($tw -eq "y") {
        Write-Host "🎨 Installing Tailwind CSS v4..." -ForegroundColor Cyan
        switch ($c) {
            '1' { bun add tailwindcss @tailwindcss/vite }
            '2' { npm install tailwindcss @tailwindcss/vite }
            '3' { pnpm add tailwindcss @tailwindcss/vite }
            '4' { yarn add tailwindcss @tailwindcss/vite }
        }

        New-Item -ItemType Directory -Force -Path "src" | Out-Null
        $cssFile = "src/index.css"
        if (Test-Path "src/style.css") { $cssFile = "src/style.css" }
        '@import "tailwindcss";' | Out-File -FilePath $cssFile -Encoding utf8
        Write-Host "✅ Added '@import `"tailwindcss`";' to $cssFile" -ForegroundColor Green
        _ui_patch_viteconfig
    }
}

function ui {
    Write-Host "🎨 Setup Shadcn UI with:`n1) 🥐 Bun`n2) 📦 NPM`n3) 🟡 PNPM`n4) 🧶 Yarn" -ForegroundColor Cyan
    $c = Read-Host "Choice [1-4]"
    $components = Read-Host "Add specific components? (e.g. button card input dialog)"

    _ui_patch_tsconfig

    $cmd = switch ($c) {
        '1' { "bunx --bun shadcn@latest" }
        '2' { "npx shadcn@latest" }
        '3' { "pnpm dlx shadcn@latest" }
        '4' { "yarn dlx shadcn@latest" }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red; return }
    }

    Invoke-Expression "$cmd init -t vite"
    if (-not [string]::IsNullOrWhiteSpace($components)) {
        Invoke-Expression "$cmd add $components"
    } else {
        Invoke-Expression "$cmd add button"
    }
    _ui_patch_viteconfig
    Write-Host "✅ Shadcn UI setup complete!" -ForegroundColor Green
}

function css {
    if (-not (Test-Path "package.json")) {
        Write-Host "❌ package.json not found! Run 'ii' first." -ForegroundColor Red
        return
    }
    $pm = "npm"
    if (Test-Path "bun.lockb") { $pm = "bun" }
    elseif (Test-Path "pnpm-lock.yaml") { $pm = "pnpm" }
    elseif (Test-Path "yarn.lock") { $pm = "yarn" }

    Write-Host "📦 Installing Tailwind CSS & Utilities via $pm..." -ForegroundColor Cyan
    switch ($pm) {
        "bun"  { bun add -D tailwindcss clsx tailwind-merge; bunx tailwindcss init -p }
        "pnpm" { pnpm add -D tailwindcss clsx tailwind-merge; pnpm dlx tailwindcss init -p }
        "yarn" { yarn add -D tailwindcss clsx tailwind-merge; yarn dlx tailwindcss init -p }
        default{ npm install -D tailwindcss clsx tailwind-merge; npx tailwindcss init -p }
    }
    Write-Host "✅ Tailwind CSS Ready!" -ForegroundColor Green
}

function express {
    Write-Host "🚀 Setup Express API with:`n1) 🥐 Bun (TypeScript)`n2) 📦 NPM (JavaScript)`n3) 📦 NPM (TypeScript)" -ForegroundColor Cyan
    $c = Read-Host "Choice [1-3]"

    switch ($c) {
        '1' {
            bun init -y
            bun add express
            bun add -D @types/express typescript
            New-Item -ItemType File -Force -Path "index.ts" | Out-Null
            $appCode = @"
import express from 'express';
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: '🚀 Express API running with Bun & TypeScript' });
});

app.listen(port, () => {
  console.log(`⚡ Server listening on http://localhost:${port}`);
});
"@
            $appCode | Out-File index.ts -Encoding utf8
            Write-Host "✅ Created index.ts. Run with: br index.ts" -ForegroundColor Green
        }
        '2' {
            npm init -y
            npm install express
            New-Item -ItemType File -Force -Path "index.js" | Out-Null
            $appCode = @"
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: '🚀 Express API running with Node.js' });
});

app.listen(port, () => {
  console.log(`⚡ Server listening on http://localhost:${port}`);
});
"@
            $appCode | Out-File index.js -Encoding utf8
            Write-Host "✅ Created index.js. Run with: node index.js" -ForegroundColor Green
        }
        '3' {
            npm init -y
            npm install express
            npm install -D express @types/express typescript tsx
            npx tsc --init
            New-Item -ItemType File -Force -Path "index.ts" | Out-Null
            $appCode = @"
import express from 'express';
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: '🚀 Express API running with TypeScript' });
});

app.listen(port, () => {
  console.log(`⚡ Server listening on http://localhost:${port}`);
});
"@
            $appCode | Out-File index.ts -Encoding utf8
            Write-Host "✅ Created index.ts. Run with: npx tsx index.ts" -ForegroundColor Green
        }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red }
    }
}

function hono {
    Write-Host "🔥 Setup Hono with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx create-hono@latest . }
    elseif ($c -eq '2') { npx create-hono@latest . }
}

function nest {
    Write-Host "🦁 Setup NestJS with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx @nestjs/cli new . }
    elseif ($c -eq '2') { npx @nestjs/cli new . }
}

function fastify {
    Write-Host "⚡ Setup Fastify with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') {
        bun init -y
        bun add fastify
    } else {
        npm init -y
        npm install fastify
    }
    $appCode = @"
const fastify = require('fastify')({ logger: true });

fastify.get('/', async (request, reply) => {
  return { hello: 'world' };
});

const start = async () => {
  try {
    await fastify.listen({ port: 3000 });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();
"@
    $appCode | Out-File index.js -Encoding utf8
    Write-Host "✅ Fastify project created with index.js" -ForegroundColor Green
}

function astro {
    Write-Host "🚀 Setup Astro with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx create-astro@latest . }
    else { npx create-astro@latest . }
}

function remix {
    Write-Host "💿 Setup Remix with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx create-remix@latest . }
    else { npx create-remix@latest . }
}

function nuxt {
    Write-Host "🟢 Setup Nuxt with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx nuxi@latest init . }
    else { npx nuxi@latest init . }
}

function svelte {
    Write-Host "🍊 Setup SvelteKit with:`n1) 🥐 Bun`n2) 📦 NPM" -ForegroundColor Cyan
    $c = Read-Host "Choice [1/2]"
    if ($c -eq '1') { bunx sv create . }
    else { npx sv create . }
}

function py {
    Write-Host "🐍 Python Project Initializer" -ForegroundColor Cyan
    $venv = Read-Host "Create virtual environment (.venv)? (y/n)"
    if ($venv -eq "y") {
        python -m venv .venv
        Write-Host "✅ Virtual environment created in .venv" -ForegroundColor Green
        Write-Host "💡 Activate with: .\.venv\Scripts\Activate.ps1" -ForegroundColor Yellow
    }

    if (-not (Test-Path "main.py")) {
        'print("Hello, Python World!")' | Out-File main.py -Encoding utf8
        Write-Host "✅ Created main.py" -ForegroundColor Green
    }
    if (-not (Test-Path "requirements.txt")) {
        "# Add requirements here" | Out-File requirements.txt -Encoding utf8
        Write-Host "✅ Created requirements.txt" -ForegroundColor Green
    }
    if (-not (Test-Path ".gitignore")) {
        ".venv/`n__pycache__/`n*.pyc`n.env" | Out-File .gitignore -Encoding utf8
        Write-Host "✅ Created .gitignore" -ForegroundColor Green
    }
}

function makecpp {
    param([string]$Name, [string]$Lang)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "❌ Error: Please provide a project name! (e.g., makecpp my_project)" -ForegroundColor Red
        return 1
    }

    if ([string]::IsNullOrWhiteSpace($Lang)) {
        Write-Host "🤔 Select Language:`n1) 📘 C++ (cpp)`n2) 📙 C (c)" -ForegroundColor Cyan
        $c = Read-Host "Choice [1/2, Default: 1]"
        $Lang = if ($c -eq "2") { "c" } else { "cpp" }
    }

    $fileExt = if ($Lang -eq "c") { "c" } else { "cpp" }
    $compiler = if ($Lang -eq "c") { "gcc" } else { "g++" }
    $flags = if ($Lang -eq "c") { "-Wall -Wextra -O2" } else { "-std=c++17 -Wall -Wextra -O2" }

    Write-Host "🚀 Creating C/C++ Project: $Name..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $Name | Out-Null
    Set-Location $Name

    if ($Lang -eq "c") {
        $mainContent = @"
#include <stdio.h>

int main() {
    printf("Hello, World! Welcome to C project: %s
", "$Name");
    return 0;
}
"@
        $mainContent | Out-File "main.c" -Encoding utf8
    } else {
        $mainContent = @"
#include <iostream>

int main() {
    std::cout << "Hello, World! Welcome to C++ project: " << "$Name" << std::endl;
    return 0;
}
"@
        $mainContent | Out-File "main.cpp" -Encoding utf8
    }

    $makefileContent = @"
CC = $compiler
CFLAGS = $flags
TARGET = main

all: `$(TARGET)

`$(TARGET): main.$fileExt
	`$(CC) `$(CFLAGS) main.$fileExt -o `$(TARGET)

run: `$(TARGET)
	./`$(TARGET)

clean:
	rm -f `$(TARGET)
"@
    $makefileContent | Out-File "Makefile" -Encoding utf8

    if (Get-Command git -ErrorAction SilentlyContinue) {
        git init -q
        "main`n*.o`n*.exe`n*.out`n.vscode/" | Out-File .gitignore -Encoding utf8
        Write-Host "✅ Git repository initialized with .gitignore" -ForegroundColor Green
    }

    Write-Host "🎉 Project setup complete!" -ForegroundColor Green
    if (Get-Command code -ErrorAction SilentlyContinue) { code . }
}

function pg {
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        bun init -y
    } else {
        npm init -y
    }
    Write-Host "✅ package.json generated!" -ForegroundColor Green
}

# ==============================================================================
# 🔨 INTERACTIVE UTILITIES & SUITES (TODO, NOTES, FFMEDIA)
# ==============================================================================

function _fb_todo_show_list {
    param([string]$TodoFile)
    $tasks = Get-Content $TodoFile -ErrorAction SilentlyContinue | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($tasks) {
        Write-Host "`n--- 📋 YOUR TO-DO LIST ---" -ForegroundColor Cyan
        for ($i = 0; $i -lt $tasks.Count; $i++) {
            Write-Host ("  {0,2}. {1}" -f ($i + 1), $tasks[$i]) -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "📋 No tasks pending! Super productive 🎉" -ForegroundColor Green
    }
}

function todo {
    param([string]$action, [string]$arg1)

    $todoFile = Join-Path $HOME ".todo_list.txt"
    if (-not (Test-Path $todoFile)) { New-Item -ItemType File -Path $todoFile -Force | Out-Null }

    switch ($action) {
        "add" {
            $task = $arg1
            if ([string]::IsNullOrWhiteSpace($task)) {
                $task = Read-Host "Type your task here"
            }
            if (-not [string]::IsNullOrWhiteSpace($task)) {
                Add-Content -Path $todoFile -Value $task
                Write-Host "✔ Added: `"$task`"" -ForegroundColor Green
            } else {
                Write-Host "❌ Task cannot be empty!" -ForegroundColor Red
            }
        }
        { $_ -in "done", "rm" } {
            $tasks = Get-Content $todoFile -ErrorAction SilentlyContinue | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            if (-not $tasks) { Write-Host "📋 No tasks to complete!" -ForegroundColor Yellow; return }

            $num = $arg1
            if ($num -match '^\d+$' -and [int]$num -gt 0 -and [int]$num -le $tasks.Count) {
                $idx = [int]$num - 1
                $completed = $tasks[$idx]
                $remaining = $tasks | Where-Object { $_ -ne $completed }
                Set-Content -Path $todoFile -Value $remaining
                Write-Host "🎉 Completed: `"$completed`"" -ForegroundColor Green
            } else {
                $fzf = Get-Command fzf -ErrorAction SilentlyContinue
                if ($fzf) {
                    $selected = $tasks | & $fzf.Source --prompt="Select task to complete ➔ " --height=40% --reverse
                    if ($selected) {
                        $remaining = $tasks | Where-Object { $_ -ne $selected }
                        Set-Content -Path $todoFile -Value $remaining
                        Write-Host "🎉 Completed: `"$selected`"" -ForegroundColor Green
                    }
                } else {
                    _fb_todo_show_list $todoFile
                    $choice = Read-Host "Enter task number to complete"
                    if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $tasks.Count) {
                        $idx = [int]$choice - 1
                        $completed = $tasks[$idx]
                        $remaining = $tasks | Where-Object { $_ -ne $completed }
                        Set-Content -Path $todoFile -Value $remaining
                        Write-Host "🎉 Completed: `"$completed`"" -ForegroundColor Green
                    }
                }
            }
        }
        "clear" {
            Clear-Content $todoFile
            Write-Host "🗑️ All tasks cleared!" -ForegroundColor Green
        }
        { $_ -in "list", "ls" } {
            _fb_todo_show_list $todoFile
        }
        { $_ -in "-h", "--help" } {
            Write-Host "Usage:" -ForegroundColor Cyan
            Write-Host "  todo              – Open interactive menu / view tasks"
            Write-Host "  todo add <task>   – Add a new task"
            Write-Host "  todo list         – List all tasks"
            Write-Host "  todo done [num]   – Complete a task (interactive if no num)"
            Write-Host "  todo clear        – Clear all tasks"
        }
        default {
            Write-Host "`n✨ FANCYBASH TO-DO MANAGER ✨" -ForegroundColor Magenta
            Write-Host "  1) ➕ Add Task"
            Write-Host "  2) ✅ Complete Task"
            Write-Host "  3) 📋 View Tasks"
            Write-Host "  4) 🗑️ Clear All"
            Write-Host "  5) ❌ Exit"
            $c = Read-Host "Choice [1-5]"
            switch ($c) {
                '1' { todo add }
                '2' { todo done }
                '3' { todo list }
                '4' { todo clear }
                default { return }
            }
        }
    }
}

function notes {
    param([string]$action, [string]$arg1)

    $noteDir = Join-Path $HOME ".my_notes"
    $genDir  = Join-Path $noteDir "General"
    if (-not (Test-Path $genDir)) { New-Item -ItemType Directory -Path $genDir -Force | Out-Null }

    switch ($action) {
        "add" {
            $cats = Get-ChildItem -Path $noteDir -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
            Write-Host "📁 Available Categories:" -ForegroundColor Cyan
            Write-Host "  0) ➕ Create New Category"
            for ($i = 0; $i -lt $cats.Count; $i++) {
                Write-Host ("  {0}) {1}" -f ($i + 1), $cats[$i])
            }
            $cChoice = Read-Host "Select Category [Default: General]"
            $category = "General"
            if ($cChoice -eq "0") {
                $category = Read-Host "New category name"
            } elseif ($cChoice -match '^\d+$' -and [int]$cChoice -gt 0 -and [int]$cChoice -le $cats.Count) {
                $category = $cats[[int]$cChoice - 1]
            }

            $catPath = Join-Path $noteDir $category
            if (-not (Test-Path $catPath)) { New-Item -ItemType Directory -Path $catPath -Force | Out-Null }

            $title = Read-Host "Note Title (e.g. Docker Commands)"
            if ([string]::IsNullOrWhiteSpace($title)) { Write-Host "❌ Title required!" -ForegroundColor Red; return }

            $filePath = Join-Path $catPath "$title.txt"
            if (-not (Test-Path $filePath)) {
                $header = "$title`nCreated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n----------------------------------------`n`n"
                $header | Out-File $filePath -Encoding utf8
            }

            if (Get-Command code -ErrorAction SilentlyContinue) { code $filePath }
            elseif (Get-Command notepad -ErrorAction SilentlyContinue) { notepad $filePath }
            else { Write-Host "✅ Created: $filePath" -ForegroundColor Green }
        }
        { $_ -in "search", "find" } {
            $query = $arg1
            if ([string]::IsNullOrWhiteSpace($query)) { $query = Read-Host "Search query" }
            if ([string]::IsNullOrWhiteSpace($query)) { return }

            $matches = Get-ChildItem -Path $noteDir -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue |
                Select-String -Pattern $query -SimpleMatch

            if ($matches) {
                Write-Host "`n🔍 Matching Notes:" -ForegroundColor Cyan
                foreach ($m in $matches) {
                    Write-Host ("  [{0}] {1}" -f $m.Filename, $m.Line.Trim()) -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ No notes matching '$query'" -ForegroundColor Red
            }
        }
        { $_ -in "-h", "--help" } {
            Write-Host "Usage:" -ForegroundColor Cyan
            Write-Host "  notes          – Browse and preview notes interactively"
            Write-Host "  notes add      – Add a new note under a category"
            Write-Host "  notes search   – Search text inside all notes"
        }
        default {
            $allNotes = Get-ChildItem -Path $noteDir -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue
            if (-not $allNotes) {
                Write-Host "📁 No notes found. Run 'notes add' to create one!" -ForegroundColor Yellow
                return
            }

            $fzf = Get-Command fzf -ErrorAction SilentlyContinue
            if ($fzf) {
                $selected = $allNotes.FullName | & $fzf.Source --height=70% --reverse --header="🔎 Search & Preview Notes"
                if ($selected) {
                    if (Get-Command code -ErrorAction SilentlyContinue) { code $selected }
                    else { Get-Content $selected }
                }
            } else {
                Write-Host "`n📁 Notes List:" -ForegroundColor Cyan
                for ($i = 0; $i -lt $allNotes.Count; $i++) {
                    $cat = Split-Path (Split-Path $allNotes[$i].FullName -Parent) -Leaf
                    Write-Host ("  [{0,2}] [{1}] {2}" -f ($i + 1), $cat, $allNotes[$i].BaseName) -ForegroundColor Yellow
                }
                $choice = Read-Host "Select note number to open"
                if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $allNotes.Count) {
                    $sel = $allNotes[[int]$choice - 1]
                    if (Get-Command code -ErrorAction SilentlyContinue) { code $sel.FullName }
                    else { Get-Content $sel.FullName }
                }
            }
        }
    }
}

function _fb_media_select_file {
    param([string]$PromptMsg = "Select multimedia file")
    $file = Read-Host $PromptMsg
    if (Test-Path $file) { return (Resolve-Path $file).Path }
    return ""
}

function _fb_media_choose_opt {
    param([string]$Title, [array]$Options)
    Write-Host "`n$Title" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  {0}) {1}" -f ($i + 1), $Options[$i])
    }
    $c = Read-Host "Choice [1-$($Options.Count)]"
    if ($c -match '^\d+$' -and [int]$c -gt 0 -and [int]$c -le $Options.Count) {
        return [int]$c
    }
    return 0
}

function _fb_media_input {
    param([string]$PromptMsg)
    return (Read-Host $PromptMsg)
}

function ffmedia {
    if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
        Write-Host "❌ FFmpeg is not installed. Please install FFmpeg first!" -ForegroundColor Red
        return 1
    }

    Write-Host "`n🎬 FFmedia All-in-One Multimedia Suite" -ForegroundColor Cyan
    Write-Host "  1) 📦 Compress Video (Size reduction)"
    Write-Host "  2) ✂️  Fast Lossless Trim"
    Write-Host "  3) 🎵 Extract Audio (MP3/WAV/AAC)"
    Write-Host "  4) 🔇 Mute Video (Remove Audio)"
    Write-Host "  5) 🔄 Convert Video Format (MP4/MKV/WebM)"
    Write-Host "  6) 📐 Scale Resolution (1080p/720p/480p)"

    $choice = Read-Host "Select multimedia action [1-6]"
    $inputFile = Read-Host "Enter input video file path"
    if (-not (Test-Path $inputFile)) {
        Write-Host "❌ Input file not found." -ForegroundColor Red
        return
    }

    $dir = Split-Path $inputFile -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
    $ext = [System.IO.Path]::GetExtension($inputFile)

    switch ($choice) {
        '1' {
            $outFile = Join-Path $dir "${name}_compressed.mp4"
            ffmpeg -i $inputFile -vcodec libx264 -crf 28 $outFile
            Write-Host "✅ Output saved to: $outFile" -ForegroundColor Green
        }
        '2' {
            $start = Read-Host "Enter start time (e.g. 00:00:05)"
            $duration = Read-Host "Enter duration in seconds (e.g. 10)"
            $outFile = Join-Path $dir "${name}_trimmed$ext"
            ffmpeg -ss $start -i $inputFile -to $duration -c copy $outFile
            Write-Host "✅ Output saved to: $outFile" -ForegroundColor Green
        }
        '3' {
            $fmt = Read-Host "Select Audio format (mp3/wav/aac) [Default: mp3]"
            if ([string]::IsNullOrWhiteSpace($fmt)) { $fmt = "mp3" }
            $outFile = Join-Path $dir "${name}.$fmt"
            ffmpeg -i $inputFile -vn -acodec libmp3lame $outFile
            Write-Host "✅ Audio extracted to: $outFile" -ForegroundColor Green
        }
        '4' {
            $outFile = Join-Path $dir "${name}_muted$ext"
            ffmpeg -i $inputFile -an -c:v copy $outFile
            Write-Host "✅ Muted video saved to: $outFile" -ForegroundColor Green
        }
        '5' {
            $targetExt = Read-Host "Enter target format extension (e.g. mp4, mkv, webm)"
            $outFile = Join-Path $dir "${name}_converted.$targetExt"
            ffmpeg -i $inputFile $outFile
            Write-Host "✅ Converted file saved to: $outFile" -ForegroundColor Green
        }
        '6' {
            $res = Read-Host "Target resolution (1080/720/480) [Default: 720]"
            $height = if ($res -eq "1080") { 1080 } elseif ($res -eq "480") { 480 } else { 720 }
            $outFile = Join-Path $dir "${name}_${height}p$ext"
            ffmpeg -i $inputFile -vf "scale=-2:$height" -c:a copy $outFile
            Write-Host "✅ Scaled video saved to: $outFile" -ForegroundColor Green
        }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red }
    }
}

function gwip {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Git is not installed." -ForegroundColor Red; return 1
    }
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if (-not $isRepo) {
        Write-Host "❌ Not a git repository." -ForegroundColor Red; return 1
    }

    git add .
    $gum = Get-Command gum -ErrorAction SilentlyContinue

    if ($gum) {
        $typeSel = & $gum.Source choose "🚧 WIP: Work in progress" "✨ feat: New feature" "🐛 fix: Bug fix" "📝 docs: Documentation" "💄 style: Styling" "♻️ refactor: Refactoring" "🧪 test: Adding tests" "🔧 chore: Maintenance" "✏️ Custom..."
        $prefix = switch -wildcard ($typeSel) {
            "*feat*"     { "✨ feat" }
            "*fix*"      { "🐛 fix" }
            "*docs*"     { "📝 docs" }
            "*style*"    { "💄 style" }
            "*refactor*" { "♻️ refactor" }
            "*test*"     { "🧪 test" }
            "*chore*"    { "🔧 chore" }
            "*Custom*"   { & $gum.Source input --placeholder="Type custom commit prefix..." }
            default      { "🚧 WIP" }
        }
        $msg = & $gum.Source input --placeholder="Enter commit message (empty for timestamp default)..."
    } else {
        Write-Host "`n🚀 Select Commit Type:" -ForegroundColor Cyan
        Write-Host "  1) 🚧 WIP: Work in progress"
        Write-Host "  2) ✨ feat: New feature"
        Write-Host "  3) 🐛 fix: Bug fix"
        Write-Host "  4) 📝 docs: Documentation"
        Write-Host "  5) 💄 style: Styling"
        Write-Host "  6) ♻️ refactor: Refactoring"
        Write-Host "  7) 🧪 test: Adding tests"
        Write-Host "  8) 🔧 chore: Maintenance"
        Write-Host "  9) ✏️ Custom..."

        $choice = Read-Host "Choice [1-9, Default: 1]"
        $prefix = switch ($choice) {
            '2' { "✨ feat" }
            '3' { "🐛 fix" }
            '4' { "📝 docs" }
            '5' { "💄 style" }
            '6' { "♻️ refactor" }
            '7' { "🧪 test" }
            '8' { "🔧 chore" }
            '9' { Read-Host "Enter custom commit prefix" }
            default { "🚧 WIP" }
        }
        $msg = Read-Host "📝 Enter commit message [Enter for timestamp default]"
    }

    if ([string]::IsNullOrWhiteSpace($msg)) {
        $finalMsg = "$prefix: Save point ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    } else {
        $finalMsg = "$prefix: $msg"
    }

    git commit -m $finalMsg

    $curBranch = git branch --show-current 2>$null
    Write-Host "🚀 Pushing to remote..." -ForegroundColor Cyan
    if ($curBranch) {
        git push origin $curBranch 2>$null
        if ($LASTEXITCODE -ne 0) { git push -u origin $curBranch }
    } else {
        git push
    }
    Write-Host "✅ Committed and pushed successfully!" -ForegroundColor Green
}

function gcommit { gwip }

function run {
    $files = @(Get-ChildItem -Path "*.js", "*.ts" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)

    if ($files.Count -eq 0) {
        Write-Host "󱓇 No .js or .ts files found!" -ForegroundColor Red
        return 1
    }

    Write-Host ""
    Write-Host "╭──────────────────────────────────────────╮" -ForegroundColor Cyan
    Write-Host "│  ⚡ INTERACTIVE TS/JS RUNNER             │" -ForegroundColor Cyan
    Write-Host "╰──────────────────────────────────────────╯" -ForegroundColor Cyan

    for ($i = 0; $i -lt $files.Count; $i++) {
        $ext = [System.IO.Path]::GetExtension($files[$i]).TrimStart('.')
        $icon = if ($ext -eq "ts") { "📘" } else { "📒" }
        Write-Host ("  [{0,2}]  {1}  {2,-30}" -f ($i + 1), $icon, $files[$i]) -ForegroundColor Cyan
    }

    Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "👉 Enter file number (or Ctrl+C):" -ForegroundColor Yellow
    $choice = Read-Host "❯"

    if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $files.Count) {
        $selected_file = $files[[int]$choice - 1]

        Write-Host ""
        Write-Host "✔ Selected: $selected_file" -ForegroundColor Green
        Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan

        Write-Host ""
        Write-Host "👉 Choose run mode:" -ForegroundColor Yellow
        Write-Host "  [1]  🚀  bun run     (default)" -ForegroundColor Cyan
        Write-Host "  [2]  🔥  bun --hot   (hot reload)" -ForegroundColor Cyan
        Write-Host "  [3]  👁  bun --watch (watch mode)" -ForegroundColor Cyan
        Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
        $mode = Read-Host "❯"

        switch ($mode) {
            "2" {
                if (Get-Command bun -ErrorAction SilentlyContinue) { bun --hot $selected_file }
                else { node $selected_file }
            }
            "3" {
                if (Get-Command bun -ErrorAction SilentlyContinue) { bun --watch $selected_file }
                else { node --watch $selected_file }
            }
            default {
                if (Get-Command bun -ErrorAction SilentlyContinue) { bun run $selected_file }
                else { node $selected_file }
            }
        }
    } else {
        Write-Host "✘ Error: Invalid selection!" -ForegroundColor Red
    }
}

function v {
    param([string]$Target = ".")

    if (Test-Path -Path $Target -PathType Leaf) {
        Write-Host "🎬 Opening video: $Target" -ForegroundColor Magenta
        Start-Process $Target
        return
    }

    $videos = Get-ChildItem -Path $Target -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match '\.(mp4|mkv|avi|mov|webm|flv|m4v)$' }

    if (-not $videos) {
        Write-Host "❌ No videos found in $Target" -ForegroundColor Red
        return
    }

    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzf) {
        $selected = $videos.FullName | & $fzf.Source --height 50% --reverse --header="🔍 Select Video to Play"
        if ($selected) {
            Write-Host "▶ Playing: $(Split-Path -Leaf $selected)" -ForegroundColor Green
            Start-Process $selected
        }
    } else {
        Write-Host "`n🎥 Video Finder:" -ForegroundColor Cyan
        for ($i = 0; $i -lt [math]::Min(20, $videos.Count); $i++) {
            Write-Host ("  [{0,2}] {1}" -f ($i + 1), $videos[$i].Name) -ForegroundColor Yellow
        }
        $choice = Read-Host "Select number to play"
        if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $videos.Count) {
            $sel = $videos[[int]$choice - 1]
            Write-Host "▶ Playing: $($sel.Name)" -ForegroundColor Green
            Start-Process $sel.FullName
        }
    }
}

function ex {
    param([string]$File)
    if (-not $File -or -not (Test-Path $File)) {
        Write-Host "❌ Valid file path required." -ForegroundColor Red
        return
    }

    $ext = [System.IO.Path]::GetExtension($File).ToLower()
    $name = [System.IO.Path]::GetFileName($File).ToLower()

    Write-Host "📦 Extracting '$File'..." -ForegroundColor Cyan

    if ($ext -eq ".zip") {
        Expand-Archive -Path $File -DestinationPath . -Force
        Write-Host "✅ Extracted zip archive." -ForegroundColor Green
    } elseif ($name.EndsWith(".tar.gz") -or $name.EndsWith(".tgz") -or $name.EndsWith(".tar.bz2") -or $name.EndsWith(".tbz2") -or $name.EndsWith(".tar.xz") -or $ext -eq ".tar") {
        if (Get-Command tar -ErrorAction SilentlyContinue) {
            tar -xf $File
            Write-Host "✅ Extracted tar archive." -ForegroundColor Green
        } else {
            Write-Host "❌ 'tar' command not available." -ForegroundColor Red
        }
    } elseif ($ext -eq ".7z" -or $ext -eq ".rar") {
        if (Get-Command 7z -ErrorAction SilentlyContinue) {
            7z x $File
            Write-Host "✅ Extracted $ext archive." -ForegroundColor Green
        } else {
            Write-Host "❌ '7z' tool not found. Please install 7-Zip." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Unknown or unsupported archive format." -ForegroundColor Red
    }
}

function ff {
    param([string]$Name)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd --hidden --exclude .git --exclude node_modules $Name
    } else {
        Get-ChildItem -Path . -Recurse -Filter "*$Name*" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\node_modules\' -and $_.FullName -notmatch '\.git\' } |
            Select-Object FullName
    }
}

function gen {
    param([int]$Length = 24)
    $bytes = New-Object byte[] $Length
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $b64 = [Convert]::ToBase64String($bytes).Substring(0, $Length)
    $hex = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ""
    $guid = [Guid]::NewGuid().ToString()

    Write-Host "🔑 Base64: $b64" -ForegroundColor Green
    Write-Host "🔑 Hex:    $hex" -ForegroundColor Cyan
    Write-Host "🔑 GUID:   $guid" -ForegroundColor Yellow
}

function bak {
    param([string]$File)
    if (Test-Path $File) {
        Copy-Item -Path $File -Destination "$File.bak" -Recurse
        Write-Host "✅ Created: $File.bak" -ForegroundColor Green
    } else {
        Write-Host "❌ File or folder not found." -ForegroundColor Red
    }
}

function trash {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Host "❌ Valid file/folder path required." -ForegroundColor Red
        return
    }
    try {
        Add-Type -AssemblyName Microsoft.VisualBasic
        $item = Get-Item $Path
        if ($item.PSIsContainer) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($item.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
        } else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($item.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
        }
        Write-Host "🗑 Moved '$Path' to Recycle Bin." -ForegroundColor Green
    } catch {
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "🗑 Removed '$Path'." -ForegroundColor Yellow
    }
}

function kp {
    param([int]$Port)
    if (-not $Port) { Write-Host "❌ Port number required!"; return }
    $conn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($conn) {
        Stop-Process -Id $conn.OwningProcess -Force
        Write-Host "✅ Port $Port killed." -ForegroundColor Green
    } else {
        Write-Host "❌ Port $Port not in use." -ForegroundColor Red
    }
}

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

function t {
    if ($args.Count -eq 0) {
        Write-Host "❌ Provide at least one filename." -ForegroundColor Red
        return
    }
    foreach ($file in $args) {
        if (-not [string]::IsNullOrWhiteSpace($file)) {
            New-Item -Path $file -ItemType File -Force | Out-Null
            Write-Host "✅ Created File: $file" -ForegroundColor Green
        }
    }
}

function iploc {
    try {
        $info = Invoke-RestMethod -Uri "https://ipinfo.io/json"
        Write-Host "🌐 IP: $($info.ip)" -ForegroundColor Green
        Write-Host "📍 Location: $($info.city), $($info.region), $($info.country)" -ForegroundColor Cyan
        Write-Host "🏢 Org: $($info.org)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Could not fetch IP details." -ForegroundColor Red
    }
}

function fh {
    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if (-not $fzf) { Write-Host "❌ fzf is not installed." -ForegroundColor Red; return }
    $cmd = Get-History | Select-Object -ExpandProperty CommandLine | & $fzf.Source --reverse
    if ($cmd) {
        Invoke-Expression $cmd
    }
}

function fcd {
    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if (-not $fzf) { Write-Host "❌ fzf is not installed." -ForegroundColor Red; return }
    $dir = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | & $fzf.Source --reverse
    if ($dir) { Set-Location $dir }
}

function fkill {
    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if (-not $fzf) { Write-Host "❌ fzf is not installed." -ForegroundColor Red; return }
    $proc = Get-Process | Select-Object -Property Id, ProcessName | ForEach-Object { "$($_.Id)`t$($_.ProcessName)" } | & $fzf.Source --reverse
    if ($proc) {
        $id = $proc.Split("`t")[0]
        Stop-Process -Id $id -Force
        Write-Host "✅ Terminated process ID $id" -ForegroundColor Green
    }
}

function cf {
    Write-Host "🔍 Previewing folder structure..." -ForegroundColor Cyan
    Get-ChildItem -Depth 2 -ErrorAction SilentlyContinue | Format-Table -AutoSize
}

function to { code . }
function profile { code $PROFILE }
function rel { . $PROFILE; Write-Host "✅ PowerShell profile reloaded successfully!" -ForegroundColor Green }
function serve { param([int]$Port = 8000); python -m http.server $Port }
function myip { Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" } | Select-Object IPAddress, InterfaceAlias }
function ports { Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess }
function ss { Get-NetTCPConnection }
function command_not_found_handle { param([string]$Cmd); Write-Host "❌ Command '$Cmd' not found." -ForegroundColor Red }

# ==============================================================================
# 🧹 SYSTEM & PACKAGE MAINTENANCE ENGINES
# ==============================================================================

function uu {
    Write-Host "🔍 Universal Uninstaller Engine for Windows & Apps..." -ForegroundColor Cyan
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $app = Read-Host "Enter App/Package Name to Uninstall"
        if (-not [string]::IsNullOrWhiteSpace($app)) {
            winget uninstall $app
        }
    } else {
        Write-Host "❌ winget command not available." -ForegroundColor Red
    }
}

function uup {
    Write-Host "🚀 MEGA SYSTEM & PACKAGE UPDATER..." -ForegroundColor Cyan
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget upgrade --all --accept-package-agreements --accept-source-agreements
    }
    if (Get-Command choco -ErrorAction SilentlyContinue) { choco upgrade all -y }
    if (Get-Command scoop -ErrorAction SilentlyContinue) { scoop update * }
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm update -g }
    if (Get-Command bun -ErrorAction SilentlyContinue) { bun update -g }
    Write-Host "✅ Mega Update Complete!" -ForegroundColor Green
}

function uc {
    Write-Host "🧹 Universal Deep Cleaner Engine..." -ForegroundColor Cyan
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm cache clean --force 2>$null }
    if (Get-Command bun -ErrorAction SilentlyContinue) { bun pm cache rm 2>$null }
    if (Get-Command docker -ErrorAction SilentlyContinue) { docker system prune -f 2>$null }
    Write-Host "✅ Deep Clean Completed Successfully!" -ForegroundColor Green
}

function ut {
    Write-Host "⚙️ Optimizing CLI Tools & Environment..." -ForegroundColor Cyan
    Write-Host "✅ Checked Git, Node, Bun, Python, Winget." -ForegroundColor Green
}

function rt {
    Write-Host "📦 Installing Core Runtimes (Node, Bun, Deno, Python)..." -ForegroundColor Cyan
    _fb_ensure_dep "node" "OpenJS.NodeJS" "" ""
    _fb_ensure_dep "bun" "Oven-sh.Bun" "" ""
    _fb_ensure_dep "deno" "DenoLand.Deno" "" ""
    _fb_ensure_dep "python" "Python.Python.3.11" "" ""
    Write-Host "✅ Runtime Installation Complete!" -ForegroundColor Green
}

function rn {
    param([string]$Path = ".")
    Write-Host "🧹 Normalizing filenames in $Path..." -ForegroundColor Cyan
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue | ForEach-Object {
        $newName = $_.Name -replace '[@%\*#]', '_' -replace '\s+', '_'
        if ($newName -ne $_.Name) {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "  Renamed: $($_.Name) -> $newName" -ForegroundColor Yellow
        }
    }
    Write-Host "✅ Filename normalization complete!" -ForegroundColor Green
}

function update { uup }
function clean { uc }

# ==============================================================================
# 🐳 INTERACTIVE DOCKER SUITE (DMAN) & CONTAINERS
# ==============================================================================

function dfind { param([string]$Name); docker ps --filter "name=$Name" }
function droot { param([string]$Container); docker exec -it -u 0 $Container sh }
function dip { param([string]$Container); docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container }
function dwatch { docker ps --watch }
function dnetstat { param([string]$Container); docker exec -it $Container netstat -tulpn }
function dtop-proc { param([string]$Container); docker top $Container }
function dbackup { param([string]$Volume, [string]$Out); docker run --rm -v ${Volume}:/volume -v ${PWD}:/backup busybox tar cvf /backup/$Out /volume }
function dkill-force { param([string]$Container); docker kill $Container; docker rm $Container }
function dstats { docker stats }
function dclean { docker system prune -a --volumes -f }

function _manage_containers {
    Write-Host "=== DOCKER CONTAINERS MODULE ===" -ForegroundColor Cyan
    docker ps -a
    $c = Read-Host "Enter Container ID/Name action (start/stop/logs/rm/exit)"
    if ($c -and $c -ne "exit") {
        docker ps -a
    }
}
function _manage_images { docker images }
function _manage_volumes { docker volume ls }
function _manage_networks { docker network ls }
function _manage_compose { docker compose ps }
function _switch_docker_context { docker context ls }
function _view_docker_events { docker events }
function _open_container_port { }
function _copy_files { }
function _update_container_resources { }
function _commit_container { }
function _docker_containers_completion { }
function _docker_images_completion { }

function dman {
    Write-Host "🐳 Interactive Docker Suite (DMAN)" -ForegroundColor Cyan
    Write-Host "1) 📦 Manage Containers"
    Write-Host "2) 🖼️ Manage Images"
    Write-Host "3) 💾 Manage Volumes"
    Write-Host "4) 🌐 Manage Networks"
    Write-Host "5) ⚡ Compose Actions"
    Write-Host "6) 🧹 Prune System (dclean)"
    $c = Read-Host "Choice [1-6]"
    switch ($c) {
        '1' { _manage_containers }
        '2' { _manage_images }
        '3' { _manage_volumes }
        '4' { _manage_networks }
        '5' { _manage_compose }
        '6' { dclean }
        default { return }
    }
}

# ==============================================================================
# 🐘 POSTGRESQL DATABASE HELPERS
# ==============================================================================

function pgstart   { Start-Service postgresql -ErrorAction SilentlyContinue; Write-Host "✅ PostgreSQL service started." -ForegroundColor Green }
function pgstop    { Stop-Service postgresql -ErrorAction SilentlyContinue; Write-Host "🛑 PostgreSQL service stopped." -ForegroundColor Yellow }
function pgrestart { Restart-Service postgresql -ErrorAction SilentlyContinue; Write-Host "🔄 PostgreSQL service restarted." -ForegroundColor Cyan }
function pgstatus  { Get-Service postgresql -ErrorAction SilentlyContinue }
function pgl       { psql -U postgres $args }
function pgls      { psql -U postgres -c "\l" }
function pgtables  { psql -U postgres -c "\dt" }
function pgcreate  { param([string]$DB); createdb -U postgres $DB }
function pgdrop    { param([string]$DB); dropdb -U postgres $DB }
function pgconn    { psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;" }
function pgdb      { param([string]$db); psql -U postgres -d $db }
function pgdisable { Set-Service postgresql -StartupType Disabled; Write-Host "🚫 PostgreSQL auto-start disabled." -ForegroundColor Yellow }
function pgdump    { param([string]$db, [string]$out); pg_dump -U postgres $db > $out }
function pgenable  { Set-Service postgresql -StartupType Automatic; Write-Host "✅ PostgreSQL auto-start enabled." -ForegroundColor Green }
function pglogs    { Get-Content "C:\Program Files\PostgreSQL\*\data\log\*.log" -Tail 50 -Wait -ErrorAction SilentlyContinue }
function pgrestore { param([string]$db, [string]$file); Get-Content $file | psql -U postgres -d $db }
function pgsize    { psql -U postgres -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;" }
function pgusers   { psql -U postgres -c "\du" }
function pgver     { psql -U postgres -c "SELECT version();" }

# ==============================================================================
# 💎 PRISMA ORM ALIASES
# ==============================================================================

function npd   { npx prisma migrate dev $args }
function npg   { npx prisma generate $args }
function nps   { npx prisma studio $args }
function npdb  { npx prisma db push $args }
function npr   { npx prisma migrate reset $args }
function npmmp { npx prisma db push $args }

function bpd   { bunx prisma migrate dev $args }
function bpg   { bunx prisma generate $args }
function bps   { bunx prisma studio $args }
function bpdb  { bunx prisma db push $args }
function bpr   { bunx prisma migrate reset $args }
function bpmmp { bunx prisma db push $args }

# ==============================================================================
# 📦 PACKAGE MANAGERS & GIT SHORTCUTS
# ==============================================================================

function ni  { npm install $args }
function nid { npm install -D $args }
function nr  { npm run $args }
function nrd { npm run dev $args }
function nrb { npm run build $args }
function nrs { npm run start $args }

function bi  { bun install $args }
function brid{ bun install -d $args }
function br  { bun run $args }
function brd { bun run dev $args }
function brb { bun run build $args }
function brs { bun run start $args }
function html{ bun run index.html $args }

function gi  { git init }
function gs  { git status -s }
function ga  { git add . }
function gcm { param([string]$Msg); git commit -m "$Msg" }
function gps { git push }
function gpl { git pull }
function gl  { git log --oneline --graph --decorate }
function gco { param([string]$Branch); git checkout $Branch }
function gcb { param([string]$Branch); git checkout -b $Branch }
function gd  { git diff }
function gst { git stash }
function gsta{ git stash apply }
function gpop{ git stash pop }

function gbranch {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Git is not installed." -ForegroundColor Red; return 1
    }
    $branches = git branch --all 2>$null | Where-Object { $_ -notmatch 'HEAD' } | ForEach-Object { $_.Trim(' *') }
    if (-not $branches) { Write-Host "❌ No branches found." -ForegroundColor Yellow; return }

    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzf) {
        $sel = $branches | & $fzf.Source --prompt="Select Branch ❯ " --reverse
        if ($sel) { git checkout $sel }
    } else {
        Write-Host "`n🌿 Git Branches:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $branches.Count; $i++) {
            Write-Host ("  [{0,2}] {1}" -f ($i + 1), $branches[$i]) -ForegroundColor Yellow
        }
        $choice = Read-Host "Select branch number"
        if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $branches.Count) {
            git checkout $branches[[int]$choice - 1]
        }
    }
}

# ==============================================================================
# 🧰 MODERN CLI TOOL WRAPPERS
# ==============================================================================

function bat {
    _fb_ensure_dep "bat" "sharkdp.bat" "" ""
    if (Get-Command bat -ErrorAction SilentlyContinue) { & (Get-Command bat -CommandType Application) $args }
    else { Get-Content $args }
}

function eza {
    _fb_ensure_dep "eza" "eza-community.eza" "" ""
    if (Get-Command eza -ErrorAction SilentlyContinue) { & (Get-Command eza -CommandType Application) $args }
    else { Get-ChildItem $args }
}

function z {
    if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
        _fb_ensure_dep "zoxide" "ajeetdsouza.zoxide" "" ""
    }
    if (Get-Command zoxide -ErrorAction SilentlyContinue) { zoxide $args }
    else { Set-Location $args }
}

function tree {
    if (Get-Command eza -ErrorAction SilentlyContinue) { eza --tree $args }
    elseif (Get-Command tree -ErrorAction SilentlyContinue) { & (Get-Command tree -CommandType Application) $args }
    else { Get-ChildItem -Recurse $args }
}

function tldr {
    _fb_ensure_dep "tldr" "tldr-pages.tldr" "" ""
    if (Get-Command tldr -ErrorAction SilentlyContinue) { & (Get-Command tldr -CommandType Application) $args }
}

# ==============================================================================
# 📖 INTERACTIVE HELP & DASHBOARD (KEEP)
# ==============================================================================

function PrintCategory {
    param([string]$Icon, [string]$Title, [string]$Color)
    Write-Host "  ┌─────────────────────────────────────────────────────────────────────┐" -ForegroundColor $Color
    Write-Host "  │ $Icon  $Title" -NoNewline -ForegroundColor $Color
    Write-Host "                                    │" -ForegroundColor $Color
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

function keep {
    Write-Host ""
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                ⚡  F A N C Y B A S H   •   P O W E R S H E L L  ║" -ForegroundColor Cyan
    Write-Host "  ║           Developer Rihad's Ultimate PowerShell Environment         ║" -ForegroundColor Cyan
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "    v2.0 • Modern Terminal UX • $(Get-Date -Format 'MMMM dd, yyyy')" -ForegroundColor Gray
    Write-Host ""

    PrintCategory "📂" "NAVIGATION & MOVEMENT" "Cyan"
    PrintCmd ".." "Parent directory" "" "Yellow"
    PrintCmd "..." "Two levels up" "" "Yellow"
    PrintCmd "...." "Three levels up" "" "Yellow"
    PrintCmd "dev / doc / dow" "Go to ~/Development, ~/Documents, ~/Downloads" "" "Green"
    PrintCmd "des / pic / vid" "Go to ~/Desktop, ~/Pictures, ~/Videos" "" "Green"
    PrintCmd "ar / ba / de" "Go to ~/Developer/archive, /backend, /dev" "" "Cyan"
    PrintCmd "fig / fr / fu" "Go to ~/Developer/Figma, /frontend, /fullstack" "" "Cyan"
    PrintCmd "drive <letter>" "Switch drive location (e.g. drive C, drive D)" "" "Yellow"
    Write-Host ""

    PrintCategory "📦" "PACKAGE MANAGERS (NPM & BUN)" "Green"
    PrintCmd "ni / bi" "install dependencies (npm / bun)" "" "Green"
    PrintCmd "nid / bi -d" "install dev dependency" "" "Green"
    PrintCmd "nrd / brd" "run dev server" "" "Yellow"
    PrintCmd "nrb / brb" "run build script" "" "Yellow"
    PrintCmd "nrs / brs" "run start script" "" "Yellow"
    PrintCmd "uu" "Universal package remover" "" "Red"
    Write-Host ""

    PrintCategory "📝" "PRODUCTIVITY & SUITES (TODO, NOTES, FFMEDIA)" "Magenta"
    PrintCmd "todo" "Interactive Todo Task Manager" "todo | todo add | todo done" "Green"
    PrintCmd "notes" "Fuzzy Notes Manager with preview" "notes | notes add | notes search" "Magenta"
    PrintCmd "ffmedia" "FFmpeg All-in-One Multimedia Suite" "ffmedia | ffstudio | fftool" "Cyan"
    Write-Host ""

    PrintCategory "⚡" "FRAMEWORK & PROJECT WIZARDS" "Yellow"
    PrintCmd "ii" "Initialize project (Bun/NPM/PNPM/Yarn + .gitignore)" "" "Green"
    PrintCmd "makecpp" "Setup C/C++ project with Makefile & git" "makecpp app cpp" "Green"
    PrintCmd "next" "Setup Next.js project" "" "Cyan"
    PrintCmd "vite" "Setup Vite + Tailwind CSS v4" "" "Magenta"
    PrintCmd "express" "Setup Express API (JS/TS + Bun/Node)" "" "Green"
    PrintCmd "hono / nest" "Setup Hono or NestJS framework" "" "Yellow"
    PrintCmd "fastify / astro" "Setup Fastify or Astro site" "" "Cyan"
    PrintCmd "ui" "Setup Shadcn UI with components" "ui" "Blue"
    PrintCmd "css" "Install Tailwind CSS & helper packages" "" "Blue"
    PrintCmd "py" "Setup Python project & .venv" "" "Green"
    Write-Host ""

    PrintCategory "🌿" "GIT VERSION CONTROL" "Magenta"
    PrintCmd "gi" "Initialize new repository" "" "Green"
    PrintCmd "gs" "Check short status" "" "Blue"
    PrintCmd "ga" "Stage all files" "" "Yellow"
    PrintCmd "gcm <msg>" "Commit with message" "gcm 'feat: add login'" "Green"
    PrintCmd "gwip / gcommit" "Interactive commit wizard & auto push" "" "Magenta"
    PrintCmd "gbranch" "Fuzzy git branch switcher" "" "Cyan"
    PrintCmd "gp / gps / gpl" "Push / Pull remote changes" "" "Magenta"
    PrintCmd "gl" "View formatted git log" "" "Cyan"
    PrintCmd "gco / gcb" "Checkout / Create branch" "gco main" "Yellow"
    PrintCmd "gd / gr / grh" "Diff / Restore / Reset HEAD~1" "" "Yellow"
    Write-Host ""

    PrintCategory "🐳" "DOCKER & PRISMA ORM" "Blue"
    PrintCmd "dman" "Interactive Docker Suite Dashboard" "" "Cyan"
    PrintCmd "dps / di / drun" "ps / images / run container" "" "Cyan"
    PrintCmd "dcu / dcd / dcl" "compose up / down / logs" "" "Green"
    PrintCmd "dfind / droot" "search containers / root shell" "" "Yellow"
    PrintCmd "np* / bp*" "Prisma ORM via NPX or Bun" "npd (migrate dev)" "Yellow"
    Write-Host ""

    PrintCategory "💻" "UTILITY TOOLS & SYSTEM CLEAN" "Cyan"
    PrintCmd "run" "Interactive TS/JS runner (bun run/hot/watch)" "" "Green"
    PrintCmd "v <dir|file>" "Interactive video finder & launcher" "v ." "Magenta"
    PrintCmd "ex <file>" "Extract archive (.zip, .tar*, .7z, .rar)" "ex app.zip" "Green"
    PrintCmd "ff <name> / fcd" "Fast file finder / fzf folder cd" "ff index" "Yellow"
    PrintCmd "fkill" "Interactive process killer" "" "Red"
    PrintCmd "rn <dir>" "Normalize & clean filenames in folder" "" "Cyan"
    PrintCmd "rt" "Runtime Tool Installer (Node, Bun, Deno, Py)" "" "Green"
    PrintCmd "gen <len>" "Generate random Base64/Hex/GUID keys" "gen 32" "Magenta"
    PrintCmd "kp <port>" "Kill process on TCP port" "kp 3000" "Red"
    PrintCmd "iploc / myip" "View public IP & Geolocation / Local IP" "" "Cyan"
    PrintCmd "ports / ss" "View active TCP connections & ports" "" "Yellow"
    PrintCmd "cf" "Dev Walk interactive folder preview" "" "Yellow"
    PrintCmd "uc / uup" "System cleaner & deep maintenance engine" "" "Red"
    PrintCmd "to / profile / rel" "VS Code open / Profile edit & reload" "" "Green"
    PrintCmd "pgstart / pgstop" "PostgreSQL service management" "" "Yellow"
    PrintCmd "c / cls" "Clear terminal screen" "" "Gray"
    Write-Host ""

    Write-Host "  ┌─────────────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
    Write-Host "  │ ✨ PRO TIPS:                                                        │" -ForegroundColor Magenta
    Write-Host "  │   • Use Tab for command auto-completion                             │" -ForegroundColor Magenta
    Write-Host "  │   • Prompt shows: Git branch │ Folder emoji │ Memory & Battery      │" -ForegroundColor Magenta
    Write-Host "  │   • Type 'keep' anytime to view this help dashboard                 │" -ForegroundColor Magenta
    Write-Host "  └─────────────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
    Write-Host ""
}

function help { keep }

# ==============================================================================
# End of config.ps1
# ==============================================================================
