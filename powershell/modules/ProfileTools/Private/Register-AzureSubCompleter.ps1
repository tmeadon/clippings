function Register-AzureSubCompleter {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        # Register an argument completer for Azure subscriptions by first getting them in a background job
        Start-Job -Name "GetAzureSubscriptions" -ScriptBlock { Get-AzSubscription } | Out-Null

        Register-ArgumentCompleter -CommandName Set-AzContext -ParameterName Subscription -ScriptBlock {
            # If the job exists from the command Get-AzSubscription, receive the results & remove the job
            if ($job = Get-job -Name "GetAzureSubscriptions" | Wait-Job) {
                $azSubscriptions = Receive-Job -Id $job.Id | Select-Object -ExpandProperty name
                Remove-Job -Id $job.Id
            }
            # Add the completion results for the parameter
            $azSubscriptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new(
                    "'$_'"
                )
            }
        }
    }

    end {}
}