// ---------------------------------------------------------------------------
//  MS-Foundry-Microhack — Main deployment
//  Provisions everything Challenge 0 (pro-code track) needs:
//    - Log Analytics workspace + Application Insights
//    - Storage account (for uploaded contract corpus and Function state)
//    - Azure AI Search (Foundry IQ backing service)
//    - Foundry (Azure AI Services) account + project
//    - Model deployment: gpt-4o-mini
//    - Embedding deployment: text-embedding-3-large
//    - Connections from the Foundry project to Search + App Insights + Storage
// ---------------------------------------------------------------------------

targetScope = 'resourceGroup'

@description('Base name used to derive all resource names. Keep it short.')
param baseName string = 'clm-microhack'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Chat/completion model deployment name and version.')
param chatModelName string = 'gpt-4o-mini'
param chatModelVersion string = '2024-07-18'
param chatModelTpm int = 30

@description('Embedding model deployment name and version.')
param embeddingModelName string = 'text-embedding-3-large'
param embeddingModelVersion string = '1'
param embeddingModelTpm int = 30

@description('Object ID of the user or group that gets full data-plane access to Foundry.')
param principalId string

// ------------------------- Monitoring --------------------------------------
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    baseName: baseName
    location: location
  }
}

// ------------------------- Storage -----------------------------------------
module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    baseName: baseName
    location: location
  }
}

// ------------------------- Azure AI Search ---------------------------------
module search 'modules/search.bicep' = {
  name: 'search'
  params: {
    baseName: baseName
    location: location
  }
}

// ------------------------- Foundry (AI Services + project) -----------------
module foundry 'modules/foundry.bicep' = {
  name: 'foundry'
  params: {
    baseName: baseName
    location: location
    chatModelName: chatModelName
    chatModelVersion: chatModelVersion
    chatModelTpm: chatModelTpm
    embeddingModelName: embeddingModelName
    embeddingModelVersion: embeddingModelVersion
    embeddingModelTpm: embeddingModelTpm
    searchName: search.outputs.searchName
    searchId: search.outputs.searchId
    appInsightsId: monitoring.outputs.appInsightsId
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    storageAccountId: storage.outputs.storageAccountId
    storageAccountName: storage.outputs.storageAccountName
    principalId: principalId
  }
}

// ------------------------- Outputs -----------------------------------------
output projectEndpoint string        = foundry.outputs.projectEndpoint
output chatDeploymentName string     = foundry.outputs.chatDeploymentName
output embeddingDeploymentName string= foundry.outputs.embeddingDeploymentName
output searchName string             = search.outputs.searchName
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString
output storageAccountName string     = storage.outputs.storageAccountName
