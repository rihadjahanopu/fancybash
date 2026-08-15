# ==============================================================================
#   F A N C Y B A S H  •  PowerShell Config Uninstaller (uninstall.ps1)
#   Author: [Rihad Jahan Opu]
#   Supports: Windows PowerShell 5.1+, PowerShell Core 7+
#
#   -- Run from INSIDE PowerShell terminal (recommended): ----------------------
#   irm https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main/uninstall.ps1 | iex
#
#   -- Run from CMD / Win+R Run dialog: ----------------------------------------
#   powershell -c "irm https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main/uninstall.ps1 | iex"
#
#   ⚠️  Do NOT use 'powershell -c' while already inside a PowerShell window.
#       That causes an 'Access is denied' / NativeCommandFailed error.
# ==============================================================================

#region -- GUARD 1: PowerShell Version ----------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "❌ PowerShell 5.1 or higher is required." -ForegroundColor Red
    Write-Host "   Please update: https://aka.ms/wmf5download" -ForegroundColor Yellow
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}
#endregion

#region -- GUARD 2: TLS 1.2 (required for irm on older Windows / PS 5.1) ------
try {
    [Net.ServicePointManager]::SecurityProtocol = (
        [Net.SecurityProtocolType]::Tls12 -bor
        [Net.SecurityProtocolType]::Tls11 -bor
        [Net.SecurityProtocolType]::Tls
    )
} catch { <# PS7+ handles TLS automatically - safe to ignore #> }
#endregion

#region -- GUARD 3: ExecutionPolicy Self-Bypass (file mode only) --------------
# When run via: irm ... | iex  → $MyInvocation.MyCommand.Path is empty → skip
# When run as a .ps1 file      → re-launch with Bypass to avoid policy blocks
$_scriptPath = $MyInvocation.MyCommand.Path
if ($_scriptPath) {
    $currentPolicy = Get-ExecutionPolicy -Scope Process
    if ($currentPolicy -eq 'Restricted' -or $currentPolicy -eq 'AllSigned') {
        Write-Host "⚠️  ExecutionPolicy blocks this script. Re-launching with Bypass..." -ForegroundColor Yellow
        $psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
        & $psExe -NoProfile -ExecutionPolicy Bypass -File $_scriptPath @args
        if ($MyInvocation.MyCommand.Path) { exit $LASTEXITCODE } else { return }
    }
}
#endregion

#region -- GUARD 4: $PROFILE Sanity Check ------------------------------------
if ([string]::IsNullOrWhiteSpace($PROFILE)) {
    Write-Host "❌ `$PROFILE is not set. Are you in a valid PowerShell session?" -ForegroundColor Red
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}
$PROFILE_PATH = $PROFILE
#endregion

# -- Colors & Formatting -------------------------------------------------------
$ESC  = [char]27
$RED  = "$ESC[1;31m"; $GRN  = "$ESC[1;32m"; $YLW  = "$ESC[1;33m"
$BLU  = "$ESC[1;34m"; $PUR  = "$ESC[1;35m"; $CYN  = "$ESC[1;36m"
$BOLD = "$ESC[1m";    $DIM  = "$ESC[2m";    $NC   = "$ESC[0m"

# -- Block Markers (must exactly match install.ps1) ----------------------------
$START = "# >>> fancy-powershell >>>"
$END   = "# <<< fancy-powershell <<<"

# -- Helper: Progress Bar ------------------------------------------------------
function Show-ProgressBar {
    param([int]$Current, [int]$Total = 5, [string]$StepName = "")
    $width = 30
    $pct   = [math]::Round(($Current / $Total) * 100)
    $done  = [math]::Round(($width * $Current) / $Total)
    $bar   = "█" * $done + "░" * ($width - $done)
    Write-Host ""
    Write-Host ("${BLU}Progress:${NC} [${RED}$bar${NC}] ${CYN}${pct}%${NC}  Step $Current/$Total - $StepName")
}

# -- Header Banner -------------------------------------------------------------
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "${PUR}          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗${NC}"
    Write-Host "${PUR}          ██=════╝██=══██╗████╗  ██║██=════╝╚██╗ ██=╝██=══██╗██=══██╗██=════╝██║  ██║${NC}"
    Write-Host "${CYN}          █████╗  ███████║██=██╗ ██║██║      ╚████=╝ ██████=╝███████║███████╗███████║${NC}"
    Write-Host "${CYN}          ██=══╝  ██=══██║██║╚██╗██║██║       ╚██=╝  ██=══██╗██=══██║╚════██║██=══██║${NC}"
    Write-Host "${BLU}          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████=╝██║  ██║███████║██║  ██║${NC}"
    Write-Host "${BLU}          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
    Write-Host ""
    Write-Host "   🗑️  ${BOLD}${RED}F A N C Y B A S H${NC}  •  ${BOLD}PowerShell Environment Uninstaller${NC}"
    Write-Host ""
}

# -- System Info Card ----------------------------------------------------------
function Show-SysInfo {
    $osName = if ($PSVersionTable.OS) { $PSVersionTable.OS } else { "Windows ($env:OS)" }
    Write-Host "${RED}--------------------------------------------------${NC}"
    Write-Host " 🖥️  ${BOLD}SYSTEM INFORMATION${NC}"
    Write-Host "${RED}--------------------------------------------------${NC}"
    Write-Host "  💻  ${BOLD}OS:${NC}      ${CYN}$osName${NC}"
    Write-Host "  👤  ${BOLD}User:${NC}    ${CYN}$env:USERNAME${NC}"
    Write-Host "  🐚  ${BOLD}Shell:${NC}   ${CYN}PowerShell v$($PSVersionTable.PSVersion)${NC}"
    Write-Host "  📄  ${BOLD}Profile:${NC} ${CYN}$PROFILE_PATH${NC}"
    Write-Host "${RED}--------------------------------------------------${NC}`n"
}

# -- Helper: BOM-safe UTF-8 file write (PS 5.1 Out-File writes BOM by default) -
function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)  # $false = no BOM
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# -- Helper: Retry-aware file read ---------------------------------------------
function Read-ProfileSafe {
    param([string]$Path, [int]$MaxRetries = 3)
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        } catch [System.IO.IOException] {
            if ($i -lt $MaxRetries) {
                Write-Host "  ${YLW}⚠️  Profile locked - retrying in 1s (attempt $i/$MaxRetries)...${NC}"
                Start-Sleep -Seconds 1
            } else {
                throw
            }
        }
    }
}

# -- Helper: Remove ALL fancybash blocks (handles multiple / orphaned markers) -
function Remove-FancybashBlocks {
    param([string]$Content)

    $startEsc = [regex]::Escape($START)
    $endEsc   = [regex]::Escape($END)

    # -- Pass 1: Remove complete blocks (START…END pairs, CRLF & LF safe) ------
    $pattern = "(?s)(\r?\n)?[ \t]*$startEsc.*?$endEsc[ \t]*(\r?\n)?"
    $cleaned = [regex]::Replace($Content, $pattern, "")

    # -- Pass 2: Remove any orphaned START markers left behind -----------------
    $cleaned = [regex]::Replace($cleaned, "(?m)^[ \t]*$startEsc[ \t]*(\r?\n)?", "")

    # -- Pass 3: Remove any orphaned END markers left behind -------------------
    $cleaned = [regex]::Replace($cleaned, "(?m)^[ \t]*$endEsc[ \t]*(\r?\n)?", "")

    # -- Normalize: collapse 3+ consecutive blank lines → 2, trim trailing -----
    $cleaned = [regex]::Replace($cleaned, "(\r?\n){3,}", "`r`n`r`n")
    $cleaned = $cleaned.TrimEnd()

    # Ensure exactly one trailing newline
    return $cleaned + [System.Environment]::NewLine
}

# ══════════════════════════════════════════════════════════════════════════════
#   MAIN UNINSTALLER
# ══════════════════════════════════════════════════════════════════════════════
Show-Header
Show-SysInfo

# --- STEP 1: Detect Installation ----------------------------------------------
Show-ProgressBar -Current 1 -Total 5 -StepName "Detecting Installation"

if (-not (Test-Path $PROFILE_PATH -PathType Leaf)) {
    Write-Host "  ${YLW}ℹ️  No `$PROFILE file found at:${NC}"
    Write-Host "      ${CYN}$PROFILE_PATH${NC}"
    Write-Host "  ${GRN}✔ Nothing to uninstall.${NC}"
    if ($MyInvocation.MyCommand.Path) { exit 0 } else { return }
}

try {
    $profileContent = Read-ProfileSafe -Path $PROFILE_PATH
} catch {
    Write-Host "  ${RED}❌ Cannot read profile: $($_.Exception.Message)${NC}"
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}

$hasStart = $profileContent.Contains($START)
$hasEnd   = $profileContent.Contains($END)

if (-not $hasStart -and -not $hasEnd) {
    Write-Host "  ${YLW}ℹ️  No fancybash block found in `$PROFILE.${NC}"
    Write-Host "  ${GRN}✔ Profile is already clean - nothing to do.${NC}"
    if ($MyInvocation.MyCommand.Path) { exit 0 } else { return }
}

if ($hasStart -and -not $hasEnd) {
    Write-Host "  ${YLW}⚠️  Orphaned START marker found without matching END.${NC}"
    Write-Host "  ${YLW}   Will clean it up safely.${NC}"
} elseif ($hasEnd -and -not $hasStart) {
    Write-Host "  ${YLW}⚠️  Orphaned END marker found without matching START.${NC}"
    Write-Host "  ${YLW}   Will clean it up safely.${NC}"
} else {
    Write-Host "  ${GRN}✔ fancybash installation detected in `$PROFILE.${NC}"
}

# --- STEP 2: Backup Profile ---------------------------------------------------
Show-ProgressBar -Current 2 -Total 5 -StepName "Backing Up Profile"

$backupFile = ""
try {
    $backupFile = "$PROFILE_PATH.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    [System.IO.File]::Copy($PROFILE_PATH, $backupFile, $true)

    # Verify backup was actually written and is non-empty
    if (-not (Test-Path $backupFile) -or (Get-Item $backupFile).Length -eq 0) {
        throw "Backup file is missing or empty after copy."
    }
    Write-Host "  ${GRN}💾 Backup saved: ${CYN}$(Split-Path $backupFile -Leaf)${NC}"
    Write-Host "  ${GRN}   Size: $([math]::Round((Get-Item $backupFile).Length / 1KB, 1)) KB${NC}"
} catch {
    Write-Host "  ${YLW}⚠️  Backup failed: $($_.Exception.Message)${NC}"
    Write-Host "  ${YLW}   Proceeding without backup (profile will still be modified).${NC}"
    $backupFile = ""
}

# --- STEP 3: Remove fancybash Block(s) ----------------------------------------
Show-ProgressBar -Current 3 -Total 5 -StepName "Removing fancybash Block"

try {
    $cleaned = Remove-FancybashBlocks -Content $profileContent

    # Safety check: if cleaned is empty but original wasn't, something went wrong
    if ([string]::IsNullOrWhiteSpace($cleaned) -and $profileContent.Length -gt 200) {
        throw "Cleaned content is unexpectedly empty. Aborting to protect your profile."
    }

    # Verify no markers remain after cleaning
    if ($cleaned.Contains($START) -or $cleaned.Contains($END)) {
        throw "Markers still present after cleaning - aborting to prevent data loss."
    }

    Write-Utf8NoBom -Path $PROFILE_PATH -Content $cleaned
    Write-Host "  ${GRN}✅ fancybash block(s) cleanly removed from `$PROFILE.${NC}"
} catch {
    Write-Host "  ${RED}❌ Failed to modify profile: $($_.Exception.Message)${NC}"
    if ($backupFile -and (Test-Path $backupFile)) {
        try {
            [System.IO.File]::Copy($backupFile, $PROFILE_PATH, $true)
            Write-Host "  ${YLW}↩️  Profile restored from backup successfully.${NC}"
        } catch {
            Write-Host "  ${RED}❌ Auto-restore also failed: $($_.Exception.Message)${NC}"
            Write-Host "  ${YLW}   Manual restore: copy ${CYN}$(Split-Path $backupFile -Leaf)${YLW} → ${CYN}$PROFILE_PATH${NC}"
        }
    }
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}

# --- STEP 4: Verify Removal ---------------------------------------------------
Show-ProgressBar -Current 4 -Total 5 -StepName "Verifying Removal"

try {
    $verifyContent = Read-ProfileSafe -Path $PROFILE_PATH
    if ($verifyContent.Contains($START) -or $verifyContent.Contains($END)) {
        Write-Host "  ${RED}❌ Verification failed - markers still present in profile!${NC}"
        if ($backupFile -and (Test-Path $backupFile)) {
            [System.IO.File]::Copy($backupFile, $PROFILE_PATH, $true)
            Write-Host "  ${YLW}↩️  Profile restored from backup.${NC}"
        }
        if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
    }
    Write-Host "  ${GRN}✔ Verified - no fancybash markers remain in profile.${NC}"
    Write-Host "  ${GRN}   Profile size: $([math]::Round((Get-Item $PROFILE_PATH).Length / 1KB, 2)) KB${NC}"
} catch {
    Write-Host "  ${YLW}⚠️  Verification skipped: $($_.Exception.Message)${NC}"
}

# --- STEP 5: Reload Profile ---------------------------------------------------
Show-ProgressBar -Current 5 -Total 5 -StepName "Reloading Shell"

Write-Host "  ${BLU}🔄 Reloading shell profile...${NC}"
try {
    . $PROFILE_PATH
    Write-Host "  ${GRN}✨ Profile reloaded - fancybash aliases are now gone.${NC}"
} catch {
    # Non-fatal: profile reload can fail in restricted sessions or irm|iex context
    Write-Host "  ${YLW}⚠️  Auto-reload skipped (this is normal).${NC}"
    Write-Host "     Open a new PowerShell window, or run: ${CYN}. `$PROFILE${NC}"
}

# --- Final Summary -------------------------------------------------------------
Write-Host ""
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
Write-Host "   🗑️  ${BOLD}UNINSTALLATION COMPLETE!${NC}"
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
if ($backupFile -and (Test-Path $backupFile)) {
    Write-Host "  📦  ${BOLD}Backup:${NC}   ${GRN}$(Split-Path $backupFile -Leaf)${NC}"
}
Write-Host "  📄  ${BOLD}Profile:${NC}  ${CYN}$PROFILE_PATH${NC}"
Write-Host "  🔄  ${BOLD}Next:${NC}     Open a new PowerShell window to apply changes."
Write-Host "${RED}══════════════════════════════════════════════════${NC}"
Write-Host "  👋  ${BOLD}fancybash has been removed. Thanks for trying it!${NC}"
Write-Host ""
