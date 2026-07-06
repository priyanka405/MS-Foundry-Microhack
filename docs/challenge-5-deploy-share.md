# Challenge 5 — Deploy and Share

> **Goal:** Deploy the CLM Agent as a **Web App**, a **Microsoft Teams App**, and an **API endpoint** — with governance, identity, and observability baked in.

**Foundry feature:** Foundry Deploy, Web App, Bot Service, API endpoints, Managed Identity
**Estimated time:** 40–50 min
**Prerequisite:** Challenges 1–4 complete, evaluation gate passed.

---

## 🎯 Objective

Ship the agent to real users through three channels:

1. **Web App** — a branded web experience for Legal & Procurement (Easy Auth).
2. **Microsoft Teams App** — where sales, procurement, and legal already work.
3. **API endpoint** — for downstream systems (contract portal, CRM plugins, batch jobs).

You'll also complete the **governance checklist** and (optionally) publish `index.html` to GitHub Pages so your team can find the hackathon assets.

---

## 🚀 Deployment tracks

Do all three; each takes ~5–15 minutes.

### Track A · Web App (10 min)

1. **Foundry portal → your agent → Deploy → Web App.**
2. Name: `webapp-clm-agent`.
3. **Authentication:** enable **Easy Auth** with your tenant's Entra ID. Restrict access to the `Contracts-Users` group.
4. **Branding:** upload logo + set the agent name to *"CLM Assistant"*.
5. Deploy. Wait for the URL, then open it and run one end-to-end scenario ("Show me the Contoso MSA termination clause").

### Track B · Teams App (10 min)

1. **Foundry portal → Deploy → Microsoft Teams.**
2. Under the hood this provisions an **Azure Bot Service** and produces a Teams `manifest.zip`.
3. In Teams admin center, **upload custom app** → `manifest.zip`.
4. Pin the bot in a test channel; send it a message.
5. Bonus: add a **messaging extension** so `@CLM contract Contoso` works from any channel.

### Track C · API endpoint (5 min)

1. **Foundry portal → Deploy → API endpoint.**
2. Copy the endpoint URL and the deployment name.
3. Authenticate downstream callers with a **Managed Identity** bearer token to `https://ai.azure.com/.default`.

Sample FastAPI proxy (`app/main.py`) if you want to front the API with your own service:

```python
# pip install fastapi uvicorn azure-identity azure-ai-projects
from fastapi import FastAPI
from pydantic import BaseModel
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

app = FastAPI()
project = AIProjectClient.from_connection_string(
    conn_str="<project-connection-string>",
    credential=DefaultAzureCredential(),
)
AGENT_ID = "<clm-agent-id>"

class Ask(BaseModel):
    question: str
    thread_id: str | None = None

@app.post("/ask")
def ask(payload: Ask):
    thread_id = payload.thread_id or project.agents.create_thread().id
    project.agents.create_message(thread_id=thread_id, role="user", content=payload.question)
    run = project.agents.create_and_process_run(thread_id=thread_id, agent_id=AGENT_ID)
    msgs = project.agents.list_messages(thread_id).data
    return {"thread_id": thread_id, "answer": msgs[0].content[0].text.value}
```

---

## 🛡️ Governance checklist

Before flipping any of these to production, tick every box.

### Identity
- [ ] Web App uses **Easy Auth** with an Entra ID app registration.
- [ ] API endpoint uses **Managed Identity** — no static keys in code.
- [ ] Access is restricted to a named Entra group (e.g., `Contracts-Users`).

### Network
- [ ] AI Search + Storage are on **Private Endpoints** (production).
- [ ] Web App restricts inbound to known VNets or the corporate gateway.
- [ ] Egress from the agent is limited to declared tools' hostnames.

### Data
- [ ] Contract repository has **Purview labels** applied.
- [ ] Storage uses **Customer-Managed Keys** (CMK) if required by policy.
- [ ] No PII / contract text is written to logs — traces store IDs, not content.
- [ ] Retention on chat history and traces is set explicitly (e.g., 30 days).

### Observability
- [ ] **OpenTelemetry** is enabled — traces + metrics flow to Application Insights.
- [ ] KQL dashboards for **cost, latency, tool-call success, hallucination rate**.
- [ ] Alert on `IndirectAttack.defect_rate > 0` in production traffic.

### Lifecycle
- [ ] Evaluation gate from Challenge 4 is enforced in CI *before* deploy.
- [ ] Rollback plan documented (previous agent version tag).
- [ ] Instruction changes require peer review — treat prompt like code.

---

## 🧪 End-to-end acceptance test

Run this exact scenario once, on each deployment target (Web / Teams / API):

1. *"Do we have any active contracts with Contoso?"* — expects `contract_search`.
2. *"Show me the Contoso MSA termination clause."* — expects `clause_search` + citation.
3. *"Draft an amendment reducing the liability cap to 6 months of fees."* — expects `generate_document`, returns a doc URI.
4. *"Route this amendment for legal approval."* — confirms first, then `route_approval`, returns approval id.
5. *"Mark the contract as In Review."* — confirms first, then `contract_status`.

Every step should:
- Cite sources where relevant.
- Confirm before any irreversible action.
- Emit a trace visible in Application Insights within ~30 seconds.

---

## 🌐 Optional — publish the hackathon site

Publish this repo's `index.html` to **GitHub Pages** so your team can find the hack from anywhere.

1. Push the repo to GitHub.
2. In the repo settings → **Pages** → source: `Deploy from a branch` → branch `main` / folder `/ (root)`.
3. Wait a minute and open `https://<org>.github.io/MS-Foundry-Microhack/`.

You now have a public landing page for the CLM Agent MicroHack.

---

## ✅ Success criteria

- [ ] Web App deployed with Easy Auth and end-to-end acceptance test passing.
- [ ] Teams App installed with end-to-end acceptance test passing.
- [ ] API endpoint returns a grounded answer to a `curl` request.
- [ ] Full governance checklist ticked (or explicit exceptions documented).
- [ ] Application Insights shows traces for the acceptance test.
- [ ] (Optional) GitHub Pages site published.

## 🩹 Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Web App returns 401 on load. | Easy Auth not configured. | Re-enable Easy Auth; add allowed audience; restart. |
| Teams bot doesn't respond. | Manifest not sideloaded / bot channel not enabled. | Re-upload `manifest.zip`; enable Teams channel on Bot Service. |
| API returns 403 from downstream. | Missing Managed Identity assignment. | Grant the MI the `Cognitive Services User` role on the Foundry project. |
| No traces in App Insights. | OpenTelemetry not wired. | Install `azure-monitor-opentelemetry` + set `APPLICATIONINSIGHTS_CONNECTION_STRING`. |
| Injection alert fires on the acceptance test. | Adversarial content in a document; likely fine. | Confirm defense worked (agent didn't obey); tune alert threshold. |

## 🏁 You're done

You built, grounded, evaluated, and deployed a **Contract Lifecycle Management Agent** on **Microsoft Foundry** — with governance, identity, observability, and a real deployment gate. That's a production-shaped agent, not a demo.

Wrap up by:
- Sharing your Web / Teams / API links with the team.
- Publishing the [`index.html`](../index.html) landing page.
- Filing the improvements you spotted during evaluation as issues on the repo.

Congratulations. Now go apply the same pattern to the next contract-adjacent workflow — renewals, RFPs, vendor onboarding — the shape is the same.
