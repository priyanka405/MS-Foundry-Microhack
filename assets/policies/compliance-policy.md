# Compliance Policy — Contract Compliance & Controls (Sample)

> **Policy ID:** `POL-COMP-CONTRACT-03`
> **Owner:** Chief Compliance Officer
> **Effective:** 2025-01-01
> **Last reviewed:** 2025-04-10

## 1. Purpose

Define the compliance controls every contract — and every AI-assisted drafting workflow — must observe.

## 2. Regulatory scope

The Company is directly or indirectly subject to:

- **GDPR / UK GDPR** — personal data protection.
- **DORA** — operational resilience for financial-services customers.
- **NIS2** — cybersecurity obligations for essential and important entities.
- **EU AI Act** — obligations on providers and deployers of AI systems.
- **US SOX** — internal controls over financial reporting.
- **UK Bribery Act / FCPA** — anti-bribery and corruption.
- Sanctions regimes (EU, UK, US OFAC).

Contracts must be compatible with all of the above; the CLM Agent's outputs must not create obligations that violate any of them.

## 3. Personal data (GDPR / UK GDPR)

- A **Data Processing Addendum** (DPA) is mandatory whenever a Supplier processes personal data on the Company's behalf.
- International transfers require **SCCs** (EU) or **IDTA** (UK) plus a transfer risk assessment.
- The **CLM Agent** must flag any contract that involves personal data and does not have a DPA attached.

## 4. Sanctions and export controls

- No contract may be entered into with a party domiciled in, or majority-owned by parties from, a sanctioned jurisdiction.
- Current high-risk list (illustrative for this hack): **RU, BY, IR, KP, CN (dual-use technologies)**, plus SDN-listed entities.
- The **risk-scoring Azure Function** (Challenge 3) adds **+20 points** for high-risk jurisdictions and the agent must refuse to proceed without a Compliance override.

## 5. Anti-bribery and corruption (ABC)

- Contracts must include a compliance-with-laws clause referencing UK Bribery Act, FCPA, and local equivalents.
- Contracts with public-sector counterparties require additional ABC representations and warranties.
- Facilitation payments, kickbacks, and "success fees" not disclosed to Compliance are prohibited.

## 6. AI-specific controls (EU AI Act alignment)

Because the CLM system itself is an AI system deployed inside the Company:

- **Human oversight** — the agent must not sign, only draft and route. Signature remains a human step.
- **Transparency** — outputs to counterparties must disclose that AI was used in drafting when required by local law.
- **Data governance** — training/tuning data (evaluations, feedback) is stored in the Company tenant only.
- **Logging** — every agent decision is traceable (Challenge 5).
- **Robustness** — restricted clauses (§ Legal Policy §5) may not be modified silently.
- **Accuracy** — the ≥ 85% task-adherence gate (Challenge 6) is the deployment threshold.

## 7. Financial-reporting controls (SOX)

- Contracts materially affecting revenue recognition (multi-year, milestone-based, or with variable consideration) must be reviewed by Financial Controllership before signature.
- The `Value€` field in the register must reconcile to the Order Management System.

## 8. Records retention

- Signed contracts and their metadata: **term + 7 years**.
- Chat transcripts of agent runs: **12 months** (unless attached to a specific dispute — then legal-hold).
- Evaluation results: **24 months**, retained with the agent version they applied to.

## 9. Reporting

Compliance reviews the following monthly:

- Number of contracts requiring Compliance override (jurisdiction, PII, restricted clause).
- % of contracts with a required DPA that actually have one attached.
- Number of prompt-injection detections from Prompt Shields (Challenge 4).
- Number of runs blocked by content-safety filters.

## 10. Escalation

- Questions → `compliance@contoso.com`.
- Suspected violations → `ethics.hotline@contoso.com` (anonymous).
