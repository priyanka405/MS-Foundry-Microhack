# Challenge 5 — Observability

## 1. Title & Duration

**Challenge 5 — Observability: If You Can't Observe It, You Can't Operate It**
⏱ **30 minutes**

## 2. Objective

Turn the agent into an **operable** system. By the end of this challenge you will:

- See every **agent trace** (thread → run → step → tool call → model call) in the Foundry portal.
- Stream the same traces to **Application Insights** as **OpenTelemetry** spans.
- Build a **live dashboard** for latency, error rate, and tool-call frequency.
- Configure an **alert** on p95 latency > 8 s.
- Query traces with **Kusto (KQL)** to answer real questions.

## 3. Context

Foundry's observability model = **Trace + Monitor + Evaluate**, layered on the OpenTelemetry standard:

| Layer | What it captures | Backing service |
| --- | --- | --- |
| **Trace** | Every run, tool call, retrieval, model call as OTel spans. | Foundry Tracing pane + App Insights |
| **Monitor** | Aggregate metrics: latency, tokens, errors, cost. | Azure Monitor (Log Analytics) |
| **Evaluate** | Quality/safety scores attached to traces. | Foundry Evaluators (Challenge 6) |

Because it is OpenTelemetry, **your own app code** (the web app you'll build in Challenge 8, or the Function App from Challenge 3) gets stitched into the same trace tree.

> **If you can't observe it, you can't operate it.**

## 4. Prerequisites

- [Challenge 4](../challenge4-guardrails/README.md) done — the agent has guardrails.
- App Insights `appi-clm-microhack` connected in Challenge 0.
- Tracing enabled on the project (verified in Challenge 0 step 8).

## 5. Agents & Tools used

| Component | Used |
| --- | --- |
| **Foundry Tracing** | ✅ |
| **OpenTelemetry Python / .NET SDK** | ✅ new |
| **Azure Monitor / Application Insights** | ✅ |
| **Log Analytics workspace** | ✅ |
| **Azure Dashboards + Alerts** | ✅ new |

---

## 6. 🟢 Low-Code Steps (Portal)

1. Open the project → left nav → **Tracing**.
2. Send a few varied prompts through the Playground (draft an NDA, run the value-at-risk analytics, upload a third-party file for File Search). Each becomes a **trace**.
3. Click any trace and inspect the **step tree**:
   - `agent.run` → `retrieval.azure_ai_search` → `model.chat.completions` → `tool.code_interpreter` → …
   - Note **latency per span**, **input/output tokens**, and **evaluator scores**.
4. Click **Open in Application Insights** on any span. Confirm the span appears in App Insights with the same `operation_id`.
5. Left nav → **Monitor** → **Dashboards** → **+ New dashboard**.
   - Add tiles:
     - **Requests per hour** (metric: `requests/count`, filter `cloud_RoleName == "agents"`).
     - **P95 end-to-end latency** (metric: `requests/duration`, percentile 95).
     - **Errors by kind** (KQL below).
     - **Top tools called** (KQL below).
6. Left nav → **Monitor** → **Alerts** → **+ Create alert rule**.
   - Signal: `requests/duration`, aggregation P95, threshold **> 8000 ms** over 5 min.
   - Action group: email `oncall@yourdomain.com`.
7. Run this KQL in the Log Analytics workspace query editor:

   ```kusto
   // Top tools called in the last 24h
   dependencies
   | where timestamp > ago(24h)
   | where cloud_RoleName == "agents"
   | where type == "InProc" and name startswith "tool."
   | summarize calls=count(), p95_ms=percentile(duration, 95) by tool=name
   | order by calls desc
   ```

   ```kusto
   // Errors by kind
   exceptions
   | where timestamp > ago(24h)
   | where cloud_RoleName == "agents"
   | summarize count() by problemId, outerType
   | order by count_ desc
   ```

## 7. 🔵 Pro-Code Steps (SDK / VS Code)

### 7.1 Python — enable OTel export to App Insights

```bash
pip install azure-monitor-opentelemetry \
            opentelemetry-sdk \
            opentelemetry-instrumentation-openai-v2 \
            azure-ai-projects
```

```python
# scripts/challenge5_trace.py
import os
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.openai_v2 import OpenAIInstrumentor
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

# 1. Configure OTel → App Insights (connection string comes from the Foundry project)
project = AIProjectClient(endpoint=os.environ["PROJECT_ENDPOINT"],
                          credential=DefaultAzureCredential())
appinsights_conn = project.telemetry.get_connection_string()
configure_azure_monitor(connection_string=appinsights_conn)

# 2. Auto-instrument OpenAI calls made by the SDK
OpenAIInstrumentor().instrument()

# 3. Now every agent run emits OTel spans with the same trace-id as your app
thread = project.agents.threads.create()
project.agents.messages.create(thread_id=thread.id, role="user",
                               content="Summarize our NDA template.")
run = project.agents.runs.create_and_process(
    thread_id=thread.id, agent_id=os.environ["AGENT_ID"])
print("run status:", run.status)
```

### 7.2 C#

```csharp
using Azure.Monitor.OpenTelemetry.AspNetCore;
using OpenTelemetry.Trace;

builder.Services.AddOpenTelemetry()
    .UseAzureMonitor(o => o.ConnectionString = Environment.GetEnvironmentVariable("APPINSIGHTS_CONNECTION_STRING"))
    .WithTracing(t => t.AddSource("Azure.AI.Agents.Persistent"));
```

### 7.3 Add custom attributes to spans

```python
from opentelemetry import trace
tracer = trace.get_tracer("clm.agent")

with tracer.start_as_current_span("clm.intake") as span:
    span.set_attribute("clm.vendor", "Contoso Retail")
    span.set_attribute("clm.contract_type", "NDA")
    span.set_attribute("clm.value_eur", 250_000)
    # ... call the agent ...
```

### 7.4 A KQL query you can rerun after every change

```kusto
// End-to-end latency and error rate per agent, last hour
dependencies
| where timestamp > ago(1h)
| where name == "agent.run"
| extend agent = tostring(customDimensions["agent.name"])
| summarize
    runs = count(),
    p50_ms = percentile(duration, 50),
    p95_ms = percentile(duration, 95),
    errors = countif(success == false)
  by agent
| extend error_rate = todouble(errors) / runs
```

## 8. Success Criteria

- [ ] Foundry **Tracing** pane shows step-level breakdown for every recent run.
- [ ] Traces appear in **Application Insights** with matching `operation_id`.
- [ ] Dashboard shows requests, P95 latency, top tools, and errors.
- [ ] Alert rule on P95 latency > 8 s is **Active**.
- [ ] (Pro-code) Custom span attributes (`clm.vendor`, `clm.contract_type`) show up in App Insights.

## 9. Next Steps

Observability tells you *what happened*. **Evaluation** tells you *whether it was any good*. In **Challenge 6** you build a test set, run Foundry's built-in evaluators, and gate progress on a **≥ 85% task-adherence** threshold.

➡ Continue to **[Challenge 6 — Evaluation](../challenge6-evaluation/README.md)**.

## 10. Key Takeaway

> If you can't observe it, you can't operate it. OpenTelemetry is the seam that lets Foundry and your app share one story.
