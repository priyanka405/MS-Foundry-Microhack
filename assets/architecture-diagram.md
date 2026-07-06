# Architecture — Contract Lifecycle Management Agent

This document describes the reference architecture for the **Contract Lifecycle Management (CLM) Agent** built on **Microsoft Foundry**. It shows how a contract question travels from a legal or procurement user to a grounded, tool-using, evaluated response.

## 🗺️ End-to-end architecture

```mermaid
flowchart TB
    subgraph Users[👤 Users]
        Legal[Legal reviewer]
        Proc[Procurement lead]
        Sales[Sales / AE]
    end

    Users --> Entry[💬 Copilot / Web App / Teams<br/>Entry points]
    Entry --> Agent

    subgraph Foundry[🧠 Microsoft Foundry Project]
        Agent[🤖 CLM Agent<br/>Model · Instructions · Orchestration]
        Agent --> KG[📚 Knowledge Grounding]
        Agent --> Tools[🔌 Tools & Actions]
        Agent --> Eval[📊 Evaluation & Monitoring]
    end

    subgraph Sources[📂 Contract Sources]
        Repo[(Contract Repository<br/>SharePoint · DMS · Blob)]
        Templates[(Templates<br/>MSA · NDA · SOW)]
        Policies[(Clause library<br/>+ policies)]
    end
    KG --> AISearch[🔍 Azure AI Search<br/>idx-clm-contracts]
    KG --> FileSearch[📄 File Search<br/>Session attachments]
    AISearch --> Repo
    AISearch --> Templates
    AISearch --> Policies

    subgraph Actions[⚙️ Business Actions]
        Approval[Logic App<br/>la-clm-approval]
        DocGen[Power Automate<br/>generate_document]
        Status[Azure Function<br/>contract_status]
        Risk[Azure Function<br/>risk_score]
        CRM[REST API<br/>CRM · Dataverse]
    end
    Tools --> Approval
    Tools --> DocGen
    Tools --> Status
    Tools --> Risk
    Tools --> CRM

    subgraph Ops[🛡️ Governance & Ops]
        Evaluators[Foundry Evaluators<br/>Groundedness · Relevance · Safety]
        Safety[Content Safety<br/>Prompt Shields]
        AppI[Application Insights<br/>OpenTelemetry]
    end
    Eval --> Evaluators
    Eval --> Safety
    Eval --> AppI

    subgraph Deploy[🚀 Deploy / Share]
        Web[Web App<br/>Easy Auth]
        TeamsApp[Teams App<br/>Bot Service]
        APIep[API Endpoint<br/>Managed Identity]
    end
    Agent --> Web
    Agent --> TeamsApp
    Agent --> APIep
```

## 🧩 Component notes

| Component | Purpose | Notes |
| --- | --- | --- |
| **Foundry Agent** | Orchestrator: routes a user turn to grounding + tools + eval. | `Model + Instructions + Tools`. Instructions define the contract-expert persona. |
| **Azure AI Search (`idx-clm-contracts`)** | Vector + hybrid retrieval over the contract repository. | `text-embedding-3-large`, chunk 1024 / overlap 100, `VECTOR_SEMANTIC_HYBRID`. |
| **File Search** | Session-scoped retrieval on user-attached contracts. | Great for one-off "review this contract" flows. |
| **Contract Repository** | SharePoint, DMS, Blob — the actual documents. | Indexed by the AI Search indexer; kept in sync. |
| **Logic App `la-clm-approval`** | HTTP-triggered approval routing to Legal / Procurement. | Office 365 approval email → response → returns decision to the agent. |
| **Power Automate `generate_document`** | Template-based document generation (NDA, SOW, amendment). | Fills templates using `{{party}}`, `{{effective_date}}`, `{{clauses}}`. |
| **Azure Function `contract_status`** | Reads / updates contract lifecycle state. | States: `Draft → In Review → Approved → Signed → Active → Expired`. |
| **Azure Function `risk_score`** | Deterministic 0–100 risk score based on missing / non-standard clauses. | Called by the agent when summarizing risks. |
| **CRM / Dataverse REST API** | Metadata about the counterparty and account. | Optional bonus tool for enrichment. |
| **Foundry Evaluators** | Groundedness, Relevance, Coherence, Task Adherence, Safety. | Gate: task adherence ≥ 4.25, groundedness ≥ 4.0, 0 injection defects. |
| **Content Safety / Prompt Shields** | Defense against jailbreaks and prompt injection in contract text. | Enabled globally at the project level. |
| **Application Insights** | Traces + evals via OpenTelemetry. | Dashboards for cost, latency, tool-call success, hallucination rate. |

## 🔁 Single-request flow

```mermaid
sequenceDiagram
    autonumber
    participant U as User (Legal)
    participant W as Web App
    participant A as Foundry Agent
    participant S as AI Search
    participant L as Logic App
    participant M as App Insights

    U->>W: "What are the termination clauses in Vendor Contract A?"
    W->>A: user_turn
    A->>S: hybrid_search(query, filters={contract_id: "vendor-a"})
    S-->>A: top-k chunks with citations
    A->>A: synthesize answer + require citations
    A-->>W: grounded response
    W-->>U: renders answer + citations
    U->>W: "Route this change for legal approval"
    W->>A: user_turn
    A->>L: POST /approval (subject, requester, doc_uri)
    L-->>A: {status: pending, approval_id}
    A-->>W: "Approval sent to Legal (id 42). I'll update you."
    A->>M: emit trace + eval score
```

## 🧱 Design principles

1. **Grounding first, generation second.** The agent must not answer contract questions without a citation from the repository.
2. **Tools describe capability, not implementation.** Tool names + descriptions are the routing surface — write them for the model.
3. **Human in the loop for irreversible actions.** Approvals, doc generation, and status changes are proposed by the agent and confirmed by a human.
4. **Evaluated before shipped.** No promotion to Web / Teams / API without passing the evaluator gate.
5. **Observable by default.** OpenTelemetry to App Insights on day one — you cannot fix what you cannot see.

## 🔧 When to change this architecture

- **Contract volume > 100k documents:** partition the AI Search index by counterparty or contract type; add a router step.
- **Multi-language contracts:** add a translation step before indexing; keep original text in a separate field.
- **Regulated deployments:** add Purview labels and Customer-Managed Keys on Blob + Search; use Private Endpoints.
- **Multi-agent scenarios:** split into a **Retriever Agent** + **Drafting Agent** + **Approval Agent** with explicit handoff instructions.

---

Back to the [landing page](../landing-page.md) or jump straight to [Challenge 1 — Build the Agent](../docs/challenge-1-build-agent.md).
