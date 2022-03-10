@allowed([
  'windows'
  'linux'
])
param os string
param gen2 bool
param name string
param location string
param vnetName string
param subnetName string
param adminUsername string
@secure()
param adminPassword string
param logAnalyticsName string

var size = 'Standard_D2a_v4'
var windowsImage = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: gen2 ? '2019-datacenter-gensecond' : '2019-datacenter'
  version: 'latest'
}
var linuxImage = {
  publisher: 'canonical'
  offer: '0001-com-ubuntu-server-focal'
  sku: gen2 ? '20_04-lts-gen2' : '20_04-lts'
  version: 'latest'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet::subnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
#disable-next-line BCP036
      vmSize: size
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    storageProfile: {
      imageReference: os == 'windows' ? windowsImage : linuxImage
      osDisk: {
        createOption: 'FromImage'
        name: '${name}-osdisk'
      }
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: name
    }
  }

  resource oms 'extensions' = {
    name: 'OMSExtension'
    location: location
    properties: {
      publisher: 'Microsoft.EnterpriseCloud.Monitoring'
      type: os == 'windows' ? 'MicrosoftMonitoringAgent' : 'OmsAgentForLinux'
      typeHandlerVersion: os == 'windows' ? '1.0' : '1.13'
      autoUpgradeMinorVersion: true
      settings: {
        workspaceId: logAnalyticsWorkspace.properties.customerId
      }
      protectedSettings: {
        workspaceKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}
