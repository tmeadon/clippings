targetScope = 'subscription'

param baseName string = 'scsm-connector'
param location string = 'uksouth'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: baseName
  location: location
}

// managed identity
module msi 'modules/identity.bicep' = {
  scope: rg
  name: 'msi'
  params: {
    location: location
    name: '${baseName}-msi'
  }
}

// storage account
module storage 'modules/storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    accountName: uniqueString(rg.id)
    location: location
    msiName: msi.outputs.name
  }
}

// key vault
module keyVault 'modules/keyvault.bicep' = {
  scope: rg
  name: 'keyVault'
  params: {
    location: location
    vaultName: uniqueString(rg.id)
    msiName: msi.outputs.name
  }
}

// logic app
module logicapp 'modules/logicapp.bicep' = {
  scope: rg
  name: 'logicapp'
  params: {
    keyVaultName: keyVault.outputs.vaultName
    location: location
    msiName: msi.outputs.name
    name: baseName
    storageAccountName: storage.outputs.accountName
  }
}
