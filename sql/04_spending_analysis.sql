--Business Analysis--
--Question 1: Which medications account for the highest total Medicaid reimbursment in North Carolina in 2024?--
SELECT product_name,
ROUND(
	SUM(total_amount_reimbursed), 2)
	AS total_reimbursement,
	SUM(number_of_prescriptions)
	AS total_prescriptions
	FROM medicaid_nc_clean
WHERE year = 2024
AND suppression_used = 'false'
AND total_amount_reimbursed IS NOT NULL
AND product_name IS NOT NULL
GROUP BY product_name
ORDER BY total_reimbursement DESC
LIMIT 10;

-- Question 2: How did total Medicaid pharmacy reimbursement change from quarter to quarter in 2024?--
-- Calculate total reimbursment amount for 2024 medicaid claims and the number of prescriptions by quarter,  and sort  by quarter--

SELECT quarter,
ROUND(SUM(total_amount_reimbursed), 2)
AS total_reimbursement,
SUM(number_of_prescriptions)
AS total_prescriptions
FROM medicaid_nc_clean
WHERE year = 2024
AND total_amount_reimbursed IS NOT NULL
AND number_of_prescriptions IS NOT NULL
GROUP BY quarter
ORDER BY quarter;

--	Quarter over quarter analysis --
WITH quarterly_spending AS (
SELECT quarter,
SUM(total_amount_reimbursed)
AS total_reimbursement,
SUM(number_of_prescriptions)
AS total_prescriptions
FROM medicaid_nc_clean
WHERE year = 2024
AND total_amount_reimbursed IS NOT NULL
AND number_of_prescriptions IS NOT NULL
GROUP BY quarter
),
quarterly_comparison AS (
SELECT
quarter,
total_reimbursement, 
total_prescriptions,
LAG(total_reimbursement)
OVER (ORDER BY quarter)
AS previous_quarter_spend
FROM quarterly_spending)

SELECT quarter, 
ROUND (total_reimbursement, 2)
AS total_reimbursement,
total_prescriptions,
ROUND(
100.0*
(total_reimbursement-previous_quarter_spend)
/ nullif(previous_quarter_spend, 0),
2)
AS qoq_change_pct
FROM quarterly_comparison
ORDER BY quarter;


-- Question 3: Which medications have the highest average reimbursement prescription?--


