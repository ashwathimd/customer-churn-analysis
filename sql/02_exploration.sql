/*
===============================================================================
CUSTOMER CHURN ANALYSIS — SQL EXPLORATION
===============================================================================

Purpose:
Explore customer churn patterns and identify customer groups associated
with elevated churn risk.

The SQL analysis follows the same analytical progression as the Python EDA:

1. Data understanding and validation
2. Overall churn distribution
3. Churn by individual customer attributes
4. Multi-dimensional segment analysis
5. High-risk segment identification
6. Comparison against overall churn

Segment stability standard:
Customer segments with fewer than 100 customers are excluded from
high-risk / low-risk segment rankings because small groups can produce
unstable churn-rate estimates.

Important:
This analysis is exploratory. Observed associations do not establish
causal relationships.
===============================================================================
*/


USE telco_churn;


/*
===============================================================================
1. DATA UNDERSTANDING
===============================================================================
*/


/*
Business Question 1:
Is the expected customer database available and active?

This confirms the database currently being queried.
*/

SELECT
    DB_NAME() AS current_database;


/*
Business Question 2:
What base tables are available in the database?

This validates the structure of the analytical database.
*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';


/*
Business Question 3:
How many customer records are present in the analytical dataset?

This establishes the total sample size used throughout the analysis.
*/

SELECT
    COUNT(*) AS customer_count
FROM dbo.customers;


/*
Business Question 4:
What do sample customer records look like?

This provides an initial inspection of the analytical dataset.
*/

SELECT TOP 10
    *
FROM dbo.customers;


/*
Business Question 5:
Does the customer table contain one unique record per customer?

This validates the basic structure of the analytical dataset by
comparing total records with distinct customer IDs.
*/

SELECT
    COUNT(*) AS customer_count,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM dbo.customers;


/*
===============================================================================
2. OVERALL CHURN
===============================================================================
*/


/*
Business Question 6:
What proportion of customers have churned?

This establishes the overall churn distribution and provides the
baseline against which customer segments can later be compared.
*/

SELECT
    churn_label,
    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS churn_percentage

FROM dbo.customers

GROUP BY
    churn_label

ORDER BY
    customer_count DESC;


/*
Business Question 7:
What is the overall customer churn rate?

This value serves as the company-wide churn benchmark for identifying
segments with above-average churn.
*/

SELECT
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS overall_churn_rate

FROM dbo.customers;


/*
===============================================================================
3. CHURN BY INDIVIDUAL CUSTOMER ATTRIBUTES
===============================================================================
*/


/*
Business Question 8:
How does churn vary by contract type?

The customer count is reported alongside the churn rate so that
differences can be interpreted in the context of segment size.
*/

SELECT
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    contract

ORDER BY
    churn_rate DESC;


/*
Business Question 9:
How does churn vary by customer tenure?

This identifies whether churn is concentrated at particular
stages of the customer lifecycle.
*/

SELECT
    tenure_months,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    tenure_months

ORDER BY
    tenure_months;


/*
Business Question 10:
How does churn vary across broader tenure bands?

Broader bands make lifecycle-level patterns easier to interpret
than individual monthly tenure values.
*/

SELECT
    CASE
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months <= 12 THEN '7 - 12 months'
        WHEN tenure_months <= 24 THEN '13 - 24 months'
        WHEN tenure_months <= 48 THEN '25 - 48 months'
        ELSE '49+ months'
    END AS tenure_band,

    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    CASE
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months <= 12 THEN '7 - 12 months'
        WHEN tenure_months <= 24 THEN '13 - 24 months'
        WHEN tenure_months <= 48 THEN '25 - 48 months'
        ELSE '49+ months'
    END

ORDER BY
    MIN(tenure_months);


/*
Business Question 11:
How does churn vary by internet service?

This identifies whether particular service categories are associated
with elevated churn.
*/

SELECT
    internet_service,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    internet_service

ORDER BY
    churn_rate DESC;


/*
Business Question 12:
How does churn vary jointly by internet service and contract type?

This begins to identify combinations of customer characteristics
associated with elevated churn.
*/

SELECT
    internet_service,
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    internet_service,
    contract

ORDER BY
    churn_rate DESC;


/*
Business Question 13:
How does churn vary jointly by tenure band and contract type?

This combines customer lifecycle stage with contractual commitment.
*/

SELECT
    CASE
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months <= 12 THEN '7 - 12 months'
        WHEN tenure_months <= 24 THEN '13 - 24 months'
        WHEN tenure_months <= 48 THEN '25 - 48 months'
        ELSE '49+ months'
    END AS tenure_band,

    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    CASE
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months <= 12 THEN '7 - 12 months'
        WHEN tenure_months <= 24 THEN '13 - 24 months'
        WHEN tenure_months <= 48 THEN '25 - 48 months'
        ELSE '49+ months'
    END,
    contract

ORDER BY
    MIN(tenure_months),
    churn_rate DESC;


/*
Business Question 14:
How does churn vary by payment method?

This identifies whether payment behavior is associated with
different levels of customer churn.
*/

SELECT
    payment_method,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    payment_method

ORDER BY
    churn_rate DESC;


/*
Business Question 15:
How are contract types distributed within each payment method?

This provides context for interpreting payment-method differences.
*/

SELECT
    payment_method,
    contract,
    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY payment_method),
        2
    ) AS percentage_within_payment_method

FROM dbo.customers

GROUP BY
    payment_method,
    contract

ORDER BY
    payment_method,
    customer_count DESC;


/*
Business Question 16:
How does churn vary jointly by payment method and contract type?

This identifies whether payment-method differences persist
across contract types.
*/

SELECT
    payment_method,
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    payment_method,
    contract

ORDER BY
    churn_rate DESC;


/*
===============================================================================
4. PRICING / MONTHLY CHARGE ANALYSIS
===============================================================================
*/


/*
Business Question 17:
How does churn vary across monthly charge bands?

This explores whether customers with different monthly spending levels
experience different churn rates.
*/

SELECT
    CASE
        WHEN monthly_charges < 30 THEN 'Under 30'
        WHEN monthly_charges < 60 THEN '30 - 59'
        WHEN monthly_charges < 90 THEN '60 - 89'
        ELSE '90+'
    END AS charges_band,

    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    CASE
        WHEN monthly_charges < 30 THEN 'Under 30'
        WHEN monthly_charges < 60 THEN '30 - 59'
        WHEN monthly_charges < 90 THEN '60 - 89'
        ELSE '90+'
    END

ORDER BY
    MIN(monthly_charges);


/*
Business Question 18:
How does churn vary across monthly charge bands and contract types?

This combines customer value with contractual commitment.
*/

SELECT
    CASE
        WHEN monthly_charges < 30 THEN 'Under 30'
        WHEN monthly_charges < 60 THEN '30 - 59'
        WHEN monthly_charges < 90 THEN '60 - 89'
        ELSE '90+'
    END AS charges_band,

    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    CASE
        WHEN monthly_charges < 30 THEN 'Under 30'
        WHEN monthly_charges < 60 THEN '30 - 59'
        WHEN monthly_charges < 90 THEN '60 - 89'
        ELSE '90+'
    END,
    contract

ORDER BY
    MIN(monthly_charges),
    churn_rate DESC;


/*
===============================================================================
5. REUSABLE CUSTOMER SEGMENT VIEW
===============================================================================

The Contract × Internet Service × Payment Method aggregation is reused
across multiple segment analyses.

The view centralizes this logic and applies the same minimum
customer threshold used in the Python EDA.

Minimum segment size: 100 customers.
*/


/*
A dynamic SQL batch is used here because SQL Server requires
CREATE OR ALTER VIEW to be the first statement in its batch.
*/

EXEC(N'
CREATE OR ALTER VIEW dbo.segment_churn AS

SELECT
    contract,
    internet_service,
    payment_method,

    COUNT(*) AS customer_count,

    SUM(churn_value) AS churned_customers,

    SUM(
        CASE
            WHEN churn_value = 0 THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    contract,
    internet_service,
    payment_method

HAVING
    COUNT(*) >= 100;
');


/*
===============================================================================
6. CUSTOMER SEGMENT ANALYSIS
===============================================================================
*/


/*
Business Question 19:
Which customer segments have the highest churn rates?

Only segments containing at least 100 customers are included.

This threshold prevents very small customer groups from dominating
the ranking because of unstable churn-rate estimates.
*/

SELECT TOP 10
    contract,
    internet_service,
    payment_method,
    customer_count,
    churned_customers,
    retained_customers,
    churn_rate,

    DENSE_RANK() OVER (
        ORDER BY churn_rate DESC
    ) AS churn_rank

FROM dbo.segment_churn

ORDER BY
    churn_rank;


/*
Business Question 20:
Which customer segments have the lowest churn rates?

The same minimum sample-size threshold is applied for consistency.
*/

SELECT TOP 10
    contract,
    internet_service,
    payment_method,
    customer_count,
    churned_customers,
    retained_customers,
    churn_rate

FROM dbo.segment_churn

ORDER BY
    churn_rate ASC;


/*
Business Question 21:
Which customer segments have churn rates above the overall
customer churn rate?

This identifies segments whose observed churn exceeds the
company-wide baseline.
*/

SELECT
    contract,
    internet_service,
    payment_method,
    customer_count,
    churned_customers,
    retained_customers,
    churn_rate

FROM dbo.segment_churn

WHERE
    churn_rate >
    (
        SELECT
            AVG(CAST(churn_value AS FLOAT)) * 100
        FROM dbo.customers
    )

ORDER BY
    churn_rate DESC;


/*
Business Question 22:
Which high-risk customer segments have the greatest relative priority?

Segments are ranked by churn rate after applying the minimum
100-customer threshold and the overall churn benchmark.
*/

SELECT
    contract,
    internet_service,
    payment_method,
    customer_count,
    churned_customers,
    retained_customers,
    churn_rate,

    DENSE_RANK() OVER (
        ORDER BY churn_rate DESC
    ) AS risk_rank

FROM dbo.segment_churn

WHERE
    churn_rate >
    (
        SELECT
            AVG(CAST(churn_value AS FLOAT)) * 100
        FROM dbo.customers
    )

ORDER BY
    risk_rank;


/*
===============================================================================
7. SERVICE COMPARISON WITHIN CONTRACT TYPE
===============================================================================
*/


/*
Business Question 23:
Within each contract type, which internet service categories
have the highest churn?

This controls the comparison for contract type and allows service
categories to be ranked within each contractual group.

Only groups containing at least 100 customers are included so that
small subgroups do not produce unstable churn-rate rankings.
*/

WITH service_churn AS
(
    SELECT
        contract,
        internet_service,
        COUNT(*) AS customer_count,
        SUM(churn_value) AS churned_customers,

        ROUND(
            AVG(CAST(churn_value AS FLOAT)) * 100,
            2
        ) AS churn_rate

    FROM dbo.customers

    GROUP BY
        contract,
        internet_service

    HAVING
        COUNT(*) >= 100
)

SELECT
    contract,
    internet_service,
    customer_count,
    churned_customers,
    churn_rate,

    DENSE_RANK() OVER (
        PARTITION BY contract
        ORDER BY churn_rate DESC
    ) AS service_rank

FROM service_churn

ORDER BY
    contract,
    service_rank;


/*
===============================================================================
8. CONTRACT PERFORMANCE AGAINST CHURN BENCHMARK
===============================================================================
*/


/*
Business Question 24:
How does each contract type compare with the average churn rate
across contract groups?

This is a descriptive comparison against the unweighted average
of the contract-level churn rates.
*/

WITH contract_churn AS
(
    SELECT
        contract,
        COUNT(*) AS customer_count,
        SUM(churn_value) AS churned_customers,

        ROUND(
            AVG(CAST(churn_value AS FLOAT)) * 100,
            2
        ) AS churn_rate

    FROM dbo.customers

    GROUP BY
        contract
)

SELECT
    contract,
    customer_count,
    churned_customers,
    churn_rate,

    ROUND(
        churn_rate - AVG(churn_rate) OVER (),
        2
    ) AS difference_from_average_contract_churn

FROM contract_churn

ORDER BY
    churn_rate DESC;


/*
Business Question 25:
Which contract types have churn above the overall customer
churn rate?

This compares each contract type directly against the company-wide
customer churn benchmark rather than against the average of the
contract-level rates.
*/

SELECT
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,

    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate

FROM dbo.customers

GROUP BY
    contract

HAVING
    AVG(CAST(churn_value AS FLOAT))
    >
    (
        SELECT
            AVG(CAST(churn_value AS FLOAT))
        FROM dbo.customers
    )

ORDER BY
    churn_rate DESC;


/*
===============================================================================
EXPLORATORY ANALYSIS NOTE
===============================================================================

The segment analysis involves multiple subgroup comparisons.

These findings are therefore treated as exploratory rather than
confirmatory. Observed associations should not be interpreted as
independent causal effects.

Statistical validation and effect-size analysis are performed separately
in the Python statistical-analysis notebook.
===============================================================================
*/


/*
===============================================================================
END OF SQL EXPLORATION
===============================================================================

Key analytical principles used throughout:

1. Customer counts are reported alongside churn rates.
2. Segment rankings use a minimum sample size of 100 customers.
3. Repeated segment aggregation is centralized in dbo.segment_churn.
4. Exploratory associations are not interpreted as causal relationships.
5. Segment findings are validated against the statistical analysis
   performed in the Python statistical-analysis notebook.
===============================================================================
*/