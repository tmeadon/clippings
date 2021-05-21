function New-VolumeSnapshot
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        # Resource ID for the volume
        [Parameter(Mandatory)]
        [string]
        $VolumeId
    )

    begin {}

    process
    {
        $snapshotName = $VolumeId.Split('/')[-1] + "_" + (Get-Date -Format 'yyyy-MM-dd_HH-mm')

        $anfVol = Get-AzNetAppFilesVolume -ResourceId $VolumeId

        if ($PSCmdlet.ShouldProcess($anfVol.Name))
        {
            Write-Information -MessageData ('Snapshots: Volume {0} - creating snapshot {1}.' -f $anfVol.Name, $snapshotName)
            $anfVol | New-AzNetAppFilesSnapshot -Name $snapshotName | Out-Null
        }
    }

    end {}
}
