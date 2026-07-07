"""Function tools for the Contract Intake & Drafting Agent (Challenge 3).

These are the Python-side representations of the tools the agent will call.
They mirror the five canonical Contract Lifecycle Management tools:

- clause_lookup       -> read approved clause text from the clause library
                         (used by the Clause Analysis Tool alongside the model)
- generate_document   -> Power Automate flow producing a filled document
- route_approval      -> Power Automate approval flow (Approval Routing Tool)
- contract_status     -> Dataverse / Azure SQL read+write (Contract Status Tool)

Also includes the app-layer approval-bypass blocklist (Challenge 4).
"""
from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from typing import Literal

import requests

from app.config import settings


# ---------------------------------------------------------------------------
# Tool: clause_lookup
# ---------------------------------------------------------------------------

ClauseCategory = Literal["payment", "liability", "termination"]

_APPROVED_CLAUSES: dict[str, tuple[str, str]] = {
    "payment": (
        "data/approved_clauses/payment_terms.md",
        "2026.07",
    ),
    "liability": (
        "data/approved_clauses/liability_clause.md",
        "2026.07",
    ),
    "termination": (
        "data/approved_clauses/termination_clause.md",
        "2026.07",
    ),
}


def clause_lookup(category: ClauseCategory) -> str:
    """Return the approved clause text and version for a given category.

    Valid categories: payment, liability, termination. Raises ValueError for
    unknown categories so the agent surfaces the error to the user.
    """
    key = category.lower().strip()
    if key not in _APPROVED_CLAUSES:
        raise ValueError(
            f"Unknown clause category '{category}'. "
            f"Valid: {sorted(_APPROVED_CLAUSES)}"
        )
    path, version = _APPROVED_CLAUSES[key]
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    return json.dumps({"category": key, "clause": text, "version": version, "source": path})


# ---------------------------------------------------------------------------
# Tool: generate_document
# ---------------------------------------------------------------------------

def generate_document(
    template: Literal["NDA", "MSA", "SOW", "Amendment"],
    counterparty: str,
    effective_date: str,
    term: str,
    clauses: list[str] | None = None,
) -> str:
    """Fill a template with fields + clauses and return the doc URI.

    Delegates to the Power Automate flow set as FUNCTION_APP_ENDPOINT / a
    dedicated URL. In local dev, returns a stubbed URI.
    """
    payload = {
        "template": template,
        "counterparty": counterparty,
        "effective_date": effective_date,
        "term": term,
        "clauses": clauses or [],
    }
    if not settings.function_app_endpoint:
        stub = f"local://drafts/{template.lower()}-{counterparty.lower()}-{effective_date}.md"
        return json.dumps({"doc_uri": stub, "template": template, "stubbed": True})
    resp = requests.post(
        f"{settings.function_app_endpoint}/api/generate_document",
        json=payload,
        timeout=30,
    )
    resp.raise_for_status()
    return json.dumps(resp.json())


# ---------------------------------------------------------------------------
# Tool: route_approval
# ---------------------------------------------------------------------------

def route_approval(
    subject: str,
    requester: str,
    counterparty: str,
    doc_uri: str,
    risk_band: Literal["Low", "Medium", "High"] = "Medium",
) -> str:
    """Send an approval request to Legal / Procurement via a Power Automate flow.

    Returns a JSON string with the approval id and initial status. The final
    decision arrives asynchronously via a callback the agent handles later.
    """
    if not settings.power_automate_approval_url:
        return json.dumps(
            {"approval_id": "local-1", "status": "pending", "stubbed": True}
        )
    payload = {
        "subject": subject,
        "requester": requester,
        "counterparty": counterparty,
        "doc_uri": doc_uri,
        "risk_band": risk_band,
    }
    resp = requests.post(settings.power_automate_approval_url, json=payload, timeout=30)
    resp.raise_for_status()
    return json.dumps(resp.json())


# ---------------------------------------------------------------------------
# Tool: contract_status
# ---------------------------------------------------------------------------

_VALID_STATES = {
    "Draft",
    "In Review",
    "Approved",
    "Signed",
    "Active",
    "Expired",
    "Terminated",
}


def contract_status(contract_id: str, new_state: str | None = None) -> str:
    """Read or update the lifecycle state of a contract.

    In production this reads/writes to Dataverse / SQL / a SharePoint list.
    Here it's a pure function so it's testable and demo-safe.
    """
    if new_state is not None and new_state not in _VALID_STATES:
        raise ValueError(
            f"Invalid state '{new_state}'. Valid: {sorted(_VALID_STATES)}"
        )
    return json.dumps(
        {
            "contract_id": contract_id,
            "state": new_state or "Active",
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }
    )


# ---------------------------------------------------------------------------
# App-layer approval-bypass blocklist (Challenge 4)
# ---------------------------------------------------------------------------

APPROVAL_BYPASS = re.compile(
    r"(?i)\b(?:auto[- ]?approve|bypass\s+approval|skip\s+legal\s+review|"
    r"approve\s+without\s+review|force\s+sign|self[- ]?sign)\b"
)


def screen_input(user_input: str) -> str | None:
    """Return an error message if the input violates the app-layer blocklist."""
    if APPROVAL_BYPASS.search(user_input):
        return "That request looks like an approval-bypass attempt and won't be processed."
    return None
