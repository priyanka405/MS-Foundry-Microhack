# Challenge 2 — Knowledge Grounding

## 1. Title & Duration

**Challenge 2 — Ground the Agent in Templates, Clauses, and Policies**
⏱ **45 minutes**

## 2. Objective

Turn your agent from *"a smart drafter"* into *"a smart drafter that answers with **citations** from **your** approved corpus"*. You will:

- Index the `clm-corpus` (templates + clause library + policies) into **Azure AI Search**.
- Attach that index to the agent as a **knowledge source** (Foundry IQ).
- Force the agent to cite sources.
- Verify a **cited answer** on a real question: *"Does this NDA deviate from our approved indemnity clause?"*

## 3. Context

Foundry's **enterprise knowledge grounding** — branded **Foundry IQ** — is built on **Azure AI Search**. The Agent Service knows how to call the index, thread top-k chunks into the model's context, and return citations back to the calling app.

Why grounding is not "just RAG":

- **Freshness** — reindexing is a first-class Foundry concern (change data capture on the source).
- **ACL trimming** — search results respect user identity, not agent identity.
- **Citations** — the agent returns file names + snippets you can render in the UI.
- **Evaluability** — grounding lets you measure **groundedness** in Challenge 6.

## 4. Prerequisites

- [Challenge 0](../challenge0-setup/README.md) done, `srch-clm-microhack` connected.
- [Challenge 1](../challenge1-build-agent/README.md) done, `contract-intake-drafting` agent exists.
- `clm-corpus` dataset uploaded (templates, clauses, policies).

## 5. Agents & Tools used

| Component | Used |
| --- | --- |
| Foundry Agent Service | ✅ |
| Model `gpt-4o-mini` | ✅ |
| **Azure AI Search** (index + skillset) | ✅ new |
| **Foundry IQ knowledge source** | ✅ new |
| Embedding model `text-embedding-3-large` | ✅ new |

---

## 6. 🟢 Low-Code Steps (Portal)

1. In the project left nav click **Data + indexes** → open the `clm-corpus` dataset uploaded in Challenge 0.
2. Click **+ Create index** → **Vector** index.
   - **Index name:** `idx-clm-corpus`
   - **Data source:** the `clm-corpus` dataset
   - **Search resource:** `srch-clm-microhack`
   - **Embedding model:** deploy `text-embedding-3-large` if not already deployed (Standard, 30K TPM).
   - **Chunk size:** 1024 tokens / **Chunk overlap:** 100.
3. Click **Create** and wait for the index status to become **Succeeded** (2–5 min).
4. Back in **Build → Agents → contract-intake-drafting**, click **+ Add knowledge** → **Azure AI Search** → pick `idx-clm-corpus`.
5. Toggle **Return citations** ON.
6. Append the following block to the agent's **Instructions**:

   ```text
   KNOWLEDGE
   - You now have grounded search over: approved templates (NDA, MSA, SOW),
     the approved clause library (liability, indemnity, termination, payment),
     and legal / procurement / compliance policies.
   - ALWAYS cite the source file(s) you used for every factual claim about
     an approved clause or policy. Cite as [filename § section].
   - If the corpus does not contain an answer, say so. Do NOT guess.
   ```

7. **Save** and open the **Playground**.
8. Ask:

   ```text
   Does this NDA deviate from our approved indemnity clause?
   Attach: "Indemnitor shall indemnify Indemnitee for all direct and
   indirect damages arising from any breach, without limitation."
   ```

9. Expected: the agent quotes the **approved** indemnity clause from `clause-library/indemnity.md`, flags the deviation (the approved clause **caps** indemnity and **excludes** consequential damages), and cites the file.
10. Test a "not in corpus" prompt:

    ```text
    What's our approved clause for cryptocurrency payment terms?
    ```

    Expected: the agent says the corpus does not cover that.

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

### 7.1 Python — attach the Search index as a tool

```python
# scripts/challenge2_attach_knowledge.py
import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import AzureAISearchTool, AzureAISearchQueryType

client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

conn = next(c for c in client.connections.list() if c.type == "CognitiveSearch")

search_tool = AzureAISearchTool(
    index_connection_id=conn.id,
    index_name="idx-clm-corpus",
    query_type=AzureAISearchQueryType.VECTOR_SEMANTIC_HYBRID,
    top_k=5,
    filter="",
)

agent = client.agents.update_agent(
    agent_id=os.environ["AGENT_ID"],
    tools=search_tool.definitions,
    tool_resources=search_tool.resources,
)
print(f"Agent {agent.id} now grounded on idx-clm-corpus")
```

### 7.2 Python — run a grounded query and print citations

```python
# scripts/challenge2_query.py
thread = client.agents.threads.create()
client.agents.messages.create(
    thread_id=thread.id, role="user",
    content=("Does this NDA deviate from our approved indemnity clause?\n"
             "Attach: 'Indemnitor shall indemnify Indemnitee for all direct "
             "and indirect damages arising from any breach, without limitation.'"),
)
run = client.agents.runs.create_and_process(thread_id=thread.id, agent_id=os.environ["AGENT_ID"])

for msg in client.agents.messages.list(thread_id=thread.id, order="asc"):
    for part in msg.content:
        if part.type == "text":
            print(f"[{msg.role}] {part.text.value}")
            for ann in part.text.annotations or []:
                if ann.type == "file_citation":
                    print(f"   ↳ cite: {ann.text}")
```

### 7.3 C#

```csharp
using Azure.AI.Agents.Persistent;

var searchConn = (await project.GetConnectionsClient()
    .GetConnectionsAsync()
    .FirstOrDefaultAsync(c => c.Type == ConnectionType.AzureAISearch))!;

var searchTool = new AzureAISearchToolDefinition(
    indexConnectionId: searchConn.Id,
    indexName: "idx-clm-corpus",
    queryType: AzureAISearchQueryType.VectorSemanticHybrid,
    topK: 5);

await agents.UpdateAgentAsync(
    agentId: agentId,
    tools: new[] { (ToolDefinition)searchTool });
```

### 7.4 Force citations in the instructions

Whether portal or SDK, append the **KNOWLEDGE** block from step 6.6 above so the agent must cite.

## 8. Success Criteria

- [ ] Index `idx-clm-corpus` exists in `srch-clm-microhack` with **Succeeded** status.
- [ ] Agent shows the index under its **Knowledge** section.
- [ ] Playground answer to the indemnity question **cites** `clause-library/indemnity.md`.
- [ ] Out-of-corpus question returns an "I don't know" response, not a hallucination.
- [ ] (Pro-code) Query script prints at least one `file_citation` annotation.

## 9. Next Steps

The agent can now **read**. In **Challenge 3** you will let it **act**: search a contract repository, look up existing clauses programmatically, trigger approval workflows, generate documents, and check contract status — the leap from *chatbot* to *agent*.

➡ Continue to **[Challenge 3 — Tools & Actions](../challenge3-tools-actions/README.md)**.

## 10. Key Takeaway

> A grounded, cited answer is auditable. A parametric answer is a rumor.
