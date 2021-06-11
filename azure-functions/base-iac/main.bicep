param baseName string
param location string = 'uksouth'

var uniqueName = '${baseName}${uniqueString(baseName, resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: uniqueName
  location: location 
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
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
  name: uniqueName
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
