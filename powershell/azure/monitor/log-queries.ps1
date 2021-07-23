# add a new query to an existing query pack using a file
$kustoFile = "$PSScriptRoot\example.kusto"
$queryPackResourceId = "/subscriptions/84ead6cc-4344-4a52-891c-c5523c6c0129/resourceGroups/test/providers/Microsoft.OperationalInsights/querypacks/testQueries"
$restApiPath = "$queryPackResourceId/queries/$((New-Guid).Guid)?api-version=2019-09-01-preview"

$payload = @{
    properties = @{
        body = (Get-Content -Path $kustoFile -Raw).ToString()
        displayName = 'example'
        tags = @{
            labels = @(
                'label1'
            )
        }
        related = @{
            resourceTypes = @(
                'microsoft.insights/components'
            )
        }
    }
}

Invoke-AzRestMethod -Path $restApiPath -Method PUT -Payload ($payload | ConvertTo-Json -Depth 10)
