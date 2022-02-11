#Requires -Version 7.0
#Requires -Module Az.Resources

param
(
    [Parameter(Mandatory)]
    [string]
    $Subscription,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -Path $_ })]
    [string]
    $OutputDirectory
)

Set-AzContext -Subscription $Subscription -ErrorAction Stop | Out-Null

Write-Host "Querying Azure..."

$volumes = Get-AzResource -ResourceType 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes' -ExpandProperties

$output = $volumes | ForEach-Object -Parallel {

    $vol = $_

    # query azure monitor to get the logical size of the volume
    $metricParams = @{
        ResourceId    = $vol.ResourceId
        MetricName    = 'VolumeLogicalSize'
        StartTime     = (Get-Date).AddMinutes(-15)
        WarningAction = 'SilentlyContinue'
        ErrorAction   = 'Stop'
    }

    $metrics = Get-AzMetric @metricParams
    $volAllocatedSpace = $metrics.Where({$_.Name.Value -eq 'VolumeLogicalSize'}).Data.Average | Select-Object -Last 1

    $match = $vol.ResourceId | Select-String -Pattern '^.*netAppAccounts\/([^\/]*)\/capacityPools\/([^\/]*)\/volumes\/([^\/]*)$' | Select-Object -ExpandProperty Matches

    [PSCustomObject]@{
        AccountName = $match.Groups[1].Value
        PoolName    = $match.Groups[2].Value
        VolumeName  = $match.Groups[3].Value
        SizeGB      = $vol.Properties.usageThreshold / 1GB
        UsedGB      = '{0:f2}' -f ($volAllocatedSpace / 1GB)
    }
}

$outputPath = ($OutputDirectory + "\anf_$Subscription.csv")
$output | Export-Csv -Path $outputPath -Append -NoTypeInformation
Write-Host "Information written to $outputPath"