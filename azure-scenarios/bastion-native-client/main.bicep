var baseName = 'tmtest'
var location = 'uksouth'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: baseName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Standard'
  } 
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-03-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableIpConnect: true
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: baseName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: baseName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        offer: 'UbuntuServer'
        publisher: 'Canonical'
        version: 'latest'
        sku: '18.04-LTS'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      adminUsername: 'tom'
      linuxConfiguration: {
        ssh: {
          publicKeys: [
            {
              keyData: loadTextContent('ssh.key.pub')
              path: '/home/tom/.ssh/authorized_keys'
            }
          ]
        }
      }
      computerName: baseName
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
