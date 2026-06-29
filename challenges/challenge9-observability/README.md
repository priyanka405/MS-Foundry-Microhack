# Challenge 9 — Observe Everything

## Scenario

The agent is in production. Something went wrong. You have no idea where.

## Goal

Configure distributed tracing, monitoring dashboards, and alerts so you can diagnose and operate the agent with confidence.

## Instructions

1. Enable **Azure Monitor** tracing for your Foundry agent.
2. Connect traces to **Application Insights**.
3. Create a dashboard that shows:
   - Request volume and latency (p50, p95)
   - Tool call success/failure rates
   - Content safety block rate
   - Evaluation score trends
4. Set an alert for p95 latency > 5 seconds.
5. Run a test conversation and verify it appears in traces end-to-end.

## Learning Objectives

- Configure distributed tracing for Foundry agents
- Build operational dashboards in Application Insights
- Set up proactive monitoring and alerting

## Key Insight

```
If you can't observe it, you can't operate it.
```
