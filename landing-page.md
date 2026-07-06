# Executive Assistant Agent MicroHack

**Build, ground, evaluate, and deploy an AI Executive Assistant using Microsoft Foundry.**

> A hands-on, challenge-based MicroHack that takes an idea from *"a prompt in a chat window"* to *"a governed, evaluated, deployed agent"* — using **Microsoft Foundry**.

<p align="center">
  <a href="docs/challenge-1-build-agent.md">🏗️ Build</a> ·
  <a href="docs/challenge-2-grounding.md">📚 Ground</a> ·
  <a href="docs/challenge-3-tools-actions.md">🔌 Tools</a> ·
  <a href="docs/challenge-4-evaluation.md">📊 Evaluate</a> ·
  <a href="docs/challenge-5-deploy-share.md">🚀 Deploy</a>
</p>

---

## 🌟 Overview

Executive assistants are the ultimate context-switchers: 40+ meetings a week, thousands of documents, hundreds of open action items. This MicroHack shows you how to give them a **real AI teammate** built on **Microsoft Foundry**.

By the end of the day you will have built an **Executive Assistant Agent** that can:

- 📝 **Summarize meetings** — extract decisions, risks, and open questions.
- ✅ **Generate action items** — with owners and due dates.
- ✉️ **Draft follow-up emails** — in the executive's voice.
- 🔎 **Search enterprise knowledge** — docs, emails, meeting notes, briefs.
- ⚙️ **Trigger business workflows** — book time, create tasks, send updates.
- 🧑‍💼 **Support executive assistant productivity scenarios** end-to-end.

## 🧭 Challenge navigation

| # | Challenge | Description | Key Foundry feature | Link |
| --- | --- | --- | --- | --- |
| **1** | **Build the Agent** | Create the base Executive Assistant agent — model + instructions + first turn. | Foundry **Agent Service** | [→ open](docs/challenge-1-build-agent.md) |
| **2** | **Ground the Agent with Knowledge** | Give the agent access to enterprise documents, emails, and meeting notes. | **Foundry IQ** on **Azure AI Search** + **File Search** | [→ open](docs/challenge-2-grounding.md) |
| **3** | **Add Tools and Actions** | Move from chatbot to agent — call APIs, trigger flows, act on the world. | **Tools catalog**, **Logic Apps**, **Power Automate**, **Azure Functions** | [→ open](docs/challenge-3-tools-actions.md) |
| **4** | **Evaluate and Improve the Agent** | Measure quality, safety, and groundedness. Set a shippable bar. | **Foundry Evaluators** + **Content Safety** | [→ open](docs/challenge-4-evaluation.md) |
| **5** | **Deploy and Share the Agent** | Ship as a Web App, a Teams App, and an API. Governance included. | **Foundry Deploy** + Web / Teams / API endpoints | [→ open](docs/challenge-5-deploy-share.md) |

## 🧑‍💼 User journey

The Executive Assistant Agent supports a six-step, real-world executive workflow:

```mermaid
journey
    title Executive Assistant — from prep to approval
    section Before the meeting
      1 · Ask the agent to prepare for a meeting: 5: Executive
      2 · Agent searches docs, emails, and meeting notes: 4: Agent
      3 · Agent summarizes key context and open tasks: 5: Agent
    section After the meeting
      4 · Ask the agent to draft follow-up actions: 5: Executive
      5 · Agent creates action items, drafts email, suggests next steps: 4: Agent
      6 · Executive reviews and approves the final output: 5: Executive
```

Or as a flow:

```mermaid
flowchart LR
    S1([1 · Prepare for meeting]) --> S2([2 · Search docs, emails, notes])
    S2 --> S3([3 · Summarize context and open tasks])
    S3 --> S4([4 · Ask for follow-up actions])
    S4 --> S5([5 · Draft email + action items + next steps])
    S5 --> S6([6 · Review and approve])
```

See [`assets/user-journey.md`](assets/user-journey.md) for the full narrative with example prompts and expected outputs.

## 🏗️ Architecture

```mermaid
flowchart LR
    User([👤 Executive]) --> Entry[Microsoft Copilot / Web App<br/>Entry point]
    Entry --> Agent[🤖 Microsoft Foundry Agent<br/>Model + Instructions]

    subgraph FoundryProject[Microsoft Foundry Project]
        Agent --> KG[(Knowledge Grounding)]
        Agent --> Tools[Tools & Actions]
        Agent --> Eval[Evaluation & Monitoring]
    end

    KG --> Search[Azure AI Search]
    KG --> FileSearch[File Search]

    Tools --> Logic[Logic Apps]
    Tools --> Power[Power Automate]
    Tools --> API[API Calls]

    Eval --> Evaluators[Foundry Evaluators]
    Eval --> AppInsights[Application Insights]

    Agent --> Deploy[Deployment / Sharing Layer]
    Deploy --> Web[Web App]
    Deploy --> Teams[Microsoft Teams]
    Deploy --> Endpoint[API Endpoint]
```

See [`assets/architecture-diagram.md`](assets/architecture-diagram.md) for the annotated diagram and design notes.

## ✅ Prerequisites

Before you start, make sure you have:

- 🧠 **Microsoft Foundry** access — a project on [ai.azure.com](https://ai.azure.com).
- ☁️ An **Azure subscription** or a Foundry sandbox.
- 📚 **Basic understanding** of what an agent is (model + instructions + tools).
- 📄 A handful of **sample documents** for grounding — meeting notes, briefs, policies, anything you'd want the assistant to know.
- 🧰 **Optional:** VS Code and GitHub Copilot.

## 🎯 Learning objectives

After completing this MicroHack you will know how to:

- 🏗️ **Build an agent** in Microsoft Foundry.
- 📚 **Ground an agent** with enterprise knowledge.
- 🔌 **Connect tools and actions** to make the agent *do*, not just *say*.
- 📊 **Evaluate agent quality and safety** — and set a real deployment gate.
- 🚀 **Deploy and share** the solution to Web, Teams, and an API endpoint.

## 📂 Repository structure

```
├── README.md
├── landing-page.md               ← you are here
├── index.html                    ← polished HTML landing page
├── docs/
│   ├── challenge-1-build-agent.md
│   ├── challenge-2-grounding.md
│   ├── challenge-3-tools-actions.md
│   ├── challenge-4-evaluation.md
│   └── challenge-5-deploy-share.md
└── assets/
    ├── architecture-diagram.md
    └── user-journey.md
```

## 🚀 Getting started

1. **Clone the repo:**

   ```bash
   git clone https://github.com/<your-org>/MS-Foundry-Microhack.git
   cd MS-Foundry-Microhack
   ```

2. **Pick your entry point:**

   - Read [`README.md`](README.md) for the repo overview.
   - Read this file ([`landing-page.md`](landing-page.md)) for the docs-style landing page.
   - Open [`index.html`](index.html) in a browser — or publish to GitHub Pages — for the visual landing page.

3. **Work the challenges in order** starting with [Challenge 1 — Build the Agent](docs/challenge-1-build-agent.md).

## 💬 Get help

- Every challenge ends with a **Success Criteria** checklist and a **Next Steps** bridge — use those to unblock.
- Stuck on grounding? Re-read the *"cite your sources"* instruction block in Challenge 2.
- Stuck on tools? Check that your tool descriptions are unambiguous — the model routes on those strings.
- Stuck on eval? Start with a 10-row test set; grow it later.

Good luck — and welcome to Foundry.
