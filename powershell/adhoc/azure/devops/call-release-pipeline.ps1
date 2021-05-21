[CmdletBinding()]
Param
(
    # Name of the Azure DevOps project
    [Parameter(Mandatory)]
    [ValidateSet('FieldToolsGlobal')]
    [string]
    $ProjectName,

    # Name of release pipeline
    [Parameter(Mandatory)]
    [string]
    $ReleasePipelineName,

    # Pipeline stage(s) to deploy
    [Parameter(Mandatory)]
    [string[]]
    $StagesToDeploy,

    # Azure DevOps personal access token for the user
    [Parameter(Mandatory)]
    [string]
    $PersonalAccessToken,

    [Parameter(Mandatory)]
    [string]
    $AccountName
)

# Variables
$accountName = $AccountName

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken"))

$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# First retrieve the release definition
try
{
    $releaseDefinition = Invoke-RestMethod -Uri "https://vsrm.dev.azure.com/$accountName/$ProjectName/_apis/release/definitions?searchText=$ReleasePipelineName&isExactNameMatch=true" -Headers $headers -ContentType 'application/json' -Method Get -ErrorAction Stop
    
    if ($releaseDefinition.count -lt 1)
    {
        throw "No release definition found matching name $ReleasePipelineName in the project $ProjectName."
    }

    if ($releaseDefinition.count -gt 1)
    {
        throw "Multiple release pipelines found matching name $ReleasePipelineName in the project $ProjectName."
    }
}
catch
{
    Write-Error -Message "Error encountered retrieving release pipeline definition: $( $_.exception.message )" 
}

# Create a release
try 
{
    $startReleaseBody = @{
        definitionId = $releaseDefinition.value[0].id
    }
    
    $startReleaseBody = ConvertTo-Json -InputObject $startReleaseBody
    
    $releaseInstance = Invoke-RestMethod -Uri "https://vsrm.dev.azure.com/$accountName/$ProjectName/_apis/release/releases?api-version=5.0" -Headers $headers -ContentType 'application/json' -Body $startReleaseBody -Method Post -ErrorAction Stop

    if ($null -eq $releaseInstance)
    {
        throw "Release was not successfully created for $ReleasePipelineName in the project $ProjectName."
    }
}
catch
{
    Write-Error -Message "Error encountered whilst creating the release: $( $_.exception.message )  Detail: $( $_.ErrorDetails.Message )"
}

# Get the response from the release
try
{
    $releaseDetails = Invoke-RestMethod -Uri "https://vsrm.dev.azure.com/$accountName/$ProjectName/_apis/release/releases/$($releaseInstance.id)" -ContentType 'application/json' -Headers $headers -Method Get -ErrorAction Stop

    if ($null -eq $releaseDetails)
    {
        throw "Release details were not successfully retrieved for release $( $releaseInstance.name ) of $ReleasePipelineName in the project $ProjectName."
    }
}
catch 
{
    Write-Error -Message "Error encountered whilst retrieving the release details: $( $_.exception.message )  Detail: $( $_.ErrorDetails.Message )"
}

# Get the environments in the release
try
{
    $environment = $releaseDetails.environments.Where({$_.name -eq $StagesToDeploy})

    if ($null -eq $environment)
    {
        throw "Environment $StagesToDeploy is not present in release $( $releaseInstance.name ) of $ReleasePipelineName in the project $ProjectName."
    }
}
catch
{
    Write-Error -Message $_.exception.message
}

# Deploy to environment
try
{
    $environmentDeployBody = @{
        status = 'InProgress'
    }

    $environmentDeployBody = ConvertTo-Json -InputObject $environmentDeployBody

    $updateEnvironment = Invoke-RestMethod -Uri "https://vsrm.dev.azure.com/$accountName/$ProjectName/_apis/release/releases/$($releaseInstance.id)/environments/$($environment.id)?api-version=5.0-preview.6" -ContentType 'application/json' -Headers $headers -Body $environmentDeployBody -Method Patch

    if ($null -eq $updateEnvironment)
    {
        throw "Environment $StagesToDeploy was not set to 'InProgress' in release $( $releaseInstance.name ) of $ReleasePipelineName in the project $ProjectName."
    }
}
catch
{
    Write-Error -Message "Error encountered whilst retrieving the release details: $( $_.exception.message )  Detail: $( $_.ErrorDetails.Message )"
}
