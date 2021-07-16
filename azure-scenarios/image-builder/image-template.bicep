param imageName string
param location string = resourceGroup().location
param galleryImageId string
param msiId string

resource template 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: '${imageName}-template'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msiId}': {}
    }
  }
  properties: {
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'runScript'
        inline: [
          '$testFilePath = (Join-Path -Path "$($env:SystemDrive)" -ChildPath "file.txt")'
          'New-Item -Path $testFilePath -ItemType File'
          '"hello" | Set-Content -Path $testFilePath'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: galleryImageId
        replicationRegions: [
          location
        ]
        runOutputName: '${imageName}-sharedImage'
      }
    ]
  }  
}
