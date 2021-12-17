function Split-AzResourceId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]$ResourceId
    )

    process
    {
        $regex = '^\/subscriptions\/([^\/]+)(\/resourceGroups\/([^\/]+))?(\/providers\/([^\/]+\/[^\/]+)\/([^\/]+))?$'
        $matches = ($ResourceId | Select-String -Pattern $regex).Matches
        
        if ($matches.Count -eq 0)
        {
            Write-Error "Invalid resource id: $ResourceId"
        }
        else
        {
            [PSCustomObject]@{
                SubscriptionId = $matches[0].Groups[1].Value
                ResourceGroupName = $matches[0].Groups[3].Value
                ResourceType = $matches[0].Groups[5].Value
                Name = $matches[0].Groups[6].Value
            }
        }
    }

}