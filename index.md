---
title: Contract Intake &amp; Drafting Agent · Microsoft Foundry MicroHack
---

# 📝 Contract Intake &amp; Drafting Agent — Microsoft Foundry MicroHack

Build a production-ready **Contract Intake &amp; Drafting Agent** on **Microsoft Foundry** — from a bare model to a governed, evaluated, deployed agent — in one focused day.

<div class="grid cards" markdown>

- :material-rocket-launch:{ .lg .middle } **Start here**

    ---
    New? Read the [student guide](docs/student-guide.md), then start with [Challenge 0 — Setup](docs/challenges/challenge-0-setup/README.md).

- :material-map:{ .lg .middle } **The 9-challenge journey**

    ---
    Setup → Build → Ground → Tools → Guardrails → Observability → Evaluate → Optimize → Publish.

- :material-account-tie:{ .lg .middle } **Coaching**

    ---
    Facilitators: run this as a one-day event using the [facilitator guide](docs/facilitator-guide.md).

- :material-source-repository:{ .lg .middle } **Code**

    ---
    Pro-code path lives in [`app/`](https://github.com/<your-org>/foundry-contract-lifecycle-management-hackathon/tree/main/app).

</div>

## The scenario

A global enterprise's Legal and Procurement teams spend **hours per week** taking contract requests, hunting for the right template, copying approved clauses, checking against policy, and routing for approval. Small mistakes create big legal risk.

You'll build a **Contract Intake &amp; Drafting Agent** that:

1. Accepts a natural-language intake request (*"I need a mutual NDA with Contoso, effective 2026-08-01"*).
2. Picks the correct **template** (NDA / MSA / SOW).
3. Populates it from the **approved clause library**.
4. Checks **legal / procurement / compliance policies** before drafting.
5. Routes the draft for **approval** through Logic Apps / Power Automate.
6. Returns a clean draft with citations to policies and clauses used.

## Why Microsoft Foundry

Foundry is **not** just a chatbot builder. It's a full platform for building agents with:

- Models + Instructions + Tools + Knowledge — versioned.
- Grounding on enterprise data with Azure AI Search / File Search.
- Tools that call Logic Apps, Power Automate, Azure Functions, OpenAPI, MCP.
- Guardrails via Content Safety and Prompt Shields.
- Tracing, evaluation, and optimization — all inside the same project.
- Deployment to Web App, Teams, and API endpoints with Managed Identity.

This MicroHack walks you through every one of those, in order.

## Challenges

| # | Title | Description |
| --- | --- | --- |
| 0 | [Setup](docs/challenges/challenge-0-setup/README.md) | Provision the Foundry project + model + storage + identity. |
| 1 | [Build the Agent](docs/challenges/challenge-1-build-agent/README.md) | Model + instructions + first grounded conversation. |
| 2 | [Knowledge Grounding](docs/challenges/challenge-2-knowledge-grounding/README.md) | Ingest templates + policies + clauses; enable RAG. |
| 3 | [Tools &amp; Actions](docs/challenges/challenge-3-tools-actions/README.md) | Clause lookup, doc-gen, approval routing. |
| 4 | [Guardrails](docs/challenges/challenge-4-guardrails/README.md) | Template enforcement, sensitive data protection, compliance. |
| 5 | [Observability](docs/challenges/challenge-5-observability/README.md) | Tracing, metrics, cost dashboards. |
| 6 | [Evaluation](docs/challenges/challenge-6-evaluation/README.md) | Groundedness, task adherence, safety scorers. |
| 7 | [Optimization](docs/challenges/challenge-7-optimization/README.md) | Model choice, prompt / retrieval tuning, cost. |
| 8 | [Publish](docs/challenges/challenge-8-publish/README.md) | Deploy to Web App, Teams App, and API endpoint. |

Ready? → **[Challenge 0 — Setup](docs/challenges/challenge-0-setup/README.md)**
