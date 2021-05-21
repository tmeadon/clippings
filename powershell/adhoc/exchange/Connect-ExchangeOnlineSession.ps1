function Connect-ExchangeOnlineSession {
    <#
    .SYNOPSIS
        This function creates a new ExchangeOnline PowerShell session.

    .PARAMETER ExchangeOnlineCredential
        Credential to use when establishing the ExchangeOnline session

    .EXAMPLE
        Connect-ExchangeOnlineSession -ExchangeOnlineCredential $PSCredential

    .LINK
        https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
    #>
    [CmdletBinding()]
    Param (

        # Credential to use when establishing the ExchangeOnline PowerShell session
        [Parameter()]
        [Alias("Credential")]
        [PSCredential]
        $ExchangeOnlineCredential

    )

    # Remove any existing Exchange OnPrem sessions and then only create a new session if one doesn't already exist in the current PowerShell session

    $WhatIfPreference = $false

    $ExistingPSSession = Get-PSSession | Where-Object -FilterScript {$_.ComputerName -eq 'outlook.office365.com' -and $_.ConfigurationName -eq 'Microsoft.Exchange'}

    if (-not $ExistingPSSession) {

        Write-Verbose -Message 'No existing Exchange Online session, creating a new one'

        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $ExchangeOnlineCredential -Authentication Basic -AllowRedirection

        # If the current execution policy is all signed then the Exchange commands will need to be signed when they are imported.  First, find a code signing
        # certificate in the current user's certificate store to do this (if one doesn't exist then error).  Then it then creates a PSSession to the ExchangeOnline
        # PowerShell endpoint and then imports commands from the session into the current PowerShell session.

        $ExecutionPolicy = Get-ExecutionPolicy

        if ($ExecutionPolicy -eq 'AllSigned') {

            $CodeSigningCert = Get-ChildItem -Path 'Cert:\CurrentUser\My' | Where-Object -FilterScript {$_.EnhancedKeyUsageList.FriendlyName -contains 'Code Signing'}

            Write-Verbose -Message 'Execution policy is AllSigned meaning a code-signing certificate is required'

            Write-Verbose -Message "Using code signing certificate with thumbprint $( $CodeSigningCert.Thumbprint )"

            try {

                if (-not $CodeSigningCert -or (-not (Test-Certificate -Cert $CodeSigningCert))) {

                    throw 'No valid code signing certificate found, please request one.'

                }

                # Block verbose output when running the 'Import-PSSession' cmdlet
                # Import the Exchange commands into the global scope so they can be used outside of this module, sign them with $CodeSigningCert

                $Verbose = $VerbosePreference

                $VerbosePreference = 'SilentlyContinue'

                Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking -Certificate $CodeSigningCert) -Global -DisableNameChecking

                $VerbosePreference = $Verbose

            }
            catch {

                Write-Error -Message $_.Exception.Message

            }

        }
        else {

            # Block verbose output when running the 'Import-PSSession' cmdlet
            # Import the Exchange commands into the global scope so they can be used outside of this module

            $Verbose = $VerbosePreference

            $VerbosePreference = 'SilentlyContinue'

            Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global -DisableNameChecking

            $VerbosePreference = $Verbose

        }

    }
    else {

        Write-Verbose -Message 'Existing Exchange Online session detected'

    }
}
