<#
.SYNOPSIS
    Runs the API status codes test suite (VirusTotal & Tatum HTTP mock tests).

.EXAMPLE
    .\scripts\run_api_tests.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Running API Status Code Tests          " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

flutter test test/api_test.dart
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAll API status code tests passed successfully!`n" -ForegroundColor Green
} else {
    Write-Host "`nAPI tests failed with exit code $LASTEXITCODE`n" -ForegroundColor Red
}
exit $LASTEXITCODE
