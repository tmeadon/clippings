# list all available managed APIs for the given region
$region = "NorthEurope"
$subscriptionId = (Get-AzContext).Subscription.Id
$apis = [System.Collections.Generic.List[object]]::new()
$requestPath = "/subscriptions/$subscriptionId/providers/Microsoft.Web/locations/$region/managedApis?api-version=2016-06-01"

do 
{
    Write-Information $requestPath
    $results = (Invoke-AzRestMethod -Path $requestPath -Method GET).Content | ConvertFrom-Json
    $apis.AddRange($results.value)
    if ($results.nextLink) { $requestPath = $results.nextLink.Substring($results.nextLink.IndexOf('/subscriptions')) }
}
while($null -ne $results.nextLink)

# search for an api
$apis.Where({$_.name -like "*servicebus*"})
