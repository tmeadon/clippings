param destroyTime string = '17:00'
targetScope = 'subscription'

resource bastionPeeredVnets 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'bastionPeeredVnets'
  location: 'uksouth'
  tags: {
    DestroyTime: destroyTime
  }
}

module vnets './vnets.bicep' = {
  name: 'vnets'
  scope: bastionPeeredVnets
}

module vm1 './vms.bicep' = {
  name: 'vm1'
  scope: bastionPeeredVnets
  params: {
    subnet: vnets.outputs.vnetuks1VmSubnet
    location: vnets.outputs.vnetuks1.location
    vmName: 'vm1'
  }
}

module vm2 './vms.bicep' = {
  name: 'vm2'
  scope: bastionPeeredVnets
  params: {
    subnet: vnets.outputs.vnetuks2VmSubnet
    location: vnets.outputs.vnetuks2.location
    vmName: 'vm2'
  }
}

module vm3 './vms.bicep' = {
  name: 'vm3'
  scope: bastionPeeredVnets
  params: {
    subnet: vnets.outputs.vneteus1VmSubnet
    location: vnets.outputs.vneteus1.location
    vmName: 'vm3'
  }
}

module vm4 './vms.bicep' = {
  name: 'vm4'
  scope: bastionPeeredVnets
  params: {
    subnet: vnets.outputs.vnetuks1VmSubnet
    location: vnets.outputs.vnetuks1.location
    vmName: 'vm4'
  }
}

module bastion './bastion.bicep' = {
  name: 'bastion'
  scope: bastionPeeredVnets
  params: {
    location: vnets.outputs.vnetuks1.location
    bastionSubnet: vnets.outputs.vnetuks1BastionSubnet
  }
}

module privateDns './privateDns.bicep' = {
  name: 'privateDns'
  scope: bastionPeeredVnets
  params: {
    linkedVnetIds: [
      vnets.outputs.vneteus1Id
      vnets.outputs.vnetuks1Id
      vnets.outputs.vnetuks2Id
    ]
  }
}
