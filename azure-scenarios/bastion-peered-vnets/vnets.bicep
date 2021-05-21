resource vnetuks1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'vnetuks1'
  location: 'uksouth'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

resource vnetuks2 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'vnetuks2'
  location: 'uksouth'
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

resource vneteus1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'vneteus1'
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.2.0.0/24'
        }
      }
    ]
  }
}

resource vnetuks1ToVnetuks2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: 'vnetuks1ToVnetuks2'
  parent: vnetuks1
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vnetuks2.id
    }
  }
}

resource vnetuks2ToVnetuks1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: 'vnetuks2ToVnetuks1'
  parent: vnetuks2
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vnetuks1.id
    }
  }
}

resource vnetuks1ToVneteus1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: 'vnetuks1ToVneteus1'
  parent: vnetuks1
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vneteus1.id
    }
  }
}

resource vneteus1ToVnetuks1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: 'vneteus1ToVnetuks1'
  parent: vneteus1
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vnetuks1.id
    }
  }
}

output vnetuks1 object = vnetuks1
output vnetuks2 object = vnetuks2
output vneteus1 object = vneteus1
output vnetuks1BastionSubnet object = vnetuks1.properties.subnets[0]
output vnetuks1VmSubnet object = vnetuks1.properties.subnets[1]
output vnetuks2VmSubnet object = vnetuks2.properties.subnets[0]
output vneteus1VmSubnet object = vneteus1.properties.subnets[0]
output vnetuks1Id string = vnetuks1.id
output vnetuks2Id string = vnetuks2.id
output vneteus1Id string = vneteus1.id
