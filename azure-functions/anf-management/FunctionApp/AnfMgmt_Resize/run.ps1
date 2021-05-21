# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

Set-AzContext -Subscription $env:subscription -ErrorAction Stop | Out-Null

# first figure out if any of the volumes need to be resized, add them to a list and track the total amount to be resized
[System.Collections.Generic.List[hashtable]] $volsToResize = @()
$volGrowthAmount = 0

foreach ($vol in $QueueItem.Volumes)
{
    try
    {
        $volAvailableSpace = Get-VolumeFreeSpace -VolumeId $vol.VolumeId
        $volCapacitySettings = Get-VolumeCapacitySettings -VolumeTags $vol.VolumeTags
        $volResizeDetails = Get-VolumeResizeDetails -AvailableSpace $volAvailableSpace -CapacitySettings $volCapacitySettings
    
        Write-Information -MessageData ('Capacity: Volume {0} has {1:n3} GB available.  Resize required: {2}.  Resize amount: {3:n3} GB' -f `
            $vol.VolumeId.Split('/')[-1], ($volAvailableSpace / 1GB), $volResizeDetails.ResizeRequired, ($volResizeDetails.ResizeAmount / 1GB))
    
        if ($volResizeDetails.ResizeRequired)
        {
            $volsToResize.Add(@{
                VolumeId         = $vol.VolumeId
                ResizeAmount     = $volResizeDetails.ResizeAmount
                CapacitySettings = $volCapacitySettings
            })
            
            # only add the resize amount to the total growth amount if it is positive growth to ensure the capacity pool is intially grown if required
            if ($volResizeDetails.ResizeAmount -gt 0)
            {
                $volGrowthAmount += $volResizeDetails.ResizeAmount
            } 
        }
    }
    catch
    {
        Write-Error -Message ('Error occurred processing volume {0}: {1}' -f $vol.VolumeId, $_.Exception.Message)
    }
}

# determine the free space in the pool and expand if theres not enough room for the volume growth
$poolResource = Get-AzResource -ResourceId $QueueItem.PoolId
$poolAvailableSpace = Get-PoolFreeSpace -PoolId $QueueItem.PoolId
$poolCapacitySettings = Get-PoolCapacitySettings -PoolTags $poolResource.Tags

if ($volGrowthAmount -gt $poolAvailableSpace)
{
    Write-Information -MessageData ('Capacity: Pool {0} has {1:n3} TB to accommodate volume growth of {2:n3} TB - resize required' -f $poolResource.Name, ($poolAvailableSpace / 1TB), ($volGrowthAmount / 1TB))
    Resize-Pool -PoolId $QueueItem.PoolId -ResizeAmount ($volGrowthAmount - $poolAvailableSpace) -CapacitySettings $poolCapacitySettings
}


# now there's enough room in the pool we can resize the volumes that need resizing
foreach ($volume in $volsToResize)
{
    Resize-Volume -VolumeId $volume.VolumeId -ResizeAmount $volume.ResizeAmount -CapacitySettings $volume.CapacitySettings
}


# finally, trim any excess pool space (leaving 1TB spare)
$poolAvailableSpace = Get-PoolFreeSpace -PoolId $QueueItem.PoolId

if ([math]::Floor($poolAvailableSpace / 1TB) -gt 1)
{
    Write-Information -MessageData ('Capacity: Pool {0} has an excess of {1:n3} TB bytes available' -f $poolResource.Name, (($poolAvailableSpace - 1TB) / 1TB))
    Resize-Pool -PoolId $QueueItem.PoolId -ResizeAmount (1TB - $poolAvailableSpace) -CapacitySettings $poolCapacitySettings
}
