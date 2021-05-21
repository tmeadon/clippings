$zipPath = "$PSScriptRoot\packer.zip"

Invoke-WebRequest -Uri "https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_windows_amd64.zip" -UseBasicParsing -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath "$PSScriptRoot"
Remove-Item -Path $zipPath