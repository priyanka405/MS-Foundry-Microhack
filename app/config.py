"""Central configuration for the Contract Intake & Drafting Agent.

Loads environment variables (from a `.env` file if present) and exposes a
single `settings` object other modules import.

The two helper dicts (`model_config`, `azure_ai_project`) are the shapes the
`azure-ai-evaluation` SDK expects.
"""
from __future__ import annotations

import os
from dataclasses import dataclass
from functools import lru_cache

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    project_connection_string: str
    model_deployment: str

    search_endpoint: str | None
    search_index: str
    search_api_key: str | None

    logic_app_approval_url: str | None
    function_app_endpoint: str | None

    appinsights_connection_string: str | None
    log_level: str


@lru_cache(maxsize=1)
def _load() -> Settings:
    return Settings(
        project_connection_string=os.environ["AZURE_AI_PROJECT_CONNECTION_STRING"],
        model_deployment=os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-4o"),
        search_endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
        search_index=os.getenv("AZURE_SEARCH_INDEX", "idx-clm-contracts"),
        search_api_key=os.getenv("AZURE_SEARCH_API_KEY"),
        logic_app_approval_url=os.getenv("LOGIC_APP_APPROVAL_URL"),
        function_app_endpoint=os.getenv("FUNCTION_APP_ENDPOINT"),
        appinsights_connection_string=os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING"),
        log_level=os.getenv("LOG_LEVEL", "INFO"),
    )


settings = _load()


# ---- Evaluation SDK shapes (used in app.evaluation) -----------------------

model_config = {
    "azure_endpoint": os.getenv("AZURE_OPENAI_ENDPOINT", ""),
    "azure_deployment": settings.model_deployment,
    "api_version": os.getenv("AZURE_OPENAI_API_VERSION", "2024-08-01-preview"),
}

azure_ai_project = {
    "subscription_id": os.getenv("AZURE_SUBSCRIPTION_ID", ""),
    "resource_group_name": os.getenv("AZURE_RESOURCE_GROUP", ""),
    "project_name": os.getenv("AZURE_AI_PROJECT_NAME", ""),
}
