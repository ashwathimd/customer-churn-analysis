USE telco_churn;
GO;
SELECT DB_NAME() AS Current_Database;

-- Check available tables
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS Customer_Count 
FROM dbo.customers


SELECT TOP 10 *
FROM dbo.customers;

-- Basic table profile 
SELECT 
    COUNT(*) AS Customer_Count,
    COUNT(DISTINCT customer_id ) AS Unique_Customers
FROM dbo.customers;

--Churn Distribution
SELECT
    churn_label,
    COUNT(*) AS Customer_Count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS Churn_Percentage 
FROM dbo.customers 
GROUP BY Churn_Label 
ORDER BY Customer_Count DESC;

-- Churn Rate by Contract Type 
SELECT
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate 
FROM dbo.customers
GROUP BY contract
ORDER BY churn_rate DESC;

--Churn Rate by tenure months 
SELECT
    tenure_months,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate
FROM dbo.customers
GROUP BY tenure_months
ORDER BY churn_rate DESC;

-- Churn Rate by tenure bands 
SELECT 
    CASE 
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months >6 AND tenure_months <=12 THEN '7 - 12 months'
        WHEN tenure_months >12 AND tenure_months <=24 THEN '13 - 24 months'
        WHEN tenure_months >24 AND tenure_months <=48 THEN '25 - 48 months'
        ELSE '49 + months'
    END AS tenure_band,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST (churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate
FROM dbo.customers 
GROUP BY 
    CASE 
        WHEN tenure_months <= 6 THEN '0 - 6 months'
        WHEN tenure_months >6 AND tenure_months <=12 THEN '7 - 12 months'
        WHEN tenure_months >12 AND tenure_months <=24 THEN '13 - 24 months'
        WHEN tenure_months >24 AND tenure_months <=48 THEN '25 - 48 months'
        ELSE '49 + months'
    END 

ORDER BY
    MIN(tenure_months);

-- Churn Rate by Internet Service 
SELECT 
    internet_service,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate
FROM dbo.customers
GROUP BY internet_service
ORDER BY churn_rate DESC;

-- Churn Rate by internet service and contract 
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
ORDER BY churn_rate DESC;

USE telco_churn
GO

-- Churn Rate by Tenure Band and Contract
SELECT 
    CASE
    WHEN tenure_months <=6 THEN '0-6 months'
    WHEN tenure_months >6 AND tenure_months <= 12 THEN '6-12 months'
    WHEN tenure_months >12 AND tenure_months <= 24 THEN '13-24 months'
    WHEN tenure_months >24 AND tenure_months <=48 THEN '25-48 months'
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
    WHEN tenure_months <=6 THEN '0-6 months'
    WHEN tenure_months >6 AND tenure_months <= 12 THEN '6-12 months'
    WHEN tenure_months >12 AND tenure_months <= 24 THEN '13-24 months'
    WHEN tenure_months >24 AND tenure_months <=48 THEN '25-48 months'
    ELSE '49+ months'
    END,
    contract
ORDER BY
    MIN(tenure_months),
    churn_rate DESC


USE telco_churn
--Churn rate by payment method
SELECT 
payment_method,
COUNT(*) AS customer_count,
SUM(churn_value) AS churned_customers,
ROUND(
    AVG(CAST(churn_value AS FLOAT)) * 100,
    2
) AS churn_rate
FROM dbo.customers
GROUP BY payment_method
ORDER BY churn_rate DESC


-- Customer Distribution by payment method and contract 
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

-- Churn Rate by payment method and contract 

SELECT 
    payment_method,
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS float)) * 100,
        2
    ) AS churn_rate
FROM dbo.customers
GROUP BY
    payment_method,
    contract
ORDER BY 
    churn_rate DESC;

-- Churn Rate by Monthly Charges Band

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

-- Churn Rate by Monthly Charges Band and Contract

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

-- Highest risk customer segments 
USE telco_churn;
WITH segment_churn AS 
(
    SELECT 
    contract,
    internet_service,
    payment_method,
    COUNT(*) AS customer_count ,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS float)) * 100,
        2
    ) AS churn_rate

    FROM dbo.customers

    GROUP BY 
    contract,
    internet_service,
    payment_method
)

SELECT 
contract,
internet_service,
payment_method,
customer_count,
churned_customers,
churn_rate,

DENSE_RANK() OVER (
    ORDER BY churn_rate DESC
) AS churn_rank
FROM segment_churn
ORDER BY churn_rank;

-- Highest risk customers(excluding small no of customers)
USE telco_churn;
WITH segment_churn AS 
(
    SELECT 
    contract,
    internet_service,
    payment_method,
    COUNT(*) AS customer_count ,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS float)) * 100,
        2
    ) AS churn_rate

    FROM dbo.customers

    GROUP BY 
    contract,
    internet_service,
    payment_method
)

SELECT 
contract,
internet_service,
payment_method,
customer_count,
churned_customers,
churn_rate,

DENSE_RANK() OVER (
    ORDER BY churn_rate DESC
) AS churn_rank
FROM segment_churn
WHERE customer_count >= 100
ORDER BY churn_rank;

-- Rank internet service within each contract type 
USE telco_churn;
WITH service_churn AS 
(
    SELECT
    contract,
    internet_service,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS float))* 100,
        2
    ) AS churn_rate 
    
    FROM dbo.customers
    GROUP BY 
    contract,
    internet_service
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

-- Contract churn vs overall churn
USE telco_churn;
WITH contract_churn AS (
    SELECT
        contract,
        COUNT(*) AS customer_count,
        SUM(churn_value) AS churned_customers,

        ROUND(
            AVG(CAST(churn_value AS FLOAT)) * 100,
            2
        ) AS churn_rate

    FROM dbo.customers
    GROUP BY contract
)

SELECT
    contract,
    customer_count,
    churned_customers,
    churn_rate,

    ROUND(
        churn_rate - AVG(churn_rate) OVER (),
        2
    ) AS difference_from_average

FROM contract_churn

ORDER BY churn_rate DESC;

-- Overall churn rate
USE telco_churn;
SELECT
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS overall_churn_rate
FROM dbo.customers;

-- Contract segments above overall churn rate 
USE telco_churn;
SELECT
    contract,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS customer_churn,
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate
FROM dbo.customers
GROUP BY contract 
HAVING AVG(CAST(churn_value AS FLOAT)) >
    (
        SELECT AVG(CAST(churn_value AS FLOAT))
        FROM dbo.customers
    )
ORDER BY churn_rate DESC;

-- Customer segments above overall churn rate
USE telco_churn;
SELECT 
    contract,
    internet_service,
    payment_method,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(AVG(CAST(churn_value AS FLOAT))*100,2) AS churn_rate
FROM dbo.customers
GROUP BY 
    contract,
    internet_service,
    payment_method
HAVING AVG(CAST(churn_value AS FLOAT)) > 
(
    SELECT AVG(CAST(churn_value AS FLOAT))
    FROM dbo.customers
)
AND COUNT(*) >= 100
ORDER BY churn_rate DESC;

-- Ranked high-risk customer segments
USE telco_churn;
SELECT
    contract,
    internet_service,
    payment_method,
    COUNT(*) AS customer_count,
    SUM(churn_value) AS churned_customers,
    ROUND(
        AVG(CAST(churn_value AS FLOAT)) * 100,
        2
    ) AS churn_rate,

    DENSE_RANK() OVER (
        ORDER BY AVG(CAST(churn_value AS FLOAT)) DESC
    ) AS risk_rank

FROM dbo.customers

GROUP BY
    contract,
    internet_service,
    payment_method

HAVING
    AVG(CAST(churn_value AS FLOAT)) >
    (
        SELECT AVG(CAST(churn_value AS FLOAT))
        FROM dbo.customers
    )
    AND COUNT(*) >= 100

ORDER BY risk_rank;