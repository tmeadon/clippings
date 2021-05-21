param($Context)

$parallel = @()

$parallel += Invoke-ActivityFunction -FunctionName 'hello' -Input 'Tokyo' -NoWait
$parallel += Invoke-ActivityFunction -FunctionName 'fail' -Input 'blah' -NoWait
$results = Wait-ActivityFunction -Task $parallel
$blah = $results.success
$results
