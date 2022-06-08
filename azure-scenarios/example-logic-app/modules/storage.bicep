param location string
param accountName string
param msiName string

// create the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: accountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
  }

  resource tableServices 'tableServices' = {
    name: 'default'
    
    resource customerDetailsTable 'tables' = {
      name: 'CustomerDetails'
    }
  }
}

// reference the built-in table reader role
resource tableReaderRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '76199698-9eea-4c19-bc75-cec21354c6b6'
}

// reference the existing msi
resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: msiName
}

// assign the table reader role to the msi on the storage account
resource tableReaderAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(storageAccount.id, msi.id, tableReaderRole.id)
  properties: {
    principalId: msi.properties.principalId
    roleDefinitionId: tableReaderRole.id
  }
  scope: storageAccount
}

output accountName string = storageAccount.name
output customerDetailsTableName string = storageAccount::tableServices::customerDetailsTable.name
