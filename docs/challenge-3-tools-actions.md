# Challenge 3 — Tools and Actions

> **Goal:** Move from *chatbot* to *agent*. Add business tools so the CLM Agent can route approvals, generate documents, and track contract status — end to end.

**Foundry feature:** Tools catalog (Logic Apps, Power Automate, Azure Functions, OpenAPI, MCP)
**Estimated time:** 50–60 min
**Prerequisite:** Challenges 1–2 complete.

---

## 🎯 Objective

Extend the CLM Agent with **five business tools**:

| # | Tool | Purpose | Backing service |
| --- | --- | --- | --- |
| 1 | `contract_search` | Structured metadata search over the repository. | (already there — Azure AI Search) |
| 2 | `clause_search` | Locate specific clauses across contracts. | Azure AI Search (filtered) |
| 3 | `route_approval` | Send an approval request to Legal / Procurement. | Logic App `la-clm-approval` |
| 4 | `generate_document` | Fill a template (NDA / SOW / amendment) and store it. | Power Automate flow |
| 5 | `contract_status` | Read / update the lifecycle state of a contract. | Azure Function |

## 📋 Tasks

1. Build the **Logic App** for approval routing.
2. Build the **Power Automate** flow for document generation.
3. Build the **Azure Function** for contract status.
4. Register all tools on the agent with clear names and descriptions.
5. Append the **TOOL ROUTING** block to the agent instructions.
6. Run the end-to-end scenario from Challenge scenario below.
7. (Bonus) Register an MCP tool for CRM enrichment.

---

## 🛠️ Step-by-step

### 1. Logic App — approval routing (`la-clm-approval`)

Create a new **Logic App (Consumption)** in the same resource group.

**Trigger:** *When an HTTP request is received.*

Request-body JSON schema:

```json
{
  "type": "object",
  "properties": {
    "subject":     { "type": "string" },
    "requester":   { "type": "string" },
    "counterparty":{ "type": "string" },
    "doc_uri":     { "type": "string" },
    "redline":     { "type": "string" },
    "risk_band":   { "type": "string", "enum": ["Low","Medium","High"] }
  },
  "required": ["subject","requester","doc_uri"]
}
```

**Actions:**
1. **Office 365 Outlook → Send approval email** to `legal-approvers@contoso.com` with `Subject`, `Requester`, and a link to `doc_uri`.
2. **Response** — return `{status, approver, decision, approval_id, decided_at}`.

Save; copy the **HTTP POST URL**.

### 2. Power Automate — `generate_document`

Create a **Power Automate cloud flow** triggered by *"When an HTTP request is received"*.

Input schema:

```json
{
  "template":     { "type": "string", "enum": ["NDA","SOW","MSA","Amendment"] },
  "party":        { "type": "string" },
  "effective_date":{ "type": "string" },
  "clauses":      { "type": "array", "items": { "type": "string" } }
}
```

Actions:
1. **SharePoint / OneDrive** → open the corresponding `.docx` template.
2. **Populate a Microsoft Word template** — bind `{{party}}`, `{{effective_date}}`, `{{clauses}}`.
3. **Create file** in the `/Generated` folder.
4. **Response** with `{doc_uri, template, generated_at}`.

### 3. Azure Function — `contract_status`

Create a Python HTTP-triggered function:

```python
import azure.functions as func
import json, datetime

VALID = ["Draft","In Review","Approved","Signed","Active","Expired","Terminated"]

app = func.FunctionApp()

@app.function_name("contract_status")
@app.route(route="contract_status", methods=["POST"])
def contract_status(req: func.HttpRequest) -> func.HttpResponse:
    body = req.get_json()
    contract_id = body["contract_id"]
    new_state   = body.get("new_state")

    # In a real system, read/write from Dataverse / SQL / SharePoint list.
    if new_state and new_state not in VALID:
        return func.HttpResponse(
            json.dumps({"error": f"invalid state '{new_state}'"}),
            status_code=400, mimetype="application/json"
        )
    return func.HttpResponse(
        json.dumps({
            "contract_id": contract_id,
            "state":       new_state or "Active",
            "updated_at":  datetime.datetime.utcnow().isoformat() + "Z"
        }),
        mimetype="application/json"
    )
```

Deploy it and note the HTTP endpoint.

### 4. Register the tools on the agent

In the Foundry portal (**Agents → clm-agent → Tools**), add each backend as a tool with a **clear name and description** — the model routes on those strings.

| Tool | Description you should paste |
| --- | --- |
| `contract_search` | *"Search the enterprise contract repository by counterparty, contract type, or free text. Returns a list of contracts with metadata and citations. Use this whenever the user asks about specific contracts or a counterparty."* |
| `clause_search` | *"Locate specific clauses (termination, liability, indemnity, GDPR, payment, IP) across one or many contracts. Returns exact clause text with source anchors."* |
| `route_approval` | *"Send an approval request to Legal or Procurement for a proposed contract change. Requires user confirmation before firing. Returns an approval id and status."* |
| `generate_document` | *"Generate a contract document from a template (NDA / SOW / MSA / Amendment) using structured fields. Returns the location of the new document."* |
| `contract_status` | *"Read or update the lifecycle state of a contract. Valid states: Draft, In Review, Approved, Signed, Active, Expired, Terminated. Only call with new_state after explicit user confirmation."* |

### 5. Append this TOOL ROUTING block to instructions

```text
# TOOL ROUTING
- Contract or counterparty questions → contract_search first, then clause_search.
- "What does <clause> say / where is <clause>?" → clause_search.
- "Route this for approval / send to legal for review" → propose the call to
  route_approval, then ONLY fire after the user confirms.
- "Draft / generate / create <contract type>" → generate_document, then hand
  back the doc URI to the user.
- "Mark this as signed / activate this / update status" → confirm with the
  user first, then contract_status.
- After every tool call, tell the user in one sentence what you just did and
  what happens next.
- Never chain approval + status update in one silent step — always confirm.
```

### 6. Run the end-to-end scenario

**In one Playground thread**, run this sequence and confirm the agent calls the right tools:

1. **User:** *"Do we have any active contracts with Contoso?"*
   → expects `contract_search(counterparty="Contoso")`.
2. **User:** *"Show the termination clause in the Contoso MSA."*
   → expects `clause_search(contract_id="msa-contoso-*", section="termination")`.
3. **User:** *"Draft an amendment reducing the liability cap to 6 months of fees."*
   → expects `generate_document(template="Amendment", party="Contoso", clauses=[...])`. The agent should return a `doc_uri`.
4. **User:** *"Route this amendment for legal approval."*
   → expects the agent to **confirm first**, then `route_approval(subject=..., doc_uri=..., risk_band=...)`.
5. **User:** *"Mark the contract status as 'In Review'."*
   → expects the agent to **confirm first**, then `contract_status(contract_id=..., new_state="In Review")`.

The whole scenario should feel like one continuous conversation — grounded, tool-using, and never irreversible without human OK.

## 🎁 Bonus — MCP tool for CRM enrichment

If your organization has an MCP server exposing CRM data (Dataverse / Salesforce), register it as an MCP tool with `require_approval=always`. The agent can then enrich a contract question with counterparty account data ("What's Contoso's total annual spend across all their SOWs?").

## ✅ Success criteria

- [ ] Logic App `la-clm-approval` responds to HTTP POST with an approval id.
- [ ] Power Automate flow `generate_document` returns a generated document URI.
- [ ] Azure Function `contract_status` validates state and returns a timestamped payload.
- [ ] All five tools are registered on the agent with clear descriptions.
- [ ] The TOOL ROUTING block is in the instructions.
- [ ] The end-to-end scenario produces the expected 5-tool sequence.
- [ ] The agent **confirms** before firing `route_approval` and `contract_status`.

## 🩹 Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Agent picks the wrong tool. | Ambiguous descriptions. | Rewrite descriptions to start with the *user intent* they map to. |
| Agent fires `route_approval` without confirmation. | Missing rule in TOOL ROUTING. | Re-add: *"ONLY fire after the user confirms."* |
| Logic App call returns 401. | Missing SAS in the URL. | Use the full **HTTP POST URL** including `?sv=...&sig=...`. |
| `generate_document` fails with template error. | Word template placeholders are text, not content controls. | Use *Insert → Content control* for `{{party}}` etc. |
| Function returns 500. | JSON body not parsed. | Log `req.get_body()` and check content-type is `application/json`. |

## 🌉 Next challenge

The agent can now search, reason, and act. But is it **good enough to ship**? In **[Challenge 4 — Evaluation and Optimization](challenge-4-evaluation.md)** you'll measure accuracy, groundedness, and safety — and set a real deployment gate.
