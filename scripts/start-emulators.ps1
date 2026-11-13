$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not $env:JAVA_HOME) {
    foreach ($candidate in @('C:\MAD\Andriod Studio\jbr', 'C:\Program Files\Android\Android Studio\jbr')) {
        if (Test-Path (Join-Path $candidate 'bin\java.exe')) { $env:JAVA_HOME = $candidate; break }
    }
}
if ($env:JAVA_HOME) { $env:PATH = "$env:JAVA_HOME\bin;$env:PATH" }
firebase.cmd emulators:start --project demo-cloud-quest --only 'auth,firestore,functions'
if ($LASTEXITCODE -ne 0) { throw 'Firebase emulators failed to start.' }
