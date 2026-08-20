<#
.SYNOPSIS
    Builds a Debug APK using Windows environment variables.

.EXAMPLE
    .\scripts\build_debug.ps1
    .\scripts\build_debug.ps1 -Clean
#>

[CmdletBinding()]
param(
    [switch]$SplitPerAbi,
    [switch]$Clean,
    [string]$VirusTotalApiKey = $env:VIRUSTOTAL_API_KEY,
    [string]$TatumApiKey = $env:TATUM_API_KEY
)

$ErrorActionPreference = 'Stop'

# Ensure the script runs from the project root directory
$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Flutter Build: DEBUG APK               " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Project Root: $ProjectRoot"
Write-Host ""

# Check environment variable presence without printing values
$vtConfigured = -not [string]::IsNullOrWhiteSpace($VirusTotalApiKey)
$tatumConfigured = -not [string]::IsNullOrWhiteSpace($TatumApiKey)

Write-Host "Environment Variables Check:" -ForegroundColor Yellow
if ($vtConfigured) {
    Write-Host " - VIRUSTOTAL_API_KEY: [Configured]" -ForegroundColor Green
} else {
    Write-Host " - VIRUSTOTAL_API_KEY: [Not Set]" -ForegroundColor DarkGray
}

if ($tatumConfigured) {
    Write-Host " - TATUM_API_KEY:       [Configured]" -ForegroundColor Green
} else {
    Write-Host " - TATUM_API_KEY:       [Not Set]" -ForegroundColor DarkGray
}
Write-Host ""

if (-not $vtConfigured -and -not $tatumConfigured) {
    Write-Warning "Neither VIRUSTOTAL_API_KEY nor TATUM_API_KEY are configured."
    Write-Warning "The build will continue, but security/blockchain scanning may fail at runtime."
    Write-Host ""
}

# Optional clean step
if ($Clean) {
    Write-Host "Cleaning build directory and fetching packages..." -ForegroundColor Magenta
    flutter clean
    flutter pub get
    Write-Host ""
}

# Construct build arguments
$buildArgs = @("build", "apk", "--debug")
$displayArgs = @("build", "apk", "--debug")

if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
    $displayArgs += "--split-per-abi"
}

if ($vtConfigured) {
    $buildArgs += "--dart-define=VIRUSTOTAL_API_KEY=$VirusTotalApiKey"
    $displayArgs += "--dart-define=VIRUSTOTAL_API_KEY=***"
}

if ($tatumConfigured) {
    $buildArgs += "--dart-define=TATUM_API_KEY=$TatumApiKey"
    $displayArgs += "--dart-define=TATUM_API_KEY=***"
}

Write-Host "Executing build command:" -ForegroundColor Green
Write-Host "flutter $($displayArgs -join ' ')" -ForegroundColor DarkGray
Write-Host ""

& flutter @buildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  DEBUG APK BUILD SUCCEEDED!             " -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    
    $outputPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk"
    if (Test-Path $outputPath) {
        Write-Host ""
        Write-Host "Generated APK(s):" -ForegroundColor Cyan
        Get-ChildItem -Path $outputPath -Filter "*debug*.apk" | ForEach-Object {
            Write-Host " -> $($_.FullName) ($([math]::Round($_.Length / 1MB, 2)) MB)" -ForegroundColor White
        }
    }
} else {
    Write-Host ""
    Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
