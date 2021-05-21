# parameters
$toAddress = '<to>'
$fromAddress = '<from>'
$credential = Get-Credential

$params = @{
    To = $toAddress
    From = $fromAddress
    Subject = 'Test'
    Body = 'Test'
    SmtpServer = 'smtp.office365.com'
    Port = '587'
    Credential = $credential
    UseSsl = $true
}

Send-MailMessage @params