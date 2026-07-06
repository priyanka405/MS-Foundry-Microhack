# Legal Policy · Contract Drafting Standards

> **Policy ID:** `POL-LEGAL-DRAFTING-2026.07`
> **Owner:** Office of the General Counsel
> **Version:** 2026.07
> **Applies to:** All contracts drafted, reviewed, or executed on behalf of the enterprise.

---

## 1. Purpose

Set the minimum legal drafting standards that every enterprise contract must meet. This policy governs template use, mandatory clauses, escalation, and delegated authority.

## 2. Template hierarchy

1. Approved templates in the Contract Templates library (`data/contract_templates/`) MUST be used whenever a matching type exists.
2. Bespoke drafts (no matching template) require prior review by the Contracts Center of Excellence (CCoE).
3. Counterparty templates ("paper the other way") are only permitted with express Legal approval.

## 3. Mandatory clauses (all long-form contracts)

Every MSA / SOW / vendor agreement MUST include:

- **Confidentiality** covering both Parties.
- **Data protection** clause referencing the DPA when personal data is processed.
- **Limitation of liability** — see the approved liability clause library.
- **Termination for convenience** — see the approved termination clause library.
- **Governing law and dispute resolution.**
- **Insurance requirements** (for services engagements).

## 4. Non-standard terms

Non-standard terms include (but are not limited to):

- Liability caps above 12 months of fees.
- Unlimited indemnification obligations.
- Non-standard governing law (i.e., not the enterprise's home jurisdiction).
- Auto-renewals longer than 12 months.
- Exclusivity clauses of any length.

Non-standard terms require **written Legal approval** and MUST be flagged in the contract summary and the intake record.

## 5. No legal advice

The Contract Intake &amp; Drafting Agent does **not** provide legal advice. Drafts must always be reviewed by a qualified Legal reviewer before signature.

## 6. Escalation

Escalate to Legal (`legal-approvers@<your-tenant>`) when:

- Any non-standard term is requested.
- The counterparty is on the restricted list (see `compliance_policy.md`).
- The contract value exceeds `[[ESCALATION_THRESHOLD_USD]]`.
- The contract involves regulated data (PII, PHI, PCI, government).

## 7. Records

All contracts and drafts must be stored in the enterprise contract repository (SharePoint / DMS) with:

- Counterparty legal name.
- Contract type + template ID + version.
- Effective date, term, and renewal date.
- Reviewer(s) and approver(s).
- Executed PDF with signatures.
