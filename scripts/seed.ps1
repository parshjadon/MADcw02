$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:GCLOUD_PROJECT = 'demo-cloud-quest'
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
node functions/scripts/seed.js
if ($LASTEXITCODE -ne 0) { throw 'Emulator seeding failed.' }
