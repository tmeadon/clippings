param baseName string
param location string

var bastionSubnetCidr = '10.0.0.0/24'
var subnetACidr = '10.0.1.0/24'
var subnetBCidr = '10.0.2.0/24'
var subnetCCidr = '10.0.3.0/24'
var asgSuffixes = [
  'a'
  'b'
  'c'
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-12-01' = {
  name: baseName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowBastion'
        properties: {
          access: 'Allow'
          protocol: 'Tcp'
          direction: 'Inbound'
          priority: 100
          destinationPortRange: '3389'
          sourceAddressPrefix: bastionSubnetCidr
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            subnetACidr
            subnetBCidr
            subnetCCidr
          ]
        }
      }
      {
        name: 'AppAToAppB'
        properties: {
          access: 'Allow'
          protocol: '*'
          direction: 'Inbound'
          priority: 101
          sourcePortRange: '*'
          sourceApplicationSecurityGroups: [
            {
              id: asgs[0].id
            }
          ]
          destinationApplicationSecurityGroups: [
            {
              id: asgs[1].id
            }
          ]
          destinationPortRange: '*'
        }
      }
      {
        name: 'AppBToAppC'
        properties: {
          access: 'Allow'
          protocol: '*'
          direction: 'Inbound'
          priority: 102
          sourcePortRange: '*'
          sourceApplicationSecurityGroups: [
            {
              id: asgs[1].id
            }
          ]
          destinationApplicationSecurityGroups: [
            {
              id: asgs[2].id
            }
          ]
          destinationPortRange: '*'
        }
      }
      {
        name: 'DenyAll'
        properties: {
          access: 'Deny'
          protocol: '*'
          direction: 'Inbound'
          priority: 110
          sourcePortRange: '*'
          sourceAddressPrefix: '0.0.0.0/0'
          destinationAddressPrefix: '0.0.0.0/0'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-12-01' = {
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
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetCidr
        }
      }
      {
        name: 'a'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'b'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'c'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }  
}

resource asgs 'Microsoft.Network/applicationSecurityGroups@2019-12-01' = [for (item, index) in asgSuffixes: {
  name: '${baseName}-${item}'
  location: location
}]

output vnetName string = vnet.name
output subnetAId string = vnet.properties.subnets[1].id
output subnetBId string = vnet.properties.subnets[2].id
output subnetCId string = vnet.properties.subnets[3].id
output asgAId string = asgs[0].id
output asgBId string = asgs[1].id
output asgCid string = asgs[2].id
