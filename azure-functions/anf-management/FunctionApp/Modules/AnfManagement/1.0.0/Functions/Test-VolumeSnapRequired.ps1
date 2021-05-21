function Test-VolumeSnapRequired
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        # Resource ID for the ANF volume
        [Parameter(Mandatory)]
        [string]
        $VolumeId,

        # An object containing the volume's snapshot settings (produced by Get-VolumeSnapSettings)
        [Parameter(Mandatory)]
        [object]
        $SnapshotSettings,

        # An array containing all of the snapshots for the volume
        [Parameter()]
        [object[]]
        $ExistingSnapshots
    )

    begin {}

    process
    {
        $volumeName = $volumeId.Split('/')[-1]
        $utcDateTime = (Get-Date).ToUniversalTime()

        # first figure out if a snapshot is required for this hour
        if ($SnapshotSettings.SnapshotFrequency -eq 0)
        {
            # values of 0 mean snapshots are disabled
            Write-Information -MessageData ('Snapshots: Volume {0} - snapshots are disabled based on tag values' -f $volumeName)
            return $false
        }
        elseif (($utcDateTime.Hour % $SnapshotSettings.SnapshotFrequency) -ne 0)
        {
            # if the volume's defined snap frequency is not a factor of the current hour then a new snapshot isn't required
            Write-Information -MessageData ('Snapshots: Volume {0} - snapshot not required in the current hour based on defined frequency of {1}' -f $volumeName, $SnapshotSettings.SnapshotFrequency)
            return $false
        }
        else
        {
            # if snapshots are enabled and the current hour aligns with the frequency then we only need a snapshot if one doesn't exist for this hour already
            $currentSnapshot = $ExistingSnapshots.Where({$_.Created -gt (Get-Date -Date "$($utcDateTime.Hour):00")})

            if ($currentSnapshot.Count -ge 1)
            {
                Write-Information -MessageData ('Snapshots: Volume {0} - snapshot not required since one already exists for this hour: {1}' -f $volumeName, $currentSnapshot.Name)
                return $false
            }

            Write-Information -MessageData ('Snapshots: Volume {0} - snapshot required based on defined frequency of {1}' -f $volumeName, $SnapshotSettings.SnapshotFrequency)
            return $true
        }

        # if we get to this point then something's gone wrong - raise an exception
        throw ('Unable to determine if snapshot is required for volume {0}' -f $volumeName)
    }

    end {}
}
