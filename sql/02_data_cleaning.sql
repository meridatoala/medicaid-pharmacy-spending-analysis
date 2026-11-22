--Filter Data to North Carolina --
CREATE TABLE medicaid_nc_clean AS
SELECT
    TRIM(utilization_type) AS utilization_type,
    TRIM(state) AS state,
    TRIM(ndc) AS ndc,
    TRIM(product_name) AS product_name,

    CAST(NULLIF(TRIM(year), '') AS INTEGER)
        AS year,

    CAST(NULLIF(TRIM(quarter), '') AS INTEGER)
        AS quarter,

    LOWER(TRIM(suppression_used))
        AS suppression_used,

    CAST(
        NULLIF(TRIM(number_of_prescriptions), '')
        AS NUMERIC
    ) AS number_of_prescriptions,

    CAST(
        NULLIF(TRIM(units_reimbursed), '')
        AS NUMERIC
    ) AS units_reimbursed,

    CAST(
        NULLIF(TRIM(total_amount_reimbursed), '')
        AS NUMERIC
    ) AS total_amount_reimbursed,

    CAST(
        NULLIF(TRIM(medicaid_amount_reimbursed), '')
        AS NUMERIC
    ) AS medicaid_amount_reimbursed,

    CAST(
        NULLIF(TRIM(non_medicaid_amount_reimbursed), '')
        AS NUMERIC
    ) AS non_medicaid_amount_reimbursed

FROM medicaid_raw
WHERE UPPER(TRIM(state)) = 'NC';
