param msiName string
param galleryId string
param location string = resourceGroup().location

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: msiName
  location: location
}

resource gallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: last(split(galleryId, '/'))  
}

resource galleryPerms 'Microsoft.Authorization/roleAssignments@2020-03-01-preview' = {
  name: guid(msi.id, galleryId, resourceGroup().id)
  properties: {
    principalId: msi.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
  scope: gallery
}

output msiId string = msi.id
