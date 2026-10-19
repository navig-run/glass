#Requires -Version 5
<#
  Removes NAVIG Glass for the current user. Leaves your files and your
  default-app settings untouched.
#>
[CmdletBinding()]
param([switch]$DryRun)
$ErrorActionPreference = 'SilentlyContinue'
$destDir = Join-Path $env:LOCALAPPDATA 'Programs\NAVIG Glass'
$shim    = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\navig-glass.cmd'
$link    = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\NAVIG Glass.lnk'
$appKey  = 'HKCU:\Software\Classes\Applications\navig-glass.exe'

Get-Process -Name 'navig-glass' | Stop-Process -Force
foreach ($p in @($destDir, $shim, $link, $appKey)) {
    Write-Host "  remove $p"
    if (-not $DryRun) { Remove-Item -LiteralPath $p -Recurse -Force }
}
Write-Host ''
if ($DryRun) { Write-Host 'Dry run: nothing was removed.' } else { Write-Host 'NAVIG Glass removed.' }