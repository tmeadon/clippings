param name string
param location string
param automationAccountName string

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: automationAccountName
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  properties: {
     sku: {
       name: 'PerGB2018'
     }
  }

  resource automation 'linkedServices@2020-08-01' = {
    name: 'Automation'
    properties: {
      resourceId: automationAccount.id
    }
  }
}

resource updateSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Updates(${workspace.name})'
  location: location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'Updates(${workspace.name})'
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/Updates'
  }
}

output workspaceName string = workspace.name
