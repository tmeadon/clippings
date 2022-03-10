targetScope = 'subscription'

@secure()
param adminPassword string
param location string = 'uksouth'

var baseName = 'update-mgmt'

var vmConfigs = [
  {
    name: 'windows-gen1'
    os: 'windows'
    gen2: false
  }
  {
    name: 'windows-gen2'
    os: 'windows'
    gen2: true
  }
  {
    name: 'linux-gen1'
    os: 'linux'
    gen2: false
  }
  {
    name: 'linux-gen2'
    os: 'linux'
    gen2: true
  }
]

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: baseName
  location: location
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    location: location
    name: baseName
  }
}

module automation 'automation.bicep' = {
  scope: rg
  name: 'automation'
  params: {
    location: location
    name: baseName
  }
}

module logs 'logs.bicep' = {
  scope: rg
  name: baseName
  params: {
    automationAccountName: automation.outputs.name
    location: location
    name: baseName
  }
}

module vms 'vm.bicep' = [for item in vmConfigs: {
  scope: rg
  name: item.name
  params: {
    adminUsername: 'tom'
    adminPassword: adminPassword
    location: location
    gen2: item.gen2
    name: item.name
    os: item.os
    logAnalyticsName: logs.outputs.workspaceName
    vnetName: vnet.outputs.name
    subnetName: vnet.outputs.subnetName
  }
}]
