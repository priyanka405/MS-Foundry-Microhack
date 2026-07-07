# Challenge 5 &middot; Observability

> **Duration:** ~45 minutes &middot; **Path:** Low-Code + Pro-Code &middot; **Previous:** [Challenge 4](./challenge-4-guardrails.md) &middot; **Next:** [Challenge 6 &mdash; Evaluation](./challenge-6-evaluation.md)

---

<!-- CHALLENGE-SUMMARY:v1 -->
## Challenge summary

| Field | Value |
| --- | --- |
| **Objective** | Trace every prompt, retrieval, tool call, and response into Application Insights, and query them with KQL. |
| **Agent capability** | Full audit trail &mdash; end-to-end tracing for every conversation, including latency, cost, and grounding signals. |
| **Tool integration** | Tracing wraps all three agent tools (Foundry IQ, WebIQ, Azure SQL). |
| **Azure services used** | OpenTelemetry, Application Insights, Log Analytics. |
| **Expected outcome** | Reusable KQL queries return per-thread telemetry including tool-call accuracy, latency, and cost per session. |

---
## 1. Context

You cannot ship what you cannot see. This challenge wires end-to-end telemetry into every prompt, retrieval, tool call, and response &mdash; so you can answer three questions in App Insights: *is it working?*, *is it fast?*, *what does it cost?*.

## 2. Business context

Legal and Finance will want a per-agent, per-user cost view. Ops will want p95 latency and error rates. Security will want to see every retrieval and every tool call. All three read the same App Insights.

## 3. Objective

Turn on Foundry's built-in tracing **and** wire OpenTelemetry from the SDK into Application Insights. Then write the KQL that answers the three questions above.

## 4. Learning outcome

After Challenge 5 you can:

- Enable tracing on a Foundry project and inspect a trace in the portal.
- Install `azure-monitor-opentelemetry` and `opentelemetry-instrumentation-openai-v2` in a Python service.
- Wrap functions in custom OpenTelemetry spans with a `@traced` decorator.
- Write KQL queries for cost per day, p95 latency, tool routing, and grounding quality.

## 5. Prerequisites

- Challenges 0&ndash;4 complete.
- Application Insights `appi-clm-hackathon` created (Challenge 0).
- `APPLICATIONINSIGHTS_CONNECTION_STRING` set in `.env`.

## 6. Trace flow diagram

```mermaid
flowchart LR
    P[Prompt] --> A[Agent turn span]
    A --> L[LLM span<br/>gen_ai.request/response]
    A --> R[Retrieval span<br/>azure.search]
    A --> T[Tool span<br/>gen_ai.tool.call]
    L --> Tok[Token usage metric]
    R --> Ret[Grounding event]
    T --> Res[Response]
    A --> AI[Application Insights]
    Tok --> AI
    Ret --> AI
```

## 7. Low-code path &mdash; Portal walkthrough

### 7.1 Verify project tracing

Foundry project &rarr; **Tracing** &rarr; the toggle should read **Enabled** and reference `appi-clm-hackathon`. If not, connect the App Insights resource and enable it.

### 7.2 Open a trace

Foundry project &rarr; **Tracing** &rarr; select the last 15 minutes &rarr; click a run.

You should see a span tree:

```
agent.run (root)
  agent.turn
    gen_ai.request  (input, model, temperature)
    azure.search    (query, top-k, score)
    gen_ai.tool.call (name, args)
    gen_ai.response (finish reason, token usage)
```

### 7.3 In-portal Evaluations preview

Foundry project &rarr; **Evaluations** &rarr; **+ New evaluation** &rarr; pick your agent &rarr; upload `data/test_cases/evaluation_dataset.jsonl` (used in full in Challenge 6). The portal renders groundedness, relevance, and safety scorecards straight against the traced runs.

## 8. Pro-code path &mdash; SDK walkthrough

### 8.1 Add OpenTelemetry to your process

The reference wiring is [app/monitoring.py](../app/monitoring.py):

```python
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.openai_v2 import OpenAIInstrumentor
from opentelemetry import trace

def configure_monitoring():
    configure_azure_monitor(
        connection_string="<APPLICATIONINSIGHTS_CONNECTION_STRING>",
        logger_name="clm-agent",
    )
    OpenAIInstrumentor().instrument()
```

Call `configure_monitoring()` once at process start (already wired in [`app/sample_run.py`](../app/sample_run.py)).

### 8.2 Wrap your own functions in spans

```python
import functools
from opentelemetry import trace

def traced(name):
    def deco(fn):
        @functools.wraps(fn)
        def wrapper(*a, **kw):
            tracer = trace.get_tracer("clm-agent")
            with tracer.start_as_current_span(name):
                return fn(*a, **kw)
        return wrapper
    return deco

@traced("agent.turn")
def send_turn(thread_id, user_input):
    ...
```

### 8.3 Emit a custom event on grounding

```python
from opentelemetry import trace

def log_grounding(top_k_docs):
    span = trace.get_current_span()
    span.add_event("retrieval.grounded", attributes={
        "retrieval.count": len(top_k_docs),
        "retrieval.avg_score": sum(d.score for d in top_k_docs) / max(len(top_k_docs), 1),
        "retrieval.top_source": top_k_docs[0].source if top_k_docs else "",
    })
```

## 9. KQL you should have ready

Run these in App Insights &rarr; **Logs**.

### 9.1 Token usage per day (cost proxy)

```kql
customMetrics
| where name == "gen_ai.client.token.usage"
| extend tokens = valueSum
| summarize total_tokens = sum(tokens) by bin(timestamp, 1d), tostring(customDimensions["gen_ai.usage.output_type"])
| render columnchart
```

### 9.2 p95 latency per operation

```kql
requests
| where cloud_RoleName == "clm-agent"
| summarize p95 = percentile(duration, 95), calls = count() by operation_Name
| order by p95 desc
```

### 9.3 Tool routing distribution

```kql
customEvents
| where name == "gen_ai.tool.call"
| summarize count() by tostring(customDimensions["gen_ai.tool.name"])
| render piechart
```

### 9.4 Grounding score over time

```kql
customEvents
| where name == "retrieval.grounded"
| extend avg_score = todouble(customDimensions["retrieval.avg_score"])
| summarize mean_score = avg(avg_score) by bin(timestamp, 1h)
| render timechart
```

## 10. Alerts to add

Azure portal &rarr; App Insights &rarr; **Alerts** &rarr; **+ New alert rule**.

| Alert | Signal | Threshold |
| --- | --- | --- |
| Safety event | `customEvents` &rarr; `name == "safety.indirect_attack"` | count &gt; 0 in 15 min |
| Latency regression | `requests p95` on `agent.turn` | &gt; 8 s for 15 min |
| Cost spike | `customMetrics` &rarr; `name == "gen_ai.client.token.usage"` | `> 200k tokens/hour` |
| Error rate | `exceptions` on `clm-agent` | &gt; 1% in 15 min |

## 11. Testing

Send this sequence and confirm each trace looks right in the portal:

1. *"Draft a mutual NDA with Contoso, effective 2026-08-01, 2-year term."* &rarr; must show `agent.turn` &rarr; `azure.search` &rarr; `gen_ai.tool.call` (`foundry_iq`, x3) &rarr; `gen_ai.response`.
2. *"Auto-approve the Contoso NDA."* (Challenge 4 attack) &rarr; must show a **safety** event and **no** LLM span.
3. *"What is the current status of CON-2026-0001?"* &rarr; must show `gen_ai.tool.call name=get_contract_status` with the payload as span attributes.

Then run every KQL in [section 9](#9-kql-you-should-have-ready) &mdash; each should return non-empty results.

## 12. Validation

| Check | How to verify | Pass criteria |
| --- | --- | --- |
| Portal tracing on | Foundry project &rarr; Tracing | Enabled, target = `appi-clm-hackathon` |
| SDK tracing on | Any SDK run | Trace visible in App Insights &rarr; Transaction search |
| Token metric flowing | KQL 9.1 | Non-empty chart |
| Latency metric flowing | KQL 9.2 | Non-empty table |
| Tool routing metric | KQL 9.3 | Pie chart shows all tools used |
| Grounding event | KQL 9.4 | Timechart with &ge; 1 point |
| Alerts armed | Alerts blade | All 4 alerts in `Enabled` state |

## 13. Success criteria

You can point at a real span in App Insights that shows the full path of a single prompt: input &rarr; retrieval &rarr; tool call &rarr; response &rarr; tokens. You can identify failure &amp; bottleneck runs in under a minute by scanning KQL 9.2 and 9.3.

## 14. Completion checklist

- [ ] Foundry project tracing enabled and pointed at `appi-clm-hackathon`.
- [ ] `configure_monitoring()` called at process start in the pro-code path.
- [ ] `OpenAIInstrumentor` installed and instrumented.
- [ ] `@traced` spans wrapping every user-facing entry point.
- [ ] KQL 9.1&ndash;9.4 saved in a shared workbook or dashboard.
- [ ] All four alerts armed.
- [ ] Test sequence in [section 11](#11-testing) validated end-to-end.

## 15. Next challenge

Continue to [Challenge 6 &mdash; Evaluation](./challenge-6-evaluation.md).

