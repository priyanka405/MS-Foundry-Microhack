# Challenge 5 — Deploy and Share the Agent

⏱ **~40 minutes**  ·  🧠 Key Foundry feature: **Foundry Deploy · Web App · Microsoft Teams · API endpoint**

## 🎯 Objective

Publish the Executive Assistant Agent so real users can actually use it. Choose **one primary channel** and validate the other two work:

1. **Web App** — the fastest path to a demo URL.
2. **Microsoft Teams App** — where executives actually live.
3. **API endpoint** — for integration into other apps (Copilot Studio, custom UI, back-office).

Then apply the **governance / security / lifecycle checklist** so it survives its first Monday.

## 🧭 Context

Foundry treats deployment as a first-class concern: the agent lives in a project, and each **deployment channel** is a thin adapter. That means the same **grounding, tools, guardrails, evaluations, and RBAC** ride along everywhere the agent is exposed.

| Channel | Best for | Auth | Deployment surface |
| --- | --- | --- | --- |
| **Web App** | Fast demos, business showcases | Easy Auth (Entra ID) | Azure App Service |
| **Teams App** | Real EA/executive workflow | Entra ID SSO | Bot Service + Teams manifest |
| **API endpoint** | Integration into other apps | Managed Identity + API Management | Foundry's built-in agent endpoint |

## ✅ Prerequisites

- [Challenge 4](challenge-4-evaluation.md) complete — the agent version has passed the 85% task-adherence gate.
- Rights to create an Azure App Service, a Bot Service, and (optionally) an API Management instance.

## 🏗️ Steps

### 1. Web App (5 min)

1. **Agents → executive-assistant → Deploy → Web app**.
2. Fill in:
   - **App name:** `webapp-exec-assistant`
   - **Region:** same as your Foundry project
   - **Authentication:** *Sign in with Entra ID* (Easy Auth ON)
   - **Managed identity:** *System-assigned*
3. Click **Deploy**. When green, click **Open**, sign in, and run the meeting-prep prompt from Challenge 1.

### 2. Microsoft Teams App (10 min)

1. **Agents → executive-assistant → Deploy → Microsoft Teams**.
2. **App display name:** `Executive Assistant`.
3. Download the generated **`executive-assistant.zip`** Teams manifest.
4. In Teams → **Apps → Manage your apps → Upload a custom app** → pick the zip.
5. Chat with the app: *"Prep me for my next meeting."*

### 3. API endpoint (5 min)

1. **Agents → executive-assistant → Deploy → API endpoint**.
2. Copy the URL: `https://<project>.services.ai.azure.com/api/agents/executive-assistant/runs`.
3. Test with curl:

   ```bash
   TOKEN=$(az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv)
   curl -X POST "$AGENT_URL" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"messages":[{"role":"user","content":"Prep me for my next meeting."}]}'
   ```

### 4. (Optional) Minimal chat proxy for the Web App

If you want a lightweight custom front-end instead of the built-in Web App shell:

```python
# app/main.py — FastAPI proxy
import os
from fastapi import FastAPI, Request
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.monitor.opentelemetry import configure_azure_monitor

configure_azure_monitor()
project = AIProjectClient(endpoint=os.environ["PROJECT_ENDPOINT"],
                          credential=DefaultAzureCredential())
app = FastAPI()

@app.post("/chat")
async def chat(req: Request):
    body = await req.json()
    thread_id = body.get("thread_id") or project.agents.threads.create().id
    project.agents.messages.create(thread_id=thread_id, role="user",
                                   content=body["message"])
    run = project.agents.runs.create_and_process(
        thread_id=thread_id, agent_id=os.environ["AGENT_ID"])
    last = next(iter(project.agents.messages.list(thread_id=thread_id, order="desc")))
    return {"thread_id": thread_id,
            "reply": last.content[0].text.value,
            "run_id": run.id}
```

Deploy that FastAPI app to Azure App Service and put Easy Auth in front.

### 5. Governance / Security / Lifecycle checklist

Tick these before you announce the launch:

**Identity & access**
- [ ] Web App uses **Easy Auth** with Entra ID; anonymous access disabled.
- [ ] Agent uses **Managed Identity** for Azure AI Search, Storage, and tool calls — no keys in code.
- [ ] RBAC: only the `EA-Admins` group is `Cognitive Services Contributor` on the project.

**Network**
- [ ] Foundry project on a **private endpoint** (or IP allow-list) if data sensitivity requires it.
- [ ] Azure AI Search with `publicNetworkAccess = Disabled` in production.
- [ ] Storage account `allowBlobPublicAccess = false`.

**Data protection**
- [ ] PII redaction from Challenge 4 still enabled.
- [ ] Content Safety filters unchanged from Challenge 4.
- [ ] Data-retention policy on storage set to your legal-hold requirement.

**Observability & operations**
- [ ] App Insights is receiving traces for real user runs.
- [ ] Alert on P95 latency > 8 s wired to the on-call rotation.
- [ ] Evaluation from Challenge 4 attached to the **deployed** agent version.
- [ ] SLO documented: *e.g. "P95 < 8 s, ≥ 85% task adherence, 0 safety defects/week"*.

**Lifecycle**
- [ ] `evaluation/testset.jsonl` runs in CI on every agent instruction change.
- [ ] Model deployment version is pinned.
- [ ] Rollback plan: **Agents → History → Restore vN-1**.
- [ ] Owner + backup owner named in the repo `CODEOWNERS`.
- [ ] Human review is **always** in the loop for outbound emails and workflow triggers.

### 6. (Optional) Publish this repo to GitHub Pages

The [index.html](../index.html) landing page is designed to be GitHub-Pages ready:

1. Push the repo to GitHub.
2. In the repo **Settings → Pages** → source `main` branch, folder `/ (root)`.
3. Wait ~1 min. Your visual landing page will be live at `https://<user>.github.io/<repo>/`.

## 🧪 Success criteria

- [ ] At least **one** deployment channel is live and returns a valid agent response for the meeting-prep prompt.
- [ ] The other two channels validated with a smoke test.
- [ ] **Every** item in the governance/security/lifecycle checklist above is ticked or explicitly deferred with owner + date.
- [ ] The deployed version is the **evaluated** version from Challenge 4 (not a random later edit).
- [ ] `index.html` renders correctly when opened locally (and, if published, on GitHub Pages).

## 🔎 Troubleshooting

| Symptom | Fix |
| --- | --- |
| Web App deploy stuck | Retry once. If still failing, deploy the API endpoint channel and use a custom FastAPI proxy. |
| Teams App upload rejected | Manifest is missing a bot-app-id; regenerate it from Foundry with the "Microsoft Teams" deploy option. |
| API returns 401 | Wrong resource for the token. Use `https://ai.azure.com/.default` audience. |
| GitHub Pages doesn't render Mermaid | GitHub Pages does render Mermaid in Markdown — check that fenced code blocks use ```` ```mermaid ````. |

## ➡️ What's next

You've shipped an agent. Two doors are now open:

- **Iterate** — the loop from Challenges 2 → 3 → 4 is the day job. Every time you touch the instructions, run the eval, ship if you win.
- **Scale out** — connect this agent to specialists (a "Meeting Notes" agent, an "Email Composer" agent, a "Calendar" agent) via **Foundry Connected Agents** — a multi-agent EA team.

## 💡 Key takeaway

> Deployment is not the end of a build — it is the start of an operate loop. Foundry gives you the same governance surface wherever the agent lives.
