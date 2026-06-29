# Challenge 5 — Add Memory

## Scenario

Every conversation starts from scratch. The agent keeps asking "what department are you in?" Fix it.

## Goal

Implement session memory and user memory so the agent personalizes responses based on stored context.

## Instructions

1. Implement **session memory**: the agent remembers context within a single conversation (e.g., the employee's name, department mentioned earlier in the chat).
2. Implement **user memory**: persist key preferences (department, role, preferred language) across sessions using Foundry memory store.
3. Test that the agent no longer re-asks for information it already knows.

## Learning Objectives

- Understand the difference between session and user memory
- Use Foundry's agent memory capabilities
- Implement personalization without hardcoding

## Key Insight

```
Memory = Personalization
```

Memory transforms a generic assistant into a personalized colleague.
