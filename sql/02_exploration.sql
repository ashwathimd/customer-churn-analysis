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

USE telco_churn;
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