function Get-PoolFreeSpace
{
    [CmdletBinding()]
    param
    (
        # Resource ID of the capacity pool
        [Parameter(Mandatory)]
        [string]
        $PoolId
    )

    begin {}

    process
    {
        # retrieve the pool
        $anfPool = Get-AzNetAppFilesPool -ResourceId $PoolId -ErrorAction Stop

        # retrieve all volumes in that pool
        $anfVolumes = $anfPool | Get-AzNetAppFilesVolume -ErrorAction Stop

        # sum up the sizes of all the volumes and subtract from the size of the pool to get available space
        $volsTotalSize = ($anfVolumes | Measure-Object -Property UsageThreshold -Sum).Sum

        $anfPool.Size - $volsTotalSize
    }

    end {}
}
