
param($Timer)

Set-AzContext -Subscription $env:subscription -ErrorAction Stop | Out-Null

# define a regex for all storage RSGs (see Stratus Wiki for all of these) and retrieve all ANF volume resources in RSGs with matching names
$volumes = Get-AzResource -ResourceType 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'

# first enumerate the volumes and place a message on the snapshot management queue for each one
foreach ($vol in $volumes)
{
    Write-Information -MessageData ('Enumerate: Volume {0} - triggering snapshot function' -f $vol.Name)

    $queueMessage = @{
        VolumeId   = $vol.ResourceId
        VolumeTags = $vol.Tags
    }

    $queueMessage | Push-OutputBinding -Name 'anfSnapMgmtQueue'
}

# next group all the volumes by their hosting capacity pool and place a message on the capacity management queue for each pool
$uniquePoolIds = ($volumes.ResourceId | Select-String -Pattern '^.*capacityPools\/[^\/]*').Matches.Value | Sort-Object -Unique

foreach ($poolId in $uniquePoolIds)
{
    $poolVolumes = $volumes.Where({$_.ResourceId -like "$poolId*"})

    Write-Information -MessageData ('Enumerate: Pool {0} - triggering resize function' -f $poolId.Split('/')[-1])

    # we need to serialise ourselves in this case because the default serialisation method doesn't parse the object correctly when there are 
    # multiple volumes (we end up with VolumeTags = 'System.Collections.Hashtable' rather than the correct representation of the tags)
    $queueMessage = ConvertTo-Json -Depth 5 -InputObject @{
        PoolId  = $poolId
        Volumes = foreach ($vol in $poolVolumes) { @{VolumeId = $vol.Id; VolumeTags = $vol.Tags } }
    }
    
    $queueMessage | Push-OutputBinding -Name 'anfResizeQueue'
}
