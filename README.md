# Contract Lifecycle Management with Microsoft Foundry

> A production-style **Microsoft Foundry MicroHack** that walks you through building an enterprise-grade **Contract Lifecycle Management (CLM) Assistant** — from an empty Foundry project to a shipped agent.

[![Foundry](https://img.shields.io/badge/Microsoft-Foundry-0078D4?logo=microsoft&logoColor=white)](https://ai.azure.com)
[![Language](https://img.shields.io/badge/Language-Python%203.11+-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![Docs](https://img.shields.io/badge/Landing%20Page-Live-0078D4?logo=github&logoColor=white)](https://priyanka405.github.io/MS-Foundry-Microhack/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

---

## Landing page

> **Open the interactive landing page → <https://priyanka405.github.io/MS-Foundry-Microhack/>**

[![Open the Contract Lifecycle Management MicroHack landing page](./assets/images/architecture-target.png)](https://priyanka405.github.io/MS-Foundry-Microhack/)

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

Build the **Contract Intake & Drafting Agent** — the AI copilot Legal and Procurement wish they already had. Nine hands-on challenges take you from *"I have an Azure subscription"* all the way to a shipped, evaluated, and production-ready assistant.

Every challenge is fully documented for both the **Foundry portal (low-code)** and the **Foundry SDK in Python (pro-code)**, so architects, engineers, and product folks can all follow along.

## Table of contents

- [Landing page](#landing-page)
- [Hackathon overview](#hackathon-overview)
- [Business scenario](#business-scenario)
- [Learning objectives](#learning-objectives)
- [Business value](#business-value)
- [Solution architecture](#solution-architecture)
  - [Functional architecture (business capabilities)](#functional-architecture-business-capabilities)
  - [Technical architecture (Azure services)](#technical-architecture-azure-services)
  - [Agent tools](#agent-tools)
  - [Architecture design decisions](#architecture-design-decisions)
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
- Contract search and clause review
- Compliance verification
- Market and regulatory research
- Contract tracking, renewals, and expirations
- Risk identification

You will build a single **Contract Lifecycle Management Assistant** on Microsoft Foundry that owns all of the above — grounded on your organization's own templates, clause library, and policies via **Foundry IQ** (Azure AI Search + SharePoint), enriched with external context via **WebIQ** (Bing Search), and tracked in **Azure SQL**, protected by Prompt Shields and Content Safety, evaluated on a fixed dataset, and deployed to a Web App, Teams, or a plain API endpoint.

## Business scenario

**Contoso Global** is a multinational with 40,000 employees, 12,000 active contracts, and 400+ new agreements per month. Their current CLM process is scattered across SharePoint, email, and three different contract repositories. Today:

- Legal spends **~35%** of its time answering "what does clause X in contract Y say?".
- Procurement misses **~11%** of auto-renewals every year, costing millions.
- Average new-contract turnaround is **17 business days**.
- No consistent way to compare an incoming counterparty draft against the enterprise standard.

Your job: ship a **Contract Lifecycle Management Assistant** that turns this into a same-day, self-service, auditable workflow — while never crossing the line into legal advice or unilateral approvals.

## Learning objectives

By the end of this hackathon you will be able to:

1. Stand up an Azure AI Foundry project with a deployed model, indexed corpus, and enabled tracing.
2. Build a grounded agent with a strong persona and refusal behavior.
3. Ground the agent on enterprise content using Azure AI Search and File Search — with citations.
4. Extend the agent with three tools: **Foundry IQ** (Azure AI Search + SharePoint), **WebIQ** (Bing Search), and **Azure SQL** (structured contract data lookup).
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

The solution is described at two complementary levels. The two diagrams below show **what the agent does for the business** and **which Azure services power it**.

### Functional architecture (business capabilities)

Legal, Procurement, and Sales users interact with **one Contract Lifecycle Management Agent**. The agent exposes five business capabilities:

1. **Intake & drafting** — turn a plain-English request into a first draft using approved templates.
2. **Contract search & review** — find contracts, quote clauses, and pull templates from the enterprise repository.
3. **Market & regulatory research** — enrich answers with external context from the open web.
4. **Contract status & renewals** — report on any contract's lifecycle stage and surface upcoming renewal / expiration events from structured data.

Everything is grounded on the enterprise corpus, guarded by content safety, and audited end-to-end. The agent **never** advises on legal strategy.

### Technical architecture (Azure services)

| Layer | Azure service | Purpose |
| --- | --- | --- |
| Channel | Web App (Easy Auth) / Teams / API | User surface |
| Agent runtime | **Azure AI Foundry** (Agents + Models) | Instructions, tool orchestration, model calls |
| Model | **Azure AI Foundry Models** (gpt-4o / gpt-4o-mini) | Reasoning, drafting, and language tasks |
| Grounding (Foundry IQ) | **Azure AI Search** + **Azure Blob Storage** | Vector + semantic hybrid retrieval over the contract corpus |
| Business system (Foundry IQ) | **SharePoint** | Approved templates, executed contracts, and policies |
| External research (WebIQ) | **Bing Search** | Market intelligence, counterparty and regulatory context |
| System of record | **Azure SQL** | Contract status, owner, stage, renewal date, KPIs |
| Safety | **Azure AI Content Safety** + **Prompt Shields** | Jailbreak, PII, restricted-clause enforcement |
| Observability | **Application Insights** + OpenTelemetry | Traces, KQL, cost + latency dashboards |
| CI gate | **GitHub Actions** + **Azure AI Evaluation SDK** | Groundedness / safety / tool accuracy gate |

<div align="center">
  <img src="./assets/images/customer-journey.png" alt="Contract Lifecycle Management Customer Journey on Microsoft Foundry showing the six-step flow from Ask to Handoff." width="100%" />
  <p><em>Customer journey: the six-step process from Ask to Handoff.</em></p>
</div>

<div align="center">
  <img src="./assets/images/architecture-target.png" alt="Contract Lifecycle Management Target Architecture on Microsoft Foundry showing the user layer, agent layer, data layer, and governance." width="100%" />
  <p><em>Target architecture: user layer, agent layer, data layer, and governance.</em></p>
</div>

Every challenge builds one slice of this picture. By the end, the whole diagram is real.

### Agent tools

The Contract Lifecycle Management Agent is powered by **three** explicit tools. Every user request is answered by orchestrating one or more of them.

| # | Tool | Connected service(s) | Purpose | Expected outcome |
| --- | --- | --- | --- | --- |
| 1 | **Foundry IQ** | Azure AI Search · SharePoint | Contract search, document grounding, and knowledge retrieval across the contract corpus, templates, executed contracts, and policies | Grounded answers with citations to the exact clause, paragraph, or SharePoint document |
| 2 | **WebIQ** | Bing Search | External research and market intelligence — counterparty background, regulatory context, and industry benchmarks | Fresh, cited web sources augmenting the internal corpus |
| 3 | **Azure SQL** | Azure SQL | Structured contract metadata: status, dates, owners, renewal information, KPIs | Deterministic status answers; renewals never missed |

Use-case mapping for the agent:

- **Contract Search (Foundry IQ & Azure AI Search)** — find contracts, clauses, and policies in the corpus.
- **SharePoint Knowledge Access (Foundry IQ)** — pull templates, executed contracts, and policy documents.
- **Web Research (WebIQ / Bing Search)** — market intelligence, counterparty background, regulatory news.
- **Structured Contract Data Lookup (Azure SQL)** — contract status, dates, owners, renewals, KPIs.

Every tool call is traced end-to-end into Application Insights (Challenge 5) and scored by the evaluation gate for **tool call accuracy** (Challenge 6).

### Architecture design decisions

- **One agent, three tools.** A single agent owns the CLM domain and orchestrates a small, orthogonal tool set. Fewer tools mean less misrouting and a tighter audit trail.
- **Foundry IQ for internal knowledge.** One tool wraps both Azure AI Search (contract corpus, hybrid vector + semantic retrieval) and SharePoint (templates, executed contracts, policies). The agent never has to choose which internal source to hit.
- **WebIQ for external research.** Bing Search plugs the gap for anything not in the corpus — counterparty background, regulatory updates, benchmarks — with fresh, cited web results.
- **Azure SQL for structured contract data.** Contract state is structured and queryable, so a direct SQL connector beats hand-rolled APIs. Status, owners, renewal dates, and KPIs all live in one relational store.
- **Grounding first, tools second.** Retrieval (Foundry IQ) fires before any status write, so every answer is anchored to real content.
- **Safety wraps every tool.** Prompt Shields, Content Safety, and PII detection sit between the user and every tool call — there is no "unsafe fast path".

## Challenge roadmap

| # | Challenge | Focus | Path |
| --- | --- | --- | --- |
| 0 | [Setup](./challenges/challenge-0-setup.md) | Foundry project, model, Search, tracing, corpus | Low-code + Pro-code |
| 1 | [Build Agent — Contract Intake & Drafting](./challenges/challenge-1-build-agent.md) | Persona, instructions, refusal behavior | Low-code + Pro-code |
| 2 | [Knowledge Grounding](./challenges/challenge-2-knowledge-grounding.md) | Azure AI Search + File Search with citations | Low-code + Pro-code |
| 3 | [Tools & Actions](./challenges/challenge-3-tools-actions.md) | Foundry IQ (Azure AI Search + SharePoint), WebIQ (Bing), Azure SQL | Low-code + Pro-code |
| 4 | [Guardrails](./challenges/challenge-4-guardrails.md) | Prompt Shields, PII, template enforcement | Low-code + Pro-code |
| 5 | [Observability](./challenges/challenge-5-observability.md) | Tracing, monitoring, tool telemetry | Low-code + Pro-code |
| 6 | [Evaluation](./challenges/challenge-6-evaluation.md) | Groundedness, safety, tool accuracy | Low-code + Pro-code |
| 7 | [Optimization](./challenges/challenge-7-optimization.md) | Model, prompt, retrieval, cost, latency | Low-code + Pro-code |
| 8 | [Publish](./challenges/challenge-8-publish.md) | Web App, Teams, API endpoint | Low-code + Pro-code |

Every challenge follows the same anatomy: **Context → Objective → Learning Outcome → Prerequisites → Architecture Diagram → Low-Code Path → Pro-Code Path → Portal Walkthrough & Deployment Checklist**.

## Prerequisites

Before you start Challenge 0, make sure you have:

- An **Azure subscription** with permission to create resource groups and role assignments (Owner, or Contributor + User Access Administrator).
- Access to **Microsoft Foundry** at [`ai.azure.com`](https://ai.azure.com).
- Quota to deploy **gpt-4o** or **gpt-4o-mini** in your target region (≥ 30k TPM recommended).
- **Python 3.11+**, **Git**, and **VS Code** with the Python + Azure extensions.
- **Azure CLI** (`az login` works).
- (For pro-code path) `pip install -r requirements.txt`.
- (For Challenge 3 & 5) A Microsoft 365 tenant with **SharePoint**, a **Bing Search** resource, and an **Azure SQL** database — or the ability to stub the equivalent HTTP endpoints.

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
- **Function calling** — wiring Foundry IQ (Azure AI Search + SharePoint), WebIQ (Bing), and Azure SQL as function tools on an agent.
- **Guardrails** — Prompt Shields, Content Safety, PII detection, app-layer blocklists.
- **Observability** — OpenTelemetry, Application Insights, KQL, cost tracking.
- **Evaluation** — groundedness, task adherence, safety, tool call accuracy, gate design.
- **Optimization** — model + prompt + retrieval + cost sweeps with reproducible runs.
- **Deployment** — Web App with Easy Auth, Teams manifest, API endpoint with Managed Identity.

## Success outcomes

You have "shipped" this MicroHack when:

- Your CLM agent answers the 15-question evaluation set with citations and hits the deployment gate.
- The full end-to-end scenario (intake → draft → retrieve clause via Foundry IQ → enrich via WebIQ → lookup contract status in Azure SQL) works from a single Foundry thread.
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
│   ├── images/                       <- Architecture overview + per-challenge diagrams (SVG)
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
