function Get-NasuniVolume {
    [CmdletBinding()]
    param
    (
        # The GUID for the specific volume to retrieve
        [Parameter()]
        [string]
        $VolumeGuid
    )
    
    begin {}
    
    process
    {
        $relativeUri = 'volumes/'

        if ($VolumeGuid)
        {
            $relativeUri += "$VolumeGuid/"
        }

        $response = Invoke-NasuniApiCall -RelativeUri $relativeUri -Method GET -PageSize 20

        foreach ($item in $response)
        {
            [NasuniVolume]::new($item)
        }
    }
    
    end {}
}