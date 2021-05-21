using namespace System.Net

param($Request, $TriggerMetadata)

$input = [pscustomobject]@{
    'test' = $Request.Query.test
}

$InstanceId = Start-NewOrchestration -FunctionName 'orchestrator' -InputObject $input
Write-Host "Started orchestration with ID = '$InstanceId'"

$Response = New-OrchestrationCheckStatusResponse -Request $Request -InstanceId $InstanceId
Push-OutputBinding -Name Response -Value $Response
