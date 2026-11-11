/* ============================================================
   OLIST E-COMMERCE ANALYTICS PROJECT
   FILE: 02_marketplace_overview.sql

   PURPOSE:
   Analyze overall marketplace performance including:
   - Revenue
   - Orders
   - Average Order Value
   - Monthly Trends
   - Yearly Trends

   DATA QUALITY NOTE:

   The following periods appear incomplete and should be
   treated carefully during trend analysis:

   - Sep 2016
   - Oct 2016
   - Dec 2016
   - Sep 2018
   - Oct 2018

   These periods are included in the dataset but should
   generally be excluded from business trend reporting.

============================================================ */


/* ============================================================
   TOTAL REVENUE
============================================================ */

SELECT ROUND(SUM(payment_value)::NUMERIC, 2) AS total_revenue
FROM order_payments;

/*
Finding:

Total Marketplace Revenue = $16,008,872.12

The marketplace generated approximately $16 million in sales 
during the available analysis period.
*/


/* ============================================================
   AVERAGE ORDER VALUE (AOV)
============================================================ */

SELECT ROUND(AVG(payment_value)::NUMERIC, 2) AS average_order_value
FROM order_payments;

/*
Finding:

Average Order Value (AOV) = $154.10

On average, customers spend approximately $154 per order.
*/


/* ============================================================
   MONTHLY REVENUE TREND
============================================================ */

SELECT
EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP) AS month_number,
TO_CHAR(o.order_purchase_timestamp::TIMESTAMP,'Month') AS month_name,
ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP),
TO_CHAR(o.order_purchase_timestamp::TIMESTAMP,'Month')
ORDER BY month_number;

/*
Finding:

Highest Revenue Month: May = $1,746,900.97

Lowest Revenue Month: September = $732,454.23

Revenue generally peaks during:
- May
- July
- August

September and October should be interpreted carefully 
because of incomplete data periods.
*/


/* ============================================================
   CHRONOLOGICAL MONTHLY REVENUE TREND
============================================================ */

SELECT
DATE_TRUNC('month',o.order_purchase_timestamp::TIMESTAMP) AS month,
ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

/*
Finding:

Provides a true chronological revenue trend.
"2017-11-01 00:00:00"	1194882.80 has highest revenue (nov 2017)
"2018-04-01 00:00:00"	1160785.48 second highest (april 2018)
"2018-03-01 00:00:00"	1159652.12 third high (march 2018)

Useful for:
- Time-series analysis
- Trend visualization
- Dashboard reporting
*/


/* ============================================================
   YEARLY REVENUE
============================================================ */

SELECT
    EXTRACT(
        YEAR
        FROM o.order_purchase_timestamp::TIMESTAMP
    ) AS year,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

/*
Results:

2016 = $59,362.34
2017 = $7,249,746.73
2018 = $8,699,763.05

Finding:

Revenue increased approximately 20%
from 2017 to 2018.

This indicates strong marketplace growth.
*/


/* ============================================================
   MONTHLY ORDER TREND
============================================================ */

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP) AS month_number,
    TO_CHAR(
        o.order_purchase_timestamp::TIMESTAMP,
        'Month'
    ) AS month_name,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP),
    TO_CHAR(
        o.order_purchase_timestamp::TIMESTAMP,
        'Month'
    )
ORDER BY month_number;

/*
Finding:

Highest Order Volume:
August = 10,843 orders

Lowest Order Volume:
September = 4,305 orders

Order volume closely follows
the revenue pattern.
*/


/* ============================================================
   CHRONOLOGICAL MONTHLY ORDER TREND
============================================================ */

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp::TIMESTAMP
    ) AS month,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY 1
ORDER BY 1;

/*
Finding:

Provides a true chronological order trend.

Useful for:
- Growth analysis
- Dashboard visualizations
- Time-series reporting
*/


/* ============================================================
   YEARLY ORDERS
============================================================ */

SELECT
    EXTRACT(
        YEAR
        FROM o.order_purchase_timestamp::TIMESTAMP
    ) AS year,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY 1
ORDER BY 1;

/*
Results:

2016 = 329
2017 = 45,101
2018 = 54,011

Finding:

Orders increased approximately 20%
from 2017 to 2018.
*/


/* ============================================================
   EXECUTIVE SUMMARY
============================================================ */

/*
Marketplace KPIs

Total Revenue:
$16,008,872.12

Total Orders:
99,441

Average Order Value:
$154.10


Key Insights

1. Marketplace generated approximately $16 million in revenue.

2. Revenue grew approximately 20% from 2017 to 2018.

3. Orders grew approximately 20% from 2017 to 2018.

4. Revenue growth closely mirrors order growth, indicating that
   growth is primarily driven by increased order volume rather than
   higher order values.

5. Several edge months appear incomplete and should be excluded 
   from trend reporting when building dashboards.
*/