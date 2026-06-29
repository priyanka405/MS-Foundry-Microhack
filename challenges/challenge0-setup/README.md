# Challenge 0 — Environment Setup

## Goal

Deploy the full Azure Foundry environment using Infrastructure as Code (Bicep).

## What You Will Deploy

- Azure AI Foundry Project
- Azure OpenAI model deployment
- Azure Storage Account
- Azure Monitor / Application Insights
- (Optional) Azure AI Search for grounding

## Instructions

1. Open `infra/main.bicep` and review the parameters.
2. Copy `infra/parameters/parameters.example.json` to `infra/parameters/parameters.json` and fill in your values.
3. Run the deployment:

```bash
az deployment sub create \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/parameters.json
```

4. Confirm all resources appear in the Azure Portal.

## Learning Objectives

- Understand Infrastructure as Code with Bicep
- Learn Foundry Project setup best practices
- Validate that monitoring is configured before building

## Tips

- Use an existing resource group to keep things tidy.
- The `coach-guide/challenge0.md` contains facilitator notes if you get stuck.
