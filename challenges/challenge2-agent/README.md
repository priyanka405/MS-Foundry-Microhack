# Challenge 2 — Build Your First Agent

## Scenario

Create the baseline Employee Support Agent with a system prompt and basic instructions.

## Goal

Build an agent that can answer general employee questions using instructions — not just a raw chat completion.

## Instructions

1. In Foundry, create a new Agent.
2. Write a system prompt that:
   - Defines the agent's role (HR/IT support assistant)
   - Sets the tone (professional, helpful)
   - Lists what the agent can and cannot do
3. Test with at least 5 employee questions.
4. Observe how the agent behaves without grounding (it will hallucinate — that's expected here).

## Learning Objectives

- Understand the difference between an agent and a chat completion
- Learn how system instructions shape agent behaviour
- See the limitations of a model without grounding

## Key Insight

```
Prompt + Model ≠ Production Agent
```

An agent needs grounding, tools, memory, and guardrails — challenges 3–6 add those.
