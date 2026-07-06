# Student guide

Welcome! Here's how to get the most out of the **Contract Intake &amp; Drafting Agent** MicroHack.

## 🎯 What you'll walk out with

- A **Microsoft Foundry** project of your own.
- A working **Contract Intake &amp; Drafting Agent** with grounding, tools, guardrails, tracing, and evaluation.
- A **GitHub fork** with your changes.
- A **live deployment** (Web App, Teams, or API endpoint).
- A working understanding of what Foundry actually is — and where it fits in your day job.

## ⏱️ How long does it take?

- **Fast path (portal only, 1 person)**: ~4 hours.
- **Standard path (mixed portal + SDK, team of 2–3)**: ~6–7 hours.
- **Deep path (SDK-first, evaluation + optimization)**: full day.

## 🧑‍💻 Pick a path

Both paths land at the same success criteria at the end of each challenge. Pick based on what you want to practice.

### 🖱️ Low-code / portal path

- Works entirely in the [Foundry portal](https://ai.azure.com).
- Best for **PMs, business users, first-time Foundry users**.
- Each challenge has a *"Portal path"* section.

### 💻 Pro-code / SDK path

- Uses the Python SDK — `azure-ai-projects` + `azure-identity` — in the [`app/`](../app/) folder.
- Best for **developers, ML engineers, platform builders**.
- Each challenge has a *"SDK path"* section referencing files under `app/`.

## 🚀 First 15 minutes

1. **Clone the repo:**
   ```bash
   git clone https://github.com/<your-org>/foundry-contract-lifecycle-management-hackathon.git
   cd foundry-contract-lifecycle-management-hackathon
   ```
2. **(SDK path only) Set up Python:**
   ```bash
   python -m venv .venv
   source .venv/bin/activate   # macOS/Linux
   # .venv\Scripts\Activate.ps1  # Windows
   pip install -r requirements.txt
   cp .env.example .env
   ```
3. **Log in:**
   ```bash
   az login
   ```
4. **Open [Challenge 0 — Setup](challenges/challenge-0-setup/README.md).**

## 📓 How each challenge is structured

Every challenge follows the same shape so you always know where you are:

1. **🎯 Objective** — the one sentence you'd write on a whiteboard.
2. **📋 Tasks** — the numbered checklist.
3. **🛠️ Portal path** — step-by-step for the low-code route.
4. **💻 SDK path** — Python code with references to files in `app/`.
5. **✅ Success criteria** — a tickable checklist.
6. **🩹 Tips &amp; troubleshooting** — the failures we know you'll hit.
7. **🌉 Next challenge** — a one-line bridge.

## 🧭 Golden rules

1. **Do the challenges in order.** Each challenge builds on the previous one.
2. **Never skip the refusal tests.** The whole point of Foundry is safe, grounded agents — a working agent that hallucinates isn't working.
3. **Cite everything.** If your agent claims a clause exists, it must show the source.
4. **Confirm before irreversible actions.** Approvals, doc-gen, and status updates are proposed → confirmed → executed.
5. **Read the errors.** Foundry errors are unusually helpful. Read them before searching.

## 🩹 When you're stuck (in order)

1. Re-read the challenge's **Success criteria** — did you complete every step?
2. Check the challenge's **Tips &amp; troubleshooting** table.
3. Ask your team-mate.
4. Ask a coach.
5. Ask the room.

## 💡 Tips from previous cohorts

- The **hardest** challenge is not the one you think. Challenge 2 (grounding) is fiddly; Challenge 6 (evaluation) is often what changes people's mental model.
- **The persona matters.** If Challenge 1 feels underwhelming, spend an extra 10 minutes on the instructions before moving on. Everything downstream gets easier.
- **Small test set > big test set.** Ship an eval with 10 rows on day one. You'll add rows for free later.
- **Cost matters.** Track model + retrieval cost from Challenge 5. Optimizing without a baseline is guessing.

## 🎓 What you should be able to explain by the end

- The difference between a **chatbot** and an **agent**.
- What **grounding** does and why refusals matter.
- Why **tool descriptions** are prompts.
- What a **jailbreak / prompt-injection** attack looks like.
- What **"good enough to ship"** means with a Foundry evaluation gate.
- How you'd apply the same shape to another contract-adjacent workflow (renewals, RFPs, vendor onboarding).

Ready? → **[Challenge 0 — Setup](challenges/challenge-0-setup/README.md)**.
