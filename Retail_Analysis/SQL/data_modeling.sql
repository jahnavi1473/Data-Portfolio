--- DATA MODELLING
--- Creating a) fact_sales
------------ b) dim_product
------------ b) dim_customer
------------ c) dim_country
------------ d) dim_date

---- a) creating dim_product

DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product AS
SELECT
    StockCode,
    MAX(TRIM(REPLACE(Description,'*',''))) AS product_name
FROM online_retail_net_model
WHERE Description IS NOT NULL
GROUP BY StockCode;

SELECT COUNT(*)
FROM dim_product;

SELECT *
FROM dim_product 
WHERE StockCode LIKE '85179%'
ORDER BY StockCode ASC;

SELECT COUNT(*) AS total_rows,
COUNT(DISTINCT stockcode) AS unique_stockcodes
FROM dim_product;

SELECT StockCode, COUNT(*)
FROM dim_product
GROUP BY StockCode
ORDER BY Count DESC;

---- b) dim_country
CREATE TABLE dim_country AS
SELECT DISTINCT
    Country
FROM online_retail_net_model;

SELECT *
FROM dim_country;

---- c) dim_customer
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer AS
SELECT
    CustomerID,
    MAX(Country) AS Country
FROM online_retail_net_model
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT COUNT(*)
FROM dim_customer;

---- d) dim_date
CREATE TABLE dim_date AS
SELECT DISTINCT
    DATE(InvoiceDate) AS order_date,
    EXTRACT(YEAR FROM InvoiceDate) AS year,
    EXTRACT(MONTH FROM InvoiceDate) AS month,
    EXTRACT(DAY FROM InvoiceDate) AS day
FROM online_retail_net_model;

SELECT *
FROM dim_date
ORDER BY order_date
LIMIT 10;

---- e) fact_sales
CREATE TABLE fact_sales AS
SELECT
    InvoiceNo,
    StockCode,
    CustomerID,
    Country,
    DATE(InvoiceDate) AS order_date,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS revenue
FROM online_retail_net_model;

-- ---- after dropping and rebuilding dim prod all were in upper 
-- so have to change fact sales as well

UPDATE fact_sales
SET stockcode = UPPER(stockcode);

SELECT COUNT(*)
FROM fact_sales;

SELECT *
FROM fact_sales 
WHERE StockCode LIKE '85179A';

---validation
SELECT COUNT(DISTINCT StockCode)
FROM online_retail_net_model
WHERE Description IS NOT NULL;-- 3933

SELECT COUNT(DISTINCT StockCode)
FROM dim_product;
-- WHERE product_name IS NOT NULL;--3824

SELECT COUNT(DISTINCT StockCode)
FROM fact_sales;-- 3838

SELECT COUNT(DISTINCT Country)
FROM online_retail_net_model; -- 38

SELECT COUNT(DISTINCT CustomerID)
FROM online_retail_net_model
WHERE CustomerID IS NOT NULL; --4363

SELECT COUNT(DISTINCT DATE(InvoiceDate))
FROM online_retail_net_model;--305

SELECT COUNT(*)
FROM online_retail_net_model; --539690


-- ALTER TABLE dim_product
-- ADD COLUMN product_type TEXT;

-- UPDATE dim_product
-- SET product_type =
-- CASE
-- WHEN StockCode IN ('POST','DOT') THEN 'Shipping'
-- WHEN StockCode LIKE 'gift_%' THEN 'Gift Voucher'
-- WHEN StockCode = 'S' THEN 'Sample'
-- ELSE 'Product'
-- END;

----- had a data modelling issue, so rebuilding dim_product

DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product AS
SELECT
UPPER(stockcode) AS stockcode,
MAX(TRIM(REPLACE(description,'*',''))) AS product_name
FROM online_retail_net_model
WHERE description IS NOT NULL
AND LOWER(description) NOT LIKE '%wrong%'
AND LOWER(description) NOT LIKE '%adjust%'
AND LOWER(description) NOT LIKE '%check%'
AND LOWER(description) NOT LIKE '%test%'
AND LOWER(description) NOT LIKE '%return%'
AND LOWER(description) NOT LIKE '%damage%'
AND LOWER(description) NOT LIKE '%found%'
AND LOWER(description) NOT LIKE '%mail%'
AND LOWER(description) NOT LIKE '%website%'
AND LOWER(description) NOT LIKE '%aside%'
GROUP BY UPPER(stockcode);


ALTER TABLE dim_product
ADD COLUMN product_type TEXT;

UPDATE dim_product
SET product_type =
CASE
WHEN UPPER(StockCode) IN ('POST','DOT') OR 
LOWER(product_name) LIKE '%carriage%' THEN 'Shipping'
WHEN UPPER(StockCode) LIKE 'GIFT%' THEN 'Gift Voucher'
WHEN StockCode = 'S' THEN 'Sample'
ELSE 'Product'
END;

SELECT *
FROM dim_product;