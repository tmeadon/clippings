param serverName string
param name string
param location string

resource db 'Microsoft.Sql/servers/databases@2019-06-01-preview' = {
  name: '${serverName}/${name}'
  location: location
  sku: {
    name: 'GP_Gen5_4'
    tier: 'GeneralPurpose'
  }
  properties: {
    createMode: 'Default'
  }
}
