param name string
param location string = resourceGroup().location

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${name}-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${name}-spoke1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
    ]
  }
}

resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: 'hub-to-spoke1'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
    allowForwardedTraffic: true
  }
}

resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: 'spoke1-to-hub'
  parent: spokeVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowForwardedTraffic: true
  }
}

output hubVnetName string = hubVnet.name
output spokeVnetName string = spokeVnet.name
output vmSubnetName string = spokeVnet.properties.subnets[0].name
