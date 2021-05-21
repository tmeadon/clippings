function Get-VolumeFreeSpace
{
    [CmdletBinding()]
    param
    (
        # Resource ID of the volume
        [Parameter(Mandatory)]
        [string]
        $VolumeId
    )

    begin {}

    process
    {
        # get the volume size by querying the volume's 'usageThreshold' property and validate the response is sensible
        $volSize = (Get-AzResource -ResourceId $VolumeId -ErrorAction Stop).Properties.usageThreshold

        if (($null -eq $volSize) -or ($volSize -lt (100GB)))
        {
            throw ('Unable to determine correct size of volume {0}' -f $VolumeId)
        }

        # query azure monitor to get the logical size of the volume
        $metricParams = @{
            ResourceId    = $VolumeId
            MetricName    = 'VolumeLogicalSize'
            StartTime     = (Get-Date).AddMinutes(-15)
            WarningAction = 'SilentlyContinue'
            ErrorAction   = 'Stop'
        }

        $metrics = Get-AzMetric @metricParams
        $volAllocatedSpace = $metrics.Where({$_.Name.Value -eq 'VolumeLogicalSize'}).Data.Average | Select-Object -Last 1

        if ($null -eq $volAllocatedSpace)
        {
            throw ('Unable to determine consumed space from Azure Monitor for volume {0}' -f $VolumeId)
        }
        
        $volFreeSpace = $volSize - $volAllocatedSpace
        $volFreeSpace
    }

    end {}
}
