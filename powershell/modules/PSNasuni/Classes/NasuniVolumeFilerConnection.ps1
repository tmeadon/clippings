class NasuniVolumeFilerConnection
{
    [string] $VolumeName
    [string] $FilerDescription
    [string] $FilerSerial
    [bool] $IsOwner

    NasuniVolumeFilerConnection ([string] $volumeName, [bool] $isOwner, [PSCustomObject] $httpResponse)
    {
        $filer = Get-NasuniFiler -FilerSerial $httpResponse.filer_serial_number
        
        $this.VolumeName = $volumeName
        $this.FilerDescription = $filer.FilerDescription
        $this.FilerSerial = $filer.FilerSerial
        $this.IsOwner = $isOwner        
    }
}