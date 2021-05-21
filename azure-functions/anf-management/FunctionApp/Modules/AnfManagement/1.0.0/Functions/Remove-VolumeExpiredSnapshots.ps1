function Remove-VolumeExpiredSnapshots
{
    [CmdletBinding(SupportsShouldProcess)]
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
        if ($ExistingSnapshots)
        {
            if (-not $SnapshotSettings.SnapshotAge)
            {
                throw ('"SnapshotAge" property missing from SnapshotSettings for volume {0}' -f  $VolumeId.Split('/')[-1])
            }

            if ($SnapshotSettings.SnapshotAge -eq 0)
            {
                Write-Information -MessageData ('Snapshots: Volume {0} - snapshots are configured to never expire' -f $VolumeId.Split('/')[-1])
            }
            else
            {
                $snapExpiryDate = (Get-Date).ToUniversalTime().AddDays(-$SnapshotSettings.SnapshotAge)

                $expiredSnaps = $ExistingSnapshots.Where({$_.Created -lt $snapExpiryDate})

                if ($expiredSnaps.Count -gt 0)
                {
                    Write-Information -MessageData ('Snapshots: Volume {0} - removing the following snapshots older than {1} days: {2}' -f $VolumeId.Split('/')[-1], $SnapshotSettings.SnapshotAge, ($expiredSnaps.Name -join ", "))

                    if ($PSCmdlet.ShouldProcess($expiredSnaps.Name -join ", "))
                    {
                        $expiredSnaps | Remove-AzNetAppFilesSnapshot
                    }

                }
                else
                {
                    Write-Information -MessageData ('Snapshots: Volume {0} - no snapshots to expire' -f $VolumeId.Split('/')[-1])
                }
            }
            #next we prune snapshot older than 45 days so that we keep dailies, pruning to keep under the 255 snapshot NetApp limit
            $cutoff =  (Get-Date).AddDays(-45)
            Write-Information -MessageData ("Cutoff for 6 hourly snaps is $cutoff")
            ForEach ($snap in $ExistingSnapshots){
                if ($snap.Created -lt $cutoff -and $snap.Created -match "[0-1]?[2-8]:[0-5]?[0-9]:[0-5][0-9]")
                {
                    Write-Information -MessageData ("Starting to delete hourly snapshot $($snap.Name)")
                    $snap | Remove-AzNetAppFilesSnapshot
                    Write-Information -MessageData ("Deleted hourly snapshot $($snap.Name)")
                }
            }
        }
        else
        {
            Write-Information -MessageData ('Snapshots: Volume {0} - there are no existing snapshots to check for expiry' -f $VolumeId.Split('/')[-1])
        }
    }

    end {}
}
