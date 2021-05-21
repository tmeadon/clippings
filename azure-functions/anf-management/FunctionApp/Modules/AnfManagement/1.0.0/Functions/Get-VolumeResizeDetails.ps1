function Get-VolumeResizeDetails
{
    [CmdletBinding()]
    param
    (
        # Available space (bytes) in the volume
        [Parameter(Mandatory)]
        [Int64]
        $AvailableSpace,

        # Object containing the capacity settings for the volume (produced by Get-VolumeCapacitySettings)
        [Parameter(Mandatory)]
        [pscustomobject]
        $CapacitySettings
    )

    begin {}

    process
    {
        # default to resize not being required
        $resizeRequired = $false
        $resizeAmount = 0

        # if the available space is outside of the limits defined in the capacity settings, set the variables accordingly
        if (($AvailableSpace -gt $CapacitySettings.MaxFreeSpace) -or ($AvailableSpace -lt $CapacitySettings.MinFreeSpace))
        {
            $resizeAmount = $CapacitySettings.MinFreeSpace - $AvailableSpace

            if ([math]::Floor($resizeAmount / 1GB) -ne 0)
            {
                $resizeRequired = $true
            }
        }

        # return a pscustomobject
        [PSCustomObject]@{
            ResizeRequired = $resizeRequired
            ResizeAmount   = $resizeAmount
        }
    }

    end {}
}
