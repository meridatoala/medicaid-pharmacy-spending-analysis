--Validate cleaned dataset--

SELECT COUNT(*) AS total_records
FROM medicaid_nc_clean;

--reporting periods--

SELECT
    year,
    quarter,
    COUNT(*) AS record_count
FROM medicaid_nc_clean
GROUP BY year, quarter
ORDER BY year, quarter;

--missing and suppressed financial information--

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE total_amount_reimbursed IS NULL
    ) AS missing_reimbursement,

    COUNT(*) FILTER (
        WHERE number_of_prescriptions IS NULL
    ) AS missing_prescriptions,

    COUNT(*) FILTER (
        WHERE suppression_used = 'true'
    ) AS suppressed_records

FROM medicaid_nc_clean;
