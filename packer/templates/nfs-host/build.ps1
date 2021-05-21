Push-Location -Path $PSScriptRoot

$packerPath = "$PSScriptRoot\..\..\bin\packer.exe"

if (-not (Test-Path -Path $packerPath))
{
    & "$PSScriptRoot\..\..\bin\download.ps1"
}

Remove-Item -Path "$PSScriptRoot\output-*" -Recurse -Force -ErrorAction SilentlyContinue 

New-Item -Path "$PSScriptRoot\output-ssh" -ItemType Directory | Out-Null

ssh-keygen -b 2048 -t rsa -f "$PSScriptRoot\output-ssh\ssh.key" -q -N '""'

$ssh_public_key = Get-Content "$PSScriptRoot\output-ssh\ssh.key.pub"

& $packerPath build -var "ssh_public_key=$ssh_public_key" "$PSScriptRoot\hv-centos7.json"

Pop-Location