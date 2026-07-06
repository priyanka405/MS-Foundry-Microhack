# TOOLS Catalog

This catalog is the master reference for every tool wired into the CLM agent in **[Challenge 3](../challenges/challenge3-tools-actions/README.md)**. Use it as the checklist when you attach tools in the portal or declare them in code.

> **Rule of thumb.**
> *Prose over documents* (summaries, obligation extraction, clause comparison) → **grounded model + Search**.
> *Numbers over structured data* (renewal timelines, value-at-risk, spend/risk analytics) → **Code Interpreter**.

---

## 1. Azure AI Search

**Purpose.** The enterprise knowledge backbone for CLM.

**Used for**
- Storing indexed contracts, templates, clauses, and policies.
- Semantic + vector + hybrid search over the corpus.
- Finding *similar* signed agreements to a new draft (retrieval-augmented drafting).
- Enterprise knowledge grounding — powers **Foundry IQ**.

**Where in this hack**
- Challenge 0: provisioned as `srch-clm-microhack`.
- Challenge 2: `idx-clm-corpus` (templates + clauses + policies).
- Challenge 3: `idx-contract-register` (structured contract lookup).

**Configuration hints**
- Chunk size 1024 tokens / overlap 100 is a solid default for legal prose.
- Use `VECTOR_SEMANTIC_HYBRID` for clause questions, `SIMPLE` for exact metadata lookups.

---

## 2. File Search

**Purpose.** Ad-hoc search over user-uploaded Word / PDF files that are **not** yet in the corpus.

**Used for**
- Comparing a third-party contract against approved templates.
- Diffing a redline sent by counterparty against the version you sent.
- Quick retrieval of a specific document in a thread.

**Notes**
- File Search is a Foundry built-in tool — no extra infrastructure.
- Files uploaded through File Search are scoped to the thread by default; give them a longer lifetime by attaching them at the agent level.

---

## 3. Logic Apps

**Purpose.** Business-process actions that live outside the model.

**Used for**
- Approval routing (send to the right approver, wait for decision, return result).
- Email notifications on draft ready, approval needed, or renewal upcoming.
- Renewal reminders on a schedule (recurrence trigger).
- Any *"then do this in our system of record"* action.

**Where in this hack**
- Challenge 3: `la-clm-approvals` — HTTP-triggered approval flow.
- Challenge 8: optional renewal-reminder flow tied to `RenewalDate` in the register.

---

## 4. Azure Functions

**Purpose.** Custom business logic exposed as OpenAPI so the agent can call it.

**Used for**
- **Risk scoring** — computes 0–100 based on value, term, jurisdiction, counterparty.
- **Contract status API** — read/write `Status` on the register.
- **Approval decision logic** — codified rules for auto-approve thresholds.
- Any deterministic function you do not want the model to guess.

**Where in this hack**
- Challenge 3: `func-clm-risk` (`/api/risk`) and `func-clm-status` (`/api/status`).
- Both are declared to the agent via an **OpenAPI tool** definition.

---

## 5. Code Interpreter

**Purpose.** Sandboxed Python for numeric analytics + charting.

**Used for (structured data only)**
- Renewal timelines and Gantt-style plots.
- Contract **value-at-risk** by vendor / month / risk score band.
- Spend and risk distributions with charts (matplotlib / pandas).
- Portfolio metrics: concentration, tail exposure, mean risk, renewal cliff.

**Deliberately NOT used for**
- Prose contract summaries.
- Obligation extraction from contract text.
- Clause comparison against templates.

Those belong to the **grounded model** (Azure AI Search + `File Search`), because Code Interpreter has no grounding and cannot cite.

**Where in this hack**
- Challenge 3: analyze `assets/contract-register.md`.

---

## 6. MCP Tools *(bonus)*

**Purpose.** Attach external or internal systems via the **Model Context Protocol** as first-class tools with a governance surface.

**Used for**
- SAP Ariba / Coupa lookups (`supplier_lookup`, `po_status`).
- DocuSign / Adobe Sign envelopes.
- Internal CMDB / HR / CRM systems your organization already exposes over MCP.

**Configuration**
- `serverLabel` — a human-readable name shown in the portal.
- `serverUrl` — the MCP endpoint.
- `allowed_tools` — an allowlist; nothing outside this list will be called.
- `require_approval` — recommended value: `always` for the hackathon, `once_per_session` for production after review.

**Where in this hack**
- Challenge 3 (bonus step): register `sap-ariba` MCP server with the two tools above; both require user approval before each call.
