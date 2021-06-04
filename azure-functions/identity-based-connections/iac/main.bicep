var baseName = 'tmtest0198'
var location = 'uksouth'
var queueName = 'queue'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: baseName
  location: location 
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource qServices 'queueServices@2019-06-01' = {
    name: 'default'

    resource q 'queues@2019-06-01' = {
      name: queueName     
    }
  }
}

resource asp 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource ai 'Microsoft.Insights/components@2015-05-01' = {
  name: baseName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource fa 'Microsoft.Web/sites@2019-08-01' = {
  name: baseName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: asp.id
  }
  kind: 'functionapp'

  resource appSettings 'config@2018-11-01' = {
    name: 'appsettings'
    properties: {
      'AzureWebJobsStorage__accountName': stg.name
      'FUNCTIONS_WORKER_RUNTIME': 'powershell'
      'FUNCTIONS_WORKER_RUNTIME_VERSION': '~7'
      'queueName': queueName
      'APPINSIGHTS_INSTRUMENTATIONKEY': ai.properties.InstrumentationKey
    }
  }
}

module perms 'perms.bicep' = {
  name: 'perms'
  params: {
    functionAppName: fa.name
    storageAccountName: stg.name
  }  
}
