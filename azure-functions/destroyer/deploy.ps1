[CmdletBinding()]
param (
    # ID of the Azure AD app registration used
    [Parameter(Mandatory)]
    [string]
    $AppRegistrationId,

    # Password for the app registration
    [Parameter(Mandatory)]
    [string]
    $AppRegistrationToken,

    # Email address to receive the destroyer alerts
    [Parameter(Mandatory)]
    [string]
    $AlertEmailAddress
)

if (-not (Get-AzADApplication -ApplicationId $AppRegistrationId)) {
    throw "Unable to find application registration with ID $AppRegistrationId"
}

# create the rg if one doesn't exist
$rgParams = @{
    ResourceGroupName = 'destroyer'
    Location = "uksouth"
}

$rg = Get-AzResourceGroup -Name $rgParams['ResourceGroupName'] -ErrorAction SilentlyContinue

if ($null -eq $rg) {
    $rg = New-AzResourceGroup @rgParams
}
elseif ($rg.Location -ne $rgParams['Location']) {
    throw "Resource group $($rgParams['ResourceGroupName']) already exists in a different location"
}

# deploy the arm template
$deployParams = @{
    Name              = "destroyer-deploy-$(Get-Random -Minimum 1000 -Maximum 9999)"
    ResourceGroupName = $rg.ResourceGroupName
    TemplateFile      = "$PSScriptRoot\functionapp.deploy.json"
    appRegistrationId = $AppRegistrationId
    appRegistrationToken = $AppRegistrationToken
    alertEmailAddress = $AlertEmailAddress
}

$deployment = New-AzResourceGroupDeployment @deployParams

# publish the function app after waiting for it to start up
Start-Sleep -Seconds 10 
$zipPath = "$PSScriptRoot\destroyer.zip"
Compress-Archive -Path "$PSScriptRoot\function-app\*" -DestinationPath $zipPath
Publish-AzWebApp -ResourceGroupName $rg.ResourceGroupName -Name $deployment.Outputs.functionAppName.Value -ArchivePath $zipPath -Force
Remove-Item -Path $zipPath


