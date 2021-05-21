# get throughput for datbase
$apiVersion = "2015-04-08"
$resourceGroupName = "<rgName>"
$accountName = "<cosmosAccountname>"
$databaseName = "<dbName>"
$databaseThroughputResourceName = $accountName + "/sql/" + $databaseName + "/throughput"
$databaseThroughputResourceType = "Microsoft.DocumentDb/databaseAccounts/apis/databases/settings"

Get-AzResource -ResourceType $databaseThroughputResourceType -ApiVersion $apiVersion -ResourceGroupName $resourceGroupName -Name $databaseThroughputResourceName | Select-Object Properties


# get throughput for collection
$apiVersion = "2015-04-08"
$resourceGroupName = "<rgName>"
$accountName = "<cosmosAccountname>"
$databaseName = "<dbName>"
$collectionName = "<collName>"
$databaseThroughputResourceName = $accountName + "/sql/" + $databaseName + "/" + $collectionName + "/throughput"
$databaseThroughputResourceType = "Microsoft.DocumentDb/databaseAccounts/apis/databases/containers/settings"

Get-AzResource -ResourceType $databaseThroughputResourceType -ApiVersion $apiVersion -ResourceGroupName $resourceGroupName -Name $databaseThroughputResourceName | Select-Object Properties

