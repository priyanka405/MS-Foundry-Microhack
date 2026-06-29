# MS Foundry MicroHack — Employee Support Agent

> **🌐 Landing page:** [priyanka405.github.io/MS-Foundry-Microhack](https://priyanka405.github.io/MS-Foundry-Microhack/)

A hands-on hackathon that takes you from a simple chat prompt to a fully
production-ready, enterprise AI agent using **Microsoft Foundry** — in 11
structured challenges.

---

## Scenario

You work in a company. Employees ask questions every day:

- *How do I request vacation?*
- *How do I reset my password?*
- *Where is the travel policy?*
- *Who approves my expenses?*

Your mission: build an **Employee Support Agent** that answers questions,
searches company documents, creates IT tickets, remembers preferences, and
follows company policies — safely and observably.

---

## Learning Journey

| # | Challenge | Key Learning |
|---|-----------|-------------|
| 0 | Environment Setup | Deploy Foundry infra with Bicep |
| 1 | Model Choice | Benchmark models for quality & cost |
| 2 | First Agent | Build a basic agent with instructions |
| 3 | Grounding | Add HR + IT knowledge base |
| 4 | Tools | Create IT tickets via mock API |
| 5 | Memory | Remember employee preferences |
| 6 | Guardrails | Content safety & prompt injection protection |
| 7 | Evaluation | Measure correctness & groundedness |
| 8 | Optimization | Improve prompts & tools |
| 9 | Observability | Traces & monitoring dashboards |
| 10 | Publish | Enterprise rollout & governance |

---

## Repository Structure

```
MS-Foundry-Microhack/
├── README.md
├── docs/                    # GitHub Pages landing page
│   ├── index.html
│   └── styles.css
├── challenges/              # One folder per challenge
│   ├── challenge0-setup/
│   ├── challenge1-models/
│   ├── challenge2-agent/
│   ├── challenge3-grounding/
│   ├── challenge4-tools/
│   ├── challenge5-memory/
│   ├── challenge6-guardrails/
│   ├── challenge7-evals/
│   ├── challenge8-optimization/
│   ├── challenge9-observability/
│   └── challenge10-publish/
├── infra/                   # Bicep IaC templates
│   ├── main.bicep
│   ├── modules/
│   └── parameters/
├── starter-code/            # Boilerplate code & sample documents
├── coach-guide/             # Facilitator notes (do not share before challenges)
├── student-guide/           # Participant walkthroughs
└── solution-guide/          # Reference implementations
```

---

## Getting Started

1. **Fork this repository** or clone it locally.
2. Follow `challenges/challenge0-setup/README.md` to deploy your Azure Foundry environment.
3. Work through challenges 1–10 in order.
4. Enable **GitHub Pages** (`Settings → Pages → Deploy from /docs`) to publish the landing page.

## Prerequisites

- Azure subscription with Microsoft Foundry access
- Azure CLI + Bicep CLI
- Python 3.11+ or Node.js 20+
- VS Code with GitHub Copilot (recommended)

---

## Contributing

Contributions are welcome! Open a pull request to improve challenges,
add starter code, or fix issues.

---

*Microsoft, Azure, and Foundry are trademarks of Microsoft Corporation.
This is a community hackathon resource.*
