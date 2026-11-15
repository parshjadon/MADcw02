param([switch]$UseRunningEmulators, [string]$DeviceId)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Path evidence -Force | Out-Null
function Invoke-Check([string]$Name, [string]$Executable, [string[]]$CommandArguments) {
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Executable @CommandArguments 2>&1 | ForEach-Object {
            "$_" -replace 'http://127\.0\.0\.1:\d+/[^\s]+', '[local Dart VM service URL omitted]' -replace '-Pdart-defines=\S+', '-Pdart-defines=[local values omitted]'
        } | Tee-Object -FilePath "evidence/$Name.txt"
        $resultCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    $recorded = (Get-Content "evidence/$Name.txt" | ForEach-Object { $_.TrimEnd() }) -join "`n"
    Set-Content -LiteralPath "evidence/$Name.txt" -Value $recorded.TrimEnd() -Encoding UTF8
    if ($resultCode -ne 0) { throw "$Name failed with exit code $resultCode" }
}
Invoke-Check 'flutter-analyze' 'flutter.bat' @('analyze')
Invoke-Check 'widget-tests' 'flutter.bat' @('test', '--reporter', 'expanded')
if ($UseRunningEmulators) {
    $env:GCLOUD_PROJECT = 'demo-cloud-quest'
    $env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
    $env:FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099'
    Invoke-Check 'backend-run' 'node.exe' @('functions/scripts/run-tests.js')
} else {
    Invoke-Check 'backend-run' 'firebase.cmd' @('emulators:exec', '--project', 'demo-cloud-quest', '--only', 'auth,firestore,functions', 'node functions/scripts/run-tests.js')
}
if ($DeviceId) {
    if (-not $UseRunningEmulators) { throw 'For mobile tests, keep emulators running and pass -UseRunningEmulators.' }
    Invoke-Check 'mobile-run' 'flutter.bat' @('drive', '--driver=test_driver/integration_test.dart', '--target=integration_test/quest_flow_test.dart', '-d', $DeviceId)
}
Write-Output 'Requested checks passed. Evidence is in evidence/.'
