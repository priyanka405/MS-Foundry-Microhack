# Challenge 1 — Build the Agent

> **Goal:** Create the base **Contract Intake &amp; Drafting Agent** — model + instructions + persona — and have your first real intake conversation.

**Foundry surface:** Agent Service
**Estimated time:** 35–45 min
**Prerequisite:** Challenge 0.

---

## 🎯 Objective

Build a Foundry Agent that behaves like a **contract-drafting specialist**: precise, cautious, template-first, and never a lawyer. In this challenge the agent has **no external knowledge yet** — you're establishing the persona, the behavior rules, and the output shapes. Grounding, tools, guardrails, evaluation, and deployment come in Challenges 2–8.

## 📋 Tasks

1. Create an **Agent** named `contract-intake-drafting-agent`.
2. Paste the **contract-drafting instructions** below.
3. Run three test prompts (a persona check, a scope check, and a refusal check).
4. (SDK path) Repro the same three prompts from Python.

---

## 🖱️ Portal path

### 1. Create the agent

1. Foundry portal → **Agents** → **+ New agent**.
2. Name: `contract-intake-drafting-agent`.
3. Model deployment: pick your `gpt-4o` deployment from Challenge 0.
4. Save.

### 2. Paste the instructions

Open the **Instructions** tab and paste this verbatim.

```text
You are the Contract Intake & Drafting Agent, a specialist assistant for a
global enterprise's Legal and Procurement teams. You help intake, draft, and
route contract requests.

# MISSION
- Take an intake request in natural language.
- Pick the correct TEMPLATE (NDA / MSA / SOW / Amendment).
- Populate it using APPROVED CLAUSES from the approved clause library.
- Apply LEGAL, PROCUREMENT, and COMPLIANCE policies.
- Route the finished draft for approval when the user confirms.

# BEHAVIOR
- Be precise. Contracts are legal documents. Do not paraphrase away terms.
- Prefer "I don't have that on file" over guessing. Never invent counterparty
  names, dates, amounts, or clause text.
- Every clause quote MUST be verbatim, wrapped in quotes, with a citation of
  the form [source: <file>#<anchor>] once knowledge sources are attached.
- After every clause quote, add a one-paragraph plain-English explanation.
- You are NOT a lawyer. Never give legal advice. Retrieval and drafting only.
- Human in the loop for anything irreversible (approvals, doc-gen, sign).

# INTAKE PROTOCOL
When the user requests a new contract, always confirm the following BEFORE
drafting:
- Contract TYPE (NDA / MSA / SOW / Amendment).
- COUNTERPARTY (legal entity name).
- EFFECTIVE DATE and TERM.
- Any NON-STANDARD terms the user wants (e.g., liability cap variance).
If any of these is missing, ask ONE clarifying question at a time.

# OUTPUT SHAPES
- Intake summary → structured markdown block with the 4 fields above.
- Draft → the filled template with `[[FIELD]]` placeholders replaced.
- Clause quote → verbatim quote + plain-English summary + citation.
- Refusal → one paragraph explaining why, plus what the user could do instead.

# NEVER
- Never sign a contract on behalf of a user.
- Never approve a change without an explicit user confirmation.
- Never invent template text, clause text, or counterparty details.
- Never give legal advice.
```

### 3. Save and open the Playground

Click **Save** → **Try in Playground**.

### 4. Run the three test prompts

**Prompt 1 — persona check:**

> Introduce yourself. What are you good at, and what are you *not* good at?

**Expected:** Self-intro that mirrors the MISSION block. Includes a *"not a lawyer / no legal advice"* disclaimer. Mentions it needs sources to work with a specific contract.

**Prompt 2 — intake scope check:**

> I need an NDA with Contoso.

**Expected:** The agent kicks off the **intake protocol**, asking ONE clarifying question (probably *"Mutual or one-way, and when is the effective date?"*). It does **not** immediately produce a draft.

**Prompt 3 — refusal check:**

> Just draft me an NDA for Northwind Traders — copy the standard clauses.

**Expected:** The agent refuses to fabricate. Something like: *"I don't have a Northwind Traders record or your standard clause library on file yet. Once I have them, I can draft. For now, I need the effective date and whether it should be mutual or one-way."*

This third prompt is the whole point of the challenge — **the agent refuses to hallucinate**.

---

## 💻 SDK path

See [`app/contract_agent.py`](../../../app/contract_agent.py) — the same instructions expressed in code.

```python
# minimal excerpt — full file is in app/contract_agent.py
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient
from app.config import settings

client = AIProjectClient.from_connection_string(
    conn_str=settings.project_connection_string,
    credential=DefaultAzureCredential(),
)

INSTRUCTIONS = open("app/instructions/contract_intake_drafting.md").read()

agent = client.agents.create_agent(
    model=settings.model_deployment,
    name="contract-intake-drafting-agent",
    instructions=INSTRUCTIONS,
)

thread = client.agents.create_thread()
for prompt in [
    "Introduce yourself. What are you good at, and what are you *not* good at?",
    "I need an NDA with Contoso.",
    "Just draft me an NDA for Northwind Traders — copy the standard clauses.",
]:
    client.agents.create_message(thread_id=thread.id, role="user", content=prompt)
    client.agents.create_and_process_run(thread_id=thread.id, agent_id=agent.id)
    msg = client.agents.list_messages(thread.id).data[0]
    print("→", msg.content[0].text.value, "\n---")
```

Run:

```bash
python -m app.sample_run --challenge 1
```

---

## ✅ Success criteria

- [ ] Agent `contract-intake-drafting-agent` exists with the full instruction block.
- [ ] Prompt 1 returns a persona-consistent intro with a *"no legal advice"* disclaimer.
- [ ] Prompt 2 triggers the intake protocol with ONE clarifying question.
- [ ] Prompt 3 **refuses** to fabricate a draft.
- [ ] (SDK path) `python -m app.sample_run --challenge 1` prints all three responses without errors.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Agent produces a full draft on Prompt 2. | INTAKE PROTOCOL section was skipped / truncated. | Re-paste the full block; re-save; refresh Playground. |
| Agent invents Northwind Traders content on Prompt 3. | BEHAVIOR block missing or too soft. | Add stronger phrasing: *"NEVER invent counterparty names, dates, amounts, or clause text."* |
| Agent gives legal advice. | Model over-eager. | Add explicit refusal example under NEVER. |
| SDK returns 404 on agent create. | Wrong project connection string. | Copy again from the project Overview page. |
| Agent asks 5 questions at once. | Missing "one at a time" rule. | Tighten INTAKE PROTOCOL: *"Ask ONE clarifying question at a time."* |

## 🌉 Next challenge

Right now the agent has a persona but no data. In **[Challenge 2 — Knowledge Grounding](../challenge-2-knowledge-grounding/README.md)** you'll connect it to the contract templates, approved clauses, and policies so it can actually draft.
