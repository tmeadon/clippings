[CmdletBinding()]
param
(
    [Parameter()]
    [string]
    $resourceGroupName,

    [Parameter()]
    [string]
    $location = 'uksouth'
)

# set variables
$templateStorageAccountName = "tmtemplates"
$templateContainerName = "templates"

# create resource group
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue))
{
    Write-Verbose -Message "Creating resource group $resourceGroupName"
    New-AzResourceGroup -Name $resourceGroupName -Location $location | Out-Null
}

# deploy storage account for linked templates and copy templates up
Write-Verbose -Message "Deploying temporary storage account for linked templates"

$templateStorageParams = @{
    accountName = $templateStorageAccountName
    templateContainerName = $templateContainerName
    sasExpiry = ((Get-Date).AddDays(1) | Get-Date -Format "yyyy-MM-ddThh:MM:ssZ").ToString()
}

$templateStorage = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "$PSScriptRoot\shared\templateStorage.deploy.json" -TemplateParameterObject $templateStorageParams

$storageContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $templateStorageAccountName).Context

Get-ChildItem -Path "$PSScriptRoot\..\shared" | ForEach-Object -Process {
    Write-Verbose -Message "Copying $($_.Name) to temporary storage container"
    Set-AzStorageBlobContent -File $_.FullName -Container $templateContainerName -Blob $_.Name -Context $storageContext -Force | Out-Null
}

# deploy stack
Write-Verbose -Message "Deploying stack"

Remove-Item "$PSScriptRoot\ssh*"
ssh-keygen -b 2048 -t rsa -f $sshKeyFile -q -N '""'

$deploymentParams = @{
    templateContainerUri = $templateStorage.Outputs.templateContainerEndpoint.Value
    templateContainerSas = $templateStorage.Outputs.sasToken.Value
    sshPublicKeys = @(
        (Get-Content -Path "$sshKeyFile.pub" -Raw).ToString()
    )
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "$PSScriptRoot\stack.deploy.json" -TemplateParameterObject $deploymentParams | Out-Null

# remove the template storage account
Write-Verbose -Message "Removing template storage account"

Remove-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $templateStorageAccountName -Force