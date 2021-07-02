param name string
param location string
param vnetName string

resource pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: '${name}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2019-12-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
        }
      }
    ]
  }
  
}
