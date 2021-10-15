param name string
param location string = resourceGroup().location
param vnetName string
param vmPrivateIp string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName

  resource firewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${name}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::firewallSubnet.id
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: policy.id
    } 
  }
}

resource policy 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: '${name}-policy'
  location: location

  resource ruleCollectionGroup 'ruleCollectionGroups' = {
    name: 'ruleCollectionGroup1'
    properties: {
      priority: 100
      ruleCollections: [
        {
          name: 'dnatCollection1'
          ruleCollectionType: 'FirewallPolicyNatRuleCollection'
          action: {
            type: 'DNAT'
          }
          priority: 100
          rules: [
            {
              name: 'allow_rdp_to_vm'
              ruleType: 'NatRule'
              sourceAddresses: [
                '151.225.7.14'
              ]
              destinationAddresses: [
                pip.properties.ipAddress
              ]
              destinationPorts: [
                '3389'
              ]
              ipProtocols: [
                'Any'
              ]
              translatedAddress: vmPrivateIp
              translatedPort: '3389'
            }
          ]
        }
      ]
    }
  }
}
