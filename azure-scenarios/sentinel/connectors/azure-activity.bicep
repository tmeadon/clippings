targetScope = 'subscription'

param workspaceResourceId string
param location string = 'uksouth'

var monitoringContribRoleId = '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
var logAnalyticsContributorRoleId = '92aaf0da-9dab-42b6-94a3-d43ce8d16293'

// assign the azure activity logs policy to the subscription
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'azure-activity-to-log-analytics'
  location: location
  scope: subscription()
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
    parameters: {
      logAnalytics: {
        value: workspaceResourceId
      }
    }
  }
}

// create required role assignments for the policy's identity
resource monitoringContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, policyAssignment.name, monitoringContribRoleId)
  properties: {
    principalId: policyAssignment.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringContribRoleId)
  }
  scope: subscription()
}

resource logAnalyticsContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, policyAssignment.name, logAnalyticsContributorRoleId)
  properties: {
    principalId: policyAssignment.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', logAnalyticsContributorRoleId)
  }
  scope: subscription()
}

// finally remediate the policy assignment
resource remediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: '${policyAssignment.name}-remediation'
  properties: {
    failureThreshold: {
      percentage: 0
    }
    policyAssignmentId: policyAssignment.id
  }
}
