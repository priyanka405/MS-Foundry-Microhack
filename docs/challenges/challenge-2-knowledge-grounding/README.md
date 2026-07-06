# Challenge 2 — Knowledge Grounding

> **Goal:** Ground the agent on your **contract templates**, **approved clauses**, and **policies** so it can actually draft — with citations.

**Foundry surface:** Foundry IQ, Azure AI Search (`AzureAISearchTool`), File Search
**Estimated time:** 45–55 min
**Prerequisite:** Challenge 1.

---

## 🎯 Objective

Give the agent access to three grounding sources:

- **Contract templates** — `data/contract_templates/` (NDA, MSA, SOW).
- **Approved clauses** — `data/approved_clauses/` (payment, liability, termination).
- **Policies** — `data/policies/` (legal, procurement, compliance).

By the end, the agent can answer intake requests with real, cited draft output — and it refuses cleanly when a template or clause isn't in the corpus.

## 📋 Tasks

1. Provision (or reuse) the Azure AI Search resource.
2. Upload `data/` to Blob (or use SharePoint).
3. Create the **`idx-clm-contracts`** vector + hybrid index.
4. Attach the **AzureAISearchTool** and enable **File Search** on the agent.
5. Append the **KNOWLEDGE** block to the instructions.
6. Run three grounded prompts (draft + cross-corpus + refusal).

---

## 🖱️ Portal path

### 1. Upload the data

If you don't have your own Blob container, create one and upload the contents of `data/`:

```bash
az storage blob upload-batch \
  --account-name <your-storage> \
  --destination clm-corpus \
  --source ./data \
  --auth-mode login
```

### 2. Create the vector + hybrid index

1. Foundry portal → **Agents → your agent → Knowledge → + Add source → Azure AI Search**.
2. Pick the AI Search resource created in Challenge 0.
3. Point it at the `clm-corpus` Blob container.
4. Configure:

| Setting | Value |
| --- | --- |
| Index name | `idx-clm-contracts` |
| Embedding model | `text-embedding-3-large` |
| Chunk size | `1024` tokens |
| Chunk overlap | `100` tokens |
| Retrieval strategy | `VECTOR_SEMANTIC_HYBRID` |
| Semantic ranker | `enabled` |

5. Kick off the indexer. Wait for status *Success*.

### 3. Wire it into the agent

1. In the agent's **Tools** tab, add **Azure AI Search** and point it at `idx-clm-contracts`.
2. Set **top-k = 5** and **Require citations = on**.
3. Also enable **File Search** so users can drop a one-off document into a thread.

### 4. Append this KNOWLEDGE block to the instructions

```text
# KNOWLEDGE
You have TWO grounding sources:
1. `AzureAISearchTool` -> index `idx-clm-contracts` — the enterprise
   corpus of templates, approved clauses, and policies.
2. `FileSearch` — for documents attached by the user in this session.

# RETRIEVAL RULES
- Always ground factual claims about a template / clause / policy in a
  retrieved passage. Every clause quote MUST include an inline citation of
  the form [source: <file>#<anchor>].
- If the top-k results don't contain the answer, say so plainly:
  "I don't have that on file. Try uploading it or refining your search."
- Prefer the APPROVED CLAUSE from the library over writing new clause text.
  Only write new text if the user explicitly asks and no approved clause
  matches.
- Prefer FileSearch results over the repository when the user has attached
  a specific file to the thread.

# DRAFTING RULE
When drafting a contract:
- Start from a TEMPLATE (NDA / MSA / SOW).
- Fill placeholders (`[[COUNTERPARTY]]`, `[[EFFECTIVE_DATE]]`, `[[TERM]]`, ...).
- For each variable clause (payment / liability / termination), retrieve the
  APPROVED CLAUSE and insert it verbatim with a citation.
- If the user requests a NON-STANDARD term, flag it in a "⚠️ Non-standard"
  section at the top of the draft and cite the applicable policy.
```

### 5. Test in the Playground

**Prompt A — draft an NDA:**

> Draft a mutual NDA with Contoso, effective 2026-08-01, 2-year term.

**Expected:** The agent retrieves `nda_template.md`, fills the placeholders, pulls the approved confidentiality clause with a citation, and returns a clean draft.

**Prompt B — cross-corpus policy query:**

> What does our procurement policy say about payment terms shorter than net-30?

**Expected:** The agent retrieves `procurement_guidelines.md`, quotes the relevant paragraph with a citation, and summarizes in one line.

**Prompt C — out-of-corpus refusal:**

> Draft me a construction subcontract for Fabrikam.

**Expected:** *"I don't have a construction subcontract template on file — I only have NDA, MSA, and SOW. Would you like me to draft an MSA and note that it needs construction-specific clauses, or should we escalate to Legal to create the template first?"*

**Prompt D — File Search bonus:**

Attach a redlined draft NDA and ask:

> Compare this to our standard NDA template and flag deviations.

**Expected:** The agent uses File Search on the attachment and AI Search on the template, then produces a comparison table.

---

## 💻 SDK path

See [`app/grounding.py`](../../../app/grounding.py).

```python
from azure.ai.projects.models import AzureAISearchTool, FileSearchTool
from app.contract_agent import client, agent

search_tool = AzureAISearchTool(
    index_connection_id=settings.search_connection_id,
    index_name="idx-clm-contracts",
    top_k=5,
)
file_tool = FileSearchTool()

client.agents.update_agent(
    agent_id=agent.id,
    tools=[search_tool.definitions[0], file_tool.definitions[0]],
    tool_resources={**search_tool.resources, **file_tool.resources},
)
```

Then run:

```bash
python -m app.sample_run --challenge 2
```

---

## ✅ Success criteria

- [ ] `idx-clm-contracts` exists and the indexer status is *Success*.
- [ ] The AzureAISearchTool and File Search are attached to the agent.
- [ ] The KNOWLEDGE + DRAFTING RULE blocks are in the instructions.
- [ ] Prompt A produces a filled NDA draft with a citation on the confidentiality clause.
- [ ] Prompt B quotes the procurement policy with a citation.
- [ ] Prompt C **refuses** to fabricate a template that isn't in the corpus.
- [ ] Prompt D produces a comparison from an attached file.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No citations in output. | *Require citations* off / KNOWLEDGE block missing. | Re-enable in tool config; re-paste the block. |
| Draft uses generic clause text instead of approved. | DRAFTING RULE missing or too soft. | Add explicit *"prefer approved over new"* phrasing. |
| Empty results for known templates. | Indexer status not *Success*. | Wait for indexer to finish; verify `idx-clm-contracts` in tool config. |
| Agent hallucinates a "construction template" on Prompt C. | RETRIEVAL RULES block skipped. | Re-add and re-save. |
| File Search returns nothing for attachment. | File uploaded to a different thread. | Attach in the same thread before asking. |

## 🌉 Next challenge

The agent can now *read* templates, clauses, and policies. In **[Challenge 3 — Tools &amp; Actions](../challenge-3-tools-actions/README.md)** you'll teach it to *act* — clause lookup, doc generation, and approval routing.
