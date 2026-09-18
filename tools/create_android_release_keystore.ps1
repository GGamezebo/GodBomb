# Creates a local Android release keystore (NOT committed).
# Usage: powershell -ExecutionPolicy Bypass -File tools/create_android_release_keystore.ps1
$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
$secrets = Join-Path $root "secrets"
$keystore = Join-Path $secrets "tictacbadaboom-release.keystore"
$passFile = Join-Path $secrets "keystore_passwords.txt"
$aliasName = "tictacbadaboom"

$keytool = $null
$candidates = @(
    (Join-Path ${env:ProgramFiles} "Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\keytool.exe")
)
if ($env:JAVA_HOME) {
    $candidates += (Join-Path $env:JAVA_HOME "bin\keytool.exe")
}
$candidates += "keytool"
foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) {
        $keytool = $candidate
        break
    }
    if ($candidate -and (Get-Command $candidate -ErrorAction SilentlyContinue)) {
        $keytool = (Get-Command $candidate).Source
        break
    }
}
if (-not $keytool) {
    throw "keytool not found. Install JDK 17 and retry."
}

if (-not (Test-Path $secrets)) {
    New-Item -ItemType Directory -Path $secrets | Out-Null
}

if (Test-Path $keystore) {
    Write-Output "Keystore already exists: $keystore"
    Write-Output "Passwords file: $passFile"
    exit 0
}

# Random store/key password (same value; Godot uses one field for both typically).
$bytes = New-Object byte[] 24
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$storePass = ([Convert]::ToBase64String($bytes) -replace "[+/=]", "x").Substring(0, 20)

$dname = "CN=Tic-Tac-Bada-Boom, OU=Mobile, O=TicTacBadaBoom, L=Online, ST=NA, C=XX"
& $keytool -genkeypair `
    -v `
    -keystore $keystore `
    -alias $aliasName `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass $storePass `
    -keypass $storePass `
    -dname $dname

@"
# KEEP PRIVATE — do not commit
keystore=$keystore
alias=$aliasName
store_password=$storePass
key_password=$storePass
created=$(Get-Date -Format o)
"@ | Set-Content -Path $passFile -Encoding UTF8

# Wire Godot export_credentials.cfg (gitignored)
$credPath = Join-Path $root "export_credentials.cfg"
$ksUnix = ($keystore -replace "\\", "/")
@"
[preset.0]

script_encryption_key=""
keystore/debug=""
keystore/debug_user=""
keystore/debug_password=""
keystore/release="$ksUnix"
keystore/release_user="$aliasName"
keystore/release_password="$storePass"
"@ | Set-Content -Path $credPath -Encoding UTF8

Write-Output "Created: $keystore"
Write-Output "Passwords: $passFile"
Write-Output "Godot credentials: $credPath"
Write-Output "Backup secrets/ offline. Losing this keystore blocks Play updates."
