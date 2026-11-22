--Businss Analysis--
--Which medications account for the highest total Medicaid reimbursment in North Carolina in 2024?--
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


