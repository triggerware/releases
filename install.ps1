# install.ps1
$ErrorActionPreference = "Stop"
$repo = "triggerware/releases"
$binary = "triggerware"

$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "amd64" } else {
    Write-Error "Unsupported arch: $env:PROCESSOR_ARCHITECTURE"; exit 1
}

$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
$version = $release.tag_name
$filename = "$binary-$version-windows-$arch.exe"
$url = "https://github.com/$repo/releases/download/$version/$filename"

Write-Host "Installing $binary $version (windows/$arch)..."
$tmp = "$env:TEMP\$binary.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp

$installDir = "$env:LOCALAPPDATA\triggerware"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Move-Item -Force $tmp "$installDir\$binary.exe"

# Add to PATH if not already there
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to user PATH (restart your terminal)"
}

# Config dir
$configDir = "$env:APPDATA\triggerware"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

Write-Host "Installed to $installDir\$binary.exe"
Write-Host "Config dir: $configDir"
Write-Host "Run: $binary --version"
