param 
(
    [Parameter(Mandatory)]
    [string]
    $ScheduledTaskName,

    [string]
    $ComputerName
)

if ($ComputerName)
{
    $cimSession = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    $taskInfo = Get-ScheduledTaskInfo -TaskName $ScheduledTaskName -CimSession $cimSession
}
else
{
    $taskInfo = Get-ScheduledTaskInfo -TaskName $ScheduledTaskName
}

# output in PRTG'S XML format
Write-Host "<prtg>"
Write-Host "<text></text>"
Write-Host "<result>"
Write-Host "<channel>Time since last run (mins)</channel>"
Write-Host "<value>$( (New-TimeSpan -Start $taskInfo.LastRunTime -End (Get-Date)).Minutes )</value>"
Write-Host "</result>"  
Write-Host "<result>"
Write-Host "<channel>Last run result</channel>"
Write-Host "<value>$( $info.LastTaskResult )</value>"
Write-Host "</result>"  
Write-Host "</prtg>"

