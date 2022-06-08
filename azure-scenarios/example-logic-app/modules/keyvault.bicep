param vaultName string
param location string
param msiName string

// create the key vault
resource vault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    enableRbacAuthorization: true
  
  }
}

// reference the built-in secrets user role
resource secretsUserRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

// reference the existing managed identity
resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: msiName
}

// assign the managed identity the secrets user role
resource msiSecretsUserAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(vault.id, msi.id, secretsUserRole.id)
  properties: {
    principalId: msi.properties.principalId
    roleDefinitionId: secretsUserRole.id
  }
  scope: vault
}

output vaultName string = vault.name

