param functionAppName string
param storageAccountName string

resource asp 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: '${functionAppName}-asp'
  location: resourceGroup().location
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource ai 'Microsoft.Insights/components@2015-05-01' = {
  name: '${functionAppName}-ai'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource functionapp 'Microsoft.Web/sites@2019-08-01' = {
  name: functionAppName
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    siteConfig: {
      powerShellVersion: '~7'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listkeys(storage.id, '2021-01-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listkeys(storage.id, '2021-01-01').keys[0].value};EndpointSuffix=core.windows.net' 
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${toLower(functionAppName)}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: ai.properties.InstrumentationKey
        }
      ]
    }
    httpsOnly: true
    serverFarmId: asp.id
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: '${functionAppName}-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'ApplicationGatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        } 
      }
    ]
  }
}

resource appGwPip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: '${functionAppName}-gwpip'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appGw 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: '${functionAppName}-gw'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIP'
        properties: {
          publicIPAddress: {
            id: appGwPip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend'
        properties: {
          backendAddresses: [
            {
              fqdn: functionapp.properties.hostNames[0]
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: functionapp.properties.hostNames[0]
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${functionAppName}-gw', 'frontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${functionAppName}-gw', 'frontendPort')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${functionAppName}-gw', 'listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${functionAppName}-gw', 'backend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${functionAppName}-gw', 'httpSettings')
          }
        }
      }
    ]
  }
}

resource appgwdiag 'microsoft.insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  scope: appGw
  location: resourceGroup().location
  properties: {
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        enabled: true
        timeGrain: '5m'
      }
    ]
    workspaceId: logs.id
    storageAccountId: storage.id
  }
}

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: '${functionAppName}-logs'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard'
    }
  }
}
