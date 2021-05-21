class NasuniFiler
{
    [string] $FilerSerial
    [string] $FilerDescription
    [string] $Build
    hidden [pscustomobject] $OriginalResponse

    NasuniFiler ([pscustomobject] $httpResponse)
    {
        if ((-not $httpResponse.serial_number) -or (-not $httpResponse.description) -or (-not $httpResponse.build))
        {
            throw "Supplied object does not contain properties expected for Nasuni API response"
        }

        $this.OriginalResponse = $httpResponse
        $this.FilerSerial = $httpResponse.serial_number
        $this.FilerDescription = $httpResponse.description
        $this.Build = $httpResponse.build
    }
}