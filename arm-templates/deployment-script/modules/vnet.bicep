param name string
param location string
param addressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'subnet0'
        properties: {
          addressPrefix: addressPrefix
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
