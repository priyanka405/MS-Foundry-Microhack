# Infra — Bicep Templates

This directory contains Azure Bicep templates for deploying all infrastructure required by the MicroHack.

## Structure

```
infra/
├── main.bicep          # Top-level deployment template
├── modules/            # Reusable Bicep modules
│   ├── foundry.bicep
│   ├── storage.bicep
│   ├── search.bicep
│   └── monitoring.bicep
└── parameters/
    ├── parameters.example.json
    └── parameters.json   # (git-ignored) your local values
```

## Usage

See `challenges/challenge0-setup/README.md` for deployment instructions.

## Resources Deployed

| Resource | Purpose |
|----------|---------|
| Azure AI Foundry Project | Agent hosting and management |
| Azure OpenAI | Model deployments |
| Azure Storage | Document storage |
| Azure AI Search | Knowledge base indexing |
| Application Insights | Monitoring and tracing |
| Log Analytics Workspace | Log aggregation |
