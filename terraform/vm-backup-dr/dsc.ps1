Configuration config
{
    Import-DscResource -ModuleName 'StorageDsc'

    $dataDisks = Get-Disk | Where-Object PartitionStyle -eq 'raw'

    Node localhost
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            AllowModuleOverWrite = $true
        }

        foreach ($disk in $dataDisks)
        {
            WaitForDisk "disk$($disk.DiskNumber)"
            {
                DiskId = $disk.UniqueId
                RetryIntervalSec = 60
                RetryCount = 60
                DiskIdType = 'UniqueId'
            }

            $diskLetter = (Get-ChildItem Function:[f-z]: -Name | Where-Object { !(Test-Path $_) } | Select-Object -First 1 ).Substring(0,1)

            Disk "volume$diskLetter"
            {
                DiskId = $disk.UniqueId
                DiskIdType = 'UniqueId'
                DriveLetter = $diskLetter
                FSFormat = 'NTFS'
                DependsOn = "[WaitForDisk]disk$($disk.DiskNumber)"
            }
        }
    }
}