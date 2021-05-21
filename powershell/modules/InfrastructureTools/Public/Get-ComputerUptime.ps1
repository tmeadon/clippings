function Get-ComputerUptime
{
    <#
    .SYNOPSIS
    Returns uptime information for the specified computer(s)

    .PARAMETER ComputerName
    Name(s) of computer(s) to query.  Accepts pipeline input.

    .EXAMPLE
    Get-ComputerUptime -ComputerName 'server01'

    .EXAMPLE
    Get-Content -Path .\Computers.txt | Get-ComputerUptime
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWMICmdlet")]

    [CmdletBinding()]
    Param (

        # Name of computer to query
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Alias("ComputerName")]
        [string]
        $Name

    )

    Process {

        try {

            Write-Verbose "$Name : checking uptime"

            # Use WMI to query operating system information and then convert LastBootUpTime to a DateTime object
            $OperatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $Name -ErrorAction Stop
            $LastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)

            # Return a PSObject for the computer containing the name, last boot up time and the computed system uptime
            [PSCustomObject]@{
                Name = $Name
                LastBootUpTime = $LastBootUpTime
                Uptime = ((Get-Date) - $LastBootUpTime)
            }

        }
        catch {

            Write-Error $_.exception.message

        }
    }
}
