[CmdletBinding()]
Param ()

# define target regions
$deploymentRegion = 'PZNE'

# load the region.json configuration file and set the azure context
$regionJsonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Region.json'
$regionJson = Get-Content -Path $regionJsonPath -Raw | ConvertFrom-Json
$region = $regionJson.Where({$_.Environment -eq $deploymentRegion})

Set-AzContext -Subscription $region.Subscription

# save the dependant modules into the function app's module directory
Save-Module -Name Az.NetAppFiles -Path $PSScriptRoot\FunctionApp\Modules -RequiredVersion '0.1.3'

# get the managed identity
$identity = Get-AzUserAssignedIdentity -ResourceGroupName $region.AnfAutomationResourceGroup -Name $region.AnfAutomationMsi

# get the names of the subscriptions the function app will target
$subscriptions = $regionJson.Where({$_.Environment -like "P*"}).Subscription

# deploy the arm template
$deployParams = @{
    Name                  = "AnfMgmt"
    ResourceGroupName     = $region.AnfAutomationResourceGroup
    TemplateFile          = "$PSScriptRoot\functionapp.deploy.json"
    functionAppNamePrefix = $region.AnfAutomationFunctionAppPrefix
    appInsightsName       = $region.AnfAutomationAppInsights
    aspNamePrefix         = $region.AnfAutomationAppServicePlanPrefix
    storageAccountName    = $region.AnfAutomationStorageAccount
    msiResourceId         = $identity.Id
    msiClientId           = $identity.ClientId
    subscriptions         = $subscriptions
}

$deployment = New-AzResourceGroupDeployment @deployParams

# publish the function app after waiting for it to start up
Start-Sleep -Seconds 10 
$zipPath = "$PSScriptRoot\AnfMgmt.zip"
Compress-Archive -Path "$PSScriptRoot\FunctionApp\*" -DestinationPath $zipPath

foreach ($fa in $deployment.Outputs.functionApps.value)
{
    Publish-AzWebApp -ResourceGroupName $region.AnfAutomationResourceGroup -Name $fa.value -ArchivePath $zipPath -Force | Out-Null
}

# tidy up
Remove-Item -Path $zipPath
Remove-Item -Path "$PSScriptRoot\FunctionApp\Modules\Az.Accounts", "$PSScriptRoot\FunctionApp\Modules\Az.NetAppFiles" -Recurse -Force