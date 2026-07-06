# Challenge 1 — Build the Agent

> **Goal:** Create the base **Contract Lifecycle Management (CLM) Agent** in Microsoft Foundry — model + instructions + a contract-expert persona — and have your first real contract conversation.

**Foundry feature:** Agent Service (Model + Instructions)
**Estimated time:** 30–40 min
**Prerequisite:** Foundry project on [ai.azure.com](https://ai.azure.com).

---

## 🎯 Objective

Build a Foundry Agent that behaves like a **senior contracts analyst**: precise, cautious, and grounded in facts. In this challenge the agent has **no external knowledge yet** — you're establishing the persona, the behavior rules, and the output shapes. Grounding, tools, evaluation, and deployment come in Challenges 2–5.

## 📋 Tasks

1. Create a **Foundry Project** (or use an existing one).
2. Create an **Agent** named `clm-agent`.
3. Configure **Instructions** using the block below.
4. Define the **Contract Expert persona**.
5. Implement **basic contract Q&A** in the Foundry playground.

## 🛠️ Step-by-step

### 1. Create the Foundry Project

1. Open [ai.azure.com](https://ai.azure.com).
2. **+ Create project** → name it `prj-clm-hackathon`.
3. Pick a hub in a region that supports Agents (e.g., East US 2 / Sweden Central).
4. Wait for provisioning — this creates the Foundry project, the connected Azure AI Search, Storage, and Key Vault.

### 2. Create the Agent

1. In the project, open **Agents** → **+ New agent**.
2. Name: `clm-agent`.
3. Model: `gpt-4o` (or `gpt-4.1` if available in your region).
4. Save. You now have a bare-bones agent.

### 3. Paste the Instructions

Open the **Instructions** tab on the agent and paste this block verbatim.

```text
You are the Contract Lifecycle Management (CLM) Agent, a senior contracts analyst
for a global enterprise. You help Legal, Procurement, and Sales teams work with
contracts across the full lifecycle.

# MISSION
Answer questions and take actions about contracts:
- Search contracts and retrieve clauses.
- Compare agreements side by side.
- Explain contract terms in plain business language.
- Draft contract summaries with obligations and key dates.
- Identify risks and missing / non-standard clauses.
- Route approvals when the user requests them.

# BEHAVIOR
- Be precise. Contracts are legal documents; do not paraphrase away important terms.
- Prefer *"I don't have that on file"* over guessing. Never fabricate contract text.
- Always quote clause text verbatim between quotes when the user asks for a clause.
- After every clause quote, add a one-paragraph plain-English explanation.
- For any risk you flag, name the specific clause and why it deviates from standard.
- You are NOT a lawyer. Never give legal advice — retrieval and summarization only.
- Human in the loop for irreversible actions (approvals, doc-generation, signature).

# GROUNDING (will be added in Challenge 2)
When knowledge sources are attached, every factual claim about a specific contract
MUST include an inline citation of the form [source: <file>#<anchor>].
If a fact is not supported by an attached source, say so plainly.

# OUTPUT SHAPES
- Clause retrieval → quoted clause + plain-English summary + citation.
- Contract brief → structured markdown (Key obligations · Risks · Key dates).
- Comparison → 3-column markdown table (Term | Contract A | Contract B).
- Risk summary → bulleted list with clause reference and severity (Low/Med/High).

# NEVER
- Never sign a contract on behalf of a user.
- Never approve a change without an explicit user confirmation.
- Never invent counterparty names, dates, amounts, or clause text.
- Never give legal advice.
```

### 4. Save and open the Playground

Click **Save**, then **Try in Playground**.

### 5. Run these three test prompts

Paste each prompt and observe the response quality.

**Prompt 1 — persona check:**

> Introduce yourself. What are you good at, and what are you *not* good at?

**Expected:** Concise self-intro that mirrors the MISSION block. Should include a *"not a lawyer / no legal advice"* disclaimer. Should mention it needs sources to answer specific contract questions.

**Prompt 2 — clause explanation (no source yet):**

> Explain what a "termination for convenience" clause is, in plain English.

**Expected:** A clean plain-English explanation. Because no contract source is attached yet, the agent should stay generic and **not** cite a specific contract.

**Prompt 3 — refusal check:**

> What are the payment terms in the Contoso MSA?

**Expected:** The agent refuses to fabricate. Something like: *"I don't have the Contoso MSA on file yet. Please upload it, or connect the contract repository. I don't want to guess at payment terms."*

This third prompt is the whole point of the challenge — **the agent refuses to hallucinate**.

## 🧪 Optional — do the same with the SDK

If you'd rather do this in code (Python):

```python
# pip install azure-ai-projects azure-identity
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

client = AIProjectClient.from_connection_string(
    conn_str="<your-project-connection-string>",
    credential=DefaultAzureCredential(),
)

INSTRUCTIONS = """<paste the instruction block above>"""

agent = client.agents.create_agent(
    model="gpt-4o",
    name="clm-agent",
    instructions=INSTRUCTIONS,
)

thread = client.agents.create_thread()
client.agents.create_message(
    thread_id=thread.id,
    role="user",
    content="What are the payment terms in the Contoso MSA?",
)
run = client.agents.create_and_process_run(thread_id=thread.id, agent_id=agent.id)
for m in client.agents.list_messages(thread.id).data:
    print(m.role, "→", m.content[0].text.value)
```

## ✅ Success criteria

- [ ] Foundry project created and the `clm-agent` agent exists.
- [ ] Instructions include MISSION · BEHAVIOR · GROUNDING · OUTPUT SHAPES · NEVER.
- [ ] Prompt 1 returns a persona-consistent self-introduction with a non-legal-advice disclaimer.
- [ ] Prompt 2 returns a clean plain-English explanation of a "termination for convenience" clause.
- [ ] Prompt 3 **refuses** to fabricate a contract term.
- [ ] Optional: the same three prompts work through the SDK.

## 🩹 Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Agent invents a contract term for Prompt 3. | BEHAVIOR block was truncated. | Re-paste the full instruction block; re-save; refresh playground. |
| Agent gives legal advice. | Model over-eager. | Add stricter "You are not a lawyer" phrasing at the top of BEHAVIOR. |
| Playground errors on Save. | Model deployment missing. | In the Foundry project → **Deployments**, add a `gpt-4o` deployment first. |
| "No agent found" via SDK. | Wrong project connection string. | Copy the connection string from the project's Overview page. |

## 🌉 Next challenge

Right now the agent is smart but blind — it has no contracts to work with. In **[Challenge 2 — Ground the Agent with Knowledge](challenge-2-grounding.md)** you'll connect it to the contract repository via Foundry IQ + Azure AI Search, so it can actually answer questions like *"What are the termination clauses in the Contoso MSA?"* with real citations.
