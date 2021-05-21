function Resize-Pool
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        # Resource ID of the capacity pool
        [Parameter(Mandatory)]
        [string]
        $PoolId,

        # Amount to resize by (positive values for growth and negative values for shrink)
        [Parameter(Mandatory)]
        [long]
        $ResizeAmount,

        # Object containing the capacity settings for the pool (produced by Get-PoolCapacitySettings)
        [Parameter(Mandatory)]
        [pscustomobject]
        $CapacitySettings
    )

    begin {}

    process
    {
        # retrieve the pool
        $anfPool = Get-AzNetAppFilesPool -ResourceId $PoolId -ErrorAction Stop

        # round the resize amount up to the nearest TB and calculate the new size for the pool in bytes
        $resizeAmountTb = [math]::Ceiling($ResizeAmount / 1TB)
        $newPoolSize = $anfPool.Size + ($resizeAmountTb * 1TB)

        # if the new pool size is outside the limits defined in capacity settings then raise a non-terminating error
        if ($newPoolSize -lt $CapacitySettings.MinSize)
        {
            Write-Information -MessageData ('Unable to resize pool {0} to {1:n3} TB - new size is below the minimum size of {2} TB set for the pool' -f $anfPool.Name, ($newPoolSize / 1TB), ($CapacitySettings.MinSize / 1TB))
        }
        elseif ($newPoolSize -gt $CapacitySettings.MaxSize)
        {
            Write-Error -Message ('Unable to resize pool {0} to {1:n3} TB - the new size is above the max size of {2} TB set for the pool' -f $anfPool.Name, ($newPoolSize / 1TB), ($CapacitySettings.MaxSize / 1TB))
        }
        else
        {
            # resize the pool
            if ($PSCmdlet.ShouldProcess($anfPool.Name))
            {
                Write-Information -MessageData ('Capacity: Resizing the pool {0} to {1} TB' -f $anfPool.Name, ($newPoolSize / 1TB))
                $anfPool | Update-AzNetAppFilesPool -PoolSize $newPoolSize -ErrorAction Stop | Out-Null
            }
        }
    }

    end {}
}
