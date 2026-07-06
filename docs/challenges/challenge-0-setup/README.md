# Challenge 0 — Setup

> **Goal:** Provision the **Microsoft Foundry** project, deploy a model, wire up storage + identity, and prove your account can talk to Foundry from both the portal and the SDK.

**Estimated time:** 25–35 min
**Prerequisite:** An Azure subscription (or a Foundry sandbox), permission to create resources.

---

## 🎯 Objective

Land you at a clean starting point: a working **Foundry project**, a **model deployment**, and a `.env` file that lets your local Python talk to it.

## 📋 Tasks

1. Create a **Foundry project** on [ai.azure.com](https://ai.azure.com).
2. Deploy a **model** — `gpt-4o` (or `gpt-4.1` if available).
3. Note the **project connection string**.
4. (SDK path) Install the Python deps and populate `.env`.
5. Run a **hello-world** call from the SDK.

---

## 🖱️ Portal path

### 1. Create the project

1. Open [https://ai.azure.com](https://ai.azure.com) and sign in.
2. Click **+ Create project**.
3. Configure:
   - **Name:** `prj-clm-hackathon-<yourname>`.
   - **Hub:** pick a region that supports Agents (e.g., East US 2, Sweden Central).
   - **Resource group:** create `rg-clm-hackathon`.
4. Wait for provisioning (~2–3 min). This creates the project **plus** an Azure AI Search, an Azure Storage account, and a Key Vault — everything the later challenges need.

### 2. Deploy the model

1. In the project → **Deployments** → **+ Deploy model**.
2. Pick `gpt-4o` (or `gpt-4o-mini` if you're cost-sensitive — you can upgrade later).
3. Deployment name: `gpt-4o` — **keep it exactly that**; the code samples expect it.
4. Set **TPM (tokens per minute)** to at least 30k so evaluation doesn't throttle.

### 3. Copy the connection string

1. Project → **Overview** → **Project connection string** → copy.
2. You'll paste this into `.env` in the SDK path below.

### 4. Sanity check

1. Project → **Playground** → **Chat**.
2. Send: *"Say the word `foundry` back to me and nothing else."*
3. You should get `foundry` back. If you don't, your model deployment failed — recreate it.

---

## 💻 SDK path

### 1. Install dependencies

```bash
python -m venv .venv
source .venv/bin/activate         # macOS/Linux
# .venv\Scripts\Activate.ps1       # Windows

pip install -r requirements.txt
```

### 2. Populate `.env`

```bash
cp .env.example .env
# then edit .env and fill in AZURE_AI_PROJECT_CONNECTION_STRING and AZURE_OPENAI_DEPLOYMENT
```

### 3. Log in

```bash
az login
# optional if you have multiple subscriptions:
az account set --subscription "<sub-id>"
```

### 4. Hello, Foundry

The starter code lives in [`app/config.py`](../../../app/config.py) and [`app/sample_run.py`](../../../app/sample_run.py). Run:

```bash
python -m app.sample_run --smoke
```

Expected output:

```
✅ Connected to Foundry project: prj-clm-hackathon-<you>
✅ Model deployment reachable: gpt-4o
🤖 Sample reply: "foundry"
```

Under the hood:

```python
# app/config.py — excerpt
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient
from app.config import settings

client = AIProjectClient.from_connection_string(
    conn_str=settings.project_connection_string,
    credential=DefaultAzureCredential(),
)
```

---

## ✅ Success criteria

- [ ] Foundry project `prj-clm-hackathon-<you>` exists and is *Succeeded*.
- [ ] Model deployment `gpt-4o` (or your chosen name) is *Succeeded*.
- [ ] Portal Playground returns `foundry` on the sanity-check prompt.
- [ ] (SDK path) `python -m app.sample_run --smoke` prints all three ✅ lines.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `AuthenticationFailedError` from SDK | Not logged in to Azure. | `az login` and retry. |
| `ResourceNotFound: deployment 'gpt-4o'` | Deployment name mismatch. | Either rename the deployment or update `AZURE_OPENAI_DEPLOYMENT` in `.env`. |
| Project creation fails on quota | Region can't provision your chosen model. | Pick a different region (East US 2 / Sweden Central are usually fine). |
| Playground error: *"No deployments available"* | The model deployment isn't finished yet. | Wait for the deployment status to be *Succeeded*. |
| SDK returns 429 | TPM too low. | Bump TPM to 30k+. |

## 🌉 Next challenge

You now have a Foundry project you can talk to. In **[Challenge 1 — Build the Agent](../challenge-1-build-agent/README.md)** you'll turn that raw model into an actual **agent** with a contract-drafting persona.
