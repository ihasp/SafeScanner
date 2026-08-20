<#
.SYNOPSIS
    Builds a Release APK using Windows environment variables.

.EXAMPLE
    .\scripts\build_release.ps1
    .\scripts\build_release.ps1 -Clean -SplitPerAbi
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
Write-Host "  Flutter Build: RELEASE APK             " -ForegroundColor Cyan
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
    Write-Host " - VIRUSTOTAL_API_KEY: [Not Set]" -ForegroundColor Red
}

if ($tatumConfigured) {
    Write-Host " - TATUM_API_KEY:       [Configured]" -ForegroundColor Green
} else {
    Write-Host " - TATUM_API_KEY:       [Not Set]" -ForegroundColor Red
}
Write-Host ""

if (-not $vtConfigured -or -not $tatumConfigured) {
    Write-Host "ERROR: Required environment variable(s) missing or not configured for release build." -ForegroundColor Red
    if (-not $vtConfigured) {
        Write-Host "  - VIRUSTOTAL_API_KEY is required but not set or empty." -ForegroundColor Red
    }
    if (-not $tatumConfigured) {
        Write-Host "  - TATUM_API_KEY is required but not set or empty." -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please set the environment variables or pass them as parameters (-VirusTotalApiKey, -TatumApiKey)." -ForegroundColor Yellow
    exit 1
}

# Optional clean step
if ($Clean) {
    Write-Host "Cleaning build directory and fetching packages..." -ForegroundColor Magenta
    flutter clean
    flutter pub get
    Write-Host ""
}

# Construct build arguments
$buildArgs = @("build", "apk", "--release")
$displayArgs = @("build", "apk", "--release")

if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
    $displayArgs += "--split-per-abi"
}

$buildArgs += "--dart-define=VIRUSTOTAL_API_KEY=$VirusTotalApiKey"
$displayArgs += "--dart-define=VIRUSTOTAL_API_KEY=***"

$buildArgs += "--dart-define=TATUM_API_KEY=$TatumApiKey"
$displayArgs += "--dart-define=TATUM_API_KEY=***"

Write-Host "Executing build command:" -ForegroundColor Green
Write-Host "flutter $($displayArgs -join ' ')" -ForegroundColor DarkGray
Write-Host ""

& flutter @buildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  RELEASE APK BUILD SUCCEEDED!           " -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    
    $outputPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk"
    if (Test-Path $outputPath) {
        Write-Host ""
        Write-Host "Generated APK(s):" -ForegroundColor Cyan
        Get-ChildItem -Path $outputPath -Filter "*release*.apk" | ForEach-Object {
            Write-Host " -> $($_.FullName) ($([math]::Round($_.Length / 1MB, 2)) MB)" -ForegroundColor White
        }
    }
} else {
    Write-Host ""
    Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
