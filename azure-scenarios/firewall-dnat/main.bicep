targetScope = 'subscription'

var baseName = 'fw-nat-test'
var location = 'uksouth'

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: baseName
  location: location
  tags: {
    DestroyTime: '11:00'
  }
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    name: baseName
  }
}

module vm 'windows.bicep' = {
  scope: rg
  name: 'vm'
  params: {
    name: baseName
    subnetName: vnet.outputs.vmSubnetName
    vnetName: vnet.outputs.spokeVnetName
  }
}

module fw 'firewall.bicep' = {
  scope: rg
  name: 'fw'
  params: {
    name: baseName
    vmPrivateIp: vm.outputs.privateIpAddress
    vnetName: vnet.outputs.hubVnetName
  }
}
