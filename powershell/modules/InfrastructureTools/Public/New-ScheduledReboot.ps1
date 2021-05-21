function New-ScheduledReboot {
    <#
    .SYNOPSIS
    This function creates a new reboot scheduled task on remote computers at a specified date and time.

    .PARAMETER ComputerName
    Name of the computer on which to schedule the reboot

    .PARAMETER RebootDateTime
    DateTime object containing the date and time for the reboot

    .EXAMPLE
    New-ScheduledReboot -ComputerName serv01 -RebootDateTime (Get-Date "01/01/2019 02:00")

    .EXAMPLE
    Get-Content -Path .\ServersToReboot.txt | New-ScheduledReboot -RebootDateTime (Get-Date "01/01/2019 02:00")
    #>

    [CmdletBinding(SupportsShouldProcess)]

    Param
    (
        # Name of the computer on which to schedule the reboot
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('ComputerName')]
        [string]
        $Name,

        # DateTime object containing the date and time for the reboot
        [Parameter(Mandatory)]
        [datetime]
        $RebootDateTime

    )

    Begin {

        # Get the user's password for the scheduled task
        $UserPassword = Read-Host -Prompt "Enter the password for $env:USERNAME" -AsSecureString

    }
    Process {

        Try {

            Write-Verbose -Message "Connecting to $Name"

            # Test the computer is alive and configured for PSRemoting
            if (-not (Test-WSMan -ComputerName $Name -ErrorAction SilentlyContinue)) {

                throw "$Name`: unable to connect to WSMan service.  Ensure the computer is alive and configured for PSRemoting"

            }

            if ($PSCmdlet.ShouldProcess($Name)) {

                # Use PSRemoting to connect to the target computer(s) and schedule the task
                Invoke-Command -ComputerName $Name -ErrorAction Stop -ScriptBlock {

                    # Convert the datetime object to a string for use in the task's name
                    $StringDate = Get-Date -Date $using:RebootDateTime -Format "yyyy-MM-dd HH.mm.ss"

                    # Convert the password from secure string to plain text (required for Register-ScheduledTask)
                    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($using:UserPassword)
                    $PasswordPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

                    # Create and register the task
                    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Restart-Computer -Force'
                    $trigger = New-ScheduledTaskTrigger -Once -At $using:RebootDateTime
                    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboot $StringDate" -User "$env:USERNAME" -Password $PasswordPlainText

                } | Select-Object PSComputerName, TaskName, @{name='TriggerTime';expression={$_.Triggers.StartBoundary}}, State

            }

        }
        Catch {

            Write-Error $_.exception.message

        }
    }
}
