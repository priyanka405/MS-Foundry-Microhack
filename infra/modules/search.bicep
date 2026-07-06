// Azure AI Search — the storage engine behind Foundry IQ knowledge grounding.

param baseName string
param location string

@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param sku string = 'basic'

resource search 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: 'srch-${baseName}'
  location: location
  sku: { name: sku }
  properties: {
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
    semanticSearch: 'standard'
    disableLocalAuth: false // set true + AAD-only in production
    publicNetworkAccess: 'Enabled' // gate behind a private endpoint in production
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

output searchId string   = search.id
output searchName string = search.name
