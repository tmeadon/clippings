# Input bindings are passed in via param block.
param($Timer)

# request REST API access token
$resource = "https://management.core.windows.net/"
$requestAccessTokenUri = "https://login.microsoftonline.com/{0}/oauth2/token" -f $env:TenantId
$body = "grant_type=client_credentials&client_id={0}&client_secret={1}&resource={2}" -f $env:AppRegId, $env:AppRegToken, $resource
$token = Invoke-RestMethod -Method Post -Uri $requestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

# prepare HTTP headers
$headers = @{
    Authorization = ("{0} " -f $token.token_type) + " " + ("{0}" -f $token.access_token)
}

# find the resource groups with a destroy tag using the GET REST API
$resourceGroupGetUri = "https://management.azure.com/subscriptions/{0}/resourcegroups?api-version=2019-10-01" -f $env:SubscriptionId
$targetResourceGroups = (Invoke-RestMethod -Method Get -Uri $resourceGroupGetUri -Headers $headers).Value | Where-Object -FilterScript {$_.Tags.DestroyTime}

Write-Information -MessageData "Resource groups with a destroy tag have been discovered"
Write-Information -MessageData ($targetResourceGroups | ConvertTo-Json)

# use the Azure REST API to issue delete commands to resource groups with destroy time in the past
$currentDateTime = (Get-Date).ToUniversalTime()

foreach ($target in $targetResourceGroups) {
    try {
        $destroyTime = Get-Date -Date $target.Tags.DestroyTime
    }
    catch {
        Write-Error -Message ("Unable to convert {0} to datetime for resource group {1}" -f $target.Tags.DestroyTime, $target.Name)
    }

    if (($destroyTime -lt $currentDateTime) -and ($target.Properties.ProvisioningState -ne 'Deleting')) {
        Write-Information -MessageData ("The destroy time for Resource group {0} is in the past ({1}).  Destroying..." -f $target.Name, $destroyTime.ToString())
        $resourceGroupDeleteUri = "https://management.azure.com/subscriptions/{0}/resourcegroups/{1}?api-version=2019-10-01" -f $env:SubscriptionId, $target.Name
        Invoke-RestMethod -Method Delete -Uri $resourceGroupDeleteUri -Headers $headers
    }
    elseif (($destroyTime -lt $currentDateTime) -and ($target.Properties.ProvisioningState -eq 'Deleting')) {
        Write-Information -MessageData ("Resource group {0} is in a deleting state.  Skipping..." -f $target.Name)
    }
    elseif ($destroyTime -lt $currentDateTime.AddHours(1)) {
        Write-Warning -Message ("The destroy time for Resource Group {0} is in the next hour!" -f $target.Name)
    }
    else {
        Write-Information -MessageData ("The destroy time for Resource Group {0} is in the future ({1}).  Skipping..." -f $target.Name, $destroyTime.ToString())
    }
}
