var vmContributorRoleId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'init-disks-deployment-script'
  location: resourceGroup().location
}

resource msiPermissions 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(msi.name, vmContributorRoleId, resourceGroup().id)
  properties: {
    principalId: msi.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', vmContributorRoleId)
  }
  scope: resourceGroup()
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'init-disks'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.3'
    retentionInterval: 'PT2H'
    scriptContent: loadTextContent('init-disks.ps1')
    arguments: '-ResourceGroupName "${resourceGroup().name}"'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
  dependsOn: [
    msiPermissions
  ]
}
