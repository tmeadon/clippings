function Invoke-NasuniApiCall {
    [CmdletBinding()]
    param
    (
        # URI relative to the base path (https://<hostname>/api/v1.1/)
        [Parameter(Mandatory, ParameterSetName = "RelativeUri")]
        [string]
        $RelativeUri,

        # Absolute URI for the resource
        [Parameter(Mandatory, ParameterSetName = "AbsoluteUri")]
        [string]
        $AbsoluteUri,

        # REST method to invoke
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method,

        # Body to post (optional)
        [Parameter()]
        [string]
        $Body,

        # The maximum number of objects to return per request
        [Parameter()]
        [int]
        $PageSize,

        # The maximum number of retries
        [Parameter()]
        [int]
        $Retries = 5
    )
    
    begin {}
    
    process
    {
        if ((-not $script:baseUri) -or (-not $script:requestHeaders))
        {
            throw "Not connected to Nasuni API host.  Please run 'Connect-NasuniApi'."
        }

        $restMethodParams = @{
            Method = $Method
            Headers = $script:requestHeaders
        }

        switch ($PSCmdlet.ParameterSetName) 
        {
            "RelativeUri" { $restMethodParams['Uri'] = ($script:baseUri + $RelativeUri) }
            "AbsoluteUri" { $restMethodParams['Uri'] = $AbsoluteUri }
        }

        if ($Body)
        {
            $restMethodParams['Body'] = $Body
        }

        if ($PageSize)
        {
            $restMethodParams['Uri'] = $restMethodParams['Uri'] + "?limit=$PageSize"
        }

        [System.Collections.Generic.List[PSCustomObject]] $returnItems = @()

        do
        {
            if ($local:result.next)
            {
                $restMethodParams['Uri'] = $result.next
            }

            $attempt = 0

            do
            {
                try
                {
                    $attempt++
                    $local:result = Invoke-RestMethod @restMethodParams -ErrorAction Stop
                    $success = $true
                }
                catch
                {
                    if ($_.Exception.Response.StatusCode.value__ -eq '429')
                    {
                        $success = $false
                        Start-Sleep -Seconds $attempt
                    }
                    else
                    {
                        throw $_
                    }
                }
            } while ((-not $success) -and ($attempt -le $Retries))
            
            if ($local:result.items)
            {
                foreach ($item in $local:result.items)
                {
                    $returnItems.Add([PSCustomObject] $item)
                }
            }
            else
            {
                $returnItems.Add([PSCustomObject] $result)
            }

        } while ($local:result.next)

        $returnItems

    }

    end {}
}