$ErrorActionPreference = 'Stop';

$packageName = 'blackfiredaemon'
$softwareName = 'blackfiredaemon*'
$installerType = 'EXE' 

if (Get-Service -Name "BlackfireDaemon" -ErrorAction SilentlyContinue)
{
    nssm remove BlackfireDaemon confirm
}

Netsh.exe advfirewall firewall remove rule name="Blackfire Daemon"

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installDir = Join-Path $env:ProgramData "blackfire"

Remove-Item -Recurse -Force $installDir

$silentArgs = '/qn /norestart'
$validExitCodes = @(0, 3010, 1605, 1614, 1641)
$uninstalled = $false

