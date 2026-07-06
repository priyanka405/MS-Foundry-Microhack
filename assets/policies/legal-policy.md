# Legal Policy — Contracting Standards (Sample)

> **Policy ID:** `POL-LEGAL-CONTRACT-01`
> **Owner:** General Counsel's Office
> **Effective:** 2025-01-01
> **Last reviewed:** 2025-04-10

## 1. Purpose

This policy sets out the minimum legal standards that all contracts entered into on behalf of the Company must meet. It complements — and does not replace — the approved templates in `assets/templates/` and the clause library in `assets/clause-library/`.

## 2. Scope

Applies to every written commitment binding the Company, including:

- MSAs, SOWs, NDAs, DPAs, order forms, licenses.
- Amendments, addenda, and change requests to any of the above.
- Third-party paper (counterparty's template) marked-up for our signature.

Not covered by this policy: employment agreements (see People Ops policy), corporate transactional documents (M&A, financing).

## 3. Approved templates

- The Company drafts on **its own approved templates** whenever possible.
- Third-party paper is acceptable **only** if it meets the minimum standards in §4 and the deviation table in §5.
- Approved templates are versioned in the CLM repository. The **CLM Agent** is authorized to draft from the current approved version and no other.

## 4. Minimum legal standards

Every executed contract must include:

1. **Identified parties** with correct legal entity names and registered addresses.
2. **Effective date** and **term** (including renewal mechanics).
3. **Scope** — either directly or by reference to an SOW.
4. **Fees and payment terms** consistent with `clause-library/payment.md`.
5. **Confidentiality** protection at least as strong as the approved NDA.
6. **Data protection** — a DPA if personal data flows, aligned with GDPR/UK GDPR.
7. **Liability cap** consistent with `clause-library/liability.md`.
8. **Indemnity** consistent with `clause-library/indemnity.md`.
9. **Termination** rights consistent with `clause-library/termination.md`.
10. **Governing law and jurisdiction** — Irish law + Dublin courts unless General Counsel approves otherwise.
11. **Signatures** by an authorized signatory per the Company's Delegation of Authority.

## 5. Restricted clauses

These clauses may **not** be modified in a draft without explicit, written General Counsel approval attached to the contract record:

- Limitation of liability (§ CLL-LIAB-v2.0).
- Indemnification (§ CLL-INDEM-v2.1).
- Termination for cause and for convenience (§ CLL-TERM-v1.4).
- Payment terms (§ CLL-PAY-v1.3).

The **CLM Agent** must refuse to silently modify these clauses. It may:

- Show the counterparty's proposed language side-by-side with the approved language.
- Route the deviation for approval via the Logic App flow.
- Under **no circumstances** simply accept the counterparty's language without flagging.

## 6. High-risk deals

A deal is **high-risk** if any of the following apply — and must be routed to General Counsel before signature:

- Total contract value > **€2,000,000**.
- Counterparty is domiciled in a **sanctioned jurisdiction** (see Compliance policy §4).
- Contract transfers or processes personal data on a scale > **100,000 data subjects**.
- Term exceeds **five (5) years**.
- Deviates from any restricted clause in §5.

## 7. Contract record and audit

- Every executed contract is stored in the Contract Repository (see `assets/contract-register.md`) with `ContractID`, all metadata fields, and a link to the signed PDF.
- The **CLM Agent** must attach its risk score and any deviation flags to the record.
- Records are retained for **the term of the contract plus seven (7) years**.

## 8. Escalation

Questions about this policy → `legal.ops@contoso.com`. Suspected policy violations → `general.counsel@contoso.com`.
