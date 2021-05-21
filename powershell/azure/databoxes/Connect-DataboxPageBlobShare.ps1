function Connect-DataboxPageBlobShare {
    [CmdletBinding()]
    param (
        # IP address for the databox (assigned to the DATA-1 interface)
        [Parameter(Mandatory)]
        [ipaddress]
        $DataboxIpAddress,

        # Username for the databox (provided by Azure)
        [Parameter(Mandatory)]
        [string]
        $DataboxUsername,

        # Password for the databox (provided by Azure)
        [Parameter(Mandatory)]
        [securestring]
        $DataboxPassword,

        # Drive letter to mount the databox page blob share to
        [Parameter(Mandatory)]
        [string]
        $DriveLetter
    )
    
    begin {}
    
    process {
        # create a PsCredential object for the smb connection
        $credential = New-Object -TypeName 'System.Management.Automation.PsCredential' -ArgumentList @($DataboxUsername, $DataboxPassword)

        # prepare the page blob share path
        $sharePath = "\\{0}\{1}_PageBlob" -f $DataboxIpAddress, $DataboxUsername

        # attempt to map the drive, test the path exists and catch any exceptions
        try {
            New-PSDrive -Name $DriveLetter -Root $sharePath -PSProvider 'FileSystem' -Credential $credential
            
            $mappedDrivePath = "{0}:\" -f $DriveLetter

            if (-not (Test-Path -Path $mappedDrivePath)) {
                throw "Path $mappedDrivePath does not exist."
            }
        }
        catch {
            Write-Error -Message "Error encountered whilst connecting the databox page blob share: $($_.Exception.Message)"
        }
    }
    
    end {}
}