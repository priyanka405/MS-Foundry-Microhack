# MS Foundry MicroHack

## Prototype to Publish an Employee Support Agent

This MicroHack walks participants through the full Microsoft Foundry lifecycle for building an enterprise-ready **Employee Support Agent**.

## Quick Links

- [Open landing page](./index.html)
- [Repository](https://github.com/priyanka405/MS-Foundry-Microhack)
- [Student guide](../student-guide/README.md)
- [Challenge 0 — Environment Setup](../challenges/challenge0-setup/README.md)

---

## Prerequisites

Before starting, make sure you have:

- Access to Microsoft Foundry
- An Azure subscription
- Azure CLI and Bicep CLI installed
- Python 3.11+ or Node.js 20+
- This repository cloned locally
- Environment values ready for deployment parameters

---

## Use Case — Employee Support Agent

### Story

You work in a company where employees ask questions every day such as:

- How do I request vacation?
- How do I reset my password?
- Where is the travel policy?
- Who approves expenses?

The AI agent should be able to:

- Answer questions
- Search documents
- Create IT tickets through a mock API
- Remember preferences and context
- Follow company policies

### Why this scenario fits every challenge

| Challenge | Scenario fit |
|---|---|
| Model Choice | Compare high-quality vs. efficient models |
| First Agent | Build a baseline employee assistant |
| Grounding | Use HR and IT documents as trusted sources |
| Tools | Create tickets and trigger actions |
| Memory | Personalize answers based on known context |
| Guardrails | Protect confidential information |
| Evaluation | Measure groundedness and correctness |
| Optimization | Improve prompts, retrieval, and tools |
| Observability | Inspect traces, latency, and failures |
| Publish | Prepare for enterprise rollout |

---

## Challenge Journey

0. **Environment Setup**  
   Deploy the Azure infrastructure needed for the workshop.

1. **Model Choice Matters**  
   Compare models for quality, speed, and cost.

2. **Build Your First Agent**  
   Create the baseline Employee Support Agent.

3. **Ground the Agent**  
   Connect the agent to enterprise knowledge.

4. **Give the Agent Tools**  
   Add the mock ticketing API as an action tool.

5. **Add Memory**  
   Personalize the experience with session and user memory.

6. **Make It Safe**  
   Add guardrails, content safety, and prompt injection protection.

7. **Evaluate the Agent**  
   Measure correctness, relevance, and groundedness.

8. **Optimize the Agent**  
   Improve prompts, tools, and retrieval based on evidence.

9. **Observe Everything**  
   Configure tracing, dashboards, and alerts.

10. **Enterprise Ready**  
   Publish with governance, operations, and access controls.

---

## Challenge Hub

### Challenge 0 — Environment Setup
- **Goal:** Deploy the full Azure Foundry environment using Bicep.
- **Open:** [Challenge README](../challenges/challenge0-setup/README.md)
- **Related:** [Infra guide](../infra/README.md)

### Challenge 1 — Model Choice Matters
- **Goal:** Compare candidate models and choose the best fit.
- **Open:** [Challenge README](../challenges/challenge1-models/README.md)

### Challenge 2 — Build Your First Agent
- **Goal:** Create the baseline Employee Support Agent with system instructions.
- **Open:** [Challenge README](../challenges/challenge2-agent/README.md)

### Challenge 3 — Ground the Agent
- **Goal:** Connect the agent to HR and IT knowledge.
- **Open:** [Challenge README](../challenges/challenge3-grounding/README.md)
- **Starter assets:** `starter-code/documents/`

### Challenge 4 — Give the Agent Tools
- **Goal:** Register the mock ticketing API as a tool.
- **Open:** [Challenge README](../challenges/challenge4-tools/README.md)
- **Starter assets:** `starter-code/mock-api/`

### Challenge 5 — Add Memory
- **Goal:** Store useful employee context across conversations.
- **Open:** [Challenge README](../challenges/challenge5-memory/README.md)

### Challenge 6 — Make It Safe
- **Goal:** Prevent policy leakage and unsafe responses.
- **Open:** [Challenge README](../challenges/challenge6-guardrails/README.md)

### Challenge 7 — Evaluate the Agent
- **Goal:** Create a dataset and measure agent quality.
- **Open:** [Challenge README](../challenges/challenge7-evals/README.md)
- **Starter assets:** `starter-code/eval-dataset/`

### Challenge 8 — Optimize the Agent
- **Goal:** Improve the agent based on evaluation findings.
- **Open:** [Challenge README](../challenges/challenge8-optimization/README.md)

### Challenge 9 — Observe Everything
- **Goal:** Enable tracing, monitoring, and alerting.
- **Open:** [Challenge README](../challenges/challenge9-observability/README.md)

### Challenge 10 — Enterprise Ready
- **Goal:** Publish the agent with governance and operational readiness.
- **Open:** [Challenge README](../challenges/challenge10-publish/README.md)
