function Get-MyPublicIp {
    [CmdletBinding()]
    param ()

    Process {
        (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    }
}