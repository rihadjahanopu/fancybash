# ==============================================================================
#   ULTRA-THIN COMPACT PRO WINDOWS POWERSHELL ENVIRONMENT
#   Author: [Rihad Jahan Opu]
#   Version: 2.0.0 Complete Multi-Platform Edition
#   Purpose: A fast, beautiful, and productive terminal for Web Development
#   Supports: Windows PowerShell 5.1+, PowerShell Core 7+ (Windows, macOS, Linux)
#   Verified: 2026 - Feature-Complete Parity with config.zsh & config.sh
# ==============================================================================

# 1. Output Encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Execution Policy Bypass (Process Scope)
if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
}

# 3. ANSI Color Definitions & Formatting Helpers
$ESC  = [char]27
$RED  = "$ESC[1;31m"
$GRN  = "$ESC[1;32m"
$YLW  = "$ESC[1;33m"
$BLU  = "$ESC[1;34m"
$PUR  = "$ESC[1;35m"
$CYN  = "$ESC[1;36m"
$WHT  = "$ESC[1;37m"
$BOLD = "$ESC[1m"
$DIM  = "$ESC[2m"
$NC   = "$ESC[0m"

# ==============================================================================
# 🎨 SMART PROMPT SYSTEM
# ==============================================================================

function Get-GitBranch {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return "" }
    $branch = git branch --show-current 2>$null
    if (-not $branch) {
        $branch = git rev-parse --short HEAD 2>$null
        if ($branch) { $branch = "➦ $branch" }
    }
    if (-not $branch) { return "" }

    $dirty = ""
    $status = git status --porcelain 2>$null
    if ($status) { $dirty = " ❗" }
    return " [🌿 $branch$dirty]"
}

function Get-NodeVersion {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $v = node -v 2>$null
        if ($v) { return "🟢 $v │ " }
    }
    return ""
}

function Get-NpmVersion {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $v = npm -v 2>$null
        if ($v) { return "📦 v$v │ " }
    }
    return ""
}

function Get-BunVersion {
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        $v = bun -v 2>$null
        if ($v) { return "🥐 v$v │ " }
    }
    return ""
}

function Get-SystemInfo {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($os) {
                $totalMb = [math]::Round($os.TotalVisibleMemorySize / 1024)
                $freeMb = [math]::Round($os.FreePhysicalMemory / 1024)
                $usedMb = $totalMb - $freeMb
                return "📟 🧠 ${usedMb}M/${totalMb}M │ "
            }
        }
    } catch {}
    return ""
}

function Get-BatteryInfo {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
            if ($bat -and $bat.EstimatedChargeRemaining) {
                return "🔋$($bat.EstimatedChargeRemaining)% │ "
            }
        }
    } catch {}
    return ""
}

function prompt {
    $folder = Split-Path -Leaf $PWD
    if (-not $folder) { $folder = "\" }

    # Folder Emoji Selection
    $emoji = "🚀"
    switch -wildcard ($folder.ToLower()) {
        "*web*"  { $emoji = "🌐" }
        "*node*" { $emoji = "🟢" }
        "*bun*"  { $emoji = "🥐" }
        "*py*"   { $emoji = "🐍" }
        "*proj*" { $emoji = "💻" }
        default  {
            $emojis = @("🔥", "⚡️", "🚀", "💫", "🌈", "🌀", "✨", "🧠")
            $emoji = $emojis[(Get-Random -Maximum $emojis.Length)]
        }
    }

    # Dynamic Rainbow Colors
    $rainbowColors = @("Red", "Green", "Yellow", "Blue", "Magenta", "Cyan")
    $randColor = $rainbowColors[(Get-Random -Maximum $rainbowColors.Length)]

    # Information Elements
    $gitInfo  = Get-GitBranch
    $nodeInfo = Get-NodeVersion
    $bunInfo  = Get-BunVersion
    $sysInfo  = Get-SystemInfo
    $batInfo  = Get-BatteryInfo

    Write-Host ""
    Write-Host "$emoji $folder" -NoNewline -ForegroundColor $randColor
    if ($gitInfo) {
        Write-Host $gitInfo -NoNewline -ForegroundColor Cyan
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
# 📂 NAVIGATION & MOVEMENT
# ==============================================================================

function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function rd   { Set-Location \ }

# Folder Shortcuts
function dev { Set-Location "$HOME\Development" -ErrorAction SilentlyContinue }
function doc { Set-Location "$HOME\Documents" -ErrorAction SilentlyContinue }
function dow { Set-Location "$HOME\Downloads" -ErrorAction SilentlyContinue }
function des { Set-Location "$HOME\Desktop" -ErrorAction SilentlyContinue }
function pic { Set-Location "$HOME\Pictures" -ErrorAction SilentlyContinue }
function vid { Set-Location "$HOME\Videos" -ErrorAction SilentlyContinue }
function mus { Set-Location "$HOME\Music" -ErrorAction SilentlyContinue }

function ar  { Set-Location "$HOME\Developer\archive" -ErrorAction SilentlyContinue }
function ba  { Set-Location "$HOME\Developer\backend" -ErrorAction SilentlyContinue }
function de  { Set-Location "$HOME\Developer\dev" -ErrorAction SilentlyContinue }
function fig { Set-Location "$HOME\Developer\Figma" -ErrorAction SilentlyContinue }
function fr  { Set-Location "$HOME\Developer\frontend" -ErrorAction SilentlyContinue }
function fu  { Set-Location "$HOME\Developer\fullstack" -ErrorAction SilentlyContinue }

function drive {
    param([string]$Letter = "C")
    $drv = "${Letter}:\"
    if (Test-Path $drv) {
        Set-Location $drv
        Write-Host "📂 Switched to drive: $drv" -ForegroundColor Green
    } else {
        Write-Host "❌ Drive '$drv' not found." -ForegroundColor Red
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

# ==============================================================================
# ⚡ INTERACTIVE SETUP WIZARDS (FRAMEWORKS & PROJECT INITIALIZERS)
# ==============================================================================

# --- Initialize a Project (Bun, NPM, PNPM, Yarn) ---
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

# --- Next.js Setup ---
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

# --- Vite Setup ---
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
        Write-Host "⚠️ Remember to add import tailwindcss from '@tailwindcss/vite' to vite.config.ts" -ForegroundColor Yellow
    }
}

# --- Shadcn UI Setup ---
function ui {
    Write-Host "🎨 Setup Shadcn UI with:`n1) 🥐 Bun`n2) 📦 NPM`n3) 🟡 PNPM`n4) 🧶 Yarn" -ForegroundColor Cyan
    $c = Read-Host "Choice [1-4]"
    $components = Read-Host "Add specific components? (e.g. button card input dialog)"

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
    Write-Host "✅ Shadcn UI setup complete!" -ForegroundColor Green
}

# --- Tailwind CSS Setup ---
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

# --- Express.js Setup ---
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

# --- Additional Backend & Frontend Wizards ---
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
    printf("Hello, World! Welcome to C project: %s\n", "$Name");
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

# --- Todo Manager ---
function todo {
    param([string]$action, [string]$arg1)

    $todoFile = Join-Path $HOME ".todo_list.txt"
    if (-not (Test-Path $todoFile)) { New-Item -ItemType File -Path $todoFile -Force | Out-Null }

    function Show-TodoList {
        $tasks = Get-Content $todoFile -ErrorAction SilentlyContinue | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
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
                    Show-TodoList
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
            Show-TodoList
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

# --- Notes Manager ---
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

# --- FFmpeg Multimedia Suite ---
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

# --- Interactive Git Commit & Push ---
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

# --- Interactive TS/JS File Runner ---
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

# --- Video Launcher & Finder ---
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

# --- Universal Extractor ---
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

# --- Fast File Finder ---
function ff {
    param([string]$Name)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd --hidden --exclude .git --exclude node_modules $Name
    } else {
        Get-ChildItem -Path . -Recurse -Filter "*$Name*" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' } |
            Select-Object FullName
    }
}

# --- Secret Generator ---
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

# --- Backup Helper ---
function bak {
    param([string]$File)
    if (Test-Path $File) {
        Copy-Item -Path $File -Destination "$File.bak" -Recurse
        Write-Host "✅ Created: $File.bak" -ForegroundColor Green
    } else {
        Write-Host "❌ File or folder not found." -ForegroundColor Red
    }
}

# --- Safe Trash Mover ---
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

# --- Kill Process by TCP Port ---
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

# --- Directory & File Management Helpers ---
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

function to { code . }
function profile { code $PROFILE }
function rel { . $PROFILE; Write-Host "✅ PowerShell profile reloaded successfully!" -ForegroundColor Green }
function serve { param([int]$Port = 8000); python -m http.server $Port }
function myip { Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" } | Select-Object IPAddress, InterfaceAlias }
function ports { Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess }
function ss { Get-NetTCPConnection }

# --- Database / PostgreSQL Helpers ---
function pgstart   { Start-Service postgresql -ErrorAction SilentlyContinue }
function pgstop    { Stop-Service postgresql -ErrorAction SilentlyContinue }
function pgrestart { Restart-Service postgresql -ErrorAction SilentlyContinue }
function pgstatus  { Get-Service postgresql -ErrorAction SilentlyContinue }
function pgl       { psql -U postgres $args }
function pgls      { psql -U postgres -c "\l" }
function pgtables  { psql -U postgres -c "\dt" }
function pgcreate  { createdb -U postgres $args }
function pgdrop    { dropdb -U postgres $args }
function pgconn    { psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;" }
function pgdb      { param([string]$db); psql -U postgres -d $db }
function pgdisable { Set-Service postgresql -StartupType Disabled; Write-Host "🚫 PostgreSQL auto-start disabled." -ForegroundColor Yellow }
function pgdump    { param([string]$db, [string]$out); pg_dump -U postgres $db > $out }
function pgenable  { Set-Service postgresql -StartupType Automatic; Write-Host "✅ PostgreSQL auto-start enabled." -ForegroundColor Green }
function pglogs    { Get-Content "C:\Program Files\PostgreSQL\*\data\log\*.log" -Tail 50 -Wait }
function pgrestore { param([string]$db, [string]$file); Get-Content $file | psql -U postgres -d $db }
function pgsize    { psql -U postgres -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;" }
function pgusers   { psql -U postgres -c "\du" }
function pgver     { psql -U postgres -c "SELECT version();" }

# --- Interactive Git Branch Switcher ---
function gbranch {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Git is not installed." -ForegroundColor Red; return 1
    }
    $branches = git branch --all 2>$null | Where-Object { $_ -notmatch 'HEAD' } | ForEach-Object { $_.Trim(' *') }
    if (-not $branches) { Write-Host "❌ No branches found." -ForegroundColor Yellow; return }

    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzf) {
        $sel = $branches | & $fzf.Source --prompt="Select Branch: " --height 40% --reverse
    } else {
        Write-Host "🌿 Branches:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $branches.Count; $i++) {
            Write-Host ("  [{0,2}] {1}" -f ($i + 1), $branches[$i])
        }
        $c = Read-Host "Select branch number"
        if ($c -match '^\d+$' -and [int]$c -gt 0 -and [int]$c -le $branches.Count) {
            $sel = $branches[[int]$c - 1]
        }
    }

    if ($sel) {
        $cleanBranch = $sel -replace 'remotes/origin/', ''
        git checkout $cleanBranch
    }
}

# --- Interactive Process Killer ---
function fkill {
    $procs = Get-Process | Select-Object Id, ProcessName
    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzf) {
        $lines = $procs | ForEach-Object { "$($_.Id)`t$($_.ProcessName)" }
        $sel = $lines | & $fzf.Source --header="Select process to kill" --height 40% --reverse
        if ($sel) {
            $pidToKill = ($sel -split "`t")[0]
            Stop-Process -Id $pidToKill -Force
            Write-Host "✅ Killed process $pidToKill" -ForegroundColor Green
        }
    } else {
        $c = Read-Host "Enter Process ID (PID) to kill"
        if ($c -match '^\d+$') {
            Stop-Process -Id $c -Force
            Write-Host "✅ Killed process $c" -ForegroundColor Green
        }
    }
}

# --- Interactive Directory Search & CD ---
function fcd {
    $dirs = Get-ChildItem -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' } |
        Select-Object -ExpandProperty FullName

    $fzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzf) {
        $sel = $dirs | & $fzf.Source --prompt="Select Directory: " --height 40% --reverse
        if ($sel) { Set-Location $sel }
    } else {
        for ($i = 0; $i -lt [math]::Min(20, $dirs.Count); $i++) {
            Write-Host ("  [{0,2}] {1}" -f ($i + 1), $dirs[$i])
        }
        $c = Read-Host "Select directory number"
        if ($c -match '^\d+$' -and [int]$c -gt 0 -and [int]$c -le $dirs.Count) {
            Set-Location $dirs[[int]$c - 1]
        }
    }
}

# --- File Renamer & Normalizer ---
function rn {
    param([string]$TargetDir = ".")
    if (-not (Test-Path $TargetDir)) { Write-Host "❌ Directory '$TargetDir' not found." -ForegroundColor Red; return 1 }

    Write-Host "🧹 Normalizing filenames in '$TargetDir'..." -ForegroundColor Cyan
    Get-ChildItem -Path $TargetDir -File | ForEach-Object {
        $baseName = $_.BaseName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9_-]', ''
        $ext = $_.Extension.ToLower()
        $newName = "$baseName$ext"
        if ($_.Name -ne $newName) {
            $destPath = Join-Path $_.DirectoryName $newName
            if (-not (Test-Path $destPath)) {
                Rename-Item -Path $_.FullName -NewName $newName
                Write-Host "Renamed: '$($_.Name)' -> '$newName'" -ForegroundColor Green
            }
        }
    }
    Write-Host "Done!" -ForegroundColor Green
}

# --- Runtime Tool Installer Wizard ---
function rt {
    Write-Host "`n🚀 Runtime Tool Installer:" -ForegroundColor Cyan
    Write-Host "  1) 🟢 Node.js (via NVM/Winget)"
    Write-Host "  2) 🥐 Bun (Fast JS Runtime)"
    Write-Host "  3) 🦕 Deno (Secure JS Runtime)"
    Write-Host "  4) 🐍 Python (Standard)"

    $c = Read-Host "Select tool to install [1-4]"
    switch ($c) {
        '1' { if (Get-Command winget -ErrorAction SilentlyContinue) { winget install OpenJS.NodeJS.LTS } else { Write-Host "❌ Winget not found." -ForegroundColor Red } }
        '2' { powershell -c "irm bun.sh/install.ps1 | iex" }
        '3' { powershell -c "irm https://deno.land/install.ps1 | iex" }
        '4' { if (Get-Command winget -ErrorAction SilentlyContinue) { winget install Python.Python.3.12 } }
        default { Write-Host "❌ Cancelled." -ForegroundColor Red }
    }
}

# --- Docker Advanced Utility Functions ---
function dfind { param([string]$Query); docker ps | Select-String $Query; docker images | Select-String $Query }
function droot { param([string]$Container); docker exec -it -u root $Container powershell || docker exec -it -u root $Container bash || docker exec -it -u root $Container sh }
function dip   { param([string]$Container); docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container }
function dwatch{ param([string]$Container); Write-Host "Watching diff in $Container..."; while($true) { Clear-Host; docker diff $Container; Start-Sleep -Seconds 2 } }
function dnetstat { param([string]$Container); docker exec -it $Container netstat -tulan 2>$null || docker exec -it $Container ss -tulan }
function dtop-proc { param([string]$Container); docker top $Container aux }
function dbackup { param([string]$Volume, [string]$OutFile); docker run --rm -v "${Volume}:/volume" -v "${PWD}:/backup" alpine tar cvf /backup/$OutFile -C /volume . }
function dkill-force {
    Write-Host "⚠️ WARNING: Stopping and removing ALL containers..." -ForegroundColor Red
    $c = Read-Host "Confirm [y/N]"
    if ($c -eq "y") {
        docker stop $(docker ps -q) 2>$null
        docker rm $(docker ps -a -q) 2>$null
        Write-Host "✅ All containers cleared." -ForegroundColor Green
    }
}

# --- Web & Application Shortcuts ---
function brave { Start-Process "brave" $args -ErrorAction SilentlyContinue || Start-Process "https://google.com" }
function youtube { Start-Process "https://youtube.com" }
function ch { Start-Process "chrome" $args -ErrorAction SilentlyContinue || Start-Process "https://google.com" }
function vi { if (Get-Command code -ErrorAction SilentlyContinue) { code $args } else { notepad $args } }
function vlc { Start-Process "vlc" $args -ErrorAction SilentlyContinue }

# --- Dev Walk Directory Navigator ---
function cf {
    param([string]$target_dir = ".")

    $search_cmd = "Get-ChildItem -Path '$target_dir' -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { `$_.FullName -notmatch '\\.git\\' -and `$_.FullName -notmatch '\\node_modules\\' } | Select-Object -ExpandProperty FullName"

    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $search_cmd = "fd --type d --hidden --exclude .git --exclude node_modules . '$target_dir'"
    }

    $previewCmd = "powershell -NoProfile -Command `" " +
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

    $fzfExe = (Get-Command fzf -ErrorAction SilentlyContinue)?.Source
    if (-not $fzfExe) {
        Write-Host "❌ fzf is not installed." -ForegroundColor Red
        return
    }

    $selected = Invoke-Expression $search_cmd | & $fzfExe `
        --height 90% `
        --layout=reverse `
        --border=rounded `
        --prompt="⚡ Dev Walk: " `
        --pointer="❯" `
        --marker="✔" `
        --header="[ENTER] Cd | [CTRL-O] VS Code | [CTRL-Y] Copy Path" `
        --header-first `
        --bind "ctrl-y:execute-silent(powershell -NoProfile -Command `"Set-Clipboard -Value '{}'`")+change-prompt(📋 Copied! > )" `
        --bind "ctrl-o:execute(code {} || nvim {})+abort" `
        --preview $previewCmd `
        --preview-window=right:50%:wrap

    if (-not [string]::IsNullOrWhiteSpace($selected)) {
        Set-Location $selected
    }
}

# --- Universal Package Remover ---
function uu {
    Write-Host "`n📦 Universal Package Remover:" -ForegroundColor Cyan
    Write-Host "  1) 📦 NPM Global Package"
    Write-Host "  2) 🥐 Bun Package"
    Write-Host "  3) 🟡 PNPM Package"
    Write-Host "  4) 🧶 Yarn Package"
    Write-Host "  5) 🪟 Winget Package"
    Write-Host "  6) 🍫 Chocolatey Package"
    Write-Host "  7) 🥄 Scoop Package"

    $choice = Read-Host "Select ecosystem [1-7]"
    $pkg = Read-Host "Enter package name to remove"
    if ([string]::IsNullOrWhiteSpace($pkg)) { Write-Host "❌ Cancelled." -ForegroundColor Red; return }

    switch ($choice) {
        '1' { npm uninstall -g $pkg }
        '2' { bun remove $pkg }
        '3' { pnpm remove $pkg }
        '4' { yarn remove $pkg }
        '5' { winget uninstall $pkg }
        '6' { choco uninstall $pkg -y }
        '7' { scoop uninstall $pkg }
        default { Write-Host "❌ Invalid choice." -ForegroundColor Red }
    }
}

# --- Universal Deep System Cleaner ---
function uc {
    Write-Host "🧹 Universal System Cleaner..." -ForegroundColor Red
    @("$env:TEMP", "$env:LOCALAPPDATA\Temp", "C:\Windows\Temp") | ForEach-Object {
        if (Test-Path $_) {
            Get-ChildItem -Path $_ -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    try { Clear-RecycleBin -Force -ErrorAction Stop } catch {}
    ipconfig /flushdns | Out-Null
    Write-Host "✅ Deep System Clean Complete!" -ForegroundColor Green
}

function update {
    Write-Host "🔄 Updating system packages..." -ForegroundColor Cyan
    if (Get-Command winget -ErrorAction SilentlyContinue) { winget upgrade --all }
    if (Get-Command choco -ErrorAction SilentlyContinue)  { choco upgrade all -y }
    if (Get-Command scoop -ErrorAction SilentlyContinue)  { scoop update; scoop update * }
}

# --- Universal System Updater & Maintenance Cleaner Engine ---
function uup {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "❌ Run PowerShell as Administrator to use uup!" -ForegroundColor Red
        return
    }

    $hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
    $hasChoco  = $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
    $hasScoop  = $null -ne (Get-Command scoop -ErrorAction SilentlyContinue)

    $fzfExe = (Get-Command fzf -ErrorAction SilentlyContinue)?.Source
    if (-not $fzfExe) {
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

    if (-not $fzfExe) {
        Write-Host "🔍 fzf not found. Installing via Winget..." -ForegroundColor Yellow
        if ($hasWinget) {
            winget install --id junegunn.fzf -e --accept-source-agreements --accept-package-agreements
            $fzfExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf*\fzf.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
        }
    }

    Clear-Host
    Write-Host "  User: $($env:USERNAME) | OS: Windows" -ForegroundColor Cyan
    Write-Host "  Winget: $(if($hasWinget){'✅'}else{'❌'}) | Choco: $(if($hasChoco){'✅'}else{'❌'}) | Scoop: $(if($hasScoop){'✅'}else{'❌'})" -ForegroundColor Cyan
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

    if ($fzfExe) {
        $SELECTED_TASKS = $tasks | & $fzfExe --ansi --multi --height=18 --layout=reverse --border=rounded `
            --prompt="⚡ Action: " --header="[TAB] Select | [ENTER] Execute" `
            --color='bg+:#292e42,hl:#bb9af7,prompt:#7dcfff,pointer:#f7768e,marker:#9ece6a'
    } else {
        Write-Host "Available Tasks:" -ForegroundColor Yellow
        $tasks | ForEach-Object { Write-Host "  $_" }
        $SELECTED_TASKS = Read-Host "Enter task numbers (comma separated, or 0 for all)"
    }

    if ([string]::IsNullOrWhiteSpace($SELECTED_TASKS)) {
        Write-Host "❌ No tasks selected." -ForegroundColor Red
        return
    }

    $selectedArray = @($SELECTED_TASKS -split "`n|,| " | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    if ($selectedArray -contains "0. ALL_MAINTENANCE_TASKS" -or $selectedArray -contains "0") {
        $selectedArray = $tasks
    }

    # 1. Winget
    if ($selectedArray -match "1") {
        Write-Host "`n📦 [1/7] Winget Packages..." -ForegroundColor Blue
        if ($hasWinget) { winget upgrade --all --accept-source-agreements --accept-package-agreements }
    }

    # 2. Chocolatey
    if ($selectedArray -match "2") {
        Write-Host "`n🍫 [2/7] Chocolatey..." -ForegroundColor Cyan
        if ($hasChoco) { choco upgrade all -y }
    }

    # 3. Scoop
    if ($selectedArray -match "3") {
        Write-Host "`n🥄 [3/7] Scoop..." -ForegroundColor Magenta
        if ($hasScoop) { scoop update; scoop update * }
    }

    # 4. Bun
    if ($selectedArray -match "4") {
        Write-Host "`n🥬 [4/7] Bun..." -ForegroundColor Cyan
        if (Get-Command bun -ErrorAction SilentlyContinue) { bun upgrade }
    }

    # 5. Node.js
    if ($selectedArray -match "5") {
        Write-Host "`n🟢 [5/7] Node.js LTS..." -ForegroundColor Green
        $nvmPath = "$env:NVM_HOME\nvm.exe"
        if (-not (Test-Path $nvmPath)) { $nvmPath = "$env:APPDATA\nvm\nvm.exe" }
        if (Test-Path $nvmPath) { & $nvmPath install lts; & $nvmPath use lts }
    }

    # 6. Global NPM
    if ($selectedArray -match "6") {
        Write-Host "`n✨ [6/7] NPM..." -ForegroundColor Yellow
        if (Get-Command npm -ErrorAction SilentlyContinue) { npm install -g npm@latest }
    }

    # 7. Deep System Clean
    if ($selectedArray -match "7") {
        uc
        Write-Host "  🧽 Windows Update Cache..." -ForegroundColor Cyan
        $wuauserv = Get-Service wuauserv -ErrorAction SilentlyContinue
        if ($wuauserv -and $wuauserv.Status -eq 'Running') {
            Stop-Service wuauserv -Force
            Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
            Start-Service wuauserv
        }

        Write-Host "  💿 Component Cleanup (DISM)..." -ForegroundColor Cyan
        Dism /Online /Cleanup-Image /StartComponentCleanup
    }

    Write-Host "`n✅ MAINTENANCE COMPLETED!" -ForegroundColor Green
}

# --- CLI Tool Wrappers ---
function bat {
    if (Get-Command bat -ErrorAction SilentlyContinue) { command bat $args }
    elseif (Get-Command batcat -ErrorAction SilentlyContinue) { command batcat $args }
    else { Get-Content $args }
}

function eza {
    if (Get-Command eza -ErrorAction SilentlyContinue) { command eza $args }
    else { Get-ChildItem $args }
}

function z {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        zoxide $args
    } else {
        Set-Location $args
    }
}

function tree {
    if (Get-Command eza -ErrorAction SilentlyContinue) { eza --tree $args }
    elseif (Get-Command tree.com -ErrorAction SilentlyContinue) { tree.com $args }
    else { Get-ChildItem -Recurse $args }
}

function tldr {
    if (Get-Command tldr -ErrorAction SilentlyContinue) { command tldr $args }
    else { Write-Host "❌ tldr is not installed." -ForegroundColor Red }
}

# ==============================================================================
# 📦 DEV STACK ALIASES (NPM, BUN, PNPM, YARN, GIT, DOCKER, PRISMA)
# ==============================================================================

# --- Builtin Alias Overrides ---
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name h -Value Get-History
Set-Alias -Name gcommit -Value gwip
Set-Alias -Name ps1rc -Value profile

# --- FFmedia Aliases ---
Set-Alias -Name ffstudio -Value ffmedia
Set-Alias -Name fftool -Value ffmedia
Set-Alias -Name fancy_ffmpeg -Value ffmedia

# --- Navigation Shortcuts ---
function ll { Get-ChildItem $args }
function la { Get-ChildItem -Force $args }
function ls { Get-ChildItem $args }

# --- NPM Shortcuts ---
function ni  { npm install $args }
function nid { npm install -D $args }
function nr  { npm run $args }
function nrd { npm run dev }
function nrb { npm run build }
function nrs { npm run start }
function nu  { npm uninstall $args }
function nup { npm update $args }
function nls { npm list --depth=0 }
function ncl { npm cache clean --force }

# --- Bun Shortcuts ---
function bi   { bun install $args }
function br   { bun run $args }
function brd  { bun run dev }
function brb  { bun run build }
function brs  { bun run start }
function bx   { bunx $args }
function bu   { bun remove $args }
function html { bun run index.html }
function w    { bun --watch $args }
function h    { bun --hot $args }

# --- PNPM Shortcuts ---
function pi  { pnpm install $args }
function px  { pnpm exec $args }
function prd { pnpm run dev }
function prb { pnpm run build }
function prs { pnpm run start }

# --- Yarn Shortcuts ---
function yi  { yarn install $args }
function yx  { yarn exec $args }
function yrd { yarn dev }
function yrb { yarn build }

# --- Git Shortcuts ---
function gi   { git init }
function gs   { git status -sb }
function ga   { git add . }
function gcm  { git commit -m $args }
function gp   { git push $args }
function gps  { git push $args }
function gpl  { git pull $args }
function gl   { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit }
function gco  { git checkout $args }
function gcb  { git checkout -b $args }
function gd   { git diff $args }
function gr   { git restore $args }
function grh  { git reset HEAD~1 }
function gc   { git clone $args }
function gst  { git stash }
function gsta { git stash apply }
function gpop { git stash pop }
function gfp  { git fetch --prune }
function gb   { git branch }

# --- Node/NPX Prisma ORM Shortcuts (np*) ---
function np    { npx prisma $args }
function npi   { npx prisma init $args }
function npg   { npx prisma generate $args }
function nps   { npx prisma studio $args }
function npmd  { npx prisma migrate dev $args }
function npmdn { npx prisma migrate dev --name $args }
function npmr  { npx prisma migrate reset $args }
function npmdp { npx prisma migrate deploy $args }
function npms  { npx prisma migrate status $args }
function npdp  { npx prisma db push $args }
function npdl  { npx prisma db pull $args }
function npds  { npx prisma db seed $args }
function npf   { npx prisma format }
function npv   { npx prisma version }

# --- Bun Prisma ORM Shortcuts (bp*) ---
function bp    { bunx prisma $args }
function bpi   { bunx prisma init $args }
function bpg   { bunx prisma generate $args }
function bps   { bunx prisma studio $args }
function bpmd  { bunx prisma migrate dev $args }
function bpmdn { bunx prisma migrate dev --name $args }
function bpmr  { bunx prisma migrate reset $args }
function bpmdp { bunx prisma migrate deploy $args }
function bpms  { bunx prisma migrate status $args }
function bpdp  { bunx prisma db push $args }
function bpdl  { bunx prisma db pull $args }
function bpds  { bunx prisma db seed $args }
function bpf   { bunx prisma format }
function bpv   { bunx prisma version }

# --- General Prisma Shortcuts ---
function pm    { npx prisma $args }
function pmini { npx prisma init $args }
function pmg   { npx prisma generate $args }
function pms   { npx prisma studio $args }
function pmd   { npx prisma migrate dev $args }
function pmdn  { npx prisma migrate dev --name $args }
function pmr   { npx prisma migrate reset $args }
function pmdp  { npx prisma migrate deploy $args }
function pmst  { npx prisma migrate status $args }
function pmp   { npx prisma db push $args }
function pml   { npx prisma db pull $args }
function pmsd  { npx prisma db seed $args }
function pmf   { npx prisma format $args }
function pmv   { npx prisma version $args }

# --- Bun Prisma Long-form Aliases (bpm*) ---
function bpm   { bunx prisma $args }
function bpmini{ bunx prisma init $args }
function bpmg  { bunx prisma generate $args }
function bpmst { bunx prisma migrate status $args }
function bpmmp { bunx prisma db push $args }
function bpml  { bunx prisma db pull $args }
function bpmsd { bunx prisma db seed $args }
function bpmf  { bunx prisma format $args }
function bpmv  { bunx prisma version $args }


# --- Docker Shortcuts ---
function d        { docker $args }
function dps      { docker ps $args }
function dpsa     { docker ps -a $args }
function di       { docker images $args }
function dpu      { docker pull $args }
function drun     { docker run $args }
function dex      { docker exec -it $args }
function dstop    { docker stop $args }
function drm      { docker rm $args }
function drmi     { docker rmi $args }
function dlog     { docker logs -f $args }
function dbuild   { docker build $args }
function dprune   { docker system prune -f }
function dvol     { docker volume ls }
function dnet     { docker network ls }
function dstopall { docker stop $(docker ps -q) }
function drmall   { docker rm $(docker ps -aq) }
function drmiall  { docker rmi $(docker images -q) }

function dbuild-nocache { docker build --no-cache $args }
function dcdn           { docker compose down $args }
function dclogs         { docker compose logs -f $args }
function dcup           { docker compose up -d $args }
function dcupb          { docker compose up -d --build $args }
function ddisable       { Set-Service docker -StartupType Disabled }
function denable        { Set-Service docker -StartupType Automatic }
function dhist          { docker history $args }
function dkill          { docker rm -f $args }
function dlogs          { docker logs -f $args }
function dnl            { docker network ls }
function doff           { Stop-Service docker }
function dports         { docker port $args }
function drestart       { docker restart $args }
function dsh            { docker exec -it $args }
function dsize          { docker system df }
function dstart         { Start-Service docker }
function dstatus        { Get-Service docker }
function dtest-alpine   { docker run --rm -it alpine:latest sh }
function dtest-node     { docker run --rm -it node:alpine sh }
function dtest-ubuntu   { docker run --rm -it ubuntu:latest bash }
function dtop           { docker stats }
function dvl            { docker volume ls }

function sdps           { docker ps $args }
function sdpsa          { docker ps -a $args }
function sdi            { docker images $args }
function sdvl           { docker volume ls }
function sdnl           { docker network ls }
function sdsize         { docker system df }
function sdtop          { docker stats }

# --- Docker Compose Shortcuts ---
function dc       { docker compose $args }
function dcu      { docker compose up $args }
function dcud     { docker compose up -d $args }
function dcd      { docker compose down $args }
function dcb      { docker compose build $args }
function dcr      { docker compose restart $args }
function dcl      { docker compose logs -f $args }
function dcs      { docker compose stop $args }
function dcps     { docker compose ps $args }
function dcpull   { docker compose pull }
function dcexec   { docker compose exec $args }

# ==============================================================================
# 🆘 HELP DASHBOARD (`keep`)
# ==============================================================================

function keep {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🚀  MASTER COMMAND CENTER           Developer Rihad's Ultimate PowerShell║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "  v2.0 Complete Edition • Modern Terminal UX • $(Get-Date -Format 'MMMM dd, yyyy')" -ForegroundColor Gray
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
    PrintCmd "dev / doc / dow" "Go to ~/Development, ~/Documents, ~/Downloads" "" "Green"
    PrintCmd "des / pic / vid" "Go to ~/Desktop, ~/Pictures, ~/Videos" "" "Green"
    PrintCmd "ar / ba / de" "Go to ~/Developer/archive, /backend, /dev" "" "Cyan"
    PrintCmd "fig / fr / fu" "Go to ~/Developer/Figma, /frontend, /fullstack" "" "Cyan"
    PrintCmd "drive <letter>" "Switch drive location (e.g. drive C, drive D)" "" "Yellow"
    Write-Host ""

    # PACKAGE MANAGERS
    PrintCategory "📦" "PACKAGE MANAGERS (NPM & BUN)" "Green"
    PrintCmd "ni / bi" "install dependencies (npm / bun)" "" "Green"
    PrintCmd "nid / bi -d" "install dev dependency" "" "Green"
    PrintCmd "nrd / brd" "run dev server" "" "Yellow"
    PrintCmd "nrb / brb" "run build script" "" "Yellow"
    PrintCmd "nrs / brs" "run start script" "" "Yellow"
    PrintCmd "uu" "Universal package remover" "" "Red"
    Write-Host ""

    # PRODUCTIVITY SUITES
    PrintCategory "📝" "PRODUCTIVITY & SUITES (TODO, NOTES, FFMEDIA)" "Magenta"
    PrintCmd "todo" "Interactive Todo Task Manager" "todo | todo add | todo done" "Green"
    PrintCmd "notes" "Fuzzy Notes Manager with preview" "notes | notes add | notes search" "Magenta"
    PrintCmd "ffmedia" "FFmpeg All-in-One Multimedia Suite" "ffmedia | ffstudio | fftool" "Cyan"
    Write-Host ""

    # FRAMEWORK INITIALIZERS
    PrintCategory "⚡" "FRAMEWORK & PROJECT WIZARDS" "DarkYellow"
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

    # GIT VERSION CONTROL
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
    PrintCmd "gd / gr / grh" "Diff / Restore / Reset HEAD~1" "" "DarkYellow"
    Write-Host ""

    # DOCKER & PRISMA
    PrintCategory "🐳" "DOCKER & PRISMA ORM" "Blue"
    PrintCmd "d / dc" "docker / docker compose wrapper" "" "Blue"
    PrintCmd "dps / di / drun" "ps / images / run container" "" "Cyan"
    PrintCmd "dcu / dcd / dcl" "compose up / down / logs" "" "Green"
    PrintCmd "dfind / droot" "search containers / root shell" "" "Yellow"
    PrintCmd "np* / bp*" "Prisma ORM via NPX or Bun" "npd (migrate dev)" "Yellow"
    Write-Host ""

    # UTILITIES & SYSTEM MAINTENANCE
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

    # FOOTER
    Write-Host "  ┌─────────────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
    Write-Host "  │ ✨ PRO TIPS:                                                        │" -ForegroundColor Magenta
    Write-Host "  │   • Use Tab for command auto-completion                             │" -ForegroundColor Magenta
    Write-Host "  │   • Prompt shows: Git branch │ Folder emoji │ Memory & Battery      │" -ForegroundColor Magenta
    Write-Host "  │   • Type 'keep' anytime to view this help dashboard                 │" -ForegroundColor Magenta
    Write-Host "  └─────────────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
    Write-Host ""
}

# ==============================================================================
# End of config.ps1
# ==============================================================================
