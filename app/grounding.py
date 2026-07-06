"""Grounding wiring for Challenge 2.

Attaches the Azure AI Search index (`idx-clm-contracts`) + File Search to the
agent so it can retrieve templates, approved clauses, and policies with
citations.
"""
from __future__ import annotations

import logging

from azure.ai.projects.models import AzureAISearchTool, FileSearchTool

from app.config import settings
from app.contract_agent import client, get_agent

log = logging.getLogger(__name__)


KNOWLEDGE_BLOCK = """
# KNOWLEDGE
You have TWO grounding sources:
1. `AzureAISearchTool` -> index `idx-clm-contracts` — the enterprise
   corpus of templates, approved clauses, and policies.
2. `FileSearch` — for documents attached by the user in this session.

# RETRIEVAL RULES
- Always ground factual claims about a template / clause / policy in a
  retrieved passage. Every clause quote MUST include an inline citation of
  the form [source: <file>#<anchor>].
- If the top-k results don't contain the answer, say so plainly.
- Prefer the APPROVED CLAUSE from the library over writing new clause text.
- Prefer FileSearch results over the repository when the user has attached
  a specific file to the thread.

# DRAFTING RULE
When drafting a contract:
- Start from a TEMPLATE (NDA / MSA / SOW).
- Fill placeholders (`[[COUNTERPARTY]]`, `[[EFFECTIVE_DATE]]`, `[[TERM]]`, ...).
- For each variable clause (payment / liability / termination), retrieve the
  APPROVED CLAUSE and insert it verbatim with a citation.
- If the user requests a NON-STANDARD term, flag it in a "⚠️ Non-standard"
  section at the top of the draft and cite the applicable policy.
""".strip()


def attach_grounding(search_connection_id: str, index_name: str | None = None):
    """Attach AzureAISearchTool + FileSearchTool to the agent."""
    agent = get_agent()
    index = index_name or settings.search_index

    search_tool = AzureAISearchTool(
        index_connection_id=search_connection_id,
        index_name=index,
        top_k=5,
    )
    file_tool = FileSearchTool()

    new_instructions = agent.instructions
    if "# KNOWLEDGE" not in new_instructions:
        new_instructions = new_instructions.rstrip() + "\n\n" + KNOWLEDGE_BLOCK

    updated = client.agents.update_agent(
        agent_id=agent.id,
        instructions=new_instructions,
        tools=[search_tool.definitions[0], file_tool.definitions[0]],
        tool_resources={**search_tool.resources, **file_tool.resources},
    )
    log.info("Attached grounding to agent %s (index=%s)", updated.id, index)
    return updated
