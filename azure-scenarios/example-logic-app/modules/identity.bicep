param name string
param location string

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}

output name string = msi.name
