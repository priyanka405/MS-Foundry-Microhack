# Challenge 3 — Ground the Agent

## Scenario

Your agent is hallucinating answers about company policies. Fix it.

## Goal

Connect the agent to a grounded enterprise knowledge base using Foundry IQ.

## Instructions

1. Upload the synthetic HR and IT documents (provided in `starter-code/documents/`) to your Azure AI Search index.
2. In Foundry, attach the search index to your agent as a knowledge source.
3. Re-run your 5 test questions and compare answers with and without grounding.
4. Verify that answers include citations from the documents.

## Synthetic Documents Provided

- `hr-vacation-policy.md`
- `hr-expense-policy.md`
- `it-password-reset.md`
- `it-travel-policy.md`

## Learning Objectives

- Understand Retrieval-Augmented Generation (RAG)
- Use Foundry IQ for enterprise knowledge grounding
- See how grounding eliminates hallucinations

## Key Insight

```
Model + Knowledge = Reliable Agent
```
