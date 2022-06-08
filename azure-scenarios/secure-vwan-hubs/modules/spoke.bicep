param name string
param location string
param vnetAddressPrefix string
param subnets array
// param hubName string = ''

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for item in subnets: {
        name: item.name
        properties: {
          addressPrefix: item.addressPrefix
        }
    }]
  }
}

// resource hub 'Microsoft.Network/virtualHubs@2021-08-01' existing = {
//   name: hubName

//   resource connection 'hubVirtualNetworkConnections' = {
//     name: name
//     properties: {
//       remoteVirtualNetwork: {
//         id: vnet.id
//       }
//     }
//   }
// }

output vnetName string = vnet.name
