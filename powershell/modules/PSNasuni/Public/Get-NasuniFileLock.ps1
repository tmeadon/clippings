function Get-NasuniFileLock {
    [CmdletBinding()]
    param
    (
        # Serial number for the filer to query
        [Parameter(Mandatory)]
        [string]
        $FilerSerial
    )
    
    begin {}
    
    process
    {
        Invoke-NasuniApiCall -RelativeUri "filers/$FilerSerial/cifsclients/locks/" -Method GET
    }
    
    end {}
}