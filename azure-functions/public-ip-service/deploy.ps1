[CmdletBinding()]
param
(
    [Parameter(Mandatory)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory)]
    [string]
    $FunctionAppName,

    [Parameter(Mandatory)]
    [string]
    $StorageAccountName
)

Write-Verbose "Deploying ARM template $PSScriptRoot\main.json"
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile "$PSScriptRoot\main.json" -functionAppName $FunctionAppName -storageAccountName $StorageAccountName

Write-Verbose "Deploying Function App code"
$zipPath = "$PSScriptRoot\functionapp.zip"
Compress-Archive -Path "$PSScriptRoot\FunctionApp\*" -DestinationPath $zipPath
Publish-AzWebApp -ResourceGroupName $rg.ResourceGroupName -Name $FunctionAppName -ArchivePath $zipPath -Force
Remove-Item -Path $zipPath