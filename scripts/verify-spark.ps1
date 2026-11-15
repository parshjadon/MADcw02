param([switch]$AllowTestWrites, [string]$DeviceId)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not $AllowTestWrites) { throw 'Pass -AllowTestWrites to create synthetic accounts and progress in the registered Spark project.' }
Remove-Item Env:FIRESTORE_EMULATOR_HOST,Env:FIREBASE_AUTH_EMULATOR_HOST -ErrorAction SilentlyContinue
function Invoke-SparkCheck([string]$Name, [string]$Executable, [string[]]$CommandArguments) {
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Executable @CommandArguments 2>&1 | ForEach-Object {
            "$_" -replace 'http://127\.0\.0\.1:\d+/[^\s]+', '[local Dart VM service URL omitted]' -replace '-Pdart-defines=\S+', '-Pdart-defines=[local values omitted]'
        } | Tee-Object -FilePath "evidence/$Name.txt"
        $resultCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    $recorded = (Get-Content "evidence/$Name.txt" | ForEach-Object { $_.TrimEnd() }) -join "`n"
    Set-Content "evidence/$Name.txt" -Value $recorded.TrimEnd() -Encoding UTF8
    if ($resultCode -ne 0) { throw "$Name failed with exit code $resultCode" }
}
$env:ALLOW_SPARK_TEST_WRITES = 'YES'
Invoke-SparkCheck 'spark-tests' 'node.exe' @('scripts/test-spark.js')
if ($DeviceId) {
    $env:QUEST_SPARK_EVIDENCE = 'true'
    Invoke-SparkCheck 'spark-mobile-run' 'flutter.bat' @('drive', '--driver=test_driver/integration_test.dart', '--target=integration_test/quest_flow_test.dart', '--dart-define=USE_SPARK=true', '--dart-define-from-file=config/firebase-spark.local.json', '-d', $DeviceId)
}
Write-Output 'Requested Spark checks passed; backend stays local and billing remains unlinked.'
