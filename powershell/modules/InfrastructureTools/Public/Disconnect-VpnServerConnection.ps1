function Disconnect-VpnServerConnection
{
    <#
    .SYNOPSIS
    Disconnects a connected VPN client on an RRAS server

    .PARAMETER ComputerName
    Computer name of the vpn server hosting the connection to disconnect
    
    .PARAMETER Credential
    Credential to use to connect to the vpn server
    
    .PARAMETER ClientIpAddress
    IP address of the vpn client to disconnect
    
    .EXAMPLE
    Disconnect-VpnServerConnection -ClientIpAddress 10.219.112.4 -ComputerName vpn-server-1 -Credential (Get-Credential)

    .EXAMPLE
    Get-VpnServerConnections -ComputerName vpn-1, vpn-2 | Where-Object ConnectionStartTime -lt (Get-Date).AddDays(-10) | Disconnect-VpnServerConnection
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # computer name of the vpn server hosting the connection to disconnect
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('VpnServer')]
        [string]
        $ComputerName,

        # credential to use to connect to the vpn server
        [Parameter()]
        [pscredential]
        $Credential,

        # ip address of the vpn client to disconnect
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ClientIpAddress
    )

    Process
    {
        if ($ComputerName)
        {
            if ($Credential)
            {
                $session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
            }
            else
            {
                $session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
            }
    
            $invokeCmdParams = @{
                Session = $session
            }
        }

        if ($PSCmdlet.ShouldProcess($ClientIpAddress))
        {
            Invoke-Command @invokeCmdParams -ScriptBlock {

                Disconnect-VpnUser -HostIPAddress $using:ClientIpAddress 
    
            }
        }

        if ($session)
        {
            Remove-PSSession -Session $session -WhatIf:$false
        }
    }
}
