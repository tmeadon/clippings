param name string
param location string

@description('An array of objects with the following properties: `name`, `tier`, `sku`')
param dbs array 

@secure()
param adminPassword string

resource server 'Microsoft.Sql/servers@2020-08-01-preview' = {
  name: name
  location: location
  properties: {
    administratorLogin: 'tom'
    administratorLoginPassword: adminPassword
    publicNetworkAccess: 'Enabled'
  }

  resource databases 'databases' = [for item in dbs: {
    name: item.name
    location: location
    sku: {
      name: item.sku
    }
    properties: {
      createMode: 'Default' 
    }
  }]
}
