function Get-VolumeCapacitySettings
{
    [CmdletBinding()]
    param
    (
        # Hashtable containing the volume's resource tags
        [Parameter()]
        [hashtable]
        $VolumeTags
    )

    begin {}

    process
    {
        $minFreeSpaceGb = $anfCapacityDefaults.volMinFreeSpaceGb
        $maxFreeSpaceGb = $anfCapacityDefaults.volMaxFreeSpaceGb
        $maxVolSizeGb = $anfCapacityDefaults.volMaxSizeGb
        $minVolSizeGb = $anfCapacityDefaults.volMinSizeGb

        if ($VolumeTags.MinFreeSpaceGb)
        {
            if (([int]$VolumeTags.MinFreeSpaceGb -ge 0) -and ([int]$VolumeTags.MinFreeSpaceGb -le 102400))
            {
                $minFreeSpaceGb = [int]$VolumeTags.MinFreeSpaceGb
            }
        }

        if ($VolumeTags.MaxFreeSpaceGb)
        {
            if (([int]$VolumeTags.MaxFreeSpaceGb -ge 0) -and ([int]$VolumeTags.MaxFreeSpaceGb -le 102400))
            {
                $maxFreeSpaceGb = [int]$VolumeTags.MaxFreeSpaceGb
            }
        }

        if ($VolumeTags.MaxVolSizeGb)
        {
            if (([int]$VolumeTags.MaxVolSizeGb -ge 100) -and ([int]$VolumeTags.MaxVolSizeGb -le 102400))
            {
                $maxVolSizeGb = [int]$VolumeTags.MaxVolSizeGb
            }
        }

        if ($VolumeTags.MinVolSizeGb)
        {
            if (([int]$VolumeTags.MinVolSizeGb -ge 100) -and ([int]$VolumeTags.MinVolSizeGb -le 102400))
            {
                $MinVolSizeGb = [int]$VolumeTags.MinVolSizeGb
            }
        }

        [PSCustomObject]@{
            MaxFreeSpace = $maxFreeSpaceGb * 1GB
            MinFreeSpace = $minFreeSpaceGb * 1GB
            MaxSize      = $maxVolSizeGb * 1GB
            MinSize      = $minVolSizeGb * 1GB
        }
    }

    end {}
}
