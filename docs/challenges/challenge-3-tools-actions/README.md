# Challenge 3 — Tools &amp; Actions

> **Goal:** Move from *"chatbot that quotes clauses"* to *"agent that drafts, routes, and tracks"*. Add three real business tools.

**Foundry surface:** Tools catalog (Logic Apps, Power Automate, Azure Functions, OpenAPI, MCP)
**Estimated time:** 50–60 min
**Prerequisite:** Challenges 1–2.

---

## 🎯 Objective

Add three tools and one bonus tool:

| # | Tool | Purpose | Backing service |
| --- | --- | --- | --- |
| 1 | `clause_lookup` | Return an **approved clause** by category (`payment` / `liability` / `termination`). | Azure Function |
| 2 | `generate_document` | Fill a template with fields + clauses and store the result. | Power Automate |
| 3 | `route_approval` | Send an approval request to Legal / Procurement. | Logic App |
| 4 (bonus) | `contract_status` | Read / update the lifecycle state of a contract. | Azure Function |

## 📋 Tasks

1. Build the **Azure Function** `clause_lookup` (Python HTTP trigger).
2. Build the **Power Automate** flow `generate_document`.
3. Build the **Logic App** `la-clm-approval`.
4. (Optional) Build the **Azure Function** `contract_status`.
5. Register all tools on the agent with clear names + descriptions.
6. Append the **TOOL ROUTING** block to the instructions.
7. Run the end-to-end scenario.

---

## 🖱️ Portal path

### 1. Azure Function — `clause_lookup`

Deploy a Python HTTP-triggered function. Body:

```python
import azure.functions as func
import json, pathlib

APPROVED = {
    "payment":     pathlib.Path("clauses/payment_terms.md").read_text(),
    "liability":   pathlib.Path("clauses/liability_clause.md").read_text(),
    "termination": pathlib.Path("clauses/termination_clause.md").read_text(),
}

app = func.FunctionApp()

@app.function_name("clause_lookup")
@app.route(route="clause_lookup", methods=["POST"])
def clause_lookup(req: func.HttpRequest) -> func.HttpResponse:
    body = req.get_json()
    cat = body.get("category", "").lower()
    if cat not in APPROVED:
        return func.HttpResponse(
            json.dumps({"error": f"unknown category '{cat}'", "valid": list(APPROVED)}),
            status_code=400, mimetype="application/json"
        )
    return func.HttpResponse(
        json.dumps({"category": cat, "clause": APPROVED[cat], "version": "2026.07"}),
        mimetype="application/json"
    )
```

The clause source files ship with this repo — see [`data/approved_clauses/`](../../../data/approved_clauses).

### 2. Power Automate — `generate_document`

Cloud flow triggered by *"When an HTTP request is received"*. Input schema:

```json
{
  "template":       { "type": "string", "enum": ["NDA", "MSA", "SOW", "Amendment"] },
  "counterparty":   { "type": "string" },
  "effective_date": { "type": "string" },
  "term":           { "type": "string" },
  "clauses":        { "type": "array", "items": { "type": "string" } }
}
```

Actions: **Populate a Microsoft Word template** → **Create file in SharePoint** → **Response** with `{doc_uri}`.

Templates for the flow are in [`data/contract_templates/`](../../../data/contract_templates).

### 3. Logic App — `la-clm-approval`

HTTP trigger with:

```json
{
  "subject":     { "type": "string" },
  "requester":   { "type": "string" },
  "counterparty":{ "type": "string" },
  "doc_uri":     { "type": "string" },
  "risk_band":   { "type": "string", "enum": ["Low","Medium","High"] }
}
```

Actions: **Office 365 → Send approval email** to `legal-approvers@<your-tenant>` → **Response** with `{approval_id, status, approver, decision}`.

### 4. Register the tools on the agent

Foundry portal → **Agents → your agent → Tools → + Add**. Paste these descriptions verbatim — the model routes on the text:

| Tool | Description |
| --- | --- |
| `clause_lookup` | *"Return the approved enterprise clause text for a given category. Valid categories: `payment`, `liability`, `termination`. Use whenever drafting to insert an approved clause instead of writing one."* |
| `generate_document` | *"Fill a contract template (NDA / MSA / SOW / Amendment) with the provided fields and clauses, and return the URI of the generated document. Use ONLY after the intake protocol is complete."* |
| `route_approval` | *"Send an approval request to Legal or Procurement for a proposed contract or change. Requires user confirmation before firing. Returns an approval id."* |
| `contract_status` | *"Read or update the lifecycle state of a contract. States: Draft, In Review, Approved, Signed, Active, Expired, Terminated. Confirm with the user before calling with a new_state."* |

### 5. Append this TOOL ROUTING block to the instructions

```text
# TOOL ROUTING
- Draft contains a payment / liability / termination clause -> clause_lookup
  for the approved wording. Do NOT hand-write these clauses.
- Intake protocol complete (4 fields confirmed) -> generate_document.
- User says "send to legal / route for approval / send for review" ->
  confirm first, then route_approval.
- User says "mark as signed / activate / update status" ->
  confirm first, then contract_status.
- After every tool call, tell the user in ONE sentence what you just did and
  what happens next.
- Never chain generate_document + route_approval silently — always show the
  draft first and confirm.
```

### 6. Run the end-to-end scenario

In one Playground thread:

1. *"I need a mutual NDA with Contoso, effective 2026-08-01, 2-year term."*
   → completes intake, then `clause_lookup(category="confidentiality")` and `generate_document(...)`, returns a `doc_uri`.
2. *"Route this for legal approval."*
   → confirms, then `route_approval(...)`, returns `approval_id`.
3. *"Mark the NDA as In Review."*
   → confirms, then `contract_status(...)`.

All three responses should include a one-liner explaining what just happened.

---

## 💻 SDK path

See [`app/tools.py`](../../../app/tools.py) for the tool definitions and the FunctionTool / HTTP tool wiring.

```python
# excerpt
from azure.ai.projects.models import FunctionTool, ToolSet
from app.tools import clause_lookup, generate_document, route_approval, contract_status

toolset = ToolSet()
toolset.add(FunctionTool([clause_lookup, generate_document, route_approval, contract_status]))

client.agents.update_agent(agent_id=agent.id, toolset=toolset)
```

Run:

```bash
python -m app.sample_run --challenge 3
```

---

## 🎁 Bonus — MCP tool for CRM enrichment

If your org has an MCP server exposing CRM data (Dataverse, Salesforce), register it with `require_approval=always`. The agent can then answer *"What's Contoso's total spend across all their SOWs?"* before drafting.

## ✅ Success criteria

- [ ] Function `clause_lookup` returns valid clauses for `payment`, `liability`, `termination`.
- [ ] Power Automate flow `generate_document` returns a `doc_uri`.
- [ ] Logic App `la-clm-approval` responds with an `approval_id`.
- [ ] All tools registered on the agent with clear descriptions.
- [ ] TOOL ROUTING block is in instructions.
- [ ] End-to-end scenario produces the expected 3-tool sequence with confirmations.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Agent hand-writes clauses instead of calling `clause_lookup`. | Ambiguous tool description. | Rewrite starting with the *user intent*: *"Use whenever drafting to insert an approved clause…"*. |
| `route_approval` fires without confirmation. | TOOL ROUTING rule missing. | Re-add *"confirm first, then route_approval"*. |
| Logic App call 401. | Missing SAS in URL. | Use the full HTTP POST URL with `?sv=...&sig=...`. |
| Doc-gen 500. | Word template placeholders are plain text. | Use *Insert → Content control* for `[[FIELD]]`. |

## 🌉 Next challenge

The agent can draft, route, and update. Time to make it **safe**. In **[Challenge 4 — Guardrails](../challenge-4-guardrails/README.md)** you'll add template enforcement, sensitive-data protection, and compliance guardrails.
