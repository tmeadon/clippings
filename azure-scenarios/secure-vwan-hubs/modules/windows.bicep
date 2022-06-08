param name string
param location string = resourceGroup().location
param vnetName string
param subnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${name}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::subnet.id
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2as_v4'
    }
    osProfile: {
      computerName: name
      adminUsername: 'tom'
      adminPassword: 'P@55w0rd!'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
