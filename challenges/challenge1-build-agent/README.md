# Challenge 1 — Build the Contract Intake & Drafting Agent

## 1. Title & Duration

**Challenge 1 — Build the Contract Intake & Drafting Agent**
⏱ **40 minutes**

## 2. Objective

Create your first Foundry agent — the **Contract Intake & Drafting Agent** — that:

- Captures contract requirements from a business user (party, contract type, value, term, jurisdiction).
- Picks the right **approved template** (NDA, MSA, SOW).
- Generates a first draft.
- Asks for missing information instead of hallucinating it.

## 3. Context

An **agent** in Foundry is not just a prompt — it is **Model + Instructions + Tools** running on the Agent Service, with state, tracing, and identity. In this challenge you build the "Model + Instructions" part. Tools come in Challenge 3.

The teaching point:

> **Prompt + Model ≠ Production Agent.**
> A well-crafted prompt in a chat window has no memory of the templates you approved, no way to route approvals, no telemetry, and no evaluations. An agent does.

## 4. Prerequisites

- [Challenge 0 — Setup](../challenge0-setup/README.md) completed: Foundry project, `gpt-4o-mini` deployment, connected Search + App Insights.
- The `clm-corpus` dataset is uploaded (needed later — not this challenge).

## 5. Agents & Tools used

| Component | Used |
| --- | --- |
| Foundry Agent Service | ✅ |
| Model `gpt-4o-mini` | ✅ |
| Instructions (system prompt) | ✅ |
| Tools | ❌ (added in Challenge 3) |
| Grounding | ❌ (added in Challenge 2) |

---

## 6. 🟢 Low-Code Steps (Portal)

1. In [ai.azure.com](https://ai.azure.com) open the **clm-microhack** project.
2. In the left nav click **Build** → **Agents** → **+ New agent**.
3. Fill in:
   - **Agent name:** `contract-intake-drafting`
   - **Model deployment:** `gpt-4o-mini`
   - **Description:** `Captures contract requirements and drafts a first version from an approved template.`
4. Paste the following into **Instructions**:

   ```text
   You are the Contract Intake & Drafting Agent for a global enterprise.

   YOUR JOB
   - Capture the minimum viable set of requirements to draft a contract:
     party name, contract type (NDA / MSA / SOW), effective date, term,
     total value + currency, governing law, and business owner.
   - Confirm the contract type maps to an approved template. If unsure, ASK.
   - Produce a first draft that uses ONLY the approved template structure.
   - Flag any request that would deviate from standard clauses (liability
     cap, indemnity, termination for convenience, payment terms) — do NOT
     silently rewrite them.

   STYLE
   - Business-professional tone. Short paragraphs. No legalese theater.
   - When information is missing, ASK ONE question at a time.
   - When drafting, output the draft in fenced markdown with clear section
     headings (Parties, Term, Consideration, Confidentiality, etc.).

   HARD RULES
   - Never invent counterparties, prices, or dates. If missing, ASK.
   - Never modify liability, indemnity, termination, or payment clauses
     without explicitly telling the user "this deviates from the approved
     clause library" and quoting the approved version.
   - You do not have knowledge grounding or tools yet — say so if asked
     to look up an existing contract.
   ```

5. Click **Save**.
6. Click **Try in playground** (top-right).
7. Send the first prompt:

   ```text
   I need an NDA with Contoso Retail. Mutual, 2-year term, governed by
   Irish law. Owner is Priya Shah in Sales Ops.
   ```

8. The agent should draft a mutual NDA and **ask about effective date and any special exclusions** rather than inventing them.
9. Send a follow-up designed to trip it:

   ```text
   Cap liability at €1,000 and drop the indemnity clause.
   ```

   Confirm the agent **refuses to silently modify** those clauses and flags the deviation.
10. Screenshot the transcript — you will attach it as evidence in Challenge 6.

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

### 7.1 Python

Install once:

```bash
pip install azure-ai-projects azure-identity python-dotenv
```

```python
# scripts/challenge1_create_agent.py
import os
from dotenv import load_dotenv
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

load_dotenv()

INSTRUCTIONS = """You are the Contract Intake & Drafting Agent for a global enterprise.

YOUR JOB
- Capture: party name, contract type (NDA / MSA / SOW), effective date, term,
  total value + currency, governing law, and business owner.
- Confirm the contract type maps to an approved template. If unsure, ASK.
- Produce a first draft using ONLY the approved template structure.
- Flag any request that would deviate from standard clauses.

STYLE
- Business-professional. Short paragraphs. No legalese theater.
- Ask ONE question at a time when info is missing.
- Output drafts in fenced markdown with clear section headings.

HARD RULES
- Never invent counterparties, prices, or dates.
- Never silently modify liability / indemnity / termination / payment clauses.
- You do not have knowledge grounding or tools yet — say so if asked.
"""

client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

agent = client.agents.create_agent(
    model=os.environ["MODEL_DEPLOYMENT_NAME"],
    name="contract-intake-drafting",
    instructions=INSTRUCTIONS,
)
print(f"Created agent {agent.id}")

thread = client.agents.threads.create()
client.agents.messages.create(
    thread_id=thread.id,
    role="user",
    content=(
        "I need an NDA with Contoso Retail. Mutual, 2-year term, "
        "governed by Irish law. Owner is Priya Shah in Sales Ops."
    ),
)

run = client.agents.runs.create_and_process(thread_id=thread.id, agent_id=agent.id)
for msg in client.agents.messages.list(thread_id=thread.id):
    print(f"[{msg.role}] {msg.content[0].text.value}\n")
```

### 7.2 C#

```csharp
using Azure.AI.Projects;
using Azure.AI.Agents.Persistent;
using Azure.Identity;

var endpoint = new Uri(Environment.GetEnvironmentVariable("PROJECT_ENDPOINT")!);
var model    = Environment.GetEnvironmentVariable("MODEL_DEPLOYMENT_NAME")!;

var project = new AIProjectClient(endpoint, new DefaultAzureCredential());
var agents  = project.GetPersistentAgentsClient();

const string instructions = @"You are the Contract Intake & Drafting Agent...
(Use the same instructions as the Python sample above.)";

var agent = await agents.CreateAgentAsync(
    model: model,
    name: "contract-intake-drafting",
    instructions: instructions);

var thread = await agents.CreateThreadAsync();
await agents.CreateMessageAsync(
    threadId: thread.Value.Id,
    role: MessageRole.User,
    content: "I need an NDA with Contoso Retail. Mutual, 2-year term, governed by Irish law.");

var run = await agents.CreateRunAsync(thread.Value.Id, agent.Value.Id);
await agents.WaitForRunAsync(thread.Value.Id, run.Value.Id);

await foreach (var msg in agents.GetMessagesAsync(thread.Value.Id))
    Console.WriteLine($"[{msg.Role}] {msg.ContentItems[0]}");
```

### 7.3 VS Code (Foundry Toolkit)

- Open the **Azure AI Foundry** activity bar in VS Code.
- Sign in with the same tenant.
- Expand the `clm-microhack` project → **Agents** → your agent appears.
- Right-click → **Open in playground** to iterate without leaving VS Code.

## 8. Success Criteria

- [ ] Agent `contract-intake-drafting` appears in the project's **Agents** list.
- [ ] Playground conversation successfully drafts an NDA when given the sample prompt.
- [ ] Agent asks a clarifying question when required fields are missing.
- [ ] Agent **refuses** to silently modify liability / indemnity clauses.
- [ ] (Pro-code) Python or C# script prints agent + assistant messages.

## 9. Next Steps

The agent can draft — but it is drafting from its parametric memory, not from **your** templates and **your** clause library. In **Challenge 2** you will ground it in the `clm-corpus` you uploaded in Challenge 0 using **Foundry IQ (Azure AI Search)**, so answers become **cited** and auditable.

➡ Continue to **[Challenge 2 — Knowledge Grounding](../challenge2-grounding/README.md)**.

## 10. Key Takeaway

> Prompt + Model ≠ Production Agent. An agent is Model + Instructions + Tools + Knowledge + Guardrails + Telemetry.
