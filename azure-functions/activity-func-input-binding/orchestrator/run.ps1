param($Context)

$output = @()

try 
{
    $output += Invoke-ActivityFunction -FunctionName 'getRecord' -Input $Context.Input.test.Value
}
catch
{
    # nothing
}


$output
