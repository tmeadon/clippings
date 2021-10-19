param baseName string = 'vmss0'
param location string = 'uksouth'
param customImageName string
param customImageResouceGroup string
param vmssAdminUsername string = 'tom'

@secure()
param vmssAdminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
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
        name: 'vmss'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource image 'Microsoft.Compute/images@2020-12-01' existing = {
  name: customImageName
  scope: resourceGroup(customImageResouceGroup)
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = {
  name: baseName
  location: location
  sku: {
    name: 'Standard_B2S'
    capacity: 1
    tier: 'Standard'
  }
  plan: {
    name: 'cis-rhel7-l1'
    product: 'cis-rhel-7-v2-2-0-l1'
    publisher: 'center-for-internet-security-inc'
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    } 
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
        }
        imageReference: {
          id: image.id
        }
      }
      osProfile: {
        computerNamePrefix: baseName
        adminUsername: vmssAdminUsername
        adminPassword: vmssAdminPassword
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${baseName}-nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: vnet.properties.subnets[0].id
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
