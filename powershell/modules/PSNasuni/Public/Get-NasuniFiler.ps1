function Get-NasuniFiler {
    [CmdletBinding()]
    param
    (
        # Serial number of the filer to retrieve
        [Parameter()]
        [string]
        $FilerSerial
    )
    
    begin {}
    
    process
    {
        $relativeUri = 'filers/'

        if ($FilerSerial)
        {
            $relativeUri += "$FilerSerial/"
        }

        $response = Invoke-NasuniApiCall -RelativeUri $relativeUri -Method GET -PageSize 20

        foreach ($item in $response)
        {
            [NasuniFiler]::new($item)
        }
    }
    
    end {}
}