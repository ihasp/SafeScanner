$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

Write-Host "-/ Running checks... /-"
Write-Host ""

try {

    dart format .\lib
    dart analyze .\lib
    dcm analyze .\lib
    flutter test

} catch {
    Write-Error $_
    exit 1
}
Write-Host ""
Write-Host "-/ All passed successfully! /-"
Write-Host ""