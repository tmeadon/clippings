# get capacity metrics for every ANF volume in the subscription
Get-AzResource -ResourceType 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes' | ForEach-Object -Parallel {
    $vol = $_
    
    $metricParams = @{
        ResourceId    = $vol.ResourceId
        MetricName    = 'VolumeLogicalSize', 'VolumeAllocatedSize', 'VolumeSnapshotSize'
        StartTime     = (Get-Date).AddMinutes(-15)
        WarningAction = 'SilentlyContinue'
        ErrorAction   = 'Stop'
    }
    $metrics = Get-AzMetric @metricParams

    function ExtractMostRecentMetric ($metrics, $metricName, $aggregation)
    {
        $lastRecord = $metrics.where({$_.Name.Value -eq $metricName}).data | Sort-Object -Property timestamp -Descending | Select-Object -First 1
        $lastRecord | Select-Object -ExpandProperty $aggregation    
    }

    [PSCustomObject]@{
        VolName               = $vol.Name
        LogicalSizeTB         = '{0:n2}' -f ((ExtractMostRecentMetric $metrics 'VolumeLogicalSize' 'Average') / 1TB)
        VolumeAllocatedSizeTB = '{0:n2}' -f ((ExtractMostRecentMetric $metrics 'VolumeAllocatedSize' 'Average') / 1TB)
        VolumeSnapshotSizeTB  = '{0:n2}' -f ((ExtractMostRecentMetric $metrics 'VolumeSnapshotSize' 'Average') / 1TB)
    }
}