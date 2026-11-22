# medicaid-pharmacy-spending-analysis
SQL analysis of 2024 North Carolina Medicaid pharmacy reimbursement and prescription utilization using public CMS data.

### Business Question 1: Highest-Spending Medications

**Objective:** Identify the medications contributing the most to total Medicaid reimbursement in North Carolina during 2024.

**SQL approach:** Used `SUM()`, `GROUP BY`, `ORDER BY`, and `LIMIT` to aggregate reimbursement amounts by drug name and identify the ten highest-spending medications.

**Finding:** The top ten medication and reimbursement amounts for 2024 were:

Humira, Ozempic, Biktarvy, Trikafta, Dupixent, Vyvanse, Stelara, Invega Sustenna, Vraylar, and Wegovy

**Business implication:** The analysis highlights medications that contribute significantly to pharmacy reimbursement and may warrant additional review of utilization patterns, reimbursement trends, and available cost-management strategies.
