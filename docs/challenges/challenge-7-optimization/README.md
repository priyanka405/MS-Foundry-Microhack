# Challenge 7 — Optimization

> **Goal:** Push evaluation scores up and cost down. Compare **models**, tune the **prompt**, and refine **retrieval** — with numbers, not vibes.

**Foundry surface:** Prompt flow / A-B runs, evaluator scoring, model deployments
**Estimated time:** 40–50 min
**Prerequisite:** Challenge 6 (you need a working eval gate).

---

## 🎯 Objective

Turn the agent from *"passes the gate"* into *"passes the gate at half the cost / higher accuracy"*. Every change you make gets a numeric before/after.

## 📋 Tasks

1. Establish a **baseline** (last eval run from Challenge 6).
2. Run three optimization experiments:
   - **Model** — swap `gpt-4o` for `gpt-4o-mini`; compare.
   - **Prompt** — tighten instructions; compare.
   - **Retrieval** — tune chunk size + top-k; compare.
3. Pick a winner per axis; document the tradeoff.
4. Re-run the eval gate on the winner.

---

## 📊 The optimization table

Every experiment fills one row of this table. Only ship changes that improve **at least one** metric without regressing any other by more than `0.15`.

| Experiment | Task Adherence | Groundedness | Relevance | p95 latency | $ / 1k turns |
| --- | --- | --- | --- | --- | --- |
| Baseline (Challenge 6) | | | | | |
| Model: `gpt-4o-mini` | | | | | |
| Prompt: tightened | | | | | |
| Retrieval: chunk 512 / top-k 8 | | | | | |
| Winner (chosen combo) | | | | | |

## 🖱️ Portal path

### 1. Model comparison

1. Deploy `gpt-4o-mini` in the same project (Deployments → + Deploy).
2. Duplicate the agent → point at `gpt-4o-mini` → same instructions.
3. Foundry portal → **Evaluation → New evaluation** using the same dataset from Challenge 6, but on the `gpt-4o-mini` agent.
4. Fill the row in the table above.

If Task Adherence drops by more than `0.5`, `gpt-4o-mini` isn't the answer alone — but keep it as a candidate for cheap sub-flows (e.g., clause classification).

### 2. Prompt tightening

Try these three edits, one at a time, re-evaluating between each:

1. **Shorten** — cut any repeated / redundant lines from the instructions.
2. **Sharpen** — replace *"prefer approved clauses"* with *"NEVER hand-write payment / liability / termination clauses. ALWAYS call `clause_lookup`."*
3. **Show, don't tell** — add 2–3 few-shot examples of good refusals under `# BEHAVIOR`.

For each edit, log the delta in the table. Roll back the ones that regress.

### 3. Retrieval tuning

Rebuild `idx-clm-contracts` (or a parallel index) with different chunking:

| Config | When it helps |
| --- | --- |
| chunk 512 / overlap 64 / top-k 8 | Short clauses, precise citations. |
| chunk 1024 / overlap 100 / top-k 5 (default) | Balanced. |
| chunk 2048 / overlap 200 / top-k 3 | Long policies, more context per chunk. |

Also try **semantic ranker on/off** and **`VECTOR_SEMANTIC_HYBRID` vs `VECTOR`**. Log deltas.

---

## 💻 SDK path

See [`app/evaluation.py`](../../../app/evaluation.py) — it exposes a `run_gate(agent_id, dataset)` helper so you can loop across experiments.

```python
# scripts/optimize.py — sketch
from app.evaluation import run_gate

variants = [
    {"name": "baseline",       "agent_id": AGENT_BASELINE},
    {"name": "gpt-4o-mini",    "agent_id": AGENT_MINI},
    {"name": "prompt-tight",   "agent_id": AGENT_PROMPT_V2},
    {"name": "chunk-512-k8",   "agent_id": AGENT_RETRIEVAL_V2},
]
for v in variants:
    metrics = run_gate(agent_id=v["agent_id"], dataset="data/test_cases/evaluation_dataset.jsonl")
    print(v["name"], metrics)
```

## 💰 Cost tracking

Reuse the App Insights KQL from Challenge 5. To get $ per experiment, filter by the agent id:

```kusto
customMetrics
| where name == "gen_ai.client.token.usage"
| where customDimensions.agent_id == "<agent-id>"
| summarize tokens = sum(value)
| extend est_usd = tokens * <price-per-token-for-this-model>
```

## ✅ Success criteria

- [ ] Table above is filled for baseline + at least 3 experiments.
- [ ] Winner is selected per axis (model, prompt, retrieval).
- [ ] Winner beats baseline on **at least one** metric with no regression &gt; `0.15`.
- [ ] Winner passes the deployment gate (same thresholds as Challenge 6).
- [ ] Cost improvement (if any) is quantified with a KQL query.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `gpt-4o-mini` collapses Task Adherence. | Fewer parameters = worse instruction following. | Keep `gpt-4o` for orchestration; use mini only for scoped sub-tasks. |
| Prompt "shortening" tanks scores. | Removed a critical rule (e.g., NEVER-invent). | Re-add; keep guardrail rules non-negotiable. |
| Chunk 2048 tanks Groundedness. | Semantic ranker returns off-topic chunks. | Keep chunk ≤ 1024 or raise top-k. |
| Cost doesn't drop despite mini model. | Retrievals dominate cost. | Cache retrievals; reduce top-k. |
| Scores fluctuate between runs. | LLM-judge variance. | Average over 3 runs; set temperature 0. |

## 🌉 Next challenge

You have a fast, accurate, safe agent — with numbers. Time to **ship** it. In **[Challenge 8 — Publish](../challenge-8-publish/README.md)** you'll deploy to Web App, Teams, or an API endpoint.
