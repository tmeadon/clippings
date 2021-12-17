@secure()
param adminPassword string

var location = 'uksouth'

var scripts = [
  loadTextContent('./script1.ps1')
  loadTextContent('./script2.ps1')
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: 'vnet1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vm-subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-rdp'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '94.192.19.144'
          sourcePortRange: '*'
          priority: 100
        }
      }
    ]
  }
  
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: 'pip1'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }  
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: 'vm1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'vm1'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: 'vm1'
      adminUsername: 'tom'
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
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

@batchSize(1)
resource vmCommands 'Microsoft.Compute/virtualMachines/runCommands@2021-07-01' = [for (item, i) in scripts: {
  parent: vm
  name: 'script${i}'
  location: location
  properties: {
    source: {
      script: item
    }
  }
}]
