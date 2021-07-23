param queryPackName string = 'testQueries'
param location string = 'uksouth'

resource queryPack 'Microsoft.OperationalInsights/queryPacks@2019-09-01-preview' = {
  name: queryPackName
  location: location
  properties: {
  }

  resource query1 'queries' = {
    name: guid(resourceGroup().name, queryPackName, 'query1')
    properties: {
      displayName: 'query1'
      body: loadTextContent('query1.kusto')
      description: 'blah query 1'
      related: {
        resourceTypes: [
          'microsoft.insights/components'
        ]
        categories: [
          'applications'
        ]
      }
      tags: {
        labels: [
          'abc'
          'def'
        ]
        whatever: [
          'reallycool'
        ]
      }
    }
  }

  resource query2 'queries' = {
    name: guid(resourceGroup().name, queryPackName, 'query2')
    properties: {
      displayName: 'query2'
      body: loadTextContent('query2.kusto')
      description: 'blah query 2'
      related: {
        resourceTypes: [
          'microsoft.insights/components'
        ]
        categories: [
          'applications'
        ]
      }
      tags: {
        labels: [
          'abc'
          'def'
        ]
        whatever: [
          'cool'
        ]
      }
    }
  }
}
