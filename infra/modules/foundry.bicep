// Foundry: Azure AI Services account with a "project" child, model deployments,
// and connections back to Search + App Insights + Storage.
// Requires the caller to have User Access Administrator on the resource group.

param baseName string
param location string

param chatModelName string
param chatModelVersion string
param chatModelTpm int

param embeddingModelName string
param embeddingModelVersion string
param embeddingModelTpm int

param searchName string
param searchId string

param appInsightsId string
param appInsightsConnectionString string

param storageAccountId string
param storageAccountName string

param principalId string

// ------------------------- Foundry (AI Services) account -------------------
resource foundry 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: 'aif-${baseName}'
  location: location
  kind: 'AIServices'
  sku: { name: 'S0' }
  identity: { type: 'SystemAssigned' }
  properties: {
    allowProjectManagement: true
    customSubDomainName: 'aif-${baseName}'
    publicNetworkAccess: 'Enabled' // consider Disabled + PE for production
    disableLocalAuth: false
  }
}

// ------------------------- Foundry project ---------------------------------
resource project 'Microsoft.CognitiveServices/accounts/projects@2024-10-01' = {
  parent: foundry
  name: baseName
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    displayName: 'CLM MicroHack'
    description: 'Contract Lifecycle Management agent — MicroHack project.'
  }
}

// ------------------------- Model deployments -------------------------------
resource chatDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: foundry
  name: chatModelName
  sku: {
    name: 'Standard'
    capacity: chatModelTpm
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: chatModelName
      version: chatModelVersion
    }
    raiPolicyName: 'Microsoft.DefaultV2'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: foundry
  name: embeddingModelName
  sku: {
    name: 'Standard'
    capacity: embeddingModelTpm
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: embeddingModelName
      version: embeddingModelVersion
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
  dependsOn: [ chatDeployment ]
}

// ------------------------- Connections -------------------------------------
resource searchConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2024-10-01' = {
  parent: project
  name: 'conn-search'
  properties: {
    category: 'CognitiveSearch'
    target: 'https://${searchName}.search.windows.net'
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: searchId
    }
  }
}

resource appInsightsConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2024-10-01' = {
  parent: project
  name: 'conn-appinsights'
  properties: {
    category: 'AppInsights'
    target: appInsightsId
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: appInsightsConnectionString
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: appInsightsId
    }
  }
}

resource storageConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2024-10-01' = {
  parent: project
  name: 'conn-storage'
  properties: {
    category: 'AzureBlob'
    target: 'https://${storageAccountName}.blob.core.windows.net'
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: storageAccountId
    }
  }
}

// ------------------------- RBAC --------------------------------------------
// Give the project's managed identity data-plane access to Search & Storage.
var searchIndexDataContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
                                  '8ebe5a00-799e-43f5-93ac-243d3dce84a7')
var storageBlobDataContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
                                  'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var aiUser                     = subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
                                  '53ca6127-db72-4b80-b1b0-d745d6d5456d') // Azure AI User

resource searchRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(project.id, searchId, 'search-contrib')
  scope: resourceGroup()
  properties: {
    principalId: project.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: searchIndexDataContributor
  }
}

resource storageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(project.id, storageAccountId, 'blob-contrib')
  scope: resourceGroup()
  properties: {
    principalId: project.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributor
  }
}

// Give the human principal the "Azure AI User" role on the project.
resource userRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(project.id, principalId, 'ai-user')
  scope: resourceGroup()
  properties: {
    principalId: principalId
    principalType: 'User'
    roleDefinitionId: aiUser
  }
}

// ------------------------- Outputs -----------------------------------------
output foundryId string                = foundry.id
output projectId string                = project.id
output projectEndpoint string          = 'https://${foundry.name}.services.ai.azure.com/api/projects/${project.name}'
output chatDeploymentName string       = chatDeployment.name
output embeddingDeploymentName string  = embeddingDeployment.name
