
-- Project: Medicaid Pharmacy Spending Analysis
-- Step 1: Create raw data staging table
-- Source: CMS State Drug Utilization Data (2024)

CREATE TABLE medicaid_raw (
    utilization_type TEXT,
    state TEXT,
    ndc TEXT,
    labeler_code TEXT,
    product_code TEXT,
    package_size TEXT,
    year TEXT,
    quarter TEXT,
    suppression_used TEXT,
    product_name TEXT,
    units_reimbursed TEXT,
    number_of_prescriptions TEXT,
    total_amount_reimbursed TEXT,
    medicaid_amount_reimbursed TEXT,
    non_medicaid_amount_reimbursed TEXT
);
