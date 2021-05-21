function Get-VpnServerConnections 
{
    <#
    .SYNOPSIS
    Lists the clients currently connected to an RRAS VPN server
    
    .PARAMETER ComputerName
    Name of the vpn server to query
    
    .PARAMETER Credential
    Credential to use when connecting to remote computer
    
    .EXAMPLE
    Get-VpnServerConnections -ComputerName vpn-1 -Credential (Get-Credential)
    #>

    [CmdletBinding()]
    Param
    (
        # name of the vpn server to query
        [Parameter()]
        [string[]]
        $ComputerName,

        # credential to use when connecting to remote computer
        [Parameter()]
        [pscredential]
        $Credential
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

        $selectObjParams = @{
            Property = @(
                @{n='VpnServer';e={$_.PSComputerName}}
                @{n='Username';e={$_.Username}} 
                'ClientIPAddress'
                'ClientExternalAddress' 
                'ConnectionStartTime'
            )
        }
    
        Invoke-Command @invokeCmdParams -ScriptBlock {Get-RemoteAccessConnectionStatistics} | Select-Object @selectObjParams

        if ($session)
        {
            Remove-PSSession -Session $session
        }
    
    }
}
