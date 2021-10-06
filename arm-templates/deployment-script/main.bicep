targetScope = 'subscription'

param baseName string = 'deployment-script-demo'
param location string = 'uksouth'

var vmNames = [
  'vm1'
  'vm2'
]

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: baseName
  location: location
}

module vnet 'modules/vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefix: '10.0.0.0/24'
    location: location
    name: 'vnet'
  }
}

module vms 'modules/vm.bicep' = [for (item, index) in vmNames: {
  scope: rg
  name: item
  params: {
    name: item
    location: location
    numDataDisks: 2
    subnetId: vnet.outputs.subnetId
  }
}]

module initDisks 'modules/init-disks.bicep' = {
  scope: rg
  name: 'initDisks'
  dependsOn: [
    vms
  ]
}
