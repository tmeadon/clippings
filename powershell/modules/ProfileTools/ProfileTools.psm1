# Dot source all public and private functions
Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}

# Create a private variable storing the path to the ArmTemplates directory
$script:armTemplateDirectory = (Resolve-Path -Path "$PSScriptRoot\ArmTemplates").Path

# Create a private variable storing the path to the ProfileTools user folder and create the folder if it doesn't exist
$script:profileToolsDirectory = Join-Path -Path $env:USERPROFILE -ChildPath ".ProfileTools"
(Test-Path -Path $script:profileToolsDirectory -PathType Container) ? $null : (New-Item -Path $script:profileToolsDirectory -ItemType Directory | Out-Null)

# Export public functions
Get-ChildItem -Path $PSScriptRoot\Public -Filter "*.ps1" -Recurse | ForEach-Object {
    Export-ModuleMember -Function $_.BaseName
}

# Register Azure subscription argument completer
Register-AzureSubCompleter

# Set PSReadLine options
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView