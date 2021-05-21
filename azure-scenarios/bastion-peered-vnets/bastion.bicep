param bastionSubnet object
param location string

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'bastion-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: 'bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ipconfig'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: bastionSubnet
        }
      }
    ]
  }
}
