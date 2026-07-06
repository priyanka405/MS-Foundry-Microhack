# Challenge 8 — Publish

## 1. Title & Duration

**Challenge 8 — Publish the CLM Agent (Web / Teams / API)**
⏱ **30 minutes**

## 2. Objective

Deploy the agent so real users can actually use it. Choose **one primary** channel and validate the other two work:

1. **Web App** — the fastest path to a demo URL.
2. **Teams App** — where legal, procurement, and sales actually live.
3. **API endpoint** — for integration into your CLM system of record.

Then apply the **governance / security / lifecycle checklist** so this is a real launch, not a demo.

## 3. Context

Foundry treats deployment as a first-class concern: the agent lives in a project, and a **deployment channel** is a thin adapter. That means the same **traces, guardrails, evaluations, and RBAC** ride along everywhere the agent is exposed.

Three canonical channels:

| Channel | Best for | Auth | Deployment surface |
| --- | --- | --- | --- |
| **Web App** | Fast demos, business showcases | Easy Auth (Entra ID) | Azure App Service |
| **Teams App** | Internal legal / procurement | Entra ID SSO | Teams App Studio + Bot Service |
| **API endpoint** | Integration into a CLM/CRM/ERP | Managed Identity + API Mgmt | Foundry's built-in agent endpoint |

## 4. Prerequisites

- [Challenge 7](../challenge7-optimization/README.md) done — you have the version you want to ship.
- App Service Plan and Bot Service resource created by `infra/main.bicep` (both optional; portal path can create on the fly).

## 5. Agents & Tools used

| Component | Used |
| --- | --- |
| **Foundry Agent Deploy** (built-in) | ✅ |
| **Azure App Service** (Web App) | ✅ |
| **Azure Bot Service + Teams manifest** | ✅ |
| **Azure API Management** (optional but recommended) | 🟡 |
| **Managed Identity** for downstream Azure calls | ✅ |

---

## 6. 🟢 Low-Code Steps (Portal)

### 6.1 Web App (5 min)

1. **Agents → contract-intake-drafting → Deploy → Web app**.
2. Fill in:
   - **App name:** `webapp-clm-microhack`
   - **Region:** same as the project
   - **Authentication:** *Sign in with Entra ID* (Easy Auth ON)
   - **Managed identity:** *System-assigned*
3. Click **Deploy**. When it goes green, click **Open**. Sign in and run the same intake prompt you used in Challenge 1.

### 6.2 Teams App (10 min)

1. **Agents → contract-intake-drafting → Deploy → Microsoft Teams**.
2. **App display name:** `CLM Assistant`.
3. Download the generated **`clm-assistant.zip`** Teams manifest.
4. In Teams → **Apps** → **Manage your apps** → **Upload a custom app** → pick the zip.
5. Test in your own tenant. Ask *"Draft an NDA with Contoso, mutual, 2y, Irish law."*

### 6.3 API endpoint (5 min)

1. **Agents → contract-intake-drafting → Deploy → API endpoint**.
2. Copy the URL, e.g. `https://clm-microhack.services.ai.azure.com/api/agents/contract-intake-drafting/runs`.
3. Test:

   ```bash
   curl -X POST "$AGENT_URL" \
     -H "Authorization: Bearer $(az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv)" \
     -H "Content-Type: application/json" \
     -d '{"messages":[{"role":"user","content":"List our approved templates."}]}'
   ```

### 6.4 Governance / Security / Lifecycle checklist

Tick these before you announce the launch:

**Identity & access**
- [ ] Web App uses **Easy Auth** with Entra ID; anonymous access disabled.
- [ ] Agent uses **Managed Identity** for Azure AI Search, Storage, and Function calls (no keys in code).
- [ ] RBAC: only `CLM-Admins` group is `Cognitive Services Contributor` on the project.

**Network**
- [ ] Foundry project on a **private endpoint** (or IP allow-list).
- [ ] Azure AI Search **private endpoint** + `publicNetworkAccess = Disabled`.
- [ ] Storage account **`allowBlobPublicAccess = false`**.

**Data protection**
- [ ] PII redaction (Challenge 4) still enabled on the deployed agent.
- [ ] Content Safety filters unchanged from Challenge 4.
- [ ] Data retention policy on Storage set to your legal-hold requirement.

**Observability & operations**
- [ ] Alerts from Challenge 5 wired to the on-call rotation.
- [ ] Evaluation from Challenge 6 is **attached to the deployed version**.
- [ ] SLO documented: e.g. *"P95 < 8 s, ≥ 85% task adherence, 0 safety defects/week"*.

**Lifecycle**
- [ ] `evaluation/testset.jsonl` runs in CI on every agent instruction change.
- [ ] Model deployment version pinned in `infra/main.parameters.json`.
- [ ] Rollback plan: `Agents → History → Restore vN-1`.
- [ ] Owner + backup owner named in the repo `CODEOWNERS`.

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

### 7.1 Deploy the Web App from Bicep

```bash
az deployment group create \
  -g rg-clm-microhack \
  -f infra/modules/webapp.bicep \
  -p projectEndpoint=$PROJECT_ENDPOINT agentId=$AGENT_ID
```

### 7.2 Minimal chat proxy in Python (FastAPI)

```python
# app/main.py
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

### 7.3 Same proxy in C# / ASP.NET

```csharp
app.MapPost("/chat", async (HttpContext ctx) =>
{
    var body      = await ctx.Request.ReadFromJsonAsync<ChatIn>();
    var threadId  = body!.ThreadId ?? (await agents.CreateThreadAsync()).Value.Id;
    await agents.CreateMessageAsync(threadId, MessageRole.User, body.Message);
    var run = await agents.CreateRunAsync(threadId, agentId);
    await agents.WaitForRunAsync(threadId, run.Value.Id);
    var latest = (await agents.GetMessagesAsync(threadId).FirstAsync());
    return Results.Ok(new { threadId, reply = latest.ContentItems[0].ToString(), runId = run.Value.Id });
});
```

### 7.4 Teams — bot registration (excerpt)

```bicep
resource bot 'Microsoft.BotService/botServices@2022-09-15' = {
  name: 'bot-clm-microhack'
  location: 'global'
  sku: { name: 'S1' }
  kind: 'azurebot'
  properties: {
    displayName: 'CLM Assistant'
    endpoint: 'https://webapp-clm-microhack.azurewebsites.net/api/messages'
    msaAppId: appReg.outputs.clientId
    msaAppType: 'MultiTenant'
  }
}
```

### 7.5 API endpoint — call from any client

```python
import os, requests
from azure.identity import DefaultAzureCredential

token = DefaultAzureCredential().get_token("https://ai.azure.com/.default").token
r = requests.post(
    f"{os.environ['PROJECT_ENDPOINT']}/agents/{os.environ['AGENT_ID']}/runs",
    headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    json={"messages":[{"role":"user","content":"List our approved templates."}]})
print(r.json())
```

## 8. Success Criteria

- [ ] At least **one** deployment channel is live and returns a valid agent response.
- [ ] The other two channels are validated at minimum with a smoke test.
- [ ] **Every item** in the governance / security / lifecycle checklist above is ticked or explicitly deferred with an owner + date.
- [ ] The deployed version is the **evaluated** version from Challenge 7 (not a random newer edit).
- [ ] Alerts, dashboards, and evaluators from Challenges 5–6 are attached and firing on real traffic.

## 9. Next Steps

You have shipped an agent. Two doors are now open:

1. **Iterate** — the loop from Challenges 5→6→7 is the day job. Instrument new prompts, run the eval, ship if you win.
2. **Scale out** — go to the [solution guide](../../solution-guide/README.md) and build the **five-agent orchestration** stretch goal: *Intake & Drafting → Clause Extraction & Risk → Review & Negotiation → Signature & Repository → Obligation & Renewal.*

## 10. Key Takeaway

> Deployment is not the end of a build — it is the start of an operate loop. Foundry gives you the same governance surface wherever the agent lives.
