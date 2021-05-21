#PowerShell
$resourceGroup = '<rg>'
$functionName = '<appName>'
$publishingCredentials = Invoke-AzResourceAction -ResourceGroupName $resourceGroup -ResourceType "Microsoft.Web/sites/config" -ResourceName "$functionName/publishingcredentials" -Action list -ApiVersion 2015-08-01 -Force

$username = $publishingCredentials.properties.publishingUserName
$password = $publishingCredentials.properties.publishingPassword
$filePath = "<zipPath>"
$apiUrl = "https://$functionName.scm.azurewebsites.net/api/zipdeploy"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
$userAgent = "powershell/1.0"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UserAgent $userAgent -Method POST -InFile $filePath -ContentType "multipart/form-data"



# check deployment
$apiUrl = "https://$functionName.scm.azurewebsites.net/api/deployments"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UserAgent $userAgent -Method GET



