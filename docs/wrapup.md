# Wrap-up

Congratulations — you just built a real Foundry agent from scratch.

## 🧾 What you built

- A **Contract Intake &amp; Drafting Agent** that takes an intake request and returns a policy-compliant, cited draft.
- **Grounding** on templates + policies + clauses via Azure AI Search + File Search.
- **Tools** for clause lookup, doc generation, approval routing, and status tracking.
- **Guardrails** — content safety + prompt shields + template enforcement.
- **Observability** — OpenTelemetry traces flowing to Application Insights.
- **Evaluation** — a real gate (Task adherence ≥ 4.25, Groundedness ≥ 4.0, safety defects = 0).
- **Optimization** — model / prompt / retrieval baselines and a chosen winner.
- **Deployment** — Web App, Teams App, or API endpoint.

## 🧠 What you should now be able to explain

- Why **an agent is not a chatbot** — models + instructions + tools + knowledge, not just chat.
- Why **grounding + citations + refusals** matter more than "better prompts".
- Why **tool descriptions are prompts**, and how the model routes on them.
- What a **prompt-injection** attack looks like and how Prompt Shields defends.
- What a **shippable evaluation gate** looks like, and why you enforce it in CI.
- How to **optimize** for cost, accuracy, and latency in a principled way.
- Why **Managed Identity + Easy Auth** is not optional in production.

## 🚀 What to do next (this week)

- **Fork this repo** into your org and rename the scenario for your context (renewals? vendor onboarding? RFPs?).
- **Point it at your real data** — even a subset of a real repository will surface issues no synthetic test set will.
- **Set the eval gate in CI.** No merges to `main` if the gate fails.
- **Enable App Insights alerts** on: `IndirectAttack.defect_rate &gt; 0`, `groundedness &lt; 3.5`, `p95_latency &gt; 8s`.
- **Publish** the [`docs/`](index.md) site via `mkdocs gh-deploy` so your team can find the work.

## 🧱 Where to go from here (deeper)

- **Multi-agent workflow** — split into `Retriever` + `Drafter` + `Approver` agents with explicit handoffs.
- **MCP tools** — connect the agent to your CRM/ERP via an MCP server with `require_approval=always`.
- **Batch pipelines** — the same agent, run over 10k contracts overnight to surface renewals due.
- **Fine-tune / distill** — once you have 1000+ evaluated turns, distill to a cheaper model.
- **Human-in-the-loop labeling** — capture reviewer edits back into the eval set to close the loop.

## 📚 Reference

- [Microsoft Foundry](https://ai.azure.com)
- [Azure AI Foundry docs](https://learn.microsoft.com/azure/ai-foundry/)
- [Azure AI Search](https://learn.microsoft.com/azure/search/)
- [Foundry Evaluators](https://learn.microsoft.com/azure/ai-foundry/concepts/evaluation-metrics-built-in)
- [Content Safety](https://learn.microsoft.com/azure/ai-services/content-safety/)
- [Logic Apps](https://learn.microsoft.com/azure/logic-apps/)
- [Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)

## 🙏 Thanks

Thanks for spending a day with Foundry. Now go build something.
