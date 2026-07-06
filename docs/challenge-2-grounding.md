# Challenge 2 — Ground the Agent with Knowledge

⏱ **~45 minutes**  ·  🧠 Key Foundry feature: **Foundry IQ · Azure AI Search · File Search**

## 🎯 Objective

Turn your Executive Assistant from *"a smart writer"* into *"a smart writer that answers with **citations** from **your** documents"*.

You will:

- Upload a small corpus (sample docs, meeting notes, briefs, policies).
- Index it into **Azure AI Search** and attach it to the agent as a **knowledge source** (Foundry IQ).
- Enable **File Search** so users can also attach ad-hoc files at run time.
- Force the agent to **cite** every factual claim.
- Verify a cited answer on a realistic executive question.

## 🧭 Context

Foundry's **enterprise knowledge grounding** — branded **Foundry IQ** — is built on **Azure AI Search**. The Agent Service knows how to call the index, thread top-k chunks into the model's context, and return citations back to the calling app.

Why grounding is not "just RAG":

- **Freshness** — reindexing is a first-class Foundry concern.
- **ACL trimming** — search results can respect user identity.
- **Citations** — the agent returns file names + snippets you can render in the UI.
- **Evaluability** — grounding lets you measure **groundedness** in Challenge 4.

## ✅ Prerequisites

- [Challenge 1](challenge-1-build-agent.md) complete — `executive-assistant` agent exists.
- 5–20 sample documents you're willing to upload. Anything works: prior meeting notes (markdown or PDF), a couple of company policies, a strategy brief, a product one-pager. If you have nothing on hand, use fictional content.

## 🏗️ Steps

### 1. Prepare a small corpus

Create a folder `sample-corpus/` on your machine with:

- `meeting-notes-q3-review.md`
- `product-strategy-brief.md`
- `travel-and-expenses-policy.md`
- `board-update-summary.md`
- `email-thread-project-atlas.md`

Any 5–10 docs will do — the point is to make the citations visible.

### 2. Add an Azure AI Search connection to the project

1. In the project → **Management center → Connected resources → + New connection → Azure AI Search**.
2. Choose **Create new** → name `srch-execassistant` → **Basic** tier → **Create**.
3. When it appears, click **Add connection**.
4. In the same **Management center** view, deploy a **text-embedding-3-large** model (30k TPM, Standard). Grounding needs an embedding model.

### 3. Upload the corpus as a dataset

1. Left nav → **Data + indexes → + New data → Upload files or folders**.
2. Upload the contents of `sample-corpus/` as a dataset named **`ea-corpus`**.

### 4. Create the search index

1. Left nav → **Data + indexes → + Create index → Vector index**.
2. Configure:
   - **Index name:** `idx-ea-corpus`
   - **Data source:** the `ea-corpus` dataset
   - **Search resource:** `srch-execassistant`
   - **Embedding model:** `text-embedding-3-large`
   - **Chunk size:** `1024` / **overlap:** `100`
3. Click **Create** — wait until status is **Succeeded** (2–5 min).

### 5. Attach the index to the agent

1. **Build → Agents → executive-assistant → + Add knowledge → Azure AI Search**.
2. Pick `idx-ea-corpus`.
3. Toggle **Return citations** ON.
4. Append the following block to the agent's **Instructions** (do not overwrite the earlier block):

   ```text
   KNOWLEDGE (grounding)
   - You now have grounded search over: internal meeting notes, briefs,
     policies, and email threads.
   - ALWAYS cite the source file for every factual claim, in the form
     [filename § short section].
   - If the corpus does not contain an answer, say so. Do NOT guess.
   - Prefer grounded facts over parametric memory when they conflict.
   ```

### 6. Enable File Search (for run-time attachments)

1. Same agent → **Tools → + Add tool → File Search** → enable.
2. This lets the executive attach a fresh PDF/Word doc to a message (e.g. a third-party deck) and the agent can search it just for that conversation.

### 7. Test in the Playground

Try the following prompts:

**Prompt 1 — grounded prep**
```text
Prep me for my next meeting on Project Atlas. Use our internal notes
and past emails. Cite everything.
```

Expected: the agent answers using content from your uploaded docs (e.g. `email-thread-project-atlas.md`, `product-strategy-brief.md`) with citations in the form `[email-thread-project-atlas.md § …]`.

**Prompt 2 — out-of-corpus refusal**
```text
What's our approved policy for reimbursing crypto-currency travel expenses?
```

Expected: the agent says the corpus does not cover crypto — it does **not** invent a policy.

**Prompt 3 — File Search on an attachment**

Attach any PDF to the thread and ask:
```text
Summarize this deck and pull out the top 3 risks. Reference the slides.
```

Expected: the agent uses File Search to open the attached file and cites slide numbers or page numbers.

### 8. (Optional) Pro-code — attach the index via SDK

```python
# scripts/ground_agent.py
import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import (
    AzureAISearchTool, AzureAISearchQueryType, FileSearchTool
)

client = AIProjectClient(endpoint=os.environ["PROJECT_ENDPOINT"],
                        credential=DefaultAzureCredential())
conn = next(c for c in client.connections.list() if c.type == "CognitiveSearch")

tools = []
tools += AzureAISearchTool(
    index_connection_id=conn.id,
    index_name="idx-ea-corpus",
    query_type=AzureAISearchQueryType.VECTOR_SEMANTIC_HYBRID,
    top_k=5,
).definitions
tools += FileSearchTool().definitions

client.agents.update_agent(agent_id=os.environ["AGENT_ID"], tools=tools)
```

## 🧪 Success criteria

- [ ] Index `idx-ea-corpus` exists in `srch-execassistant` with status **Succeeded**.
- [ ] Agent shows the index under its **Knowledge** section.
- [ ] Grounded prompt returns an answer with **at least one citation**.
- [ ] Out-of-corpus prompt returns an *"I don't know"*-style response instead of a hallucination.
- [ ] File Search works when a fresh document is attached to a thread.

## 🔎 Troubleshooting

| Symptom | Fix |
| --- | --- |
| Agent answers without citations | The KNOWLEDGE block wasn't appended to Instructions. Re-paste it. |
| Index creation fails: *"no default embedding"* | Deploy `text-embedding-3-large` first. |
| Search returns nothing | Wait for indexing to finish; check the dataset actually points at your files. |

## ➡️ Next steps

The agent can now **read**. In **[Challenge 3 — Add Tools and Actions](challenge-3-tools-actions.md)** you'll let it **act** — call APIs, kick off Logic Apps and Power Automate flows, and generate real artifacts. That's the leap from *chatbot* to *agent*.

## 💡 Key takeaway

> A grounded, cited answer is auditable. A parametric answer is a rumor.
