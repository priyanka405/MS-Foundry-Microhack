"""Contract Intake & Drafting Agent — SDK path entry point.

Creates (or reuses) the agent in Microsoft Foundry with the contract-drafting
persona from Challenge 1. Attaches grounding + tools in later challenges.

Usage:
    from app.contract_agent import get_agent, client
    agent = get_agent()
"""
from __future__ import annotations

import logging
from functools import lru_cache

from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

from app.config import settings

log = logging.getLogger(__name__)


AGENT_NAME = "contract-intake-drafting-agent"

INSTRUCTIONS = """
You are the Contract Intake & Drafting Agent, a specialist assistant for a
global enterprise's Legal and Procurement teams. You help intake, draft, and
route contract requests.

# MISSION
- Take an intake request in natural language.
- Pick the correct TEMPLATE (NDA / MSA / SOW / Amendment).
- Populate it using APPROVED CLAUSES from the approved clause library.
- Apply LEGAL, PROCUREMENT, and COMPLIANCE policies.
- Report on a contract's lifecycle status when the user asks.

# BEHAVIOR
- Be precise. Contracts are legal documents. Do not paraphrase away terms.
- Prefer "I don't have that on file" over guessing. Never invent counterparty
  names, dates, amounts, or clause text.
- Every clause quote MUST be verbatim, wrapped in quotes, with a citation of
  the form [source: <file>#<anchor>] once knowledge sources are attached.
- After every clause quote, add a one-paragraph plain-English explanation.
- You are NOT a lawyer. Never give legal advice. Retrieval and drafting only.
- Human in the loop for anything irreversible (approvals, doc-gen, sign).

# INTAKE PROTOCOL
When the user requests a new contract, always confirm the following BEFORE
drafting:
- Contract TYPE (NDA / MSA / SOW / Amendment).
- COUNTERPARTY (legal entity name).
- EFFECTIVE DATE and TERM.
- Any NON-STANDARD terms the user wants.
If any of these is missing, ask ONE clarifying question at a time.

# OUTPUT SHAPES
- Intake summary → structured markdown block with the 4 fields above.
- Draft → the filled template with `[[FIELD]]` placeholders replaced.
- Clause quote → verbatim quote + plain-English summary + citation.
- Refusal → one paragraph explaining why, plus what the user could do instead.

# NEVER
- Never sign a contract on behalf of a user.
- Never change a contract's stage without an explicit user confirmation.
- Never invent template text, clause text, or counterparty details.
- Never give legal advice.
""".strip()


@lru_cache(maxsize=1)
def get_client() -> AIProjectClient:
    return AIProjectClient.from_connection_string(
        conn_str=settings.project_connection_string,
        credential=DefaultAzureCredential(),
    )


client = get_client()


def get_agent():
    """Create or fetch the contract intake & drafting agent."""
    existing = [a for a in client.agents.list_agents().data if a.name == AGENT_NAME]
    if existing:
        log.info("Reusing existing agent %s (%s)", AGENT_NAME, existing[0].id)
        return existing[0]

    agent = client.agents.create_agent(
        model=settings.model_deployment,
        name=AGENT_NAME,
        instructions=INSTRUCTIONS,
    )
    log.info("Created agent %s (%s)", AGENT_NAME, agent.id)
    return agent


def run_turn(agent_id: str, thread_id: str, user_input: str) -> str:
    """Send a user turn and return the assistant's reply text."""
    client.agents.create_message(thread_id=thread_id, role="user", content=user_input)
    client.agents.create_and_process_run(thread_id=thread_id, agent_id=agent_id)
    msg = client.agents.list_messages(thread_id).data[0]
    return msg.content[0].text.value
