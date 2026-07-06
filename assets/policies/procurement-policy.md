# Procurement Policy — Vendor Contracting (Sample)

> **Policy ID:** `POL-PROC-VENDOR-02`
> **Owner:** Head of Procurement
> **Effective:** 2025-01-01
> **Last reviewed:** 2025-04-10

## 1. Purpose

To make sure every euro the Company spends with a supplier goes through a repeatable process: correct sourcing, correct paper, correct approvals.

## 2. Scope

All external spend > **€10,000** annualized, all software subscriptions regardless of value, and all engagements that involve access to Company data or systems.

## 3. Authorized paper

- MSA + SOW is the **default** paper for services engagements (see `templates/MSA.md`, `templates/SOW.md`).
- Order forms are acceptable for productized SaaS below **€100,000** annualized.
- Third-party paper requires Procurement + Legal review; the CLM Agent must flag any third-party paper it receives.

## 4. Approval matrix

| Total contract value (€, over life) | Business Owner | Function Head | CFO Office | General Counsel | Board |
| --- | --- | --- | --- | --- | --- |
| ≤ 50,000 | ✅ | — | — | Only if restricted clauses | — |
| 50,001 – 250,000 | ✅ | ✅ | — | Only if restricted clauses | — |
| 250,001 – 1,000,000 | ✅ | ✅ | ✅ | ✅ | — |
| 1,000,001 – 5,000,000 | ✅ | ✅ | ✅ | ✅ | Notify |
| > 5,000,000 | ✅ | ✅ | ✅ | ✅ | ✅ |

The **CLM Agent** must not send a contract for signature until every required approval in this matrix is recorded against the `ContractID`.

## 5. Sourcing

- ≥ **3 comparable quotes** for services engagements above €50,000, unless a documented sole-source justification is on file.
- **Preferred-supplier list** is maintained in the CMDB and consumed via MCP (see `assets/TOOLS.md#6-mcp-tools-bonus`).
- **Supplier onboarding** — every new supplier must complete due diligence (financial health, security, ESG) before signature. The CLM Agent must not draft a contract for a supplier not present in the onboarding system.

## 6. Payment and commercial terms

- Default payment terms: **net 30** (see `clause-library/payment.md`).
- Prepayments above **20%** of contract value require CFO Office approval.
- Multi-year discounts must be captured in the SOW and reflected in the register's `Value€`.
- Contracts must be denominated in **EUR** unless the Business Owner obtains FX-risk approval from Treasury.

## 7. Renewals and expirations

- Renewal reminders fire at **T-120, T-90, T-60, T-30** days before `RenewalDate`.
- The **CLM Agent** owns the reminder cadence (Logic App from Challenge 3).
- No auto-renewal is permitted for contracts > **€500,000** without an explicit review workflow.

## 8. Prohibited practices

- Signing a contract not represented in the Contract Register.
- Splitting a spend into multiple smaller contracts to avoid the approval matrix.
- Verbal amendments — every change is a written amendment.
- Storing signed contracts anywhere other than the Contract Repository.

## 9. Metrics owned by Procurement

Procurement reviews the following monthly, using the register and the Foundry evaluators:

- Contract cycle time (target: **≤ 10 business days** for standard MSA + SOW).
- % of contracts on approved paper (target: **≥ 85%**).
- % of high-risk deals routed to GC before signature (target: **100%**).
- Aggregate renewal value at risk in next 90 days (visibility metric).

## 10. Escalation

- Questions → `procurement.ops@contoso.com`.
- Suspected policy violations → `internal.audit@contoso.com`.
