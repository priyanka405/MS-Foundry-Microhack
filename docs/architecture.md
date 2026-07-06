# Reference architecture

The **Contract Intake &amp; Drafting Agent** runs entirely inside a single **Microsoft Foundry** project. This document is the one-page reference for the shape of the solution.

## 🗺️ End-to-end diagram

```mermaid
flowchart TB
    subgraph Users[👤 Users]
        Legal[Legal reviewer]
        Proc[Procurement lead]
        Sales[Sales / AE]
    end

    Users --> Channel[💬 Copilot · Web App · Teams · API]
    Channel --> Agent

    subgraph Foundry[🧠 Microsoft Foundry Project]
        Agent[🤖 Contract Intake &amp; Drafting Agent<br/>Model · Instructions · Orchestration]
        Agent --> KG[📚 Knowledge Grounding]
        Agent --> Tools[🔌 Tools &amp; Actions]
        Agent --> Safety[🛡️ Content Safety · Prompt Shields]
        Agent --> Trace[📡 OpenTelemetry]
    end

    subgraph Ground[📂 Grounding sources]
        Templates[(Contract templates<br/>NDA · MSA · SOW)]
        Clauses[(Approved clauses)]
        Policies[(Legal · Procurement · Compliance policies)]
    end
    KG --> Search[🔍 Azure AI Search<br/>idx-clm-contracts]
    KG --> File[📄 File Search]
    Search --> Templates
    Search --> Clauses
    Search --> Policies

    subgraph Actions[⚙️ Business actions]
        Approval[Logic App<br/>la-clm-approval]
        DocGen[Power Automate<br/>generate_document]
        Status[Azure Function<br/>contract_status]
        ClauseFn[Azure Function<br/>clause_lookup]
    end
    Tools --> Approval
    Tools --> DocGen
    Tools --> Status
    Tools --> ClauseFn

    subgraph Ops[🛡️ Governance &amp; ops]
        Eval[Foundry Evaluators<br/>Groundedness · Task adherence · Safety]
        AppI[Application Insights]
    end
    Trace --> AppI
    Agent --> Eval

    subgraph Deploy[🚀 Deploy]
        Web[Web App · Easy Auth]
        TeamsApp[Teams App · Bot Service]
        APIep[API endpoint · Managed Identity]
    end
    Agent --> Web
    Agent --> TeamsApp
    Agent --> APIep
```

## 🧩 Components at a glance

| Component | Purpose | Foundry surface |
| --- | --- | --- |
| **Model** | Reasoning engine (default: `gpt-4o`). | Model deployment |
| **Instructions** | Contract-drafting persona + policy rules. | Agent → Instructions |
| **Azure AI Search — `idx-clm-contracts`** | Vector + hybrid retrieval over templates, clauses, policies. | Tools → AzureAISearchTool |
| **File Search** | Session-scoped retrieval on user-attached documents. | Tools → FileSearchTool |
| **`clause_lookup`** | Function tool — returns approved clauses by category. | Tools → Azure Function |
| **`generate_document`** | Power Automate flow — fills a template. | Tools → HTTP tool |
| **`route_approval`** | Logic App — approval email + response. | Tools → HTTP tool |
| **`contract_status`** | Azure Function — reads/updates lifecycle state. | Tools → Azure Function |
| **Content Safety + Prompt Shields** | Blocks unsafe content and prompt-injection. | Project setting |
| **OpenTelemetry** | Emits traces to Application Insights. | `azure-monitor-opentelemetry` |
| **Foundry Evaluators** | Groundedness, Relevance, TaskAdherence, Safety scorers. | Evaluation tab |

## 🔁 A single request, end-to-end

```mermaid
sequenceDiagram
    autonumber
    participant U as Legal user
    participant W as Web App
    participant A as Foundry agent
    participant S as AI Search
    participant F as clause_lookup fn
    participant P as generate_document (Power Automate)
    participant L as Logic App
    participant M as App Insights

    U->>W: "Draft a mutual NDA with Contoso, effective 2026-08-01"
    W->>A: user_turn
    A->>S: retrieve(template="NDA", policies)
    S-->>A: template + policy passages
    A->>F: clause_lookup(category="confidentiality")
    F-->>A: approved clause text + version
    A->>P: generate_document(template="NDA", fields, clauses)
    P-->>A: doc_uri
    A-->>W: "Draft ready. Do you want me to route for approval?"
    W-->>U: draft + ask
    U->>W: "Yes, send to Legal."
    W->>A: user_turn
    A->>L: POST /approval (doc_uri, requester)
    L-->>A: {approval_id, status: pending}
    A-->>W: "Approval sent (id 108)."
    A->>M: trace + eval scores
```

## 🧱 Design principles

1. **Ground first.** No clause text without a citation from an approved source.
2. **Tools describe capability, not implementation.** Model routes on tool descriptions — treat them as prompts.
3. **Human in the loop for anything irreversible.** Approvals, generation, and status updates are proposed and confirmed.
4. **Evaluate before you ship.** Task adherence &amp; groundedness gates enforced in CI.
5. **Observable by default.** OpenTelemetry to App Insights from day one.
6. **Managed Identity everywhere.** No API keys in code.

## 🔧 When to change this architecture

| Signal | Change |
| --- | --- |
| &gt; 100k templates / policies / clauses | Partition the AI Search index; add a routing agent. |
| Multi-language contracts | Add a translation step at index-time; keep source in a separate field. |
| Regulated (finance / gov) | Add Private Endpoints + CMK on Search + Storage; enable Purview labels. |
| Multiple contract domains | Split into a **Retriever** + **Drafter** + **Approver** multi-agent workflow. |
| High-volume automated intake | Batch API + async runs with a queue; keep the same eval gate. |
