#Requires -Version 5
<#
  Installs NAVIG Glass for the current user only.
  No admin rights, no default-app changes, no network access.
#>
[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$exeName = 'navig-glass.exe'
$src     = Join-Path $here $exeName
$destDir = Join-Path $env:LOCALAPPDATA 'Programs\NAVIG Glass'
$dest    = Join-Path $destDir $exeName
$menu    = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$link    = Join-Path $menu 'NAVIG Glass.lnk'
$shim    = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\navig-glass.cmd'
$appKey  = 'HKCU:\Software\Classes\Applications\navig-glass.exe'

function Step([string]$what) { Write-Host "  $what" }

if (-not (Test-Path $src)) { throw 'navig-glass.exe not found next to install.ps1' }
Write-Host ("NAVIG Glass installer" + $(if ($DryRun) { ' (dry run)' } else { '' }))

Step "program   -> $destDir"
Step "command   -> $shim"
Step "shortcut  -> $link"
Step "open with -> $appKey"

if ($DryRun) {
    Write-Host ''
    Write-Host 'Dry run: nothing was written.'
    return
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item $src $dest -Force

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $shim) | Out-Null
$cmd = '@echo off' + "`r`n" + '"' + $dest + '" %*' + "`r`n"
Set-Content -Path $shim -Value $cmd -Encoding ASCII -NoNewline

New-Item -ItemType Directory -Force -Path $menu | Out-Null
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($link)
$lnk.TargetPath       = $dest
$lnk.WorkingDirectory = $destDir
$lnk.Description      = 'NAVIG Glass - instant file viewer'
$lnk.Save()

New-Item -Path $appKey -Force | Out-Null
Set-ItemProperty -Path $appKey -Name 'FriendlyAppName' -Value 'NAVIG Glass'
New-Item -Path (Join-Path $appKey 'shell\open\command') -Force | Out-Null
Set-ItemProperty -Path (Join-Path $appKey 'shell\open\command') -Name '(default)' -Value ('"' + $dest + '" "%1"')
[string[]]$types = @('png','jpg','jpeg','gif','bmp','webp','tif','tiff','ico','avif','heic','pdf','mp4','mkv','mov','webm','mp3','wav','flac')
Set-ItemProperty -Path $appKey -Name 'SupportedTypes' -Value $types -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Done. Open any image, or run: navig-glass "C:\path\file.png"'