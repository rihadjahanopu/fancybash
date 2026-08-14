# ==============================================================================
#   F A N C Y B A S H  •  PowerShell Config Uninstaller (uninstall.ps1)
#   Author: [Rihad Jahan Opu]
#   Supports: Windows PowerShell 5.1+, PowerShell Core 7+
#
#   ── One-liner (runs directly, no download needed): ───────────────────────
#   powershell -c "irm https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main/uninstall.ps1 | iex"
#
# ==============================================================================

# ─── GUARD 1: PowerShell Version Check ────────────────────────────────────────
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "❌ PowerShell 5.1 or higher is required." -ForegroundColor Red
    Write-Host "   Please update: https://aka.ms/wmf5download" -ForegroundColor Yellow
    exit 1
}

# ─── GUARD 2: Self-Bypass (only when run as a file, not via irm | iex) ────────
$_scriptPath = $MyInvocation.MyCommand.Path
$currentPolicy = Get-ExecutionPolicy -Scope Process
if ($_scriptPath -and ($currentPolicy -eq 'Restricted' -or $currentPolicy -eq 'AllSigned')) {
    Write-Host "⚠️  ExecutionPolicy blocks this script. Re-launching with Bypass..." -ForegroundColor Yellow
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $_scriptPath @args
    } else {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $_scriptPath @args
    }
    exit
}

$ErrorActionPreference = "Continue"

# ─── Markers (must match install.ps1) ─────────────────────────────────────────
$START = "# >>> fancy-powershell >>>"
$END   = "# <<< fancy-powershell <<<"

# ─── GUARD 3: $PROFILE Sanity Check ──────────────────────────────────────────
if (-not $PROFILE) {
    Write-Host "❌ `$PROFILE variable is not set. Are you in a valid PowerShell session?" -ForegroundColor Red
    exit 1
}
$PROFILE_PATH = $PROFILE

# ─── Colors & Formatting ──────────────────────────────────────────────────────
$ESC  = [char]27
$RED  = "$ESC[1;31m"; $GRN  = "$ESC[1;32m"; $YLW  = "$ESC[1;33m"
$BLU  = "$ESC[1;34m"; $PUR  = "$ESC[1;35m"; $CYN  = "$ESC[1;36m"
$BOLD = "$ESC[1m";    $DIM  = "$ESC[2m";    $NC   = "$ESC[0m"

# ─── Helper: Progress Bar ─────────────────────────────────────────────────────
function Show-ProgressBar {
    param([int]$Current, [int]$Total = 4, [string]$StepName = "")
    $width = 30
    $pct   = [math]::Round(($Current / $Total) * 100)
    $done  = [math]::Round(($width * $Current) / $Total)
    $bar   = "█" * $done + "░" * ($width - $done)
    Write-Host ""
    Write-Host ("${BLU}Progress:${NC} [${RED}$bar${NC}] ${CYN}${pct}%${NC}  Step $Current/$Total — $StepName")
}

# ─── Header Banner ────────────────────────────────────────────────────────────
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "${PUR}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗${NC}"
    Write-Host "${PUR}          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║${NC}"
    Write-Host "${CYN}          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║${NC}"
    Write-Host "${CYN}          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║${NC}"
    Write-Host "${BLU}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║${NC}"
    Write-Host "${BLU}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
    Write-Host ""
    Write-Host "   🗑️  ${BOLD}${RED}F A N C Y B A S H${NC}  •  ${BOLD}PowerShell Environment Uninstaller${NC}"
    Write-Host ""
}

# ─── System Info Card ─────────────────────────────────────────────────────────
function Show-SysInfo {
    $osName = if ($PSVersionTable.OS) { $PSVersionTable.OS } else { "Windows ($env:OS)" }
    Write-Host "${RED}──────────────────────────────────────────────────${NC}"
    Write-Host " 🖥️  ${BOLD}SYSTEM INFORMATION${NC}"
    Write-Host "${RED}──────────────────────────────────────────────────${NC}"
    Write-Host "  💻  ${BOLD}OS:${NC}      ${CYN}$osName${NC}"
    Write-Host "  👤  ${BOLD}User:${NC}    ${CYN}$env:USERNAME${NC}"
    Write-Host "  🐚  ${BOLD}Shell:${NC}   ${CYN}PowerShell v$($PSVersionTable.PSVersion)${NC}"
    Write-Host "  📄  ${BOLD}Profile:${NC} ${CYN}$PROFILE_PATH${NC}"
    Write-Host "${RED}──────────────────────────────────────────────────${NC}`n"
}

# ══════════════════════════════════════════════════════════════════════════════
#   MAIN UNINSTALLER
# ══════════════════════════════════════════════════════════════════════════════
Show-Header
Show-SysInfo

# ─── STEP 1: Check if fancybash is installed ──────────────────────────────────
Show-ProgressBar -Current 1 -Total 4 -StepName "Detecting Installation"

if (-not (Test-Path $PROFILE_PATH)) {
    Write-Host "  ${YLW}ℹ️  No `$PROFILE file found at: $PROFILE_PATH${NC}"
    Write-Host "  ${GRN}✔ Nothing to uninstall.${NC}"
    exit 0
}

$profileContent = Get-Content $PROFILE_PATH -Raw -ErrorAction SilentlyContinue

if (-not $profileContent -or -not $profileContent.Contains($START)) {
    Write-Host "  ${YLW}ℹ️  No fancybash block found in `$PROFILE.${NC}"
    Write-Host "  ${GRN}✔ Profile is already clean — nothing to do.${NC}"
    exit 0
}

Write-Host "  ${GRN}✔ fancybash installation detected in `$PROFILE.${NC}"

# ─── STEP 2: Backup existing profile ──────────────────────────────────────────
Show-ProgressBar -Current 2 -Total 4 -StepName "Backing Up Profile"

$backupFile = ""
try {
    $backupFile = "$PROFILE_PATH.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $PROFILE_PATH $backupFile -Force -ErrorAction Stop
    Write-Host "  ${GRN}💾 Backup saved: ${CYN}$(Split-Path $backupFile -Leaf)${NC}"
} catch {
    Write-Host "  ${YLW}⚠️  Backup failed: $($_.Exception.Message)${NC}"
    Write-Host "  ${YLW}   Continuing without backup...${NC}"
    $backupFile = ""
}

# ─── STEP 3: Remove fancybash block ───────────────────────────────────────────
Show-ProgressBar -Current 3 -Total 4 -StepName "Removing fancybash Block"

try {
    $regex = "(?s)\r?\n?" + [regex]::Escape($START) + ".*?" + [regex]::Escape($END)
    $cleaned = [regex]::Replace($profileContent, $regex, "")

    # Trim trailing blank lines left behind
    $cleaned = $cleaned.TrimEnd() + "`n"

    $cleaned | Out-File $PROFILE_PATH -Encoding utf8 -NoNewline -ErrorAction Stop
    Write-Host "  ${GRN}✅ fancybash block cleanly removed from `$PROFILE.${NC}"
} catch {
    Write-Host "  ${RED}❌ Failed to modify profile: $($_.Exception.Message)${NC}"
    if ($backupFile -and (Test-Path $backupFile)) {
        Copy-Item $backupFile $PROFILE_PATH -Force
        Write-Host "  ${YLW}↩️  Restored from backup.${NC}"
    }
    exit 1
}

# ─── STEP 4: Reload profile ───────────────────────────────────────────────────
Show-ProgressBar -Current 4 -Total 4 -StepName "Reloading Shell"

Write-Host "  ${BLU}🔄 Reloading shell profile...${NC}"
try {
    . $PROFILE_PATH
    Write-Host "  ${GRN}✨ Profile reloaded — fancybash aliases are now gone.${NC}"
} catch {
    Write-Host "  ${YLW}⚠️  Auto-reload skipped (some changes need a new window).${NC}"
    Write-Host "     Run manually: ${CYN}. `$PROFILE${NC}"
}

# ─── Final Summary ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
Write-Host "   🗑️  ${BOLD}UNINSTALLATION COMPLETE!${NC}"
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
if ($backupFile) {
    Write-Host "  📦  ${BOLD}Backup:${NC}   ${GRN}$(Split-Path $backupFile -Leaf)${NC}"
}
Write-Host "  📄  ${BOLD}Profile:${NC}  ${CYN}$PROFILE_PATH${NC}"
Write-Host "  🔄  ${BOLD}Reload:${NC}   ${PUR}. `$PROFILE${NC}  ${DIM}(or open a new window)${NC}"
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
Write-Host "  👋  ${BOLD}fancybash has been removed. Thanks for trying it!${NC}"
Write-Host ""
