--- DAY 1

CREATE TABLE online_retail_raw (
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC(10,2),
    CustomerID INTEGER,
    Country TEXT
);


COPY online_retail_raw
FROM 'C:/Users/DELL/Desktop/SQL_Projects/Retail_Analysis/online_retail.csv'
DELIMITER ','
CSV HEADER;


SELECT COUNT(*) 
FROM online_retail_raw;

---- DAY 2

SELECT StockCode, COUNT(*) 
FROM online_retail_raw
WHERE StockCode IN ('B','D','M','C2','AMAZONFEE','BANK CHARGES','CRUK')
GROUP BY StockCode
ORDER BY COUNT(*) DESC;

--- found a catch, excel had 572 M rows so tried finding M variations
SELECT DISTINCT StockCode
FROM online_retail_raw
WHERE UPPER(StockCode) LIKE 'M%';

SELECT StockCode, COUNT(*)
FROM online_retail_raw
WHERE UPPER(StockCode) LIKE 'M%'
GROUP BY StockCode
ORDER BY StockCode;

SELECT COUNT(*)
FROM online_retail_raw
WHERE UPPER(StockCode) = 'M';
--- CLEANING

--- CREATING NEW TABLE 
--- STEP 1: REMOVING NON PRODUCT STOCK CODES

DROP TABLE online_retail_clean_step1;

CREATE TABLE online_retail_clean_step1 AS
SELECT *
FROM online_retail_raw
WHERE UPPER(StockCode) NOT IN (
    'B','D','M','C2','AMAZONFEE','BANK CHARGES','CRUK'
);

SELECT COUNT(*) 
FROM online_retail_clean_step1;

--- STEP 2 validate count TO REMOVE CANCELLED TRANSACTIONS
SELECT COUNT(*) 
FROM online_retail_clean_step1
WHERE InvoiceNo LIKE 'C%';

DROP TABLE online_retail_clean_sales;

CREATE TABLE online_retail_clean_sales AS
SELECT *
FROM online_retail_clean_step1
WHERE InvoiceNo NOT LIKE 'C%';

SELECT COUNT(*) 
FROM online_retail_clean_sales;

--- STEP 3 validate count TO REMOVE -ve quantity TRANSACTIONS
SELECT COUNT(*)
FROM online_retail_clean_sales
WHERE Quantity <= 0;

DROP TABLE online_retail_final;

CREATE TABLE online_retail_final AS
SELECT *
FROM online_retail_clean_sales
WHERE Quantity > 0;

SELECT COUNT(*)
FROM online_retail_final;

--- ABOVE ONLINE RETAIL FINAL GIVES GROSS SALES NO RETURNS TABLE
--- BELOW ONLINE RETAIL NET MODEL GIVES NET REVNUE MODEL ( SALES + RETURNS )

SELECT COUNT(*)
FROM online_retail_clean_step1
WHERE (
    Quantity < 0 
    AND InvoiceNo NOT LIKE 'C%'
);

CREATE TABLE online_retail_net_model AS
SELECT *
FROM online_retail_clean_step1
WHERE NOT (
    Quantity < 0 
    AND InvoiceNo NOT LIKE 'C%'
);

SELECT COUNT(*)
FROM online_retail_net_model;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice <= 0;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice = 0;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice < 0;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice IS NULL;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice::TEXT = '0';

SELECT InvoiceNo, StockCode, Quantity, UnitPrice
FROM online_retail_net_model
WHERE UnitPrice = 0
LIMIT 20;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice = 0
AND Quantity = 0;

SELECT COUNT(*)
FROM online_retail_raw
WHERE UnitPrice IS NULL;


DROP TABLE IF EXISTS online_retail_net_model;
DROP TABLE IF EXISTS online_retail_final;
DROP TABLE IF EXISTS online_retail_clean_sales;
DROP TABLE IF EXISTS online_retail_clean_step1;
DROP TABLE IF EXISTS online_retail_raw;