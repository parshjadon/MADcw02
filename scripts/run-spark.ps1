param([string]$DeviceId = 'emulator-5554')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Test-Path config/firebase-spark.local.json)) {
    throw 'Run node scripts/import-firebase-config.js after saving your local Android Firebase config.'
}
flutter.bat run -d $DeviceId --dart-define=USE_SPARK=true --dart-define-from-file=config/firebase-spark.local.json
if ($LASTEXITCODE -ne 0) { throw 'Spark app failed to run.' }
