# Contract Register — Schema & Sample Data

The **Contract Register** is the structured spine of the CLM system. It is the sheet Legal, Procurement, and Finance already keep — usually in Excel — and it is the perfect input for **Code Interpreter** analytics (Challenge 3) and evaluators over structured data.

## Schema

| Column | Type | Description | Example |
| --- | --- | --- | --- |
| `ContractID` | string (PK) | Unique identifier, `CT-` prefix. | `CT-2025-0184` |
| `Vendor` | string | Counterparty legal name. | `Contoso Retail Ltd.` |
| `Type` | enum | `NDA` / `MSA` / `SOW` / `DPA` / `Renewal`. | `MSA` |
| `Value€` | number | Total contract value in EUR. | `1250000` |
| `Start` | date (ISO) | Effective date. | `2024-04-01` |
| `End` | date (ISO) | Termination date. | `2027-03-31` |
| `RenewalDate` | date (ISO) | Next renewal / opt-out date. | `2026-12-31` |
| `Owner` | string | Internal business owner (email or "Function / Person"). | `priya.shah@contoso.com` |
| `Status` | enum | `Draft` / `InReview` / `Approved` / `Signed` / `Active` / `Expiring` / `Terminated`. | `Active` |
| `RiskScore` | int (0–100) | Output of the risk-scoring Function (Challenge 3). | `42` |

## Sample rows (25 contracts)

Copy the block below into Excel as **CSV** or into any tabular editor. It is also valid Markdown for the **Data + indexes** upload step in Challenge 0.

```csv
ContractID,Vendor,Type,Value€,Start,End,RenewalDate,Owner,Status,RiskScore
CT-2024-0091,Fabrikam GmbH,MSA,850000,2023-01-15,2026-01-14,2025-10-15,priya.shah@contoso.com,Active,38
CT-2024-0102,Contoso Retail Ltd,NDA,0,2024-03-01,2026-02-28,2026-01-28,legal.ops@contoso.com,Active,10
CT-2024-0117,Northwind Traders,MSA,2100000,2023-07-01,2026-06-30,2026-03-30,sales.ops@contoso.com,Active,55
CT-2024-0128,AdventureWorks,SOW,450000,2024-01-10,2025-01-09,2024-11-09,delivery@contoso.com,Expiring,62
CT-2024-0144,Wingtip Logistics,MSA,3200000,2022-09-01,2025-08-31,2025-06-30,ops@contoso.com,Expiring,71
CT-2024-0161,Woodgrove Bank,DPA,0,2024-05-01,2027-04-30,2027-01-30,privacy@contoso.com,Active,25
CT-2024-0184,Contoso Retail Ltd,MSA,1250000,2024-04-01,2027-03-31,2026-12-31,priya.shah@contoso.com,Active,42
CT-2024-0192,Litware Inc,NDA,0,2024-06-15,2025-06-14,2025-05-14,rd@contoso.com,Active,15
CT-2024-0207,Proseware Ltd,SOW,780000,2024-02-01,2025-01-31,2024-12-31,delivery@contoso.com,Expiring,58
CT-2024-0221,Tailspin Toys,MSA,1900000,2023-11-01,2026-10-31,2026-07-31,retail@contoso.com,Active,49
CT-2024-0233,Fabrikam GmbH,SOW,320000,2024-08-01,2025-07-31,2025-05-31,ops@contoso.com,Active,33
CT-2024-0245,Contoso Consulting,MSA,4200000,2023-04-01,2026-03-31,2025-12-31,cfo.office@contoso.com,Active,67
CT-2024-0259,Northwind Traders,DPA,0,2023-08-01,2026-07-31,2026-04-30,privacy@contoso.com,Active,20
CT-2024-0271,Trey Research,SOW,215000,2024-09-15,2025-09-14,2025-07-14,rd@contoso.com,Active,29
CT-2024-0284,Wingtip Logistics,Renewal,3200000,2025-09-01,2028-08-31,2028-05-31,ops@contoso.com,Draft,71
CT-2024-0299,Lucerne Publishing,NDA,0,2024-10-01,2026-09-30,2026-06-30,marketing@contoso.com,Active,12
CT-2024-0311,Blue Yonder Airlines,MSA,5600000,2022-12-01,2025-11-30,2025-08-31,travel@contoso.com,Expiring,78
CT-2024-0323,AdventureWorks,Renewal,450000,2025-01-15,2027-01-14,2026-10-14,delivery@contoso.com,Draft,62
CT-2024-0334,Graphic Design Co,SOW,95000,2024-07-01,2025-06-30,2025-04-30,marketing@contoso.com,Expiring,22
CT-2024-0348,Alpine Ski House,MSA,180000,2024-05-15,2026-05-14,2026-02-14,retail@contoso.com,Active,31
CT-2024-0356,Coho Vineyard,NDA,0,2024-11-01,2025-10-31,2025-08-31,marketing@contoso.com,Active,11
CT-2024-0367,Fourth Coffee,SOW,540000,2024-03-15,2025-03-14,2025-01-14,delivery@contoso.com,Expiring,44
CT-2024-0378,Humongous Insurance,MSA,7800000,2023-02-01,2026-01-31,2025-10-31,cfo.office@contoso.com,Expiring,82
CT-2024-0389,VanArsdel Ltd,DPA,0,2024-12-01,2027-11-30,2027-08-31,privacy@contoso.com,Active,18
CT-2024-0392,School of Fine Art,SOW,60000,2024-10-15,2025-10-14,2025-07-14,marketing@contoso.com,Active,26
```

## How to use

- **Challenge 2 (Grounding)** — this file is **not** for the grounding index; it is for structured analytics.
- **Challenge 3 (Tools & Actions)** — upload as a **Code Interpreter** file. Ask the agent:
  - *"Chart total value-at-risk of contracts renewing in the next 90 days, grouped by vendor."*
  - *"How many MSAs expire in Q2 2025, and what is their combined €?"*
  - *"Plot risk score distribution by contract type."*
- **Challenge 6 (Evaluation)** — several test-set entries reference specific `ContractID` values from above, so this file is part of the eval fixtures.
