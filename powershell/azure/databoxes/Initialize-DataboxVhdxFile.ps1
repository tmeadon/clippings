function Initialize-DataboxVhdxFile {
    #Requires -Module Hyper-V    
    [CmdletBinding()]
    param (
        # Path for the new VHDX file including file name
        [Parameter(Mandatory)]
        [string]
        $VhdxFilePath,

        # Size for the VHDX file (e.g. 1TB)
        [Parameter(Mandatory)]
        [uint64]
        $VhdxSizeBytes,

        # Path for the mount point for the VHDX file
        [Parameter(Mandatory)]
        [string]
        $VhdxMountPoint,

        # System label to assign to the VHDX file's volume
        [Parameter(Mandatory)]
        [string]
        $VhdxVolumeSystemLabel
    )
    
    begin {}
    
    process {
        # create and mount the VHDX file
        try {
            $vhdxFile = New-VHD -Path $VhdxFilePath -Fixed -SizeBytes $VhdxSizeBytes -ErrorAction Stop
            Mount-VHD -Path $vhdxFile.Path -ErrorAction Stop
            $vhdxFile = Get-VHD -Path $vhdxFile.Path -ErrorAction Stop
        }
        catch {
            throw "Unable to create or mount the VHDX file.  Error: $($_.Exception.Message)"
        }

        # initialize the VHDX with an NTFS volume
        try {
            # get the disk object for the mounted VHDX and verify the correct disk is selected
            $disk = Get-Disk -Number $vhdxFile.DiskNumber

            if ($disk.Location -ne $vhdxFile.Path) {
                throw "Selected disk (disk $($disk.Number)) does not have the same location as the VHDX file"
            }

            Initialize-Disk -UniqueId $disk.UniqueId -PartitionStyle GPT -ErrorAction Stop
            $partition = New-Partition -DiskId $disk.UniqueId -UseMaximumSize -ErrorAction Stop
            Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel $VhdxVolumeSystemLabel -ErrorAction Stop
        }
        catch {
            throw "Unable to initialize the VHDX file.  Error: $($_.Exception.Message)"
        }

        # mount the new volume at the specified mount point and validate
        try {
            $mountDirectory = New-Item -Path $VhdxMountPoint -ItemType Directory -ErrorAction Stop
            Add-PartitionAccessPath -AccessPath $mountDirectory.FullName -DiskNumber $partition.DiskNumber -PartitionNumber $partition.PartitionNumber -ErrorAction Stop
        }
        catch {
            throw "Unable to create mount point for the new volume.  Error: $($_.Exception.Message)"
        }

        # return an object with details of the new VHDX file
        [PSCustomObject]@{
            VhdxPath = $vhdxFile.Path
            DiskNumber = $vhdxFile.DiskNumber
            MountPoint = $mountDirectory.FullName
        }
    }
    
    end {}
}