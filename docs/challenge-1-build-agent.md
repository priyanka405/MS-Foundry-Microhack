# Challenge 1 — Build the Agent

⏱ **~40 minutes**  ·  🧠 Key Foundry feature: **Foundry Agent Service (Model + Instructions)**

## 🎯 Objective

Create the **Executive Assistant Agent** — the core "brain" of the solution. By the end of this challenge you will have:

- A Foundry project with a deployed chat model.
- A working Agent with a well-crafted instruction set for an Executive Assistant scenario.
- A first meaningful turn in the Foundry Playground (or via the SDK).

## 🧭 Context

An **agent** in Microsoft Foundry is not just a prompt — it is **Model + Instructions + Tools** running on the Foundry Agent Service, with state, tracing, identity, and evaluators. In this challenge you build the *Model + Instructions* part. Grounding comes in Challenge 2, tools in Challenge 3.

> **Prompt + Model ≠ Production Agent.**
> A great prompt in a chat window has no memory of your enterprise knowledge, no way to trigger workflows, no telemetry, and no evaluations. An agent does.

## ✅ Prerequisites

- Microsoft Foundry access (project on [ai.azure.com](https://ai.azure.com)).
- Azure subscription **or** a Foundry sandbox.
- (Pro-code path) Python 3.10+ and `pip`, or .NET 8 SDK.

## 🏗️ Steps

### 1. Create the Foundry project (if you don't have one)

1. Go to **[ai.azure.com](https://ai.azure.com)** and sign in.
2. Click **+ Create a project**.
3. **Name:** `exec-assistant`. Region: any supported (recommended `eastus2`, `swedencentral`, `westus3`).
4. Accept defaults for hub/resource group and click **Create**.

### 2. Deploy a chat model

1. In the project left nav → **Models + endpoints** → **+ Deploy base model**.
2. Pick **`gpt-4o-mini`** (or `gpt-4o` if you have quota).
3. **Deployment name:** `gpt-4o-mini`. **Type:** Standard. **TPM:** 30k (default).
4. Click **Deploy** and wait for status **Succeeded**.

### 3. Create the Agent (portal)

1. Left nav → **Build → Agents → + New agent**.
2. Fill in:
   - **Agent name:** `executive-assistant`
   - **Model deployment:** `gpt-4o-mini`
   - **Description:** *"Executive Assistant agent that prepares for meetings, summarizes context, drafts follow-ups, and triggers workflows."*
3. Paste the following into **Instructions**:

   ```text
   You are the Executive Assistant Agent for a busy executive.

   MISSION
   - Help the executive prepare for meetings, understand context, and act on
     what was decided.
   - Produce output that a human EA would be proud to send.

   BEHAVIOR
   - Ask ONE clarifying question at a time when required inputs are missing
     (attendees, meeting purpose, decisions taken, preferred tone).
   - Prefer bullet points, short sentences, and clear headings for briefs.
   - When you generate action items, ALWAYS include: owner, action, due date.
   - When you draft emails, match the executive's tone (professional, warm,
     concise) unless the user asks otherwise.
   - Distinguish clearly between "facts I found" and "suggestions I inferred".

   GROUNDING & TOOLS
   - You do not yet have enterprise-knowledge grounding or tools — tell the
     user honestly if they ask you to look up a real document, calendar, or
     workflow. These come in later challenges.

   OUTPUT SHAPES
   - Meeting brief:
       ## Meeting brief — <Title>
       **Attendees**: ...
       **Purpose**: ...
       **Key context**: bullets
       **Open questions**: bullets
       **Suggested talking points**: bullets
   - Follow-up email:
       Subject: <clear subject>
       Body: 3–5 short paragraphs, ending with next-step ask.
   - Action items:
       | # | Owner | Action | Due |
       |---|-------|--------|-----|

   NEVER
   - Never invent attendees, dates, or numbers. If missing, ASK.
   - Never send anything — you draft; the executive approves.
   ```

4. Click **Save**.

### 4. Test the agent in the Playground

Open **Try in playground** and run these prompts in order:

**Prompt 1 — meeting prep**
```text
Prep me for a 30-min meeting with the CFO tomorrow to review the Q3 forecast.
Attendees: me, CFO, Head of FP&A. Tone: professional, direct.
```

Expected: the agent should ask 1 clarifying question (e.g. *"What's the primary decision you want out of this meeting?"*), then produce a **Meeting brief** structured exactly as the instructions specify.

**Prompt 2 — follow-up**
```text
The meeting is done. Decisions:
- Cut the marketing ask by 15%
- Approve €400k for the pricing tooling project
- Push the retail launch decision to Oct 15

Draft a follow-up email to the attendees and give me action items with owners.
```

Expected: a **follow-up email** + an **action-items table** with realistic owners and due dates that the model does *not* invent for people it wasn't told about.

### 5. (Optional) Pro-code — same agent via the SDK

```bash
pip install azure-ai-projects azure-identity python-dotenv
```

```python
# scripts/build_agent.py
import os
from dotenv import load_dotenv
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

load_dotenv()

INSTRUCTIONS = """You are the Executive Assistant Agent for a busy executive.
...  (paste the same block used in step 3.3) ..."""

client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

agent = client.agents.create_agent(
    model=os.environ["MODEL_DEPLOYMENT_NAME"],
    name="executive-assistant",
    instructions=INSTRUCTIONS,
)
print(f"Created agent {agent.id}")

thread = client.agents.threads.create()
client.agents.messages.create(
    thread_id=thread.id, role="user",
    content=("Prep me for a 30-min meeting with the CFO tomorrow to review "
             "the Q3 forecast. Attendees: me, CFO, Head of FP&A."),
)
run = client.agents.runs.create_and_process(thread_id=thread.id, agent_id=agent.id)

for msg in client.agents.messages.list(thread_id=thread.id):
    print(f"[{msg.role}] {msg.content[0].text.value}\n")
```

## 🧪 Success criteria

- [ ] Agent `executive-assistant` appears in the project's **Agents** list.
- [ ] Meeting-prep prompt returns a structured brief matching the instruction template.
- [ ] Follow-up prompt returns both an email draft **and** an action-items table.
- [ ] Agent asks a clarifying question when required inputs are missing.
- [ ] Agent does **not** invent attendees, decisions, or dates.

## 🔎 Troubleshooting

| Symptom | Fix |
| --- | --- |
| `DeploymentNotFound` | Model name in the agent doesn't match your deployment. Set it to `gpt-4o-mini`. |
| Agent uses long walls of text | The instructions block was truncated when pasted. Re-paste in full. |
| Agent invents attendees | Reinforce the *"NEVER invent"* rule; add a system-nudge like *"If missing, ASK."* |

## ➡️ Next steps

The agent talks well — but it does **not** know your documents, emails, or meeting notes. **[Challenge 2 — Ground the Agent](challenge-2-grounding.md)** wires Foundry IQ (Azure AI Search + File Search) so answers become **cited** and enterprise-aware.

## 💡 Key takeaway

> The instruction set is the agent's *character*. Invest here — everything downstream (grounding, tools, evaluation) is cheaper if the character is right.
