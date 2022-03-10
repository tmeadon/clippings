param name string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet0'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'bastion'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: 'bastion'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[1].id
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
    enableTunneling: true
  }
}

output name string = vnet.name
output subnetName string = vnet.properties.subnets[0].name
