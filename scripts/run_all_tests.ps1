<#
.SYNOPSIS
    Runs all unit, widget, and API test suites.

.EXAMPLE
    .\scripts\run_all_tests.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Running All Test Suites                " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

flutter test
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAll test suites passed successfully!`n" -ForegroundColor Green
} else {
    Write-Host "`nTests failed with exit code $LASTEXITCODE`n" -ForegroundColor Red
}
exit $LASTEXITCODE
