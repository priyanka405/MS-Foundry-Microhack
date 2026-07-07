# Contract Lifecycle Management with Microsoft Foundry

> A production-style **Microsoft Foundry MicroHack** that walks you through building an enterprise-grade **Contract Lifecycle Management (CLM) Assistant** — from an empty Foundry project to a shipped, evaluated, and observable AI solution.

[![Foundry](https://img.shields.io/badge/Microsoft-Foundry-0078D4?logo=microsoft&logoColor=white)](https://ai.azure.com)
[![Language](https://img.shields.io/badge/Language-Python%203.11+-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![Docs](https://img.shields.io/badge/Landing%20Page-Live-0078D4?logo=github&logoColor=white)](https://priyanka405.github.io/MS-Foundry-Microhack/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

---

## Landing page

> **Open the interactive landing page → <https://priyanka405.github.io/MS-Foundry-Microhack/>**

[![Open the Contract Lifecycle Management MicroHack landing page](./assets/images/architecture-overview.svg)](https://priyanka405.github.io/MS-Foundry-Microhack/)

<p align="center">
  <a href="https://priyanka405.github.io/MS-Foundry-Microhack/">
    <img alt="Open the landing page" src="https://img.shields.io/badge/%E2%86%92%20Open%20the%20landing%20page-0078D4?style=for-the-badge&logo=github&logoColor=white">
  </a>
  &nbsp;
  <a href="./index.html">
    <img alt="View HTML source in the repo" src="https://img.shields.io/badge/View%20HTML%20source-5C2D91?style=for-the-badge&logo=html5&logoColor=white">
  </a>
</p>

Click the image or the button above to launch the full-page site (dark mode, Mermaid diagrams, individual challenge pages, and a QR code that opens the microhack on your phone).

---

## Hero

Build the **Contract Intake & Drafting Agent** — the AI copilot Legal and Procurement wish they already had. Nine hands-on challenges take you from *"I have an Azure subscription"* all the way to *"it's live and measurable."*

Every challenge is fully documented for both the **Foundry portal (low-code)** and the **Foundry SDK in Python (pro-code)**, so architects, engineers, and product folks can all follow along.

## Table of contents

- [Landing page](#landing-page)
- [Hackathon overview](#hackathon-overview)
- [Business scenario](#business-scenario)
- [Learning objectives](#learning-objectives)
- [Business value](#business-value)
- [Solution architecture](#solution-architecture)
- [Challenge roadmap](#challenge-roadmap)
- [Prerequisites](#prerequisites)
- [Estimated duration](#estimated-duration)
- [Skills you will learn](#skills-you-will-learn)
- [Success outcomes](#success-outcomes)
- [Repository structure](#repository-structure)
- [Getting started](#getting-started)
- [Resources](#resources)

## Hackathon overview

Organizations process hundreds of contracts every month. Legal and Procurement need help with:

- Contract creation and drafting
- Contract review and clause analysis
- Compliance verification
- Approval routing
- Contract tracking, renewals, and expirations
- Risk identification

You will build a single **Contract Lifecycle Management Assistant** on Microsoft Foundry that owns all of the above — grounded on your organization's own templates, clause library, and policies, protected by safety guardrails, and proven by evaluation gates.

## Business scenario

**Contoso Global** is a multinational with 40,000 employees, 12,000 active contracts, and 400+ new agreements per month. Their current CLM process is scattered across SharePoint, email, and three legacy DMS systems. Here's where the pain lives:

- Legal spends **~35%** of its time answering "what does clause X in contract Y say?".
- Procurement misses **~11%** of auto-renewals every year, costing millions.
- Average new-contract turnaround is **17 business days**.
- No consistent way to compare an incoming counterparty draft against the enterprise standard.

Your job: ship a **Contract Lifecycle Management Assistant** that turns this into a same-day, self-service, auditable workflow — while never crossing the line into legal advice or unilateral approval.

## Learning objectives

By the end of this hackathon you will be able to:

1. Stand up an Azure AI Foundry project with a deployed model, indexed corpus, and enabled tracing.
2. Build a grounded agent with a strong persona and refusal behavior.
3. Ground the agent on enterprise content using Azure AI Search and File Search — with citations.
4. Extend the agent with 4 tools: Azure AI Search, File Search, Azure Functions, and Code Interpreter.
5. Protect the agent with Prompt Shields, PII detection, and app-layer blocklists.
6. Trace every prompt, retrieval, tool call, and response into Application Insights.
7. Evaluate on a fixed dataset and enforce a deployment gate.
8. Optimize model, prompt, retrieval, and cost with a repeatable evaluation loop.
9. Publish the assistant as a Web App, a Teams app, or an API endpoint.

## Business value

| KPI | Baseline (typical) | With this solution (target) |
| --- | --- | --- |
| Time to first draft (NDA / MSA / SOW) | 3–5 days | Under 10 minutes |
| Legal time on "what does clause X say?" | ~35% | Under 10% |
| Missed auto-renewals per year | ~11% | Under 2% |
| Contract turnaround (draft → signature) | 17 business days | Under 5 business days |
| Audit trail for AI-assisted actions | Ad hoc | 100% traced in App Insights |

## Solution architecture

```mermaid
flowchart LR
    subgraph Users
        L[Legal]
        P[Procurement]
        S[Sales]
    end

    subgraph Channel[Channel]
        UI[Web / Teams UI]
    end

    subgraph Foundry[Microsoft Foundry]
        A[Contract Intake and Drafting Agent]
        KG[Knowledge Grounding]
        T[Function Tools]
        GR[Guardrails and Safety]
        EV[Evaluators]
        OB[Tracing]
    end

    subgraph Ground[Grounding]
        AIS[Azure AI Search - idx-clm-contracts]
        BLOB[Blob - clm-corpus]
    end

    subgraph Actions[Business Actions]
        FN[Azure Functions - Clause / Status / Risk]
        CI[Code Interpreter - Summaries and Reports]
    end

    subgraph Ops[Ops]
        AI[Application Insights]
        GH[GitHub Actions - CI Gate]
    end

    L & P & S --> UI --> A
    A --> KG --> AIS & BLOB
    A --> T --> FN & CI
    A --> GR
    A --> OB --> AI
    EV --> GH
```

Every challenge builds one slice of this picture. By the end, the whole diagram is real.

## Challenge roadmap

| # | Challenge | Focus | Path |
| --- | --- | --- | --- |
| 0 | [Setup](./challenges/challenge-0-setup.md) | Foundry project, model, Search, tracing, corpus | Low-code + Pro-code |
| 1 | [Build Agent — Contract Intake & Drafting](./challenges/challenge-1-build-agent.md) | Persona, instructions, refusal behavior | Low-code + Pro-code |
| 2 | [Knowledge Grounding](./challenges/challenge-2-knowledge-grounding.md) | Azure AI Search + File Search with citations | Low-code + Pro-code |
| 3 | [Tools & Actions](./challenges/challenge-3-tools-actions.md) | Search, File Search, Azure Functions, Code Interpreter | Low-code + Pro-code |
| 4 | [Guardrails](./challenges/challenge-4-guardrails.md) | Prompt Shields, PII, template enforcement | Low-code + Pro-code |
| 5 | [Observability](./challenges/challenge-5-observability.md) | Tracing, monitoring, tool telemetry | Low-code + Pro-code |
| 6 | [Evaluation](./challenges/challenge-6-evaluation.md) | Groundedness, safety, tool accuracy | Low-code + Pro-code |
| 7 | [Optimization](./challenges/challenge-7-optimization.md) | Model, prompt, retrieval, cost, latency | Low-code + Pro-code |
| 8 | [Publish](./challenges/challenge-8-publish.md) | Web App, Teams, API endpoint | Low-code + Pro-code |

Every challenge follows the same anatomy: **Context → Objective → Learning Outcome → Prerequisites → Architecture Diagram → Low-Code Path → Pro-Code Path → Portal Walkthrough & Deployment**.

## Prerequisites

Before you start Challenge 0, make sure you have:

- An **Azure subscription** with permission to create resource groups and role assignments (Owner, or Contributor + User Access Administrator).
- Access to **Microsoft Foundry** at [`ai.azure.com`](https://ai.azure.com).
- Quota to deploy **gpt-4o** or **gpt-4o-mini** in your target region (≥ 30k TPM recommended).
- **Python 3.11+**, **Git**, and **VS Code** with the Python + Azure extensions.
- **Azure CLI** (`az login` works).
- (For pro-code path) `pip install -r requirements.txt`.

## Estimated duration

| Segment | Time |
| --- | --- |
| Challenge 0 — Setup | ~45 min |
| Challenge 1 — Build Agent | ~45 min |
| Challenge 2 — Knowledge Grounding | ~60 min |
| Challenge 3 — Tools & Actions | ~75 min |
| Challenge 4 — Guardrails | ~45 min |
| Challenge 5 — Observability | ~45 min |
| Challenge 6 — Evaluation | ~45 min |
| Challenge 7 — Optimization | ~45 min |
| Challenge 8 — Publish | ~60 min |
| **Total** | **~8 hours** |

An "Explorer" (low-code only) team can finish Challenges 0–5 in about 4 hours.

## Skills you will learn

- **Foundry project management** — creating projects, model deployments, connections, and role assignments.
- **Agent design** — instructions, personas, refusal behavior, tool routing.
- **Retrieval-Augmented Generation** — vector + semantic hybrid, chunking, top-k tuning, citations.
- **Function calling** — wiring Azure Functions and Code Interpreter as tools.
- **Guardrails** — Prompt Shields, Content Safety, PII detection, app-layer blocklists.
- **Observability** — OpenTelemetry, Application Insights, KQL, cost tracking.
- **Evaluation** — groundedness, task adherence, safety, tool call accuracy, gate design.
- **Optimization** — model + prompt + retrieval + cost sweeps with reproducible runs.
- **Deployment** — Web App with Easy Auth, Teams manifest, API endpoint with Managed Identity.

## Success outcomes

You have "shipped" this MicroHack when:

- Your CLM agent answers the 15-question evaluation set with citations and hits the deployment gate.
- The full end-to-end scenario (intake → draft → retrieve clause → route approval → update status) works from a single Foundry thread.
- Every prompt, retrieval, tool call, and response is visible in Application Insights.
- A Web App, Teams app, or authenticated API endpoint serves the assistant to a pilot user.
- GitHub Actions blocks a deploy if any gate metric regresses.

## Repository structure

```
MS-Foundry-Microhack/
├── README.md                         <- this file
├── index.html                        <- GitHub Pages landing (mirrors README, dark mode + Mermaid)
├── assets/
│   ├── css/style.css                 <- Fluent-inspired styling with light/dark theme
│   ├── js/main.js                    <- Nav, theme toggle, Mermaid init, copy buttons
│   └── README.md                     <- Where to drop screenshots and architecture PNGs
├── challenges/
│   ├── challenge-0-setup.md
│   ├── challenge-1-build-agent.md
│   ├── challenge-2-knowledge-grounding.md
│   ├── challenge-3-tools-actions.md
│   ├── challenge-4-guardrails.md
│   ├── challenge-5-observability.md
│   ├── challenge-6-evaluation.md
│   ├── challenge-7-optimization.md
│   └── challenge-8-publish.md
├── app/                              <- Pro-code (Python) reference implementation
│   ├── config.py
│   ├── contract_agent.py
│   ├── grounding.py
│   ├── tools.py
│   ├── monitoring.py
│   ├── evaluation.py
│   └── sample_run.py
├── data/                             <- Sample corpus for Challenges 2 and 6
│   ├── contract_templates/
│   ├── approved_clauses/
│   ├── policies/
│   └── test_cases/evaluation_dataset.jsonl
├── docs/                             <- Facilitator + student guides (optional)
├── requirements.txt
├── .env.example
└── .gitignore
```

## Getting started

```powershell
# 1. Clone
git clone https://github.com/priyanka405/MS-Foundry-Microhack.git
cd MS-Foundry-Microhack

# 2. Python env
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# 3. Configure
Copy-Item .env.example .env
# then fill AZURE_AI_PROJECT_CONNECTION_STRING, AZURE_OPENAI_DEPLOYMENT, ...

# 4. Smoke test
python -m app.sample_run --smoke

# 5. Open the landing page locally
Start-Process index.html
```

Then jump into [Challenge 0 — Setup](./challenges/challenge-0-setup.md).

## Resources

- **Microsoft Foundry**: <https://ai.azure.com>
- **Foundry docs**: <https://learn.microsoft.com/azure/ai-foundry/>
- **Azure AI Agents SDK (Python)**: <https://learn.microsoft.com/python/api/overview/azure/ai-agents-readme>
- **Azure AI Search**: <https://learn.microsoft.com/azure/search/>
- **Azure AI Evaluation SDK**: <https://learn.microsoft.com/azure/ai-foundry/how-to/develop/evaluate-sdk>
- **Content Safety + Prompt Shields**: <https://learn.microsoft.com/azure/ai-services/content-safety/>
- **Reference hackathon (style inspiration)**: <https://martaldsantos.github.io/foundry-hackathon/>

---

Made with care for the Microsoft Foundry community. This repository is provided under the MIT license.
