param name string
param location string
param subnetId string
param numDataDisks int

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource dataDisks 'Microsoft.Compute/disks@2020-09-30' = [for item in range(0, numDataDisks): {
  name: '${name}-disk${item}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 10
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
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
      dataDisks: [for (item, index) in range(0, numDataDisks): {
        managedDisk: {
          id: dataDisks[index].id
        }
        createOption: 'Attach'
        lun: index
      }]
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

output vmName string = vm.name
