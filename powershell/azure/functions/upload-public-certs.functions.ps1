function Get-WebsiteCertChain
{
    [CmdletBinding()]
    param
    (
        # hostname of the website to get the certificate chain for 
        [Parameter(Mandatory)]
        [string]
        $Hostname
    )
    
    process
    {
        Write-Verbose -Message "Downloading public certs from $Hostname"

        # connect to the site's url and get the certificate from the ssl stream
        $tcpClient = [System.Net.Sockets.TcpClient]::new($Hostname, '443')
        $stream = [System.Net.Security.SslStream]::new($tcpClient.GetStream())
        $stream.AuthenticateAsClient($Hostname)
        $cert = $stream.RemoteCertificate

        # build the full chain and output to the pipeline
        $chain = [System.Security.Cryptography.X509Certificates.X509Chain]::new()
        $null = $chain.Build($cert)
        Write-Output -InputObject $chain
    }
}

function Get-FunctionAppExistingCertThumbprints
{
    [CmdletBinding()]
    param
    (
        # resource ID of the function app to query
        [Parameter(Mandatory)]
        [string]
        $ResourceId
    )
    
    process
    {
        # use the azure rest api to determine which public certificates are uploaded to the function app already
        $siteCerts = ((Invoke-AzRestMethod -Path ($ResourceID + '/publicCertificates?api-version=2019-08-01') -Method GET).Content | ConvertFrom-Json).value
        Write-Output -InputObject $siteCerts.properties.thumbprint
    }
}

function Add-FunctionAppMissingCerts
{
    [CmdletBinding()]
    param
    (
        # resource ID of the function app to query
        [Parameter(Mandatory)]
        [string]
        $ResourceId,

        # x509 chain contaning the certs to upload
        [Parameter(Mandatory)]
        [System.Security.Cryptography.X509Certificates.X509Chain]
        $CertChain,

        # a list of the function app's existing public cert thumbprints
        [Parameter(Mandatory)]
        [string[]]
        $ExistingThumbprints,

        # prefix to use when naming certificates in function app
        [Parameter(Mandatory)]
        [string]
        $CertNamePrefix
    )
    
    process
    {
        # walk the certificate chain and upload each certificate if missing
        for ($i = 0; $i -lt $CertChain.ChainElements.Count; $i++)
        {
            $cert = $CertChain.ChainElements[$i].Certificate
    
            if ($cert.Thumbprint -notin $ExistingThumbprints)
            {
                Write-Verbose -Message ('Uploading certificate with thumbprint {0} and subject {1}' -f $cert.Thumbprint, $cert.Subject)
    
                $uploadPayload = @{
                    properties = @{
                        blob = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
                        publicCertificateLocation = 'LocalMachineMy'
                    }
                }
    
                $uploadParams = @{
                    Path = ('{0}/publicCertificates/{1}_{2}?api-version=2019-08-01' -f $ResourceId, $CertNamePrefix, $i)
                    Method = 'PUT'
                    Payload = $uploadPayload | ConvertTo-Json
                }
    
                $null = Invoke-AzRestMethod @uploadParams
            }
            else
            {
                Write-Verbose -Message ('Certificate with thumbprint {0} and subject {1} does not need to be uploaded' -f $cert.Thumbprint, $cert.Subject)
            }
        }
    }
}

function Test-FunctionAppSettingsUpdateRequired
{
    [CmdletBinding()]
    param
    (
        # function app object to test
        [Parameter(Mandatory)]
        [Microsoft.Azure.Commands.WebApps.Models.PSSite]
        $FunctionApp,

        # list of public cert thumbprints that have been uploaded
        [Parameter(Mandatory)]
        [string[]]
        $PublicCertThumbprints
    )
    
    process
    {
        $appSettingName = 'WEBSITE_LOAD_ROOT_CERTIFICATES'

        if ($FunctionApp.SiteConfig.AppSettings.Name -contains $appSettingName)
        {
            $existingThumbprints = $FunctionApp.SiteConfig.AppSettings.Where({$_.Name -eq $appSettingName}).Value.Split(',')

            if (Compare-Object -ReferenceObject $existingThumbprints -DifferenceObject $PublicCertThumbprints)
            {
                return $true
            }
        }
        else
        {
            return $true
        }

        return $false
    }
}

function Update-FunctionAppSettings
{
    [CmdletBinding()]
    param
    (
        # function app object to update
        [Parameter(Mandatory)]
        [Microsoft.Azure.Commands.WebApps.Models.PSSite]
        $FunctionApp,
        
        # list of public cert thumbprints that have been uploaded
        [Parameter(Mandatory)]
        [string[]]
        $PublicCertThumbprints
    )
    
    process
    {
        # convert the existing app settings to hashtable, set the app setting and update the function app
        Write-Verbose "Updating app settings to include all public cert thumbprints"

        $appSettingName = 'WEBSITE_LOAD_ROOT_CERTIFICATES'

        $newAppSettings = @{}

        foreach ($setting in $FunctionApp.SiteConfig.AppSettings)
        {
            $newAppSettings.Add($setting.Name, $setting.Value)
        }

        $newAppSettings[$appSettingName] = $PublicCertThumbprints -join ","

        $null = Set-AzWebApp -Name $functionApp.Name -ResourceGroupName $functionApp.ResourceGroup -AppSettings $newAppSettings
    }
}