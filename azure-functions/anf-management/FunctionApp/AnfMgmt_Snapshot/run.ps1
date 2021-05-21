# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

Set-AzContext -Subscription $env:subscription -ErrorAction Stop | Out-Null

# first get all the existing snapshots for the volume
$existingSnapshots = Get-AzNetAppFilesVolume -ResourceId $QueueItem.VolumeId -ErrorAction 'Stop' | Get-AzNetAppFilesSnapshot -ErrorAction 'Stop'

# check if a snapshot is required and create one if so
$snapshotSettings = Get-VolumeSnapSettings -VolumeTags $QueueItem.VolumeTags

if (Test-VolumeSnapRequired -VolumeId $QueueItem.VolumeId -SnapshotSettings $snapshotSettings -ExistingSnapshots $existingSnapshots)
{
    New-VolumeSnapshot -VolumeId $QueueItem.VolumeId
}

# check if any have expired and remove them if so
Remove-VolumeExpiredSnapshots -VolumeId $QueueItem.VolumeId -SnapshotSettings $snapshotSettings -ExistingSnapshots $existingSnapshots


