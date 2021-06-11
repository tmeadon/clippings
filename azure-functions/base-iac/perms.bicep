param functionAppName string
param storageAccountName string

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName  
}

resource fa 'Microsoft.Web/sites@2019-08-01' existing = {
  name: functionAppName  
}

resource blobContrib 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(fa.name, stg.name, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  properties: {
    principalId: fa.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalType: 'ServicePrincipal'
  }
  scope: stg
}

resource queueContrib 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(fa.name, stg.name, '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
  properties: {
    principalId: fa.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalType: 'ServicePrincipal'
  }
  scope: stg  
}
