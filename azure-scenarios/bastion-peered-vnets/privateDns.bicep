param linkedVnetIds array

resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'meadon.local'
  location: 'global'
  properties: {}
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in linkedVnetIds: {
  name: 'vnetLink${i}'
  location: 'global'
  parent: zone
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnetId
    }
  }
}]
