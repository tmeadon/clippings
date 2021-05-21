$header = @{
    "Ocp-Apim-Subscription-Key" = '<key>'
}


$apimHostname = '<hostName>'

Invoke-RestMethod -Uri "https://$apimHostname/tmapi/function01?name=tom" -Headers $header -Method Post
Invoke-RestMethod -Uri "https://$apimHostname/tmapi/function02?name=tom" -Headers $header -Method Post
Invoke-RestMethod -Uri "https://$apimHostname/tmapi/function03?name=tom" -Headers $header -Method Post
Invoke-RestMethod -Uri "https://$apimHostname/tmapi/function04?name=tom" -Headers $header -Method Post