# Challenge 2 — Ground the Agent with Knowledge

> **Goal:** Enable the CLM Agent to answer real questions about your **contract repository** by grounding it with **Foundry IQ + Azure AI Search + File Search**.

**Foundry feature:** Foundry IQ, Azure AI Search (`AzureAISearchTool`), File Search
**Estimated time:** 45–55 min
**Prerequisite:** Challenge 1 complete.

---

## 🎯 Objective

Give the agent access to your enterprise contract repository so it can:

- Search across all contracts on file (hybrid vector + keyword).
- Retrieve exact clause text with citations.
- Answer *"What are the termination clauses in Vendor Contract A?"* and *"Which contracts mention GDPR?"*
- Refuse when a contract isn't in the repository, instead of guessing.

## 📋 Tasks

1. Prepare **sample contracts** (a few MSAs, NDAs, SOWs — real or synthetic).
2. Provision the **`srch-clm`** Azure AI Search service.
3. Create the **`idx-clm-contracts`** vector + hybrid index.
4. Configure the **AzureAISearchTool** on the agent.
5. Enable **File Search** for session-scoped attachments.
6. Append the **KNOWLEDGE** block to the agent instructions.
7. Run three grounded prompts (including an out-of-corpus refusal).

## 🛠️ Step-by-step

### 1. Sample contracts

Put 8–12 sample contracts into a folder. Any mix of `.pdf`, `.docx`, `.txt` works. If you don't have real ones, synthesize small samples — the important thing is that each document *looks like* a real contract with clauses.

Suggested distribution:
- 2× MSA (one with a standard liability cap, one with a non-standard 12-month cap).
- 2× NDA (one mutual, one one-way).
- 2× SOW (one referencing GDPR, one not).
- 2× Vendor agreements (one with a `termination for convenience` clause, one without).
- Optional: 2× policy documents (a *"Standard Clause Library"* and an *"Approval Policy"*).

### 2. Provision Azure AI Search

If your Foundry project auto-connected an AI Search resource, use it. Otherwise:

```bash
# Optional — quick provision via az CLI
az search service create \
  --name srch-clm \
  --resource-group rg-clm-hackathon \
  --sku standard \
  --location eastus2
```

### 3. Create the vector + hybrid index

In the Foundry portal:

1. **Agents → your agent → Knowledge → + Add source → Azure AI Search**.
2. Pick your AI Search resource.
3. Point it at the folder / Blob container where your contracts live.
4. Configure the index as follows:

| Setting | Value |
| --- | --- |
| Index name | `idx-clm-contracts` |
| Embedding model | `text-embedding-3-large` |
| Chunk size | `1024` tokens |
| Chunk overlap | `100` tokens |
| Retrieval strategy | `VECTOR_SEMANTIC_HYBRID` |
| Semantic ranker | `enabled` |

5. Kick off the indexer. Wait for indexing to complete (Overview → Indexers → status = *Success*).

### 4. Attach the AzureAISearchTool

In the agent's **Knowledge / Tools** tab:

1. Add the **AzureAISearchTool**.
2. Point it at `idx-clm-contracts`.
3. Choose top-k = `5`.
4. **Require citations** = on. (This forces the agent to include the source anchor.)

### 5. Enable File Search

1. In the same tab, enable **File Search**.
2. This lets users drop a contract PDF into the chat and ask questions about *just that document* — perfect for one-off reviews.

### 6. Append this block to the agent instructions

Paste this **KNOWLEDGE** block at the end of your Challenge 1 instructions.

```text
# KNOWLEDGE
You have two sources of contract knowledge:
1. `AzureAISearchTool` connected to index `idx-clm-contracts` — the enterprise
   contract repository.
2. `FileSearch` — for contracts the user attaches to the current session.

# RETRIEVAL RULES
- Always ground factual claims about a specific contract in a retrieved passage.
- Every clause quote MUST include a citation of the form
  [source: <file>#<page_or_anchor>].
- If the top-k results do not contain the answer, say so plainly:
  "I don't have that contract on file. Try uploading it or refining your search."
- Do NOT combine facts from different contracts unless the user asked for a
  comparison. Contracts are legal documents — do not mix them up.
- When the user attaches a file, prefer FileSearch results over the repository
  for that specific document.

# WHEN TO SEARCH
- Any question that references a specific counterparty, contract, or clause.
- Any question about dates, amounts, obligations, or terms.
- Any comparison or risk-summary request.
Do NOT search for generic legal-concept questions ("What is force majeure?");
answer those from your own general knowledge, no citation required.
```

### 7. Test in the Playground

**Prompt A — clause retrieval:**

> What are the termination clauses in the Contoso MSA?

**Expected:** The agent calls `AzureAISearchTool`, retrieves passages from `msa-contoso-*.pdf`, quotes the clause verbatim between quotes, and includes an inline citation. Follows with a plain-English summary.

**Prompt B — cross-corpus search:**

> Which contracts mention GDPR?

**Expected:** The agent searches the index for `"GDPR"`, returns a bulleted list of matching contracts (each with a citation), and briefly summarizes what each says.

**Prompt C — out-of-corpus refusal:**

> What are the payment terms in the Northwind Traders MSA?

**Expected:** If Northwind Traders isn't in your sample corpus, the agent replies: *"I don't have a Northwind Traders MSA on file. Try uploading it or double-check the counterparty name."* It should **not** invent a contract.

**Prompt D — File Search bonus:**

Attach a fresh contract PDF (not in the index) and ask:

> Summarize this attachment and flag anything unusual.

**Expected:** The agent calls FileSearch, produces a structured contract brief, and cites sections of the attachment.

## 🧪 Optional — SDK version

```python
from azure.ai.projects.models import AzureAISearchTool, FileSearchTool

search_tool = AzureAISearchTool(
    index_connection_id="<connection-id>",
    index_name="idx-clm-contracts",
    top_k=5,
)
file_tool = FileSearchTool()

agent = client.agents.update_agent(
    agent_id=agent.id,
    tools=[search_tool.definitions[0], file_tool.definitions[0]],
    tool_resources={**search_tool.resources, **file_tool.resources},
)
```

## ✅ Success criteria

- [ ] `idx-clm-contracts` exists and is *Successful* in the indexer view.
- [ ] The AzureAISearchTool is attached to the agent.
- [ ] File Search is enabled.
- [ ] The **KNOWLEDGE** block is in the agent instructions.
- [ ] Prompt A retrieves the termination clause with a real citation.
- [ ] Prompt B lists contracts mentioning GDPR with citations.
- [ ] Prompt C **refuses** to fabricate a contract that isn't in the corpus.
- [ ] Prompt D produces a grounded brief from an attached file.

## 🩹 Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No citations in the response. | "Require citations" not enabled, or KNOWLEDGE block missing. | Re-enable in the tool config; re-paste the block. |
| Empty search results for known contracts. | Indexer hasn't finished / wrong index name. | Check indexer status; verify `idx-clm-contracts` is bound in the tool config. |
| Agent hallucinates a contract in Prompt C. | RETRIEVAL RULES block was skipped. | Add stricter phrasing: *"If the top-k results are empty or off-topic, refuse."* |
| Bad relevance for cross-corpus queries. | Chunk size / overlap too small. | Re-index with 1024/100; ensure `VECTOR_SEMANTIC_HYBRID` is on. |
| File Search returns nothing for attachment. | File wasn't uploaded to the thread. | Attach via the paperclip icon *inside the same thread* before asking. |

## 🌉 Next challenge

The agent can now *read* contracts. In **[Challenge 3 — Tools and Actions](challenge-3-tools-actions.md)** you'll teach it to *act* on them — route approvals, generate documents, and update contract status.
