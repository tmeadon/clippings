$Destination = "8.8.8.8"

$End = (Get-Date).AddHours(8)

$ScriptBlock = {
    while ((Get-Date) -lt $using:End) {
        if ( -not (Test-Connection -ComputerName $using:Destination -Count 1 -Quiet) ) {
            New-BurntToastNotification -Text ($using:Destination + " is offline"), ("Last checked :" + (Get-Date).ToString())   -UniqueIdentifier $using:Destination
        }
        Start-Sleep -Seconds 5
    }
}

Start-Job -Name CheckConnection -ScriptBlock $ScriptBlock