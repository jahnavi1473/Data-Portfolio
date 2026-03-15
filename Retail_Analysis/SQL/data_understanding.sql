--- Data Understanding Phase
--- 1. Check Total Rows

SELECT COUNT(*) FROM online_retail_raw;

--- 2. view Sample Data
SELECT * FROM online_retail_raw LIMIT 10;

--- 3. Checking Columns and datatypes
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'online_retail_raw';

-- 4. NULL VALUE ANALYSIS
---A) Null Customer IDs
SELECT COUNT(*)
FROM online_retail_raw
WHERE CustomerID IS NULL;

---B)Null Descriptions
SELECT COUNT(*)
FROM online_retail_raw
WHERE Description IS NULL;

--- 5. Distinct StockCodes
SELECT COUNT(DISTINCT StockCode)
FROM online_retail_raw;

--- 6. Distinct Countries
SELECT DISTINCT Country
FROM online_retail_raw
ORDER BY Country;

--- 7. Distinct Invoice Numbers
SELECT COUNT(DISTINCT InvoiceNo)
FROM online_retail_raw;

--- 8. Identify Cancellation Transactions
SELECT COUNT(*)
FROM online_retail_raw
WHERE InvoiceNo LIKE 'C%';
----Inspect Cancellation Records
SELECT *
FROM online_retail_raw
WHERE InvoiceNo LIKE 'C%'
LIMIT 20;

--- 9. Quantity Analysis
--- a) -ve quantity
SELECT COUNT(*)
FROM online_retail_raw
WHERE Quantity < 0;
---b) max and min quantity
SELECT
MIN(Quantity),
MAX(Quantity)
FROM online_retail_raw;

--- 10. Unit price Analysis
--- a) Zero unit prices
SELECT COUNT(*)
FROM online_retail_raw
WHERE UnitPrice = 0;
----b) Small prices
SELECT COUNT(*)
FROM online_retail_raw
WHERE UnitPrice > 0 AND UnitPrice < 0.01;
---c)-ve unit price
SELECT COUNT(*)
FROM online_retail_raw
WHERE UnitPrice < 0;


---- 11. Stock Code Understanding
--- a) most frequent stockcodes
SELECT StockCode, COUNT(*) AS count
FROM online_retail_raw
GROUP BY StockCode
ORDER BY count DESC
LIMIT 20;

---- b)operational stock codes
SELECT DISTINCT StockCode
FROM online_retail_raw
ORDER BY StockCode;

---- 12. Description Check
--- a) blank descriptions
SELECT COUNT(*)
FROM online_retail_raw
WHERE Description = ' ';

--- b ) weird descriptions
SELECT *
FROM online_retail_raw
WHERE Description LIKE '*%'
LIMIT 20;

--- c) ? descriptions
SELECT *
FROM online_retail_raw
WHERE TRIM(Description) = '?';

--- 13. dates exploration
SELECT
MIN(InvoiceDate) AS start_date,
MAX(InvoiceDate) AS end_date
FROM online_retail_raw;

--- 14. Country distribution
SELECT Country, COUNT(*) AS transactions
FROM online_retail_raw
GROUP BY Country
ORDER BY transactions DESC;