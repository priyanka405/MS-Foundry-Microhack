"""OpenTelemetry wiring for Challenge 5.

`configure_monitoring()` should be called once at process start. After that,
use `traced("name")` as a decorator around any function you want as a span.
"""
from __future__ import annotations

import functools
import logging
from typing import Callable

try:
    from azure.monitor.opentelemetry import configure_azure_monitor
    from opentelemetry import trace
except ImportError:  # pragma: no cover
    configure_azure_monitor = None  # type: ignore
    trace = None  # type: ignore

from app.config import settings

log = logging.getLogger(__name__)

_CONFIGURED = False


def configure_monitoring(force: bool = False) -> None:
    """Wire OpenTelemetry to Application Insights (idempotent)."""
    global _CONFIGURED
    if _CONFIGURED and not force:
        return
    if configure_azure_monitor is None:
        log.warning(
            "azure-monitor-opentelemetry not installed; skipping observability wiring."
        )
        return
    if not settings.appinsights_connection_string:
        log.warning(
            "APPLICATIONINSIGHTS_CONNECTION_STRING not set; skipping observability wiring."
        )
        return
    configure_azure_monitor(
        connection_string=settings.appinsights_connection_string,
        logger_name="clm-agent",
    )
    try:
        from opentelemetry.instrumentation.openai_v2 import OpenAIInstrumentor
        OpenAIInstrumentor().instrument()
    except ImportError:
        log.info("openai-v2 instrumentation not installed; token metrics may be missing.")
    _CONFIGURED = True
    log.info("OpenTelemetry -> Application Insights configured.")


def traced(name: str) -> Callable:
    """Decorator: wrap a function in an OTel span."""
    def deco(fn: Callable) -> Callable:
        @functools.wraps(fn)
        def wrapper(*a, **kw):
            if trace is None:
                return fn(*a, **kw)
            tracer = trace.get_tracer("clm-agent")
            with tracer.start_as_current_span(name):
                return fn(*a, **kw)
        return wrapper
    return deco
