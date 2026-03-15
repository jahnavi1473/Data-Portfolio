CREATE TABLE online_retail_raw (
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC,   -- ← no scale restriction
    CustomerID INTEGER,
    Country TEXT
);

SELECT COUNT(*) 
FROM online_retail_raw;

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

--- CREATING NEW TABLE 
--- STEP 1: REMOVING NON PRODUCT STOCK CODES

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
WHERE UnitPrice = 0;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE UnitPrice > 0
AND UnitPrice < 0.01;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE CustomerID IS NULL;

---Investigate NULL Descriptions
SELECT COUNT(*)
FROM online_retail_net_model
WHERE Description IS NULL;

--- Stockcodes for those null desc
SELECT StockCode, COUNT(*) 
FROM online_retail_net_model
WHERE Description IS NULL
GROUP BY StockCode
ORDER BY COUNT(*) DESC;

--- invoices cancelled for null desc
SELECT COUNT(*)
FROM online_retail_net_model
WHERE Description IS NULL
AND InvoiceNo LIKE 'C%';

--- descriptions that can be recovered
SELECT DISTINCT StockCode
FROM online_retail_net_model n
WHERE n.Description IS NULL
AND EXISTS (
    SELECT 1
    FROM online_retail_net_model v
    WHERE v.StockCode = n.StockCode
    AND v.Description IS NOT NULL
);
--- 409 can be recovered ante 575 TRANSACTIONS WILL BE RECOVERED


--- descriptions that cant be recovered
SELECT DISTINCT StockCode
FROM online_retail_net_model n
WHERE n.Description IS NULL
AND NOT EXISTS (
    SELECT 1
    FROM online_retail_net_model v
    WHERE v.StockCode = n.StockCode
    AND v.Description IS NOT NULL
);

---- finding
SELECT 
    SUM(Quantity * UnitPrice) AS total_revenue,
    COUNT(*) AS rows_count
FROM online_retail_net_model
WHERE StockCode IN (
'20849','20950','21134','35592T','35951','62095B',
'72803B','72814','84247C','84611B','84670',
'84971L','85018C','85044','85226A','90042B'
);


SELECT DISTINCT Description
FROM online_retail_net_model
WHERE Description LIKE '*%';

SELECT *
FROM online_retail_net_model
WHERE TRIM(Description) = '?';

SELECT * 
FROM online_retail_net_model
WHERE Description IS NULL;

SELECT * 
FROM online_retail_net_model
WHERE Description IS NOT NULL;

SELECT COUNT(*)
FROM online_retail_net_model
WHERE Description IS NULL;

SELECT Description
FROM online_retail_net_model
WHERE Description IS NULL; ---3949

SELECT COUNT(DISTINCT StockCode)
FROM online_retail_net_model
where Description IS NULL ;---425

---- 16 CANT BE
