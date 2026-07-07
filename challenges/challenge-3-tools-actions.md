# Challenge 3 &middot; Tools &amp; Actions

> **Duration:** ~75 minutes &middot; **Path:** Low-Code + Pro-Code &middot; **Previous:** [Challenge 2](./challenge-2-knowledge-grounding.md) &middot; **Next:** [Challenge 4 &mdash; Guardrails](./challenge-4-guardrails.md)

---

## 1. Context

An agent that can only read is a chatbot. In this challenge you turn the CLM assistant into a real **enterprise agent** by giving it four tools that touch business systems: search, file search, deterministic functions, and analytics.

Every tool needs a clear reason to exist. The agent doesn't get to pick tools it doesn't need &mdash; the more tools, the more misrouting risk.

## 2. Business context

The real workday of a Legal or Procurement analyst is stitched together across search, contract analysis, and spreadsheet math. This challenge wires each of those into a single conversation.

## 3. Objective

Register four tools with the Contract Intake &amp; Drafting Agent, teach it when to use each, and prove it end-to-end with a scripted scenario.

| # | Tool | Purpose | Business value |
| --- | --- | --- | --- |
| 1 | **Azure AI Search** | Find contracts, search clauses, retrieve similar agreements | Cuts "where does it live?" from days to seconds |
| 2 | **File Search** | Search uploaded PDFs, Word docs, and files attached to threads | Users can drop a counterparty draft and get a compare-and-contrast |
| 3 | **Azure Functions** | Approved clause lookup, contract status, risk scoring | Deterministic business logic the LLM cannot bluff |
| 4 | **Code Interpreter** | Contract summaries, obligation analysis, risk reports, renewal reports | On-the-fly analytics without a BI project |

## 4. Learning outcome

After Challenge 3 you can:

- Design a small, orthogonal tool set the agent can route to reliably.
- Register Foundry tools of three shapes: **built-in** (Search, File Search, Code Interpreter) and **function** (Azure Functions).
- Write a TOOL ROUTING block that stops the agent from firing the wrong tool.
- Confirm irreversible actions with the user before firing them.

## 5. Prerequisites

- Challenge 2 complete (agent, index, File Search all working).
- Azure Functions Core Tools installed (`func --version`) &mdash; for the pro-code path.

## 6. Architecture diagram

```mermaid
flowchart TD
    A[Contract Intake and Drafting Agent] --> T{Tool router}
    T -->|"question about corpus"| S[Azure AI Search]
    T -->|"question about attached file"| FS[File Search]
    T -->|"needs deterministic logic"| FN[Azure Functions<br/>clause_lookup / contract_status / risk_score]
    T -->|"needs computation / chart"| CI[Code Interpreter]
    FN --> DB[(Contract register)]
    CI --> Out[Summary, obligations, renewal report]
```

## 7. Tool 1 &mdash; Azure AI Search

### Purpose
Find contracts, clauses, and policies in the enterprise corpus.

### Business value
Answers "what does clause X say in contract Y?" in seconds, with citations.

### Configuration
Already attached in Challenge 2. Confirm: agent &rarr; **Tools** &rarr; **AzureAISearchTool**, top-k `5`.

### Sample prompts
- *"Find every contract with Contoso from 2025."*
- *"What is our standard liability cap?"*

## 8. Tool 2 &mdash; File Search

### Purpose
Search inside PDFs, Word docs, and files attached to the thread.

### Business value
Reviewer drops a counterparty draft in chat and the agent can quote/compare without a re-index.

### Configuration
Attached in Challenge 2. Confirm: agent &rarr; **Tools** &rarr; **FileSearchTool**.

### Sample prompts
- Attach a PDF, then: *"What is the notice period in this contract?"*
- *"Compare the liability clause in the attached PDF to our approved liability clause."*

## 9. Tool 3 &mdash; Azure Functions

### Purpose
Deterministic business logic the LLM should not bluff: approved clause lookup, contract status, risk scoring.

### Business value
Uses a system of record instead of the model's opinion. Fully testable.

### Functions to deploy

| Function | Route | Input | Output |
| --- | --- | --- | --- |
| `clause_lookup` | `POST /api/clause_lookup` | `{ category: "payment"|"liability"|"termination" }` | `{ clause, version, source }` |
| `contract_status` | `POST /api/contract_status` | `{ contract_id, new_state? }` | `{ contract_id, state, updated_at }` |
| `risk_score` | `POST /api/risk_score` | `{ contract_json }` | `{ risk_band: "Low"|"Medium"|"High", reasons: [...] }` |

The Python reference lives in [app/tools.py](../app/tools.py). Deploy skeleton:

```powershell
func init clm-func --python
cd clm-func
func new --name clause_lookup --template "HTTP trigger" --authlevel "function"
# paste the body from app/tools.py `clause_lookup`
func azure functionapp publish func-clm-<your-alias>
```

Copy `FUNCTION_APP_ENDPOINT` (e.g. `https://func-clm-<your-alias>.azurewebsites.net`) into `.env`.

### Register with the agent

Portal &rarr; agent &rarr; **Tools** &rarr; **+ Add tool** &rarr; **Function** &rarr; paste the JSON schema for each function. Suggested names: `clause_lookup`, `contract_status`, `risk_score`.

### Sample prompts
- *"Look up our approved liability clause."* &rarr; `clause_lookup(category="liability")`.
- *"What state is contract CON-2024-0417?"* &rarr; `contract_status(contract_id="CON-2024-0417")`.
- *"Score the risk of this draft."* &rarr; `risk_score(contract_json=...)`.

## 10. Tool 4 &mdash; Code Interpreter

### Purpose
On-the-fly Python for summaries, obligation extraction, renewal reports, ad-hoc math.

### Business value
Skip the "let me open Excel" detour. The agent can chart auto-renewals over the next 90 days in-conversation.

### Configuration

Portal &rarr; agent &rarr; **Tools** &rarr; **+ Add tool** &rarr; **Code Interpreter**. That's it &mdash; Foundry runs it in a sandbox.

### Sample prompts
- *"Summarize this MSA in 5 bullet points, and list every obligation on us."*
- *"Give me a table of every contract expiring in the next 90 days."* (Feed it a CSV of contract IDs and end dates.)

## 11. TOOL ROUTING block (append to instructions)

Append this to your agent instructions after DRAFTING RULE:

```text
# TOOL ROUTING
- Retrieval about a template, clause, policy, or historical contract -> AzureAISearchTool.
- Question about a file attached in this thread -> FileSearchTool.
- User wants a specific approved clause quoted -> clause_lookup(category).
- User asks about a contract's lifecycle state, or wants to change it -> contract_status(contract_id, new_state?). Ask before changing state.
- User wants a numeric risk read -> risk_score(contract_json).
- User wants a summary, obligations table, or a chart -> Code Interpreter.
```

## 12. Pro-code path &mdash; SDK walkthrough

Reference: [app/tools.py](../app/tools.py) exposes each tool as a Python function.

```python
from azure.ai.projects.models import FunctionTool, CodeInterpreterTool
from app.contract_agent import client, get_agent
from app import tools

functions = FunctionTool(functions={
    tools.clause_lookup,
    tools.contract_status,
    tools.risk_score,
})
code = CodeInterpreterTool()

agent = get_agent()
client.agents.update_agent(
    agent_id=agent.id,
    tools=[*functions.definitions, *code.definitions],
    tool_resources=code.resources,
)
```

The dispatch loop that maps function-tool calls back into `tools.py` is built into `create_and_process_run` when you register `FunctionTool` &mdash; no extra glue required.

## 13. End-to-end scenario

Run this scenario in one thread. Every step should feel like a single conversation.

1. *"I need a mutual NDA with Contoso, effective 2026-08-01, 2-year term."* &rarr; intake protocol.
2. *"Use our standard liability clause."* &rarr; `clause_lookup(category="liability")`.
3. *"Fill the template and give me a summary."* &rarr; draft, then Code Interpreter.
4. *"Mark the NDA as In Review."* &rarr; `contract_status(new_state="In Review")` (asks for confirmation first).
5. *"Score the risk of this draft."* &rarr; `risk_score(contract_json=...)`.

## 14. Testing

Verify in App Insights that each turn produced a `gen_ai.tool.call` event with the expected tool name. Bad routing (fires `risk_score` for a summary request, for example) means TOOL ROUTING needs adjustment.

## 15. Validation

| Check | How to verify | Pass criteria |
| --- | --- | --- |
| All four tools registered | Portal &rarr; agent &rarr; Tools | Search, File Search, `clause_lookup`, `contract_status`, `risk_score`, Code Interpreter |
| Search tool | *"Find every contract with Contoso"* | Cites real corpus docs |
| Function tool | *"Look up our approved liability clause."* | `clause_lookup` invoked with `category="liability"` |
| Function tool | *"What state is contract CON-2024-0417?"* | `contract_status` invoked correctly |
| Code Interpreter | *"Summarize in 5 bullets."* | Runs Python; returns bullets |
| Confirmation | *"Mark the NDA as Signed."* | Agent asks to confirm before firing |
| SDK parity | `python -m app.sample_run --challenge 3` | Same behavior end-to-end |

## 16. Success criteria

The end-to-end scenario in [section 13](#13-end-to-end-scenario) completes in one thread, produces the right tool calls in the right order, and the trace in App Insights shows every step.

## 17. Completion checklist

- [ ] Function App with `clause_lookup`, `contract_status`, `risk_score` deployed; `FUNCTION_APP_ENDPOINT` in `.env`.
- [ ] Four tools registered on the agent (Search, File Search, functions x3, Code Interpreter).
- [ ] TOOL ROUTING block appended to instructions.
- [ ] End-to-end scenario runs in a single thread.
- [ ] App Insights shows each `gen_ai.tool.call` event.
- [ ] Agent asks to confirm before any irreversible action.

## 18. Next challenge

Continue to [Challenge 4 &mdash; Guardrails](./challenge-4-guardrails.md).
