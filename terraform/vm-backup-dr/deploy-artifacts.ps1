param (
    [string] $StorageAccountName,
    [string] $StorageAccountResourceGroup
)

Save-Module -Name 'StorageDsc' -Path $PSScriptRoot
Compress-Archive -Path "$PSScriptRoot\dsc.ps1", "$PSScriptRoot\StorageDsc" -DestinationPath "$PSScriptRoot\dsc.zip" -Force
$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroup
$sa | New-AzStorageContainer -Name 'dsc' -ErrorAction SilentlyContinue
$container = $sa | Get-AzStorageContainer -Name 'dsc'
$blob = $container | Set-AzStorageBlobContent -Blob 'dsc.zip' -File "$PSScriptRoot\dsc.zip" -Force
$sas = $container | New-AzStorageContainerSASToken -Permission 'r'

Remove-Item -Path "$PSScriptRoot\StorageDsc", "$PSScriptRoot\dsc.zip" -Recurse -Force

Write-Output -InputObject @{
    url = $blob.ICloudBlob.Uri
    sas = $sas
}

