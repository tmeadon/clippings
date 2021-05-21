$database = "<database>"
$server = "<serverHostname>"
$username = "<username>"
$password = "<password>"

$params = @{
    Database = $database
    ServerInstance = $server
    Username = $username
    Password = $password
    Query = "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
}

$response = Invoke-SqlCmd @params

$response