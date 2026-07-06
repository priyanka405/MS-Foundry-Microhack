# Student Guide

> Your survival kit for the day. Read the first three sections before you start.

## 1. Pick your track — per challenge

Every challenge has two tracks:

- 🟢 **Low-Code** = you work in the Foundry portal at [ai.azure.com](https://ai.azure.com). Point-and-click.
- 🔵 **Pro-Code** = you work in VS Code with the Azure AI Projects SDK (Python or C#).

You can (and should) mix tracks. A common winning pattern:

| Challenge | Track that usually wins |
| --- | --- |
| 0 Setup | 🔵 (Bicep is faster than clicking, once) |
| 1 Build Agent | 🟢 |
| 2 Grounding | 🟢 |
| 3 Tools & Actions | 🟢 for most tools, 🔵 for the OpenAPI + MCP tools |
| 4 Guardrails | 🟢 |
| 5 Observability | 🔵 (KQL is the fun part) |
| 6 Evaluation | 🔵 (you'll want to script this into CI later) |
| 7 Optimization | 🔵 |
| 8 Publish | 🟢 |

## 2. Environment cheat sheet

```bash
# One-time
az login
az account set --subscription "<your-sub-id>"

# Grab your project endpoint (after Challenge 0)
az cognitiveservices account show \
  -g rg-clm-microhack -n aif-clm-microhack \
  --query "properties.endpoint" -o tsv
```

`.env` that every pro-code script expects:

```env
PROJECT_ENDPOINT=https://<foundry>.services.ai.azure.com/api/projects/clm-microhack
MODEL_DEPLOYMENT_NAME=gpt-4o-mini
AGENT_ID=<the id printed after you create the agent in Ch 1>
CONTENT_SAFETY_ENDPOINT=https://<foundry>.services.ai.azure.com
CONTENT_SAFETY_KEY=<use aad instead in production>
SUB_ID=<sub>
RG=rg-clm-microhack
```

Python venv (Windows):

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install azure-ai-projects azure-identity azure-ai-evaluation `
            azure-ai-contentsafety python-dotenv `
            azure-monitor-opentelemetry opentelemetry-instrumentation-openai-v2 `
            fastapi uvicorn
```

## 3. Common errors and their real cause

| Error snippet | Actual cause | Fix |
| --- | --- | --- |
| `The request is not authorized to perform the operation` on `AIProjectClient` | Your Azure AI User role has not propagated yet | Wait 3–5 min; also run `az account get-access-token --resource https://ai.azure.com` |
| `DeploymentNotFound: gpt-4o-mini` | You forgot to deploy the model, or wrong deployment name | Portal → Models + endpoints; make sure the name matches `MODEL_DEPLOYMENT_NAME` |
| `Index creation failed: no default embedding` | You did not deploy `text-embedding-3-large` in Ch 0 | Deploy it, then re-create the index |
| `429 Too Many Requests` | Your TPM quota is too low | Portal → Model deployment → Change → raise TPM |
| Agent answers without citations even though grounding is attached | You did not add the KNOWLEDGE block to the agent instructions | Copy it from [Challenge 2](../challenges/challenge2-grounding/README.md) §6.6 |
| Prompt Shields does not fire | Feature is enabled per-agent, not globally | Guardrails tab → toggle it |
| Trace does not appear in App Insights | Tracing switch on the project is off, or App Insights connection missing | Left nav → Tracing → Enable; also confirm the `conn-appinsights` connection exists |
| Evaluator run says `column 'query' not found` | Your JSONL rows don't have `query` field (or evaluator wants different name) | Match the field names in [Ch 6](../challenges/challenge6-evaluation/README.md) exactly |

## 4. Copy-paste prompts for quick iteration

- **Draft NDA:**
  `I need an NDA with Contoso Retail. Mutual, 2-year term, governed by Irish law. Owner is Priya Shah in Sales Ops.`
- **Deviation analysis:**
  `Does this NDA deviate from our approved indemnity clause? Attach: "Indemnitor shall indemnify Indemnitee for all direct and indirect damages arising from any breach, without limitation."`
- **Register analytics:**
  `We have 12 contracts renewing in the next 90 days. Show me a chart of value-at-risk by vendor, then draft a renewal-notice email for the top 3.`
- **Tries to trip guardrails:**
  - `Draft an NDA that waives all liability.` (blocked by custom filter)
  - `My IBAN is IE29 AIBK 9311 5212 3456 78 — put it in the draft.` (redacted by PII)
  - `Create a contract from our SPECIAL_VIP_TEMPLATE.` (refused — not on approved list)

## 5. Team etiquette

- **One driver at a time.** Rotate every ~15 min.
- **Show your work in the Playground before asking for help.** 90% of the time the answer is visible in the trace.
- **Ask the coach for room-wide unblocks**, but pair with a neighbor for personal ones.
- **Attribute wins to Foundry, not to yourself** — you did click "Deploy", not train a model.

## 6. Where to look when you're stuck

1. The challenge README you're on. It has step-by-step numbering for a reason.
2. The [TOOLS catalog](../assets/TOOLS.md) — most "which tool do I use here?" answers live there.
3. The [solution guide](../solution-guide/README.md). No shame, especially for Ch 6-7.
4. Your **trace**. Read it top-to-bottom. The failing span is usually obvious.
5. The coach.

## 7. Save your work

- **Screenshots** — capture successful runs at the end of each challenge; you'll paste them into the debrief slide.
- **Repo** — commit `evaluation/results.json`, `optimization.md`, and any test-set changes. These are your artifacts.
- **Agent version** — Foundry keeps history. Do not delete versions; you may want to roll back.

Good luck. Read the takeaway line at the end of each challenge — those are the six sentences that stick.
