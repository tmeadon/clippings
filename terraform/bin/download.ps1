$zipPath = "$PSScriptRoot\terraform.zip"

Remove-Item -Path "$PSScriptRoot\*.exe"
Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_windows_amd64.zip" -UseBasicParsing -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath "$PSScriptRoot"
Remove-Item -Path $zipPath

# update $PATH
if ($env:Path.split(';') -notcontains $PSScriptRoot)
{
    [System.Environment]::SetEnvironmentVariable('Path', $env:Path + ";$PSScriptRoot", [System.EnvironmentVariableTarget]::User)
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
}
