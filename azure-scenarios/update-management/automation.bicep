param name string
param location string

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output name string = automationAccount.name
