# ==============================================================================
#   PowerShell Config Installer (install.ps1)
# ==============================================================================

$PROFILE_PATH = $PROFILE
$URL = "https://raw.githubusercontent.com/rihadjahanopu/fancybash/refs/heads/main/config.ps1"
$START = "# >>> fancy-powershell >>>"
$END = "# <<< fancy-powershell <<<"

# ─── Header ─────────────────────────────
Write-Host ""
Write-Host "          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗" -ForegroundColor Magenta
Write-Host "          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║" -ForegroundColor Magenta
Write-Host "          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║" -ForegroundColor Cyan
Write-Host "          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║" -ForegroundColor Cyan
Write-Host "          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║" -ForegroundColor Blue
Write-Host "          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝" -ForegroundColor Blue
Write-Host "`n   🚀  PowerShell Config Installer`n" -ForegroundColor Cyan

# ─── Check / Create Profile ──────────────
Write-Host "🔍 Checking existing profile..." -ForegroundColor Blue
$ProfileDir = Split-Path $PROFILE_PATH -Parent
if (-not (Test-Path $ProfileDir)) {
    Write-Host "⚠ Creating profile directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}
if (-not (Test-Path $PROFILE_PATH)) {
    Write-Host "⚠ Creating profile file..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $PROFILE_PATH -Force | Out-Null
}

# ─── Check Already Installed ────────────
$content = Get-Content $PROFILE_PATH -Raw
if ($content -and $content.Contains($START)) {
    Write-Host "✅ Already installed!" -ForegroundColor Yellow
    Write-Host "💡 Run: . `$PROFILE to reload if needed." -ForegroundColor Cyan
    exit
}

# ─── Backup ─────────────────────────────
$backupFile = "$PROFILE_PATH.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Write-Host "💾 Backing up to: $(Split-Path $backupFile -Leaf)" -ForegroundColor Blue
Copy-Item $PROFILE_PATH $backupFile

# ─── Get config.ps1 Content ─────────────
$configContent = $null
$localConfigPath = Join-Path $PSScriptRoot "config.ps1"

if (Test-Path $localConfigPath) {
    Write-Host "📂 Found local config.ps1. Installing from local file..." -ForegroundColor Blue
    $configContent = Get-Content $localConfigPath -Raw
} else {
    Write-Host "📥 Local config.ps1 not found. Downloading from GitHub..." -ForegroundColor Blue
    try {
        $configContent = Invoke-RestMethod -Uri $URL -TimeoutSec 10
    } catch {
        Write-Host "❌ Download failed! Check your internet connection." -ForegroundColor Red
        exit 1
    }
}

if (-not $configContent) {
    Write-Host "❌ Configuration content is empty!" -ForegroundColor Red
    exit 1
}

# ─── Append to Profile ──────────────────
Write-Host "📥 Installing config..." -ForegroundColor Blue
$installText = @"

$START
# Installed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$configContent
$END
"@

Add-Content -Path $PROFILE_PATH -Value $installText

# ─── Reload ─────────────────────────────
Write-Host "🔄 Reloading shell..." -ForegroundColor Blue
try {
    . $PROFILE_PATH
    Write-Host "✅ Installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Auto-reload failed. Run: . `$PROFILE" -ForegroundColor Yellow
}

# ─── Summary ────────────────────────────
Write-Host "`n┌────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│  📋 Installation Summary           │" -ForegroundColor Cyan
Write-Host "├────────────────────────────────────┤" -ForegroundColor Cyan
Write-Host "│  Backup: $(Split-Path $backupFile -Leaf)" -ForegroundColor Green
Write-Host "│  Profile: `$PROFILE" -ForegroundColor Green
Write-Host "│  Remove: Delete the fancy-powershell" -ForegroundColor Yellow
Write-Host "│          block from your `$PROFILE." -ForegroundColor Yellow
Write-Host "└────────────────────────────────────┘`n" -ForegroundColor Cyan
