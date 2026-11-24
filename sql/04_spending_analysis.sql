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
--inspect table schema--

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'medicaid_nc_clean'
ORDER BY ordinal_position;

-- calculations and filtering--

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

SELECT
    product_name,
    ROUND(SUM(total_amount_reimbursed), 2)
        AS total_reimbursement,
    SUM(number_of_prescriptions)
        AS total_prescriptions,
    ROUND(
        SUM(total_amount_reimbursed)
        / NULLIF(SUM(number_of_prescriptions), 0),
        2
    ) AS avg_reimbursement_per_rx

FROM medicaid_nc_clean

WHERE year = 2024
    AND total_amount_reimbursed IS NOT NULL
    AND number_of_prescriptions IS NOT NULL

GROUP BY product_name

HAVING SUM(number_of_prescriptions) > 0

ORDER BY avg_reimbursement_per_rx DESC,
    product_name

LIMIT 10;

--sensitivity analysis--
SELECT
    product_name,
    ROUND(SUM(total_amount_reimbursed), 2)
        AS total_reimbursement,
    SUM(number_of_prescriptions)
        AS total_prescriptions,
    ROUND(
        SUM(total_amount_reimbursed)
        / NULLIF(SUM(number_of_prescriptions), 0),
        2
    ) AS avg_reimbursement_per_rx

FROM medicaid_nc_clean

WHERE year = 2024
    AND total_amount_reimbursed IS NOT NULL
    AND number_of_prescriptions IS NOT NULL

GROUP BY product_name

HAVING SUM(number_of_prescriptions) >= 100

ORDER BY avg_reimbursement_per_rx DESC,
    product_name

LIMIT 10;

--question 4
-- Question 4: What percentage of total pharmacy 
--reimbursement is concentrated among the 
--top 10 medications?--

WITH drug_spending AS (

    SELECT
        product_name,
        SUM(total_amount_reimbursed)
            AS total_reimbursement

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY product_name

),

top_10_drugs AS (

    SELECT
        product_name,
        total_reimbursement

    FROM drug_spending

    ORDER BY total_reimbursement DESC,
        product_name

    LIMIT 10

),

overall_spending AS (

    SELECT
        SUM(total_reimbursement)
            AS overall_reimbursement

    FROM drug_spending

)

SELECT
    ROUND(SUM(t.total_reimbursement), 2)
        AS top_10_reimbursement,

    ROUND(o.overall_reimbursement, 2)
        AS overall_reimbursement,

    ROUND(
        100.0 * SUM(t.total_reimbursement)
        / NULLIF(o.overall_reimbursement, 0),
        2
    ) AS top_10_share_pct

FROM top_10_drugs t

CROSS JOIN overall_spending o

GROUP BY o.overall_reimbursement;

--invidual medication shre --


WITH drug_spending AS (

    SELECT
        product_name,
        SUM(total_amount_reimbursed)
            AS total_reimbursement

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY product_name

)

SELECT
    product_name,

    ROUND(total_reimbursement, 2)
        AS total_reimbursement,

    ROUND(
        100.0 * total_reimbursement
        / NULLIF(SUM(total_reimbursement) OVER (), 0),
        2
    ) AS share_of_total_pct,

    ROUND(
        100.0 * SUM(total_reimbursement) OVER (
            ORDER BY total_reimbursement DESC,
                product_name
            ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
        )
        / NULLIF(SUM(total_reimbursement) OVER (), 0),
        2
    ) AS cumulative_share_pct

FROM drug_spending

ORDER BY total_reimbursement DESC,
    product_name

LIMIT 10;

-- Question 5 which medications 
-- have high reimbursement relative 
-- to prescription volume?
 
WITH drug_metrics AS (

    SELECT
        product_name,

        SUM(total_amount_reimbursed)
            AS total_reimbursement,

        SUM(number_of_prescriptions)
            AS total_prescriptions,

        SUM(total_amount_reimbursed)
        / NULLIF(SUM(number_of_prescriptions), 0)
            AS avg_reimbursement_per_rx

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY product_name

    HAVING SUM(number_of_prescriptions) > 0

),

benchmarks AS (

    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_reimbursement
        ) AS median_reimbursement,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_prescriptions
        ) AS median_prescriptions

    FROM drug_metrics

)

SELECT
    d.product_name,

    ROUND(d.total_reimbursement, 2)
        AS total_reimbursement,

    d.total_prescriptions,

    ROUND(d.avg_reimbursement_per_rx, 2)
        AS avg_reimbursement_per_rx,

    CASE

        WHEN d.total_reimbursement >= b.median_reimbursement
            AND d.total_prescriptions < b.median_prescriptions
            THEN 'High Spend - Low Utilization'

        WHEN d.total_reimbursement >= b.median_reimbursement
            AND d.total_prescriptions >= b.median_prescriptions
            THEN 'High Spend - High Utilization'

        WHEN d.total_reimbursement < b.median_reimbursement
            AND d.total_prescriptions >= b.median_prescriptions
            THEN 'Low Spend - High Utilization'

        ELSE 'Low Spend - Low Utilization'

    END AS spending_category

FROM drug_metrics d

CROSS JOIN benchmarks b

ORDER BY d.total_reimbursement DESC,
    d.product_name;


--identify top 10 high spend, low utilizations meds--


WITH drug_metrics AS (

    SELECT
        product_name,

        SUM(total_amount_reimbursed)
            AS total_reimbursement,

        SUM(number_of_prescriptions)
            AS total_prescriptions,

        SUM(total_amount_reimbursed)
        / NULLIF(SUM(number_of_prescriptions), 0)
            AS avg_reimbursement_per_rx

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY product_name

    HAVING SUM(number_of_prescriptions) > 0

),

benchmarks AS (

    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_reimbursement
        ) AS median_reimbursement,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_prescriptions
        ) AS median_prescriptions

    FROM drug_metrics

)

SELECT
    d.product_name,

    ROUND(d.total_reimbursement, 2)
        AS total_reimbursement,

    d.total_prescriptions,

    ROUND(d.avg_reimbursement_per_rx, 2)
        AS avg_reimbursement_per_rx

FROM drug_metrics d

CROSS JOIN benchmarks b

WHERE d.total_reimbursement >= b.median_reimbursement
    AND d.total_prescriptions < b.median_prescriptions

ORDER BY d.total_reimbursement DESC,
    d.product_name

LIMIT 10;

-- Question 6 -- how does pharmacy
-- reimbursement differ between fee-for-service
-- and managed care?
--Medicaid program comparison

WITH program_spending AS (

    SELECT

        CASE
            WHEN utilization_type = 'FFSU'
                THEN 'Fee-for-Service'

            WHEN utilization_type = 'MCOU'
                THEN 'Managed Care'

            ELSE 'Other'

        END AS program_type,

        SUM(total_amount_reimbursed)
            AS total_reimbursement,

        SUM(number_of_prescriptions)
            AS total_prescriptions

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY utilization_type

)

SELECT
    program_type,

    ROUND(total_reimbursement, 2)
        AS total_reimbursement,

    total_prescriptions,

    ROUND(
        total_reimbursement
        / NULLIF(total_prescriptions, 0),
        2
    ) AS avg_reimbursement_per_rx,

    ROUND(
        100.0 * total_reimbursement
        / NULLIF(SUM(total_reimbursement) OVER (), 0),
        2
    ) AS reimbursement_share_pct,

    ROUND(
        100.0 * total_prescriptions
        / NULLIF(SUM(total_prescriptions) OVER (), 0),
        2
    ) AS prescription_share_pct

FROM program_spending

ORDER BY total_reimbursement DESC;

-- how does quarterly reimbursement dffer by Medicaid program?

WITH quarterly_program_spending AS (

    SELECT
        utilization_type,
        quarter,

        SUM(total_amount_reimbursed)
            AS total_reimbursement,

        SUM(number_of_prescriptions)
            AS total_prescriptions

    FROM medicaid_nc_clean

    WHERE year = 2024
        AND total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL

    GROUP BY utilization_type, quarter

),

quarterly_comparison AS (

    SELECT
        utilization_type,
        quarter,
        total_reimbursement,
        total_prescriptions,

        LAG(total_reimbursement) OVER (
            PARTITION BY utilization_type
            ORDER BY quarter
        ) AS previous_quarter_spend

    FROM quarterly_program_spending

)

SELECT

    CASE
        WHEN utilization_type = 'FFSU'
            THEN 'Fee-for-Service'

        WHEN utilization_type = 'MCOU'
            THEN 'Managed Care'

        ELSE 'Other'

    END AS program_type,

    quarter,

    ROUND(total_reimbursement, 2)
        AS total_reimbursement,

    total_prescriptions,

    ROUND(
        total_reimbursement
        / NULLIF(total_prescriptions, 0),
        2
    ) AS avg_reimbursement_per_rx,

    ROUND(
        100.0 *
        (total_reimbursement - previous_quarter_spend)
        / NULLIF(previous_quarter_spend, 0),
        2
    ) AS qoq_change_pct

FROM quarterly_comparison

ORDER BY utilization_type, quarter;

-- summary of KPI's--

SELECT
    COUNT(*) AS total_analytical_records,

    COUNT(DISTINCT product_name)
        AS unique_products,

    COUNT(DISTINCT ndc)
        AS unique_ndcs,

    ROUND(SUM(total_amount_reimbursed), 2)
        AS total_reimbursement,

    SUM(number_of_prescriptions)
        AS total_prescriptions,

    ROUND(
        SUM(total_amount_reimbursed)
        / NULLIF(SUM(number_of_prescriptions), 0),
        2
    ) AS avg_reimbursement_per_rx,

    ROUND(SUM(medicaid_amount_reimbursed), 2)
        AS total_medicaid_reimbursement,

    ROUND(SUM(non_medicaid_amount_reimbursed), 2)
        AS total_non_medicaid_reimbursement

FROM medicaid_nc_clean

WHERE year = 2024
    AND total_amount_reimbursed IS NOT NULL
    AND number_of_prescriptions IS NOT NULL;

-- quantify how many records are available for analysis--

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE suppression_used = 'true'
    ) AS suppressed_records,

    COUNT(*) FILTER (
        WHERE total_amount_reimbursed IS NULL
    ) AS missing_reimbursement_records,

    COUNT(*) FILTER (
        WHERE number_of_prescriptions IS NULL
    ) AS missing_prescription_records,

    COUNT(*) FILTER (
        WHERE total_amount_reimbursed IS NOT NULL
        AND number_of_prescriptions IS NOT NULL
    ) AS included_records,

    COUNT(*) FILTER (
        WHERE total_amount_reimbursed IS NULL
        OR number_of_prescriptions IS NULL
    ) AS excluded_records,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE total_amount_reimbursed IS NOT NULL
            AND number_of_prescriptions IS NOT NULL
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS inclusion_rate_pct

FROM medicaid_nc_clean

WHERE year = 2024;

