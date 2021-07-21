param baseName string = uniqueString(subscription().id, resourceGroup().name)
param location string = resourceGroup().location

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'  
}

resource ai 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: baseName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }  
}

resource asp 'Microsoft.Web/serverfarms@2020-09-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  } 
}

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: baseName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }

  resource stgConnStr 'secrets' = {
    name: 'stgConnStr'
    properties: {
      value: 'DefaultEndpointsProtocol=https;AccountName=${stg.name};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', stg.name), '2015-05-01-preview').key1};EndpointSuffix=core.windows.net'
    }
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2020-09-01' = {
  name: baseName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    enableMultipleWriteLocations: false
  }
  kind: 'GlobalDocumentDB'

  resource database 'sqlDatabases' = {
    name: 'db'
    properties: {
      resource: {
        id: 'db'
      }
      options: {
        throughput: 400
      }
    }

    resource randomDataContainer 'containers' = {
      name: 'randomData'
      properties: {
        options: {}
        resource: {
          id: 'randomData'
          partitionKey: {
            paths: [
              '/id'
            ]
          }
        }
      }
    }    

    resource resourcesContainer 'containers' = {
      name: 'resources'
      properties: {
        options: {}
        resource: {
          id: 'resources'
          partitionKey: {
            paths: [
              '/id'
            ]
          }
        }
      }
    }   
  } 
}

resource functionApp 'Microsoft.Web/sites@2020-09-01' = {
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
      'AzureWebJobsStorage': '@Microsoft.KeyVault(SecretUri=${kv::stgConnStr.properties.secretUriWithVersion})'
      'FUNCTIONS_EXTENSION_VERSION': '~3'
      'FUNCTIONS_WORKER_RUNTIME': 'powershell'
      'FUNCTIONS_WORKER_RUNTIME_VERSION': '~7'
      'APPINSIGHTS_INSTRUMENTATIONKEY': ai.properties.InstrumentationKey
    }
  } 
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${kv.name}/replace'
  properties: {
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        tenantId: functionApp.identity.tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
