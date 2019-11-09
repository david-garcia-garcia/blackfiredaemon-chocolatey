$ErrorActionPreference = 'Stop';

$packageName= 'blackfiredaemon'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$installDir = Join-Path $env:ProgramData "blackfire";
New-Item -ItemType Directory -Force -Path $installDir;

# Download the agent
$ZipPath = Join-Path $toolsDir '\agent.zip'
(New-Object Net.WebClient).DownloadFile('https://packages.blackfire.io/binaries/blackfire-agent/1.28.0/blackfire-agent-windows_amd64.zip', $ZipPath)
New-Item -ItemType directory -Force -Path $toolsDir
(new-object -com shell.application).namespace($installDir).CopyHere((new-object -com shell.application).namespace($ZipPath).Items(),16)
Remove-Item $ZipPath

# Add the ini file
$iniPath = "$installDir\agent.ini";
if (!([System.IO.File]::Exists($path))) {
  Copy-Item "$toolsDir\agent.ini" -Destination $iniPath;
}

$fileLocation = Join-Path $installDir 'blackfire-agent.exe'

Netsh.exe advfirewall firewall add rule name="Blackfire Daemon" program=$fileLocation protocol=tcp dir=out enable=yes action=allow

$destinationPath = $fileLocation
$destinationDir = $installDir

if (!(Get-Service -Name "BlackfireDaemon" -ErrorAction SilentlyContinue))
{
    nssm install BlackfireDaemon $destinationPath
}

nssm set BlackfireDaemon Application  $destinationPath
nssm set BlackfireDaemon AppDirectory $destinationDir
#nssm set BlackfireDaemon AppParameters '--address="127.0.0.1:8136"'

$old_Path=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name Path).Path;
echo $old_Path;
if ($old_path -notcontains $installDir) {
  #Append new path to existing path variable
  Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value ($old_Path += ';' + $installDir);
}

nssm set BlackfireDaemon DisplayName Blackfire Daemon
nssm set BlackfireDaemon Description The Blackfire Profiler Daemon
nssm set BlackfireDaemon Start SERVICE_AUTO_START

# nssm start BlackfireDaemon
Write-Warning "To enable the Black Fire service, configure your server tokens in $installDir/agent.ini or run blackfire-agent -register"