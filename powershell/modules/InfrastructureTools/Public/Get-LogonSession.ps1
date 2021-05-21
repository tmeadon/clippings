function Get-LogonSession {
    <#
    .SYNOPSIS
    Returns the logged on users for all computers specified.

    .PARAMETER ComputerName
    Name(s) of computer(s) to query.  Accepts pipeline input (for example Get-ADComputer | Get-LogonSessions).

    .EXAMPLE
    Get-LogonSessions -ComputerName 'serv01' | Format-Table

    .EXAMPLE
    Get-ADComputer -Filter {name -like "serv*"} | Get-LogonSessions | Format-Table
    #>

    [CmdletBinding()]

    Param (

        # Name(s) of computer(s) to query.  Accepts pipeline input.
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('ComputerName')]
        [string]
        $Name

    )

    Process {

        Write-Verbose "$Name : checking connection"

        if (Test-Connection -ComputerName $Name -Quiet -Count 1) {

            $Users = query user /server:$Name 2>&1

            if ($Users -like "*USERNAME*") {

                # This transforms the output of 'query user' to a CSV object
                $Users = $Users | ForEach-Object {(($_.trim() -replace ">" -replace "(?m)^([A-Za-z0-9]{3,})\s+(\d{1,2}\s+\w+)", '$1  none  $2' -replace "\s{2,}", "," -replace "none", $null))} | ConvertFrom-Csv

            }
            else {

                $Users = $null

            }

            # Build and return a PSObject containing details of the logon sessions

            foreach ($User in $Users) {

                if ($User.ID -eq 'Disc') {

                    [PSCustomObject]@{
                        Computer = $Name
                        Username = $User.Username
                        State = 'Disconnected'
                        IdleTime = ((Get-Date) - (Get-Date "$($User.'Idle Time')")).Minutes
                        LogonTime = (Get-Date "$($User.'Idle Time')")
                    }
                }
                else {

                    [PSCustomObject]@{
                        Computer = $Name
                        Username = $User.Username
                        State = $User.State
                        IdleTime = $User.IdleTime
                        LogonTime = (Get-Date "$($User.'Logon Time')")
                    }

                }
            }
        }
    }
}
