resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: 'vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: 'pip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '90.208.118.46'
          priority: 100
        }
      }
    ]
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: 'nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: vnet.properties.subnets[0]
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vm'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B8ms'
    }
    osProfile: {
      computerName: 'vm'
      adminPassword: 'P@55word!'
      adminUsername: 'azureuser'
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
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2021-01-01' = {
  name: 'rsvault'
  location: resourceGroup().location
  properties: {}
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
}

output publicIp string = pip.properties.ipAddress
