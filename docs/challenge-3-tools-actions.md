# Challenge 3 — Add Tools and Actions

⏱ **~50 minutes**  ·  🧠 Key Foundry feature: **Tools catalog · Logic Apps · Power Automate · Azure Functions**

## 🎯 Objective

Give the Executive Assistant Agent the ability to **act** on the real world:

1. **Create tasks** — via a Power Automate flow that writes to Microsoft Planner or a to-do list.
2. **Send drafts for approval** — via a Logic App that emails a draft and returns the executive's decision.
3. **Book time / propose meeting slots** — via a Logic App that hits Microsoft Graph (mocked or real).
4. **Custom business logic** — an Azure Function that scores follow-up urgency.
5. *(Bonus)* an **MCP tool** for an external system you care about (e.g. CRM, ticketing).

## 🧭 Context

Tools are the leap from **chatbot** to **agent**. A chatbot answers. An agent *does things* — it calls APIs, files a ticket, kicks off a workflow, returns a chart. In Foundry, tools are declared once on the agent; the model decides which to call, when, and with what arguments. The Agent Service handles auth, retries, and tracing.

Rule of thumb:

> **Prose belongs to the grounded model. Verbs belong to tools.**
> Draft = model. *Create the task* = tool.

## ✅ Prerequisites

- [Challenge 2](challenge-2-grounding.md) complete — the agent is grounded.
- The ability to create a **Logic App** and a **Power Automate flow** in your tenant (or a mock endpoint you control).
- An Azure Function App (Consumption plan is fine).

## 🏗️ Steps

### 1. Create a Logic App: `Send draft for approval`

1. In the Azure portal → **Create → Logic App (Consumption)** → name `la-ea-approval` in the same resource group as your Foundry project.
2. Trigger: **When an HTTP request is received**.
3. Action: **Office 365 Outlook → Send approval email** to the executive (or your own inbox for testing).
   - **Subject:** `Approve draft: @{triggerBody()?['subject']}`
   - **Body:** `@{triggerBody()?['body']}`
   - **User options:** `Approve, Reject`
4. Action: **Response**, returning `{ "decision": "@{body('Send_approval_email')?['SelectedOption']}" }`.
5. Save → copy the **HTTP POST URL**.

### 2. Create a Power Automate flow: `Create tasks`

1. In [make.powerautomate.com](https://make.powerautomate.com) → **+ Create → Instant cloud flow**.
2. Trigger: **When an HTTP request is received** with schema:
   ```json
   {
     "type": "object",
     "properties": {
       "tasks": {
         "type": "array",
         "items": {
           "type": "object",
           "properties": {
             "owner":  { "type": "string" },
             "action": { "type": "string" },
             "due":    { "type": "string" }
           }
         }
       }
     }
   }
   ```
3. Action: **Planner → Create a task** (or **To Do → Add task**) — inside an **Apply to each** loop over `triggerBody()?['tasks']`.
4. Save → copy the **HTTP URL**.

### 3. Create an Azure Function: `urgency_score`

Create a Function App `func-ea` and add a Python HTTP-triggered function:

```python
# infra/functions/urgency_score/__init__.py
import azure.functions as func
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    body = req.get_json()
    due = body.get("due")        # ISO date
    seniority = body.get("owner_seniority", "IC")  # IC / manager / vp / cxo
    is_customer_facing = bool(body.get("customer_facing", False))

    days_left = 30
    if due:
        try:
            days_left = (datetime.fromisoformat(due) - datetime.utcnow()).days
        except Exception:
            pass

    score = 0
    score += max(0, 40 - days_left * 2)                     # closer = hotter
    score += {"IC": 0, "manager": 10, "vp": 25, "cxo": 35}.get(seniority, 0)
    score += 20 if is_customer_facing else 0
    score = min(100, max(0, int(score)))
    band = "critical" if score >= 70 else "high" if score >= 45 else "normal"

    return func.HttpResponse(
        json.dumps({"urgency_score": score, "band": band}),
        mimetype="application/json")
```

Expose an OpenAPI spec at `/api/openapi.json` (Functions can auto-generate one, or hand-write it).

### 4. Register the tools on the agent (portal)

Open **Build → Agents → executive-assistant → Tools → + Add tool** and add each of the following:

| Tool name | Type | Endpoint / notes |
| --- | --- | --- |
| `send_for_approval` | Logic App | Paste the `la-ea-approval` URL. |
| `create_tasks` | Power Automate | Paste the flow URL from step 2. |
| `score_urgency` | Azure Function via OpenAPI | Paste `func-ea` OpenAPI URL. |
| `propose_meeting_slots` | Logic App or Function | Optional — mock returning 3 slots. |
| *(bonus)* `mcp-crm` | MCP server | `serverLabel: crm`, `serverUrl: <your MCP endpoint>`, `allowed_tools: ["find_account", "log_note"]`, `require_approval: always`. |

Give each tool a **clear description** — the model routes on those strings:

- `create_tasks` — *"Create planner/to-do tasks. Input: a list of {owner, action, due} objects. Output: created task ids."*
- `send_for_approval` — *"Send an email draft to the executive for approval. Input: {subject, body}. Output: {decision}."*
- `score_urgency` — *"Score follow-up urgency (0–100). Input: {due, owner_seniority, customer_facing}. Output: {urgency_score, band}."*

### 5. Extend the agent's instructions with a tool-routing block

```text
TOOL ROUTING
- After drafting action items, call `score_urgency` for each item and add
  a "band" column to the output table.
- Never send anything to a human other than the executive without first
  calling `send_for_approval` and receiving an approval decision.
- Call `create_tasks` ONLY after the executive has explicitly approved the
  action-item list.
- Use `propose_meeting_slots` when the user asks to book time.
- MCP tools require explicit user confirmation before every call.
```

### 6. Run the full scenario in the Playground

```text
The Q3 review meeting is done. Decisions:
- Cut marketing ask by 15%
- Approve €400k for pricing tooling
- Push retail launch decision to Oct 15

Give me action items with owners + due dates, score the urgency of each,
then draft a follow-up email. If I approve, create the tasks in Planner.
```

Expected sequence:
1. Model produces action items.
2. Model calls `score_urgency` **N** times → adds band column.
3. Model drafts the email.
4. Model calls `send_for_approval` → you click **Approve** in Outlook → decision returns.
5. Model calls `create_tasks` → task IDs come back.

Every step appears in the trace tree under the run.

### 7. (Optional) Pro-code — declare tools programmatically

```python
# scripts/add_tools.py
import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import (
    OpenApiTool, OpenApiAnonymousAuthDetails, McpTool,
)

client = AIProjectClient(endpoint=os.environ["PROJECT_ENDPOINT"],
                        credential=DefaultAzureCredential())

with open("infra/openapi/urgency.json") as f:
    urgency_tool = OpenApiTool(
        name="score_urgency",
        description="Score follow-up urgency 0–100.",
        spec=f.read(),
        auth=OpenApiAnonymousAuthDetails(),
    )

mcp_tool = McpTool(
    server_label="crm",
    server_url="https://mcp.example.com/crm",
    allowed_tools=["find_account", "log_note"],
    require_approval="always",
)

client.agents.update_agent(
    agent_id=os.environ["AGENT_ID"],
    tools=urgency_tool.definitions + mcp_tool.definitions,
)
```

## 🧪 Success criteria

- [ ] Agent lists **at least 3 tools**: `send_for_approval`, `create_tasks`, and `score_urgency`.
- [ ] Playground run for the Q3 scenario triggers **≥ 3 tool calls**.
- [ ] Approval email actually arrives; the returned decision changes what the agent does next.
- [ ] Tasks are created (Planner or To-Do) — you can see them in the source system.
- [ ] Tool descriptions are unambiguous — a stranger could tell what each tool does from the description alone.

## 🔎 Troubleshooting

| Symptom | Fix |
| --- | --- |
| Agent doesn't call a tool | The description is too vague. Rewrite it in imperative English (*"Call this to..."*). |
| Approval email never arrives | Logic App is missing an Office 365 connection — reconnect and re-save. |
| MCP tool returns 403 | The MCP server requires auth you didn't configure. Skip for the hackathon or provide a bearer token. |

## ➡️ Next steps

You now have an agent that **reads** (Challenge 2) and **acts** (Challenge 3). But *"can do"* is not *"should do"*. **[Challenge 4 — Evaluate and Improve](challenge-4-evaluation.md)** measures quality, safety, and groundedness — and sets a real bar you can ship against.

## 💡 Key takeaway

> Tools are what make an agent an agent. Route them by *purpose*, not by *availability*.
