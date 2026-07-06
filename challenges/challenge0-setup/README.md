# Challenge 0 — Setup

## 1. Title & Duration

**Challenge 0 — Setup the Foundry Project, Model, Search, and Monitoring**
⏱ **30 minutes**

## 2. Objective

By the end of this challenge you will have:

- A **Microsoft Foundry project** (the single control plane for everything else in this MicroHack).
- A **GPT-4o-mini** (or GPT-4o) **model deployment** inside that project.
- An **Azure AI Search** service connected to the project (this is what powers **Foundry IQ** in Challenge 2).
- **Application Insights** attached for **tracing and monitoring** (used in Challenge 5).
- The sample **contract templates**, **clauses**, and **policies** uploaded to the project's file store.

Everything else you build in this MicroHack lives inside this one project.

## 3. Context

A **Foundry project** is not just an Azure resource — it is the **unit of governance**. It bundles the model deployment, connections (Search, Storage, App Insights), agents, tools, evaluations, and RBAC. Standing it up correctly on day one is what makes the rest of the day boring in the good way.

Foundry's philosophy: **Build → Deploy → Operate** in one place. This challenge is the "Build" prerequisite.

## 4. Prerequisites

- Azure subscription with **Contributor** + **User Access Administrator** on the target resource group.
- GPT-4o / GPT-4o-mini quota in `eastus2`, `swedencentral`, or `westus3`.
- Local tools (pro-code track): Azure CLI 2.60+, Bicep, VS Code + **Azure AI Foundry** extension, Python 3.10+ or .NET 8 SDK.

## 5. Agents & Tools used

| Component | Used in this challenge? |
| --- | --- |
| Foundry project | ✅ create |
| Model deployment (GPT-4o-mini) | ✅ create |
| Azure AI Search | ✅ create + connect |
| Application Insights | ✅ create + connect |
| Storage account (data + files) | ✅ create |
| Content Safety | ✅ enable (default) |

---

## 6. 🟢 Low-Code Steps (Portal)

1. Go to **[https://ai.azure.com](https://ai.azure.com)** and sign in.
2. Click **+ Create a project** on the home page.
3. In the **Create a project** dialog:
   - **Project name:** `clm-microhack`
   - **Hub:** *Create new hub* → name it `hub-clm-microhack`
   - **Subscription / Resource group:** pick your sub, create `rg-clm-microhack`
   - **Region:** `Sweden Central` (or `East US 2`)
   - Click **Next** → **Create**.
4. Wait until the project banner shows **Ready** (2–3 min). You are now in the **project overview**.
5. In the left nav, click **Models + endpoints** → **+ Deploy model** → **Deploy base model** → pick **gpt-4o-mini** → **Confirm**.
   - **Deployment name:** `gpt-4o-mini`
   - **Deployment type:** Standard
   - **Tokens per minute:** leave default (30K is fine).
   - Click **Deploy**.
6. In the left nav, click **Management center** → **Connected resources** → **+ New connection** → **Azure AI Search**.
   - Choose **Create new** → name it `srch-clm-microhack` → **Basic** tier → **Create**.
   - When it appears, click **Add connection** so the project sees it.
7. Still in **Management center** → **Connected resources** → **+ New connection** → **Application Insights** → **Create new** → name it `appi-clm-microhack` → **Create** → **Add connection**.
8. In the left nav, click **Tracing** and confirm the banner says *"Tracing is enabled for this project"*. If prompted, click **Enable**.
9. In the left nav, click **Data + indexes** → **+ New data** → **Upload files or folders**.
   - Upload the contents of [`assets/templates/`](../../assets/templates/), [`assets/clause-library/`](../../assets/clause-library/), and [`assets/policies/`](../../assets/policies/) into a single dataset named `clm-corpus`.
10. Verify: back on the **project overview** you should see **1 model**, **2 connections**, and **1 dataset**.

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

The pro-code path provisions the whole stack with **Bicep**. It creates the same Foundry project, model deployment, Search, App Insights, and Storage as the portal path — but reproducibly.

### 7.1 Deploy the infrastructure

```bash
# From the repo root
az login
az account set --subscription "<your-subscription-id>"

az group create -n rg-clm-microhack -l swedencentral

az deployment group create \
  -g rg-clm-microhack \
  -f infra/main.bicep \
  -p infra/main.parameters.json
```

The deployment provisions:

- Foundry hub + project (`hub-clm-microhack` / `clm-microhack`)
- Model deployment `gpt-4o-mini`
- Azure AI Search `srch-clm-microhack`
- App Insights `appi-clm-microhack` + Log Analytics workspace
- Storage account for uploads

### 7.2 Grab the project connection string

```bash
az cognitiveservices account show \
  -g rg-clm-microhack -n clm-microhack \
  --query "properties.endpoint" -o tsv
```

Copy the value into a local `.env`:

```env
PROJECT_ENDPOINT=https://<your-endpoint>.services.ai.azure.com/api/projects/clm-microhack
MODEL_DEPLOYMENT_NAME=gpt-4o-mini
```

### 7.3 Verify with Python

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

pip install azure-ai-projects azure-identity python-dotenv
```

```python
# scripts/check_setup.py
import os
from dotenv import load_dotenv
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

load_dotenv()

client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

for c in client.connections.list():
    print(c.name, c.type)
```

Expected output includes at minimum `srch-clm-microhack (AzureAISearch)` and `appi-clm-microhack (AppInsights)`.

### 7.4 Verify with C#

```csharp
using Azure.AI.Projects;
using Azure.Identity;

var endpoint = new Uri(Environment.GetEnvironmentVariable("PROJECT_ENDPOINT")!);
var client = new AIProjectClient(endpoint, new DefaultAzureCredential());

await foreach (var conn in client.GetConnectionsClient().GetConnectionsAsync())
{
    Console.WriteLine($"{conn.Name} — {conn.Type}");
}
```

### 7.5 Upload the corpus

```bash
az storage blob upload-batch \
  --account-name <storage-account-name> \
  --auth-mode login \
  --destination clm-corpus \
  --source assets
```

## 8. Success Criteria

- [ ] Foundry project `clm-microhack` shows **Ready** in the portal.
- [ ] Model deployment `gpt-4o-mini` is **Succeeded** and can be selected in the Playground.
- [ ] Azure AI Search `srch-clm-microhack` is listed under **Connected resources**.
- [ ] Application Insights `appi-clm-microhack` is connected and **Tracing** is enabled.
- [ ] Contract templates, clauses, and policies are uploaded as dataset `clm-corpus`.
- [ ] (Pro-code) `python scripts/check_setup.py` lists both connections.

## 9. Next Steps

Now that the **project, model, and connections** exist, **Challenge 1** turns this raw infrastructure into a real **Contract Intake & Drafting Agent**. You will define its instructions, attach the model deployment you just created, and validate it in the Playground — the first step in proving *"Prompt + Model ≠ Production Agent."*

➡ Continue to **[Challenge 1 — Build Agent](../challenge1-build-agent/README.md)**.

## 10. Key Takeaway

> One Foundry project = one control plane for models, tools, knowledge, and telemetry.
