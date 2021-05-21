$armParams = @{
    cosmosAccountName = "tmtest"
    cosmosDatabaseName = "tmtest"
    cosmosCollectionName = "tmtest"
}

$resourceGroup = 'cosmostest'

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile .\cosmos-collection-throughput.json -TemplateParameterObject $armParams