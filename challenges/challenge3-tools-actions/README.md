# Challenge 3 — Tools & Actions

## 1. Title & Duration

**Challenge 3 — From Chatbot to Agent: Tools & Actions**
⏱ **50 minutes**

## 2. Objective

Give the agent the ability to **act** on the contract world by attaching:

1. **Contract repository lookup** (Azure AI Search over the contract register).
2. **Clause search** (already added in Challenge 2; here we make it callable as a tool the model can *choose*).
3. **Approval routing** (Logic App).
4. **Document generation** (Azure Function that turns the draft into a `.docx` in Blob Storage).
5. **Contract status tracking** (Azure Function that reads/writes status on the contract register).
6. **Code Interpreter** for **register analytics** (renewal timelines, value-at-risk, spend/risk charts).
7. **Bonus** — an **MCP server** exposed as a custom tool.

## 3. Context

Tools are the leap from **chatbot** to **agent**. A chatbot answers. An agent *does things* — it calls APIs, files a ticket, kicks off a workflow, returns a chart. In Foundry, tools are declared once on the agent; the model decides which to call, when, and with what arguments. The Agent Service handles auth, retries, and tracing.

Key rule of thumb we use in this challenge:

> **Prose summaries + obligation extraction** are the *grounded model's* job.
> **Numeric analysis over the Contract Register** is *Code Interpreter's* job.

Read the [full tool catalog in assets/TOOLS.md](../../assets/TOOLS.md) before you start — the entries below reference it.

## 4. Prerequisites

- [Challenge 2](../challenge2-grounding/README.md) completed. Agent is grounded.
- An Azure Storage account for the `contracts` container (created in Challenge 0).
- Empty Logic App workspace + Function App (both provisioned by `infra/main.bicep`).

## 5. Agents & Tools used

| Tool | Purpose | Track |
| --- | --- | --- |
| **Azure AI Search** | Contract repository + clause search | 🟢 🔵 |
| **File Search** | Compare a third-party file against approved templates | 🟢 🔵 |
| **Logic Apps** | Route approvals + send renewal reminders | 🟢 🔵 |
| **Azure Functions** | Risk scoring + status API | 🔵 (with 🟢 wrapper) |
| **Code Interpreter** | Analytics over `contract-register.md` | 🟢 🔵 |
| **MCP tool** *(bonus)* | Add an external system as a native tool | 🟢 🔵 |

---

## 6. 🟢 Low-Code Steps (Portal)

1. Open **Build → Agents → contract-intake-drafting** → **Tools** → **+ Add tool**.
2. **Azure AI Search — Contract repository**
   - Add a second Search index called `idx-contract-register` (built from `assets/contract-register.md` — the portal will infer schema).
   - Name the tool `search_contract_repository`.
   - Description: *"Look up existing contracts by vendor, type, value, or renewal date."*
3. **File Search** (already available as a built-in tool)
   - Enable **File Search** on the agent.
   - Upload one **third-party NDA** you want to compare (any sample) — the agent will diff it against `assets/templates/NDA.md`.
4. **Logic App — Approval routing**
   - In the Azure portal create a **Consumption Logic App** named `la-clm-approvals`.
   - Trigger: **When an HTTP request is received**.
   - Action 1: **Office 365 Outlook → Send approval email** to `approver@yourdomain.com`.
   - Action 2: **Response** returning `{ "decision": "@triggerBody()?.decision" }`.
   - Save → copy the HTTP POST URL.
   - Back in Foundry Agent → **+ Add tool → Logic App** → paste the URL → name the tool `route_for_approval` → description *"Send a contract draft for human approval. Input: `{ contract_id, vendor, value, owner_email }`. Returns approval decision."*
5. **Azure Function — Risk scoring** *(pre-provisioned by Bicep as `func-clm-risk`)*
   - **+ Add tool → OpenAPI (Function App)** → paste the Function's OpenAPI URL (`https://func-clm-risk.azurewebsites.net/api/openapi.json`).
   - Name the tool `score_contract_risk`.
6. **Azure Function — Status tracking** (same Function App, different route `/api/status`)
   - Add as tool `update_contract_status`.
7. **Code Interpreter**
   - Enable the built-in **Code Interpreter** tool.
   - Upload `assets/contract-register.md` (or the equivalent `.xlsx` if you converted it) as a Code Interpreter file.
8. **MCP server (bonus)**
   - **+ Add tool → MCP server**.
   - **serverLabel:** `sap-ariba`
   - **serverUrl:** `https://mcp.example.com/ariba` *(or any MCP endpoint your org exposes)*
   - **Allowed tools:** `supplier_lookup`, `po_status`.
   - **Approval mode:** *Ask user before every call* (safer for hackathon).
9. Extend the agent's **Instructions** with a tool routing block:

   ```text
   TOOL ROUTING
   - Use `search_contract_repository` for questions about existing signed contracts.
   - Use `search_clause_library` (from grounding) for approved clause language.
   - Use File Search when the user attaches a third-party contract.
   - Use `score_contract_risk` before recommending approval.
   - Use `route_for_approval` ONLY after the user confirms the draft.
   - Use `update_contract_status` after an approval decision comes back.
   - Use Code Interpreter for NUMERIC analytics over the contract register
     (renewal timelines, value-at-risk, spend/risk). Do NOT use it for
     prose summaries.
   - MCP tools require explicit user confirmation before each call.
   ```

10. **Save** and open the Playground.
11. Run this scenario:
    ```text
    We have 12 contracts renewing in the next 90 days. Show me a chart of
    value-at-risk by vendor, then draft a renewal-notice email for the
    top 3.
    ```
    Expected: the agent calls Code Interpreter to build the chart, then drafts prose. Two tool calls, one grounded prose response.

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

### 7.1 Python — declare tools programmatically

```python
# scripts/challenge3_add_tools.py
import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import (
    AzureAISearchTool, AzureAISearchQueryType,
    FileSearchTool, CodeInterpreterTool,
    OpenApiTool, OpenApiAnonymousAuthDetails,
    McpTool,
)

client = AIProjectClient(endpoint=os.environ["PROJECT_ENDPOINT"],
                        credential=DefaultAzureCredential())
search_conn = next(c for c in client.connections.list() if c.type == "CognitiveSearch").id

tools = []

# 1. Clause library (from Challenge 2) + contract register
tools += AzureAISearchTool(index_connection_id=search_conn,
                          index_name="idx-clm-corpus",
                          query_type=AzureAISearchQueryType.VECTOR_SEMANTIC_HYBRID).definitions
tools += AzureAISearchTool(index_connection_id=search_conn,
                          index_name="idx-contract-register",
                          query_type=AzureAISearchQueryType.SIMPLE).definitions

# 2. File Search built-in
tools += FileSearchTool().definitions

# 3. Code Interpreter for register analytics
tools += CodeInterpreterTool().definitions

# 4. Azure Function via OpenAPI (risk scoring + status)
with open("infra/openapi/risk.json") as f:
    tools += OpenApiTool(
        name="score_contract_risk",
        description="Score contract risk (0-100) from vendor, value, term, jurisdiction.",
        spec=f.read(),
        auth=OpenApiAnonymousAuthDetails(),
    ).definitions

# 5. MCP tool (bonus)
tools += McpTool(
    server_label="sap-ariba",
    server_url="https://mcp.example.com/ariba",
    allowed_tools=["supplier_lookup", "po_status"],
    require_approval="always",
).definitions

client.agents.update_agent(agent_id=os.environ["AGENT_ID"], tools=tools)
```

### 7.2 Python — handle a tool call end-to-end

```python
# scripts/challenge3_run.py
thread = client.agents.threads.create()
client.agents.messages.create(thread_id=thread.id, role="user", content=(
    "We have 12 contracts renewing in the next 90 days. Show me a chart "
    "of value-at-risk by vendor, then draft a renewal-notice email for "
    "the top 3."))

run = client.agents.runs.create_and_process(
    thread_id=thread.id, agent_id=os.environ["AGENT_ID"])

# Inspect tool calls that happened
steps = client.agents.runs.steps.list(thread_id=thread.id, run_id=run.id)
for s in steps:
    if s.type == "tool_calls":
        for tc in s.step_details.tool_calls:
            print(f"tool: {tc.type}: {getattr(tc, 'name', '')}")
```

### 7.3 C# — declare tools

```csharp
var searchConn = (await project.GetConnectionsClient()
    .GetConnectionsAsync().FirstOrDefaultAsync(c => c.Type == ConnectionType.AzureAISearch))!;

var tools = new List<ToolDefinition>
{
    new AzureAISearchToolDefinition(searchConn.Id, "idx-clm-corpus",
        AzureAISearchQueryType.VectorSemanticHybrid),
    new AzureAISearchToolDefinition(searchConn.Id, "idx-contract-register",
        AzureAISearchQueryType.Simple),
    new FileSearchToolDefinition(),
    new CodeInterpreterToolDefinition(),
    new OpenApiToolDefinition(
        name: "score_contract_risk",
        description: "Score contract risk 0-100.",
        spec: BinaryData.FromString(File.ReadAllText("infra/openapi/risk.json")),
        auth: new OpenApiAnonymousAuthDetails()),
    new McpToolDefinition(
        serverLabel: "sap-ariba",
        serverUrl:   "https://mcp.example.com/ariba",
        allowedTools:new[]{"supplier_lookup","po_status"},
        requireApproval: McpApprovalRequirement.Always),
};

await agents.UpdateAgentAsync(agentId, tools);
```

### 7.4 Sample Azure Function (risk scoring)

```python
# infra/functions/risk/__init__.py
import json, azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    body = req.get_json()
    value  = float(body.get("value", 0))
    term_m = int(body.get("term_months", 12))
    jur    = body.get("jurisdiction", "").upper()

    score = 0
    score += min(60, value / 10_000)                       # $ exposure
    score += 10 if term_m > 36 else 0                       # long-term
    score += 20 if jur in {"RU", "CN", "IR", "KP"} else 0   # sanctioned/high-risk
    score = min(100, int(score))

    return func.HttpResponse(
        json.dumps({"risk_score": score,
                    "band": "high" if score>=70 else "medium" if score>=40 else "low"}),
        mimetype="application/json")
```

## 8. Success Criteria

- [ ] Agent lists **at least 5 tools**: 2× Azure AI Search, File Search, 1+ Function, Code Interpreter (+ MCP bonus).
- [ ] Playground scenario triggers **≥ 2 different tool calls** in one run.
- [ ] Code Interpreter produces a **chart image** for the value-at-risk scenario.
- [ ] Logic App tool actually fires an approval email (or returns a mock decision).
- [ ] Prose analysis of contracts uses **grounded search**, not Code Interpreter.
- [ ] (Bonus) MCP tool is registered with `require_approval = always`.

## 9. Next Steps

You now have an agent that **reads** (Challenge 2) and **acts** (Challenge 3). But *"can do"* is not *"should do"*. In **Challenge 4** you will layer the **guardrails**: approved-template enforcement, PII protection, restricted clause modification, and prompt-injection defenses.

➡ Continue to **[Challenge 4 — Guardrails](../challenge4-guardrails/README.md)**.

## 10. Key Takeaway

> Tools are what make an agent an agent. Route them by *purpose*, not by *availability*.
