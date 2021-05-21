$subscription = "<subName>"
$cosmosAccountName = "<cosmosAccountName>"
$resourceGroupName = "<rg>"
$databaseName = "<dbName>"
$collectionName = "<collectionName>"
$collectionPartitionKey = "<partitionKey>"

# Connect the Az module to the right subscription
$null = Set-AzContext -Subscription $subscription

# Store the CosmosDb connection details
$ctx = New-CosmosDbContext -Account $cosmosAccountName -ResourceGroupName $resourceGroupName

Get-CosmosDbDocument -Context $ctx -CollectionId $collectionName -Database $databaseName | foreach {
    Remove-CosmosDbDocument -Context $ctx -CollectionId $collectionName -Database $databaseName -Id $_.id -PartitionKey $_.($collectionPartitionKey)
} 
