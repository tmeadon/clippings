$personalAccessToken = ""

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))

$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

'36', '41', '38', '37', '35' | foreach {

    $releaseDefinitionId = $_

    $url = "https://vsrm.dev.azure.com/<account>/<project>/_apis/release/definitions/$($releaseDefinitionId)?api-version=5.0"

    $response = Invoke-RestMethod -Uri "$url" -ContentType 'application/json' -Headers $headers -Method Get -ErrorAction Stop

    [PSCustomObject]@{
        PipelineName = $response.name
        Environments = $response.environments.name
    }
}