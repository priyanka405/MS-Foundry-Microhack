# Challenge 8 — Publish

> **Goal:** Deploy the agent as a **Web App**, a **Microsoft Teams App**, and an **API endpoint** — with Managed Identity, Easy Auth, and the evaluation gate enforced in CI.

**Foundry surface:** Foundry Deploy, Web App, Bot Service, API endpoints
**Estimated time:** 40–55 min
**Prerequisite:** Challenges 1–7 (evaluation gate passing).

---

## 🎯 Objective

Ship the agent to real users through three channels — and never let a regression sneak past the gate.

## 📋 Tasks

1. **Deploy** to at least one channel (Web / Teams / API).
2. Configure **Managed Identity** on the deployment (no keys).
3. **Wire the eval gate into CI** so no bad build gets promoted.
4. Run the end-to-end **acceptance test** against your deployment.
5. (Optional) `mkdocs gh-deploy` this repo's docs site so the team can find it.

---

## 🚀 Track A · Web App (10 min)

1. Foundry portal → **your agent → Deploy → Web App**.
2. Name: `webapp-clm-agent`.
3. **Authentication:** Easy Auth with your tenant's Entra ID, restricted to a group like `Contracts-Users`.
4. **Branding:** upload a logo; set the display name to *"Contract Intake &amp; Drafting Agent"*.
5. Deploy. Open the URL and run the acceptance test below.

## 💬 Track B · Teams App (10 min)

1. Foundry portal → **Deploy → Microsoft Teams**.
2. This provisions an **Azure Bot Service** and produces a Teams `manifest.zip`.
3. Teams admin center → **upload custom app** → `manifest.zip`.
4. Pin the bot in a test channel; run the acceptance test.
5. (Bonus) Add a messaging extension so `@CIDA nda contoso` works from any channel.

## 🌐 Track C · API endpoint (5 min)

1. Foundry portal → **Deploy → API endpoint**.
2. Copy the endpoint URL and deployment name.
3. Assign a **Managed Identity** on your caller (Web App, Function, etc.).
4. Grant the MI the `Cognitive Services User` role on the Foundry project.
5. Get a bearer token to `https://ai.azure.com/.default` and call the endpoint.

Optional — a thin FastAPI proxy in front:

```python
# app/api.py
from fastapi import FastAPI
from pydantic import BaseModel
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient
from app.config import settings

api = FastAPI()
project = AIProjectClient.from_connection_string(
    conn_str=settings.project_connection_string,
    credential=DefaultAzureCredential(),
)

class Ask(BaseModel):
    question: str
    thread_id: str | None = None

@api.post("/ask")
def ask(payload: Ask):
    thread_id = payload.thread_id or project.agents.create_thread().id
    project.agents.create_message(thread_id=thread_id, role="user", content=payload.question)
    project.agents.create_and_process_run(thread_id=thread_id, agent_id=settings.agent_id)
    msg = project.agents.list_messages(thread_id).data[0]
    return {"thread_id": thread_id, "answer": msg.content[0].text.value}
```

## 🛡️ Governance checklist

Before flipping any of these to production, tick every box.

**Identity**
- [ ] Web App uses **Easy Auth** with an Entra ID app registration.
- [ ] API endpoint callers use **Managed Identity** — no static keys.
- [ ] Access restricted to a named Entra group.

**Network**
- [ ] AI Search + Storage on **Private Endpoints** in production.
- [ ] Web App restricts inbound to known VNets or corporate gateway.
- [ ] Egress limited to declared tool hostnames.

**Data**
- [ ] Contract repository has **Purview labels** applied.
- [ ] Storage uses **CMK** if required by policy.
- [ ] No contract text written to logs — traces store IDs, not content.
- [ ] Retention on chat history and traces set explicitly.

**Observability**
- [ ] OpenTelemetry enabled (Challenge 5).
- [ ] Alerts on `IndirectAttack.defect_rate &gt; 0` and `groundedness &lt; 3.5`.

**Lifecycle**
- [ ] **Evaluation gate enforced in CI** *before* promote.
- [ ] Rollback plan documented (previous agent version tag).
- [ ] Instruction changes require peer review.

## ⚙️ CI-enforced deployment gate

```yaml
# .github/workflows/deploy.yml
name: Evaluate and deploy
on:
  push:
    branches: [main]
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - name: Azure login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Run evaluation gate
        env:
          AZURE_AI_PROJECT_CONNECTION_STRING: ${{ secrets.AZURE_AI_PROJECT_CONNECTION_STRING }}
        run: python -m app.evaluation

  deploy:
    needs: gate
    runs-on: ubuntu-latest
    steps:
      - run: echo "Promote agent to Web / Teams / API here."
```

## 🧪 End-to-end acceptance test

Run this exact scenario once per deployment target:

1. *"I need a mutual NDA with Contoso, effective 2026-08-01, 2-year term."*
   → intake protocol completes, `generate_document` fires, returns doc URI.
2. *"Route this for legal approval."*
   → confirms, `route_approval` fires, returns approval id.
3. *"Mark the NDA as In Review."*
   → confirms, `contract_status` fires, returns updated state.

Every step must cite sources where relevant, confirm before irreversible actions, and appear in App Insights within ~30s.

## 🌐 (Optional) Publish this docs site

```bash
pip install mkdocs-material
mkdocs gh-deploy --force
```

Live at `https://<org>.github.io/foundry-contract-lifecycle-management-hackathon/`.

## ✅ Success criteria

- [ ] At least one channel deployed and reachable.
- [ ] Managed Identity / Easy Auth configured — no static keys.
- [ ] Governance checklist ticked (or explicit exceptions logged).
- [ ] Evaluation gate wired into CI.
- [ ] Acceptance test passes on the deployed channel.
- [ ] (Optional) MkDocs site published.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Web App 401 on load. | Easy Auth not configured. | Enable Easy Auth; add allowed audience; restart. |
| Teams bot doesn't respond. | Manifest not sideloaded / channel not enabled. | Re-upload `manifest.zip`; enable Teams channel on Bot Service. |
| API returns 403 from a caller. | Missing role on Managed Identity. | Grant `Cognitive Services User` on the Foundry project. |
| CI eval gate fails intermittently. | LLM-judge variance. | Average over 3 runs; keep `temperature=0`. |
| MkDocs deploy 404. | GitHub Pages not enabled or Actions blocked from Pages. | Repo Settings → Pages → *Deploy from a branch* → `gh-pages`. |

## 🏁 You're done

You built, grounded, tooled, guarded, observed, evaluated, optimized, and deployed a **Contract Intake &amp; Drafting Agent** on **Microsoft Foundry** — with a real gate in CI.

Wrap up with the [wrap-up page](../../wrapup.md). Congratulations.
