$personalAccessToken = ""

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))

$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

$releaseDefinitionId = "36"

$url = "https://vsrm.dev.azure.com/<account>/<project>/_apis/release/deployments?definitionId=$releaseDefinitionId"

$response = Invoke-RestMethod -Uri "$url" -ContentType 'application/json' -Headers $headers -Method Get -ErrorAction Stop

$response.value | where {$_.releaseEnvironment.name -eq 'test'} | sort queuedon -desc | select queuedon, deploymentstatus, operationstatus