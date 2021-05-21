#Requires -Modules @{ ModuleName="Az.KeyVault"; ModuleVersion="1.1.0"}

[CmdletBinding()]
Param
(    
    # Abbreviation for the environment
    [Parameter(Mandatory)]
    [ValidateSet('dev','tst','stg','prd')]
    [string]
    $Environment,

    # Optional suffix to apply to the environment name (for dev team feature environments)
    [Parameter()]
    [string]
    $EnvironmentSuffx,

    # Path to a file containing microservice parameters
    [Parameter()]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    [string]
    $ParameterFilePath,

    # Name of the Azure Key Vault used to store secret parameters
    [Parameter()]
    [ValidateScript({Get-AzKeyVault -VaultName $_})]
    [string]
    $KeyVaultName,

    # Resource type to generate parameter file for
    [Parameter(Mandatory)]
    [ValidateSet('FunctionApp','SBQueue','SBTopic','KeyVault','StorageAccount','CosmosAccount')]
    [string]
    $ResourceType
)
Begin {}
Process
{    
    # Read the parameters in and replace any secret references (i.e. instances of the string '$secret(<secretName>)') with references to secrets in Key Vault

    $parameters = Get-Content -Path $ParameterFilePath -Raw

    $parameters -match '(?<=\$secret\().*(?=\))' | Out-Null
    
    foreach ($match in $Matches.Values)
    {
        $secretUri = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $match | Select-Object -ExpandProperty Id

        if ($null -eq $secretUri)
        { 
            throw "Secret $match was not found in $KeyVaultName."
        }

        $parameters = $parameters.Replace("`$secret($match)","@Microsoft.KeyVault(SecretUri=$secretUri)")
    }

    # Convert the $parameters JSON string to a PSCustomObject and extract the objects with resource type equal to $ResourceType
    
    $parameters = $parameters | ConvertFrom-Json
    
    $resourcesToDeploy = $parameters.resources | Where-Object -Property resourceType -EQ -Value $ResourceType
    
    # Create an ARM parameter file for each resource to deploy

    foreach ($resource in $resourcesToDeploy)
    {
        $armParameterJson = [ordered]@{
            '$schema' = "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
            'contentVersion' = "1.0.0.0"
            'parameters' = $resource.settings
        }

        $armParameterJson | ConvertTo-Json -Depth 10 | Out-File -FilePath ".\$( $resource.resourceType ).$( $resource.shortName ).$( $Environment ).json"
    }
}