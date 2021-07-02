targetScope = 'subscription'

param baseName string
param location string = 'uksouth'
@secure()
param vmAdminPassword string

resource rsg 'Microsoft.Resources/resourceGroups@2019-10-01' = {
  name: baseName
  location: location  
}

module vnet 'network.bicep' = {
  scope: rsg
  name: 'vnet'
  params: {
    baseName: baseName
    location: location
  }
}

module vmA 'vm.bicep' = {
  scope: rsg
  name: 'vma'
  params: {
    adminPassword: vmAdminPassword
    asgId: vnet.outputs.asgAId
    location: location
    subnetId: vnet.outputs.subnetAId
    vmName: 'vma'
  }
}

module vmB 'vm.bicep' = {
  scope: rsg
  name: 'vmb'
  params: {
    adminPassword: vmAdminPassword
    asgId: vnet.outputs.asgBId
    location: location
    subnetId: vnet.outputs.subnetBId
    vmName: 'vmb'
  }
}

module vmC 'vm.bicep' = {
  scope: rsg
  name: 'vmc'
  params: {
    adminPassword: vmAdminPassword
    asgId: vnet.outputs.asgCid
    location: location
    subnetId: vnet.outputs.subnetCId
    vmName: 'vmc'
  }
}

module bastion 'bastion.bicep' = {
  scope: rsg
  name: 'bastion'
  params: {
    location: location
    name: baseName
    vnetName: vnet.outputs.vnetName
  }
}
