# Facilitator guide

For coaches, MTCs, and internal enablement leads running this hack as a **one-day event**.

## 🎯 Learning objectives (attendee-facing)

By the end of the day, attendees will be able to:

1. Provision a Microsoft Foundry project and deploy a model.
2. Build an agent with instructions, tools, and grounding.
3. Ground an agent on enterprise documents using Azure AI Search + File Search.
4. Wire up business tools (approvals, doc-gen, status).
5. Add content-safety and prompt-shield guardrails.
6. Emit and read traces in Application Insights.
7. Run a Foundry evaluation and enforce a shippable bar.
8. Optimize model / prompt / retrieval for cost and accuracy.
9. Deploy to Web App, Teams, or an API endpoint.

## 🗓️ Suggested one-day agenda (7.5 hours)

| Time | Block | Content |
| --- | --- | --- |
| 09:00 – 09:30 | Kickoff | Foundry overview, scenario, teams of 2–4, roles. |
| 09:30 – 10:00 | Challenge 0 — Setup | Portal login, project, model deployment. |
| 10:00 – 11:00 | Challenge 1 — Build | Persona, first turn, refusal check. |
| 11:00 – 12:00 | Challenge 2 — Ground | Templates + policies + clauses → index. |
| 12:00 – 13:00 | 🍽️ Lunch + open Q&amp;A | — |
| 13:00 – 14:00 | Challenge 3 — Tools | Clause lookup + doc-gen + approval. |
| 14:00 – 14:45 | Challenge 4 — Guardrails | Content Safety, template enforcement. |
| 14:45 – 15:15 | Challenge 5 — Observability | OpenTelemetry + App Insights. |
| 15:15 – 15:45 | Challenge 6 — Evaluation | 15-row eval + gate. |
| 15:45 – 16:15 | Challenge 7 — Optimize | Model comparison + prompt tuning. |
| 16:15 – 16:45 | Challenge 8 — Publish | Web App / Teams / API. |
| 16:45 – 17:00 | Wrap-up | Demos + retro + next steps. |

## 🎒 What to hand out

- **Foundry sandbox creds** (or a shared subscription with `Contributor` on a resource group).
- Access to the [repo](https://github.com/<your-org>/foundry-contract-lifecycle-management-hackathon).
- A copy of the [student guide](student-guide.md).
- Optional: printed cheat-sheet with the 5 key Foundry surfaces (Agents, Models, Evaluation, Content Safety, Deploy).

## 🧑‍🏫 Coaching tips

- **Push refusals early.** Attendees are tempted to "make the agent smarter" instead of "make it more refusable." Reward refusals loudly during Challenge 1.
- **The bug is almost always the description.** In Challenge 3, when a tool isn't called at the right time, 9 times out of 10 the tool description is ambiguous. Rewrite it before touching anything else.
- **Force one eval run before Challenge 4.** Attendees think "I know it works" — the eval will surface a subtle grounding regression 100% of the time.
- **Timebox brutally.** If a team is stuck in Challenge 2 at lunch, help them past it — the second half is where the real Foundry story lives.
- **Encourage the SDK path in the afternoon.** After Challenge 4, most teams can move faster in code than in the portal.

## 🩹 Common blockers &amp; unblocks

| Blocker | Unblock |
| --- | --- |
| No permission to create resources | Give attendees a pre-created RG with `Contributor`. |
| AI Search indexer never completes | Check that Blob → Search has the right role assignment (`Storage Blob Data Reader`). |
| Logic App returns 401 | Missing SAS in the URL — use the full HTTP POST URL. |
| No traces in App Insights | Wrong connection string in `.env`; re-run after export. |
| Evaluator run fails | Check model config; some evaluators need `gpt-4o-mini` deployment. |

## 🏆 Judging / demos

Give each team **3 minutes + 2 minutes Q&amp;A** at the end. Score on:

| Criterion | Weight |
| --- | --- |
| Correctness of clause retrieval (Challenge 2) | 15% |
| Quality of tool routing (Challenge 3) | 15% |
| Effectiveness of guardrails (Challenge 4) | 15% |
| Evaluation gate passed (Challenge 6) | 20% |
| Optimization wins shown (Challenge 7) | 15% |
| Deployment demoed live (Challenge 8) | 20% |

## 📚 Backup content if you run over

If teams finish early, offer these stretch goals:

- Add a **multi-agent** flow: `Retriever` → `Drafter` → `Approver`.
- Add an **MCP server** for CRM enrichment (Contoso's total spend).
- Add a **red-team** pass with a synthetic adversarial dataset.
- Add **Purview labels** on the contract repository.

## 🎁 Attendee takeaways

Each attendee should leave with:

- A working Foundry project they can keep.
- A GitHub repo they built (fork of this one, plus their own changes).
- A **printed** evaluation gate report from Challenge 6.
- A **live URL** or Teams app installer from Challenge 8.
