function Resize-Volume
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        # Resource ID of the volume
        [Parameter(Mandatory)]
        [string]
        $VolumeId,

        # Amount to resize by (positive values for growth and negative values for shrink)
        [Parameter(Mandatory)]
        [long]
        $ResizeAmount,

        # Object containing the capacity settings for the volume (produced by Get-VolumeCapacitySettings)
        [Parameter(Mandatory)]
        [pscustomobject]
        $CapacitySettings
    )

    begin {}

    process
    {
        # retrieve the volume
        $anfVol = Get-AzNetAppFilesVolume -ResourceId $VolumeId -ErrorAction Stop

        # round the resize amount up to the nearest TB and calculate the new size for the volume in bytes
        $resizeAmountGb = [math]::Floor($ResizeAmount / 1GB)
        $newVolSize = $anfVol.UsageThreshold + ($resizeAmountGb * 1GB)

        # if the new volume size is outside the limits defined in capacity settings then raise a non-terminating error
        if ($newVolSize -lt $CapacitySettings.MinSize)
        {
            Write-Information -MessageData ('Unable to resize volume {0} to {1:n3} GB - new size is below the minimum size of {2} GB set for the volume' -f $anfVol.Name, ($newVolSize / 1GB), ($CapacitySettings.MinSize / 1GB))
        }
        elseif ($newVolSize -gt $CapacitySettings.MaxSize)
        {
            Write-Error -Message ('Unable to resize volume {0} to {1:n3} GB - new size is above the maximum size of {2} GB set for the volume' -f $anfVol.Name, ($newVolSize / 1GB), ($CapacitySettings.MaxSize / 1GB))
        }
        else
        {
            # resize the volume
            if ($PSCmdlet.ShouldProcess($anfVol.Name))
            {
                Write-Information -MessageData ('Capacity: Resizing the volume {0} to {1:n3} GB' -f $anfVol.Name, ($newVolSize / 1GB))
                $anfVol | Update-AzNetAppFilesVolume -UsageThreshold $newVolSize -ErrorAction Stop -Verbose | Out-Null
            }
        }
    }

    end {}
}
