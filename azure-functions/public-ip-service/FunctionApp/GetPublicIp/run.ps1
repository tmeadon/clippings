using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Information -MessageData "Incoming request with headers $($Request.Headers | ConvertTo-Json)"
$xForwardedForHeaders = $Request.Headers."x-forwarded-for".Split(",")
$body = $xForwardedForHeaders[0].Split(":")[0]

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
