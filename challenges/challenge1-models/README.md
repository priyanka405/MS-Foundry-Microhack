# Challenge 1 — Model Choice Matters

## Scenario

Your employee support agent needs to answer questions. But which model should it use?

## Goal

Compare two models on the same support Q&A tasks and choose the best one for your use case.

## Instructions

1. In your Foundry project, deploy:
   - `gpt-4o` (or equivalent)
   - A small/efficient model (e.g., `gpt-4o-mini`)
2. Send the same 10 employee questions to both models.
3. Record latency, cost per query, and answer quality.
4. Document your decision.

## Sample Questions

- "How do I request vacation days?"
- "Where is the travel policy document?"
- "Who approves my expense report?"

## Learning Objectives

- Understand model selection tradeoffs: quality vs. cost vs. speed
- Use the Foundry model catalog
- Apply basic benchmarking methodology

## Key Insight

```
Prompt + Model ≠ Production Agent
```

The right model is a prerequisite for everything that follows.
