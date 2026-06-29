# Challenge 4 — Give the Agent Tools

## Scenario

The agent can answer questions. Now make it *act*. An employee needs to open an IT ticket — without leaving the chat.

## Goal

Add a mock IT ticketing API as a tool so the agent can create tickets on behalf of employees.

## Instructions

1. Review the mock ticketing API in `starter-code/mock-api/`.
2. Register the API as an MCP Tool or Foundry Toolbox action.
3. Update your agent's system prompt to describe when to use the tool.
4. Test the end-to-end flow: employee asks → agent calls tool → ticket is created.

## Mock API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/tickets` | Create a new IT ticket |
| GET  | `/tickets/{id}` | Get ticket status |

## Learning Objectives

- Understand function calling and tool use in agents
- Configure MCP Tools and Foundry Toolbox
- Transition from assistant to action-taking agent

## Key Insight

```
Assistant → Agent
```

Tools are what turn a Q&A bot into a productive business agent.
