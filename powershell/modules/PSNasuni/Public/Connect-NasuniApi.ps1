function Connect-NasuniApi {
    [CmdletBinding()]
    param
    (
        # Hostname for the Nasuni API host 
        [Parameter(Mandatory)]
        [string]
        $Hostname,

        # Hostname for the Nasuni API host 
        [Parameter(Mandatory)]
        [pscredential]
        $Credential
    )
    
    begin {}
    
    process
    {
        # set the TLS type
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # store the base and token generation uris
        $script:baseUri = ("https://{0}/api/v1.1/" -f $Hostname)
        $tokenUri = $script:baseUri + "auth/login/"

        # generate the REST headers
        $script:requestHeaders = @{
            'Accept' = 'application/json'
            'Content-Type' = 'application/json'
        }

        $requestBody = @{
            'username' = $Credential.UserName
            'password' = $Credential.GetNetworkCredential().Password
        }

        $result = Invoke-RestMethod -Uri $tokenUri -Method Post -Headers $script:requestHeaders -Body ($requestBody | ConvertTo-Json)

        # save the request headers for use in other functions
        if (-not $result)
        {
            $script:requestHeaders = $null
        }
        else
        {
            $script:requestHeaders['Authorization'] = ("Token {0}" -f $result.token)
        }
    }
    
    end {}
}