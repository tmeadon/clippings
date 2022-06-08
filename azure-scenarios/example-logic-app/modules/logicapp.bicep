param name string
param location string
param msiName string
param keyVaultName string
param storageAccountName string

var keyVaultConnectionName = '${keyVaultName}-kv-connection'
var storageConnectionName = '${storageAccountName}-sa-connection'

// reference the existing managed identity
resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: msiName
}

// reference the existing key vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

// reference the existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
}

// create a connection to the key vault
resource keyVaultConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: keyVaultConnectionName
  location: location
  properties: {
    api: {
      id: 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${keyVault.location}/managedApis/keyvault'
    }
    displayName: keyVaultConnectionName
    parameterValueType: 'Alternative'
    alternativeParameterValues: {
      'vaultName': keyVaultName
    }
  }
}

// create a connection to the table storage
resource storageConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: storageConnectionName
  location: location
  properties: {
    api: {
      id: 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${storageAccount.location}/managedApis/azuretables'
    }
    displayName: storageConnectionName
    customParameterValues: {}
    parameterValues: {
      storageaccount: storageAccount.name
      sharedKey: storageAccount.listKeys().keys[0].value
    }
  }
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
  properties: {
    // definition: {
    //   '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
    //   contentVersion: '1.0.0.0'
    //   parameters: {
    //     '$connections': {
    //       defaultValue: {}
    //       type: 'Object'
    //     }
    //   }
    //   actions: {}
    //   triggers: {}
    //   outputs: {}
    // }
    definition: json(loadTextContent('./test-workflow.json')).definition
    parameters: {
      '$connections': {
        value: {
          azuretables: {
            connectionId: storageConnection.id
            connectionName: storageConnection.name
            id: storageConnection.properties.api.id
          }
          keyvault: {
            connectionId: keyVaultConnection.id
            connectionName: keyVaultConnection.name
            connectionProperties: {
              authentication: {
                identity: msi.id
                type: 'ManagedServiceIdentity'
              }
            }
            id: keyVaultConnection.properties.api.id
          }
        }
      }
    }
    state: 'Enabled'
  }
}
