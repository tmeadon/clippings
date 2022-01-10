targetScope =  'subscription'

param baseName string = 'tmsentinel'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: baseName
  location: 'uksouth'
}

module logs 'logs.bicep' = {
  scope: rg
  name: 'logs'
  params: {
    workspaceName: baseName
  }
}

module azureActivityDataConnector 'connectors/azure-activity.bicep' = {
  name: 'azure-activity'
  params: {
    workspaceResourceId: logs.outputs.workspaceResourceId 
  }
}

module keyVaultDataConnector 'connectors/keyvault.bicep' = {
  name: 'keyvault-diags'
  params: {
    workspaceResourceId: logs.outputs.workspaceResourceId 
  }
}
