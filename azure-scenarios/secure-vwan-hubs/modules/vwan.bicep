param name string = 'vwan'
param location string
param hubs array

resource vwan 'Microsoft.Network/virtualWans@2021-08-01' = {
  name: name
  location: location
  properties: {
    allowVnetToVnetTraffic: true
  }
}

resource wvanHubs 'Microsoft.Network/virtualHubs@2021-08-01' = [for item in hubs: {
  name: item.name
  location: item.location
  properties: {
    virtualWan: {
      id: vwan.id
    }
    addressPrefix: item.addressPrefix
  }
}]
