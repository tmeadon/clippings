function Disconnect-ExchangeOnlineSession {
    <#
    .SYNOPSIS
        This function removes an existing ExchangeOnline PowerShell session.

    .EXAMPLE
        Disconnect-ExchangeOnlineSession

    .LINK
        https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
    #>
    [CmdletBinding()]
    Param()

    # Block WhatIf from propagating to this function, it is not required.

    $WhatIfPreference = $false

    Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
}

