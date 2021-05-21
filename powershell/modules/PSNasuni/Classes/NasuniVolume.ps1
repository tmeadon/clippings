class NasuniVolume 
{
    [string] $VolumeGuid
    [string] $VolumeName
    hidden [pscustomobject] $OriginalResponse
    [string[]] $Protocols

    NasuniVolume ([pscustomobject] $httpResponse)
    {
        $this.OriginalResponse = $httpResponse
        $this.VolumeGuid = $httpResponse.guid
        $this.VolumeName = $httpResponse.name
        $this.Protocols = $httpResponse.protocols.protocols
    }

    [NasuniVolumeFilerConnection[]] GetConnectedFilers ()
    {
        [System.Collections.Generic.List[NasuniVolumeFilerConnection]] $filerConnections = @()

        $connections = Invoke-NasuniApiCall -AbsoluteUri $this.OriginalResponse.links.filer_connections.href -Method Get | Where-Object connected -eq $true

        foreach ($item in $connections)
        {
            $filerConnections.Add([NasuniVolumeFilerConnection]::new($this.VolumeName, $false, $item))
        }

        $filerConnections.Add([NasuniVolumeFilerConnection]::new($this.VolumeName, $true, $this.OriginalResponse))

        return $filerConnections
    }
}
