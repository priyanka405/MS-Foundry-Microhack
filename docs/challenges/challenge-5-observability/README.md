# Challenge 5 — Observability

> **Goal:** Instrument the agent with **OpenTelemetry** and stream traces to **Application Insights** so you can see every model call, tool call, retrieval, and evaluation event.

**Foundry surface:** OpenTelemetry SDK + Application Insights (Azure Monitor)
**Estimated time:** 30–40 min
**Prerequisite:** Challenges 1–4.

---

## 🎯 Objective

Make the agent **legible**. You'll be able to answer these three questions from App Insights alone:

- *"How much did we spend on this agent today?"*
- *"Which turns had a hallucination (grounding score &lt; 3)?"*
- *"What's the p95 latency for a draft-and-route flow?"*

## 📋 Tasks

1. Create (or reuse) an **Application Insights** resource in the same RG.
2. Wire the app + agent to emit **OpenTelemetry** traces.
3. Verify traces appear in App Insights (transaction search + Logs).
4. Build three KQL queries: cost, latency, grounding.
5. Add one alert.

---

## 🖱️ Portal path

### 1. Provision App Insights

1. Azure portal → **+ Create** → **Application Insights**.
2. Name: `appi-clm-hackathon`, RG: `rg-clm-hackathon`.
3. Workspace-based (recommended).
4. Copy the **connection string** into `.env`:

```dotenv
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
```

### 2. Enable Foundry tracing

1. Foundry portal → **Project → Observability → Tracing** → **Enable**.
2. Point at the App Insights resource you just created.
3. Save.

Foundry now emits traces for every agent run, tool call, and evaluation event.

---

## 💻 SDK path

Wire the SDK to the same App Insights resource — this covers your app-side calls too.

```python
# app/monitoring.py — excerpt
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry import trace
from opentelemetry.instrumentation.openai_v2 import OpenAIInstrumentor
from app.config import settings

configure_azure_monitor(
    connection_string=settings.appinsights_connection_string,
    logger_name="clm-agent",
)
OpenAIInstrumentor().instrument()

tracer = trace.get_tracer("clm-agent")

def traced(name: str):
    def deco(fn):
        def wrapper(*a, **kw):
            with tracer.start_as_current_span(name):
                return fn(*a, **kw)
        return wrapper
    return deco
```

Then wrap the agent turn:

```python
from app.monitoring import traced

@traced("agent.turn")
def run_turn(user_input: str) -> str:
    ...
```

Run:

```bash
python -m app.sample_run --challenge 5
```

Traces should show up in App Insights within ~60 seconds.

---

## 📊 Three KQL queries you should keep

### Cost per day

```kusto
customMetrics
| where name in ("gen_ai.client.token.usage", "openai.tokens.total")
| summarize tokens = sum(value) by bin(timestamp, 1d)
| extend est_usd = tokens * 0.000010   // adjust to your model's price
| render columnchart
```

### p95 latency for the full flow

```kusto
requests
| where name == "agent.turn"
| summarize p50=percentile(duration, 50), p95=percentile(duration, 95) by bin(timestamp, 5m)
| render timechart
```

### Turns with a low grounding score

```kusto
customEvents
| where name == "evaluation.groundedness"
| extend score = todouble(customDimensions.score)
| where score &lt; 3.5
| project timestamp, thread_id=tostring(customDimensions.thread_id),
          score, prompt=tostring(customDimensions.prompt)
| top 100 by timestamp desc
```

## 🚨 One alert to add today

**Alert:** IndirectAttack defect fired in production traffic.

```kusto
customEvents
| where name == "safety.indirect_attack"
| where tostring(customDimensions.defect) == "true"
```

Alert rule → trigger when *count &gt; 0 in the last 5 minutes*. Notify the on-call channel.

## ✅ Success criteria

- [ ] App Insights `appi-clm-hackathon` receives traces from the agent.
- [ ] `agent.turn` requests are visible with duration + status.
- [ ] Token usage is visible in `customMetrics`.
- [ ] The three KQL queries return meaningful results after running a few turns.
- [ ] The IndirectAttack alert is armed.

## 🩹 Tips &amp; troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No traces in App Insights. | Wrong connection string. | Re-copy from App Insights → Overview; re-run. |
| Foundry-side traces missing but SDK-side present. | Foundry Tracing toggle off. | Enable in **Observability → Tracing**. |
| Cost query returns zero. | `openai-v2` instrumentation not installed. | `pip install opentelemetry-instrumentation-openai-v2`. |
| Latency looks wrong for tool calls. | Not wrapped in a span. | Add `@traced("tool.<name>")` to each tool function. |
| Duplicate spans. | `configure_azure_monitor` called twice. | Call once at process start. |

## 🌉 Next challenge

You can see what the agent is doing. Now measure whether it's **good**. In **[Challenge 6 — Evaluation](../challenge-6-evaluation/README.md)** you'll set a real deployment gate on groundedness, task adherence, and safety.
