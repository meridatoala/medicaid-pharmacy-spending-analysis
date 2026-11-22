# medicaid-pharmacy-spending-analysis
SQL analysis of 2024 North Carolina Medicaid pharmacy reimbursement and prescription utilization using public CMS data.

### Business Question 1: Highest-Spending Medications

**Objective:** Identify the medications contributing the most to total Medicaid reimbursement in North Carolina during 2024.

**SQL approach:** Used `SUM()`, `GROUP BY`, `ORDER BY`, and `LIMIT` to aggregate reimbursement amounts by drug name and identify the ten highest-spending medications.

**Finding:** The top ten medication and reimbursement amounts for 2024 were:

Humira - $163,071,598.01

Ozempic - $124,585,185.41

Biktarvy - $111,813,361.77

Trikafta - $83,856,368.11

Dupixent - $81,820,263.67

Vyvanse - $68,550,012.68

Stelara - $61,607,303.42

Invega Sustenna - $57,433,895.58

Vraylar - $55,939,553.16

Wegovy - $46,455,765.00
 

**Business implication:** The analysis highlights medications that contribute significantly to pharmacy reimbursement and may warrant additional review of utilization patterns, reimbursement trends, and available cost-management strategies.


