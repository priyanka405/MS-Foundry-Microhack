"""Function tools for the Contract Intake & Drafting Agent (Challenge 3).

These are the Python-side representations of the three canonical Contract
Lifecycle Management tools:

- foundry_iq_search       -> Foundry IQ (Azure AI Search + SharePoint):
                             contract search, document grounding, knowledge.
- web_research            -> WebIQ (Bing Search): external research, market
                             intelligence, regulatory context.
- get_contract_status /   -> Azure SQL: structured contract data lookup and
  update_contract_status     lifecycle state read/write.

Also includes:

- clause_lookup           -> a small helper the agent instructions use when
                             quoting an approved clause verbatim (backed by
                             Foundry IQ retrieval in production).
- generate_document       -> local template-filling stub used by the drafting
                             pipeline.
- screen_input            -> app-layer write-action blocklist (Challenge 4).
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

    Delegates to a `FUNCTION_APP_ENDPOINT` HTTP endpoint if configured, or
    returns a stubbed local URI for demos.
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
# Tool: foundry_iq_search  (Foundry IQ - Azure AI Search + SharePoint)
# ---------------------------------------------------------------------------

def foundry_iq_search(
    query: str,
    source: Literal["corpus", "sharepoint", "auto"] = "auto",
    top_k: int = 5,
) -> str:
    """Search the internal knowledge surface (Azure AI Search + SharePoint).

    Returns a JSON string with hit metadata. In production this is wired to
    `AzureAISearchTool` + the SharePoint Foundry connector; the stub below
    lets the demo run without those connections.
    """
    return json.dumps(
        {
            "query": query,
            "source": source,
            "top_k": top_k,
            "hits": [],
            "stubbed": True,
            "note": "Wire to AzureAISearchTool + SharePoint via Foundry IQ.",
        }
    )


# ---------------------------------------------------------------------------
# Tool: web_research  (WebIQ - Bing Search)
# ---------------------------------------------------------------------------

def web_research(query: str, count: int = 5, market: str = "en-US") -> str:
    """Run an external research query via WebIQ (Bing Search).

    Returns a JSON string with a list of `{title, url, snippet}` results.
    Falls back to a stubbed response if `BING_SEARCH_ENDPOINT` is unset.
    """
    if not settings.bing_search_endpoint or not settings.bing_search_key:
        return json.dumps(
            {
                "query": query,
                "results": [],
                "stubbed": True,
                "note": "Set BING_SEARCH_ENDPOINT and BING_SEARCH_KEY to enable WebIQ.",
            }
        )
    resp = requests.get(
        f"{settings.bing_search_endpoint.rstrip('/')}/v7.0/search",
        params={"q": query, "count": count, "mkt": market, "safeSearch": "Moderate"},
        headers={"Ocp-Apim-Subscription-Key": settings.bing_search_key},
        timeout=30,
    )
    resp.raise_for_status()
    web = resp.json().get("webPages", {}).get("value", [])
    return json.dumps(
        {
            "query": query,
            "results": [
                {"title": h.get("name"), "url": h.get("url"), "snippet": h.get("snippet")}
                for h in web
            ],
        }
    )


# ---------------------------------------------------------------------------
# Tool: get_contract_status / update_contract_status  (Azure SQL)
# ---------------------------------------------------------------------------

_VALID_STATES = {
    "Draft",
    "In Review",
    "Signed",
    "Active",
    "Expired",
    "Terminated",
}


def get_contract_status(contract_id: str) -> str:
    """Read the lifecycle state of a contract from Azure SQL.

    In production this reads `clm_contracts` in Azure SQL. Here it returns a
    stubbed row so the demo runs without a live database.
    """
    return json.dumps(
        {
            "contract_id": contract_id,
            "stage": "Active",
            "owner": "legal@contoso.com",
            "renewal_date": "2026-08-01",
            "expiry": "2027-08-01",
            "risk_band": "Medium",
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "stubbed": not bool(settings.azure_sql_connection_string),
        }
    )


def update_contract_status(contract_id: str, new_stage: str) -> str:
    """Update the `stage` column for a contract in Azure SQL.

    Raises ValueError for an unknown stage so the agent surfaces it clearly.
    """
    if new_stage not in _VALID_STATES:
        raise ValueError(
            f"Invalid stage '{new_stage}'. Valid: {sorted(_VALID_STATES)}"
        )
    return json.dumps(
        {
            "contract_id": contract_id,
            "stage": new_stage,
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "stubbed": not bool(settings.azure_sql_connection_string),
        }
    )


# ---------------------------------------------------------------------------
# App-layer write-action blocklist (Challenge 4)
# ---------------------------------------------------------------------------

WRITE_BYPASS = re.compile(
    r"(?i)\b(?:auto[- ]?approve|bypass\s+approval|skip\s+legal\s+review|"
    r"approve\s+without\s+review|force\s+sign|self[- ]?sign)\b"
)


def screen_input(user_input: str) -> str | None:
    """Return an error message if the input violates the app-layer blocklist."""
    if WRITE_BYPASS.search(user_input):
        return "That request looks like an unauthorized write-bypass attempt and won't be processed."
    return None
