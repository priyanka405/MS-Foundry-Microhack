# Challenge 7 — Evaluate the Agent

## Scenario

Your agent seems good. But how good? You need evidence, not gut feeling.

## Goal

Build an evaluation dataset and measure the agent's groundedness and correctness.

## Instructions

1. Create (or use the provided) synthetic evaluation dataset in `starter-code/eval-dataset/`.
   - 20 question-answer pairs covering HR and IT topics
2. Run an evaluation using Foundry's evaluation service.
3. Review the groundedness, relevance, and coherence scores.
4. Identify the top 3 failure cases.

## Evaluation Metrics

| Metric | Description |
|--------|-------------|
| Groundedness | Is the answer supported by the knowledge base? |
| Relevance | Does the answer address the question? |
| Coherence | Is the answer clear and well-formed? |
| Correctness | Is the answer factually correct? |

## Learning Objectives

- Create and use evaluation datasets
- Run Foundry evaluations with rubric generation
- Interpret evaluation scores and identify improvement areas

## Key Insight

```
Don't trust. Measure.
```
