$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
Remove-Item Env:FIRESTORE_EMULATOR_HOST,Env:FIREBASE_AUTH_EMULATOR_HOST -ErrorAction SilentlyContinue
node scripts/check-spark.js
if ($LASTEXITCODE -ne 0) { throw 'Spark prerequisites or billing check failed.' }
$sparkProject = (Get-Content config/firebase-spark.json -Raw | ConvertFrom-Json).projectId
$env:QUEST_FIREBASE_MODE = 'spark'
firebase.cmd emulators:start --config firebase.spark.json --project $sparkProject --only functions
if ($LASTEXITCODE -ne 0) { throw 'Local Spark backend failed to start.' }
