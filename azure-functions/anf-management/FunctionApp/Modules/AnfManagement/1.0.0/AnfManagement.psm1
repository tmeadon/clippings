# load config files into variables
$anfCapacityDefaults = Import-PowerShellDataFile -Path "$PSScriptRoot\Config\CapacityDefaults.psd1"
$anfSnapshotDefaults = Import-PowerShellDataFile -Path "$PSScriptRoot\Config\SnapshotDefaults.psd1"

# dot source and export functions
Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter "*.ps1" -Recurse | ForEach-Object -Process {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}