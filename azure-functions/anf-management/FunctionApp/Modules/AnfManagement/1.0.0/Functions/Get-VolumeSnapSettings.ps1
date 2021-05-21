function Get-VolumeSnapSettings
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
        $snapshotAgeDays = $anfSnapshotDefaults.snapshotAgeDays
        $snapshotFrequencyHrs = $anfSnapshotDefaults.snapshotFrequencyHrs

        if ($VolumeTags.SnapshotAgeDays)
        {
            if (([int]$VolumeTags.SnapshotAgeDays -ge 0) -and ([int]$VolumeTags.SnapshotAgeDays -le 365))
            {
                $snapshotAgeDays = [int]$VolumeTags.SnapshotAgeDays
            }
        }

        if ($VolumeTags.SnapshotFrequencyHrs)
        {
            if (([int]$VolumeTags.SnapshotFrequencyHrs -eq 0) -or ((24 % [int]$VolumeTags.SnapshotFrequencyHrs) -eq 0))
            {
                $snapshotFrequencyHrs = [int]$VolumeTags.SnapshotFrequencyHrs
            }
        }

        [PSCustomObject]@{
            SnapshotAge       = $snapshotAgeDays
            SnapshotFrequency = $snapshotFrequencyHrs
        }
    }

    end {}
}
