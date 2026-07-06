# Contract Intake &amp; Drafting Agent · Microsoft Foundry MicroHack

> Build a production-ready **Contract Intake &amp; Drafting Agent** on **Microsoft Foundry** — from a bare model to a governed, evaluated, deployed agent — in one focused day.

[![Foundry](https://img.shields.io/badge/Microsoft-Foundry-0078d4)](https://ai.azure.com) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license) [![Docs: mkdocs-material](https://img.shields.io/badge/Docs-mkdocs--material-2b6cb0)](docs/index.md)

---

## 🎯 What you will build

A **Contract Intake &amp; Drafting Agent** that helps a Legal or Procurement team:

- Take an intake request (*"I need an NDA with Contoso for a joint discovery workshop"*).
- Retrieve the right template (NDA / MSA / SOW).
- Populate it with **approved clauses** from a company clause library.
- Enforce **legal, procurement, and compliance policies** as guardrails.
- Route the draft for approval, and hand back a clean draft with citations.

Along the way you'll practice everything Microsoft Foundry gives you: models, instructions, tools, knowledge grounding, guardrails, tracing, evaluation, optimization, and deployment.

## 🧭 Challenges (0 → 8)

| # | Challenge | Focus | Foundry surface |
| --- | --- | --- | --- |
| **0** | [Setup](docs/challenges/challenge-0-setup/README.md) | Foundry project, model, storage, identity. | Portal + CLI |
| **1** | [Build the Agent](docs/challenges/challenge-1-build-agent/README.md) | Model + instructions + persona. First turn. | Agent Service |
| **2** | [Knowledge Grounding](docs/challenges/challenge-2-knowledge-grounding/README.md) | Templates, policies, clauses → RAG. | Azure AI Search + File Search |
| **3** | [Tools &amp; Actions](docs/challenges/challenge-3-tools-actions/README.md) | Clause lookup, doc-gen, approval routing. | Logic Apps · Power Automate · Functions |
| **4** | [Guardrails](docs/challenges/challenge-4-guardrails/README.md) | Template enforcement, sensitive-data, compliance. | Content Safety · Prompt Shields |
| **5** | [Observability](docs/challenges/challenge-5-observability/README.md) | Tracing, metrics, cost. | OpenTelemetry + App Insights |
| **6** | [Evaluation](docs/challenges/challenge-6-evaluation/README.md) | Groundedness, task adherence, safety gate. | Foundry Evaluators |
| **7** | [Optimization](docs/challenges/challenge-7-optimization/README.md) | Model choice, prompt, retrieval, cost. | Prompt flow + tuning |
| **8** | [Publish](docs/challenges/challenge-8-publish/README.md) | Web App / Teams / API endpoint. | Foundry Deploy |

## 🗂️ Repository structure

```
├── README.md                     ← this file
├── index.md                      ← MkDocs entry page
├── mkdocs.yml                    ← MkDocs site config
├── requirements.txt              ← Python deps (SDK + evaluators + otel)
├── .env.example                  ← Environment variable template
├── .gitignore
│
├── docs/
│   ├── index.md                  ← Docs landing page
│   ├── architecture.md           ← Reference architecture
│   ├── facilitator-guide.md     ← For coaches
│   ├── student-guide.md          ← For attendees
│   ├── wrapup.md                 ← Recap + next steps
│   └── challenges/
│       ├── challenge-0-setup/README.md
│       ├── challenge-1-build-agent/README.md
│       ├── challenge-2-knowledge-grounding/README.md
│       ├── challenge-3-tools-actions/README.md
│       ├── challenge-4-guardrails/README.md
│       ├── challenge-5-observability/README.md
│       ├── challenge-6-evaluation/README.md
│       ├── challenge-7-optimization/README.md
│       └── challenge-8-publish/README.md
│
├── app/                          ← Pro-code / SDK path
│   ├── contract_agent.py
│   ├── tools.py
│   ├── grounding.py
│   ├── evaluation.py
│   ├── monitoring.py
│   ├── config.py
│   └── sample_run.py
│
└── data/                         ← Grounding + eval assets
    ├── contract_templates/
    │   ├── nda_template.md
    │   ├── msa_template.md
    │   └── sow_template.md
    ├── policies/
    │   ├── legal_policy.md
    │   ├── procurement_guidelines.md
    │   └── compliance_policy.md
    ├── approved_clauses/
    │   ├── payment_terms.md
    │   ├── liability_clause.md
    │   └── termination_clause.md
    └── test_cases/
        └── evaluation_dataset.jsonl
```

## ✅ Prerequisites

- **Microsoft Foundry** access — a project on [ai.azure.com](https://ai.azure.com).
- An **Azure subscription** (or a Foundry sandbox).
- **Python 3.10+** and **`az` CLI** (for the pro-code path).
- **VS Code** (optional but recommended). GitHub Copilot optional.
- Basic familiarity with agents (model + instructions + tools).

## 🚀 Quick start

```bash
git clone https://github.com/<your-org>/foundry-contract-lifecycle-management-hackathon.git
cd foundry-contract-lifecycle-management-hackathon

# Pro-code path
python -m venv .venv &amp;&amp; source .venv/bin/activate   # macOS/Linux
# .venv\Scripts\Activate.ps1                          # Windows
pip install -r requirements.txt
cp .env.example .env    # then fill in the values

python -m app.sample_run
```

Or serve the docs site locally:

```bash
pip install mkdocs-material
mkdocs serve
# open http://127.0.0.1:8000
```

Then work the challenges **0 → 8** in order.

## 🎓 Two paths, one hack

Every challenge offers two paths so both audiences leave with something they can build on:

| Path | Who it's for | Where you work |
| --- | --- | --- |
| **Low-code / Portal** | Business users, PMs, first-time Foundry users. | The Foundry portal at [ai.azure.com](https://ai.azure.com). |
| **Pro-code / SDK** | Developers who want to script agents. | Python SDK in [`app/`](app/) using `azure-ai-projects` + `azure-identity`. |

## 📚 Positioning — Foundry is more than a chatbot builder

Foundry gives you a full **agent platform**:

- **Agents** = model + instructions + tools + knowledge, all versioned.
- **Grounding** on your data via Azure AI Search / File Search.
- **Tools &amp; actions** — Logic Apps, Power Automate, Azure Functions, OpenAPI, MCP.
- **Guardrails** — Content Safety, Prompt Shields, jailbreak defense, PII protection.
- **Tracing &amp; monitoring** — OpenTelemetry → Application Insights.
- **Evaluation** — groundedness, task adherence, safety scorers with a real gate.
- **Optimization** — model choice, prompt / retrieval tuning, cost dashboards.
- **Deploy** — Web App, Teams App, API endpoint — Managed Identity by default.

## 💬 Getting help

- Each challenge ends with a **Success Criteria** checklist and a **Tips &amp; Troubleshooting** table.
- Coaches: see [`docs/facilitator-guide.md`](docs/facilitator-guide.md).
- Attendees: see [`docs/student-guide.md`](docs/student-guide.md).

## License

MIT — see the top of this file.
