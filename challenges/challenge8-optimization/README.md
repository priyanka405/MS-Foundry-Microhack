# Challenge 8 — Optimize the Agent

## Scenario

Evaluation revealed weak spots. Now improve the agent and prove it got better.

## Goal

Use your evaluation results to improve the agent's system prompt and tool configurations, then re-evaluate to confirm improvement.

## Instructions

1. Review the failure cases identified in Challenge 7.
2. Make targeted improvements:
   - Rewrite sections of the system prompt that led to poor responses
   - Improve tool descriptions to reduce tool-calling errors
   - Adjust knowledge source chunking if grounding was poor
3. Re-run the same evaluation dataset.
4. Compare scores before and after — document the delta.

## Learning Objectives

- Apply a structured improve-measure cycle
- Write better system prompts based on evidence
- Understand how small prompt changes affect agent quality

## Key Insight

```
Build → Evaluate → Optimize → Repeat
```

Optimisation is not a one-time step — it's a continuous loop throughout the agent lifecycle.
