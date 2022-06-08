targetScope = 'subscription'

param baseName string = 'vwan-test'
param location string = 'uksouth'

var hubs = [
  {
    name: 'uks'
    location: 'uksouth'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'eus'
    location: 'eastus'
    addressPrefix: '10.2.0.0/24'
  }
]

var spokes = [
  {
    name: 'spoke1-uks'
    location: 'uksouth'
    vnetAddressPrefix: '10.0.1.0/24'
    hubName: 'uks'
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.0.1.0/25'
      }
    ]
  }
  {
    name: 'spoke2-eus'
    location: 'eastus'
    vnetAddressPrefix: '10.1.1.0/24'
    hubName: 'eus'
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.1.1.0/25'
      }
    ]
  }
]

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: baseName
  location: location
}

module vwan 'modules/vwan.bicep' = {
  scope: rg
  name: 'vwan'
  params: {
    hubs: hubs
    location: 'uksouth'
  }
}

module spokeModule 'modules/spoke.bicep' = [for item in spokes: {
  scope: rg
  name: item.name
  params: {
    name: item.name
    location: item.location
    vnetAddressPrefix: item.vnetAddressPrefix
    subnets: item.subnets
    // hubName: item.hubName
  }
  dependsOn: [
    vwan
  ]
}]

module vms 'modules/windows.bicep' = [for (item, index) in spokes: {
  scope: rg
  name: 'vm-${item.name}'
  params: {
    name: 'vm-${item.name}'
    subnetName: item.subnets[0].name
    vnetName: item.name
    location: item.location
  }
  dependsOn: [
    spokeModule
  ]
}]
