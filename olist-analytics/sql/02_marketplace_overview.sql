/* ============================================================
   OLIST E-COMMERCE ANALYTICS PROJECT
   FILE: 02_marketplace_overview.sql

   PURPOSE:
   Analyze overall marketplace performance, including:
   - Revenue
   - Orders
   - Average Order Value (AOV)
   - Monthly trends
   - Yearly trends
   - Comparable-period year-over-year growth

   DATA COVERAGE NOTE:
   The dataset contains incomplete edge months:
   - September 2016
   - October 2016
   - December 2016
   - September 2018
   - October 2018

   Interpret these months cautiously. In particular, do not
   treat the low values in September/October 2018 as evidence
   of a business decline.

   REVENUE DEFINITION:
   Revenue in this file is calculated from order_payments.payment_value.
   It represents recorded payment value across orders in the dataset;
   it is not the delivered-order item revenue used in the dashboard
   analysis file (08_dashboard_queries.sql).

   Currency: Brazilian Real (BRL / R$).
============================================================ */


/* ============================================================
   1. TOTAL MARKETPLACE REVENUE
============================================================ */

SELECT
    ROUND(SUM(payment_value)::NUMERIC, 2) AS total_revenue
FROM order_payments;

/*
RESULT:
Total marketplace payment revenue = R$16,008,872.12

INTERPRETATION:
The sum includes payment records across the dataset and all
order statuses represented in order_payments.
*/


/* ============================================================
   2. AVERAGE ORDER VALUE (ORDER-LEVEL)
============================================================ */

WITH order_payments_total AS
(
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM order_payments
    GROUP BY order_id
)

SELECT
    COUNT(*) AS orders_with_payments,
    ROUND(AVG(order_total)::NUMERIC, 2) AS average_order_value
FROM order_payments_total;

/*
RESULT:
- Orders with payment records: 99,440
- Average order value: R$160.99

BUSINESS FINDINGS:
- AOV is calculated after summing all payment records belonging
  to each order. This avoids treating split payments as separate
  orders when calculating the average.
- One order in the orders table has no corresponding payment record.
*/


/* ============================================================
   3. REVENUE BY CALENDAR MONTH (ALL YEARS COMBINED)
============================================================ */

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP) AS month_number,
    TO_CHAR(o.order_purchase_timestamp::TIMESTAMP, 'Month') AS month_name,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP),
    TO_CHAR(o.order_purchase_timestamp::TIMESTAMP, 'Month')
ORDER BY month_number;

/*
RESULTS:
- Highest calendar-month revenue: May = R$1,746,900.97
- Lowest calendar-month revenue: September = R$732,454.23

INTERPRETATION:
These totals combine the same calendar month across all years.
September and October are affected by incomplete edge-month coverage,
so the lower September total should not be interpreted as a reliable
seasonal pattern.
*/


/* ============================================================
   4. CHRONOLOGICAL MONTHLY REVENUE TREND
============================================================ */

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP) AS month,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

/*
BUSINESS FINDINGS:
- November 2017 recorded the highest chronological monthly revenue:
  R$1,194,882.80.
- Revenue remained strong from January through August 2018.
- September and October 2018 have very low recorded revenue because
  these are incomplete dataset months.
- Use this query for a chronological monthly revenue line chart.
*/


/* ============================================================
   5. COMPARABLE-PERIOD REVENUE GROWTH (JANUARY–AUGUST)

   Compare the same eight calendar months in 2017 and 2018.
   This avoids comparing a partial 2018 year with the full 2017 year.
============================================================ */

WITH period_revenue AS
(
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp::TIMESTAMP) AS year,
        SUM(op.payment_value) AS revenue
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    WHERE
        EXTRACT(YEAR FROM o.order_purchase_timestamp::TIMESTAMP) IN (2017, 2018)
        AND EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP) BETWEEN 1 AND 8
    GROUP BY 1
),

revenue_comparison AS
(
    SELECT
        year,
        revenue,
        LAG(revenue) OVER (ORDER BY year) AS previous_period_revenue
    FROM period_revenue
)

SELECT
    year,
    ROUND(revenue::NUMERIC, 2) AS jan_aug_revenue,
    ROUND(previous_period_revenue::NUMERIC, 2) AS previous_year_jan_aug_revenue,
    ROUND(
        (
            (revenue - previous_period_revenue)
            / NULLIF(previous_period_revenue, 0) * 100
        )::NUMERIC,
        2
    ) AS revenue_growth_percentage
FROM revenue_comparison
ORDER BY year;

/*
RESULTS:
- January–August 2017 revenue: R$3,669,022.12
- January–August 2018 revenue: R$8,694,733.84
- Like-for-like revenue growth: approximately 136.96%

INTERPRETATION:
Revenue in January–August 2018 was approximately 136.96% higher
than in January–August 2017. This is the more appropriate comparison
for these years because it uses the same calendar-month window.
*/


/* ============================================================
   6. YEARLY REVENUE OVERVIEW

   Annual totals are useful for describing the data, but the years
   have different coverage. Do not interpret the raw 2017–2018
   difference as a like-for-like full-year growth rate.
============================================================ */

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp::TIMESTAMP) AS year,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

/*
RESULTS:
- 2016: R$59,362.34 (partial year)
- 2017: R$7,249,746.73
- 2018: R$8,699,763.05 (partial year)

INTERPRETATION:
The 2018 total is higher than the 2017 total even though 2018 has
incomplete coverage. However, the two annual totals do not represent
complete calendar years and should not be presented as a direct,
like-for-like annual growth comparison.
*/


/* ============================================================
   7. MONTHLY ORDER TREND (ALL YEARS COMBINED)
============================================================ */

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP) AS month_number,
    TO_CHAR(o.order_purchase_timestamp::TIMESTAMP, 'Month') AS month_name,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY
    EXTRACT(MONTH FROM o.order_purchase_timestamp::TIMESTAMP),
    TO_CHAR(o.order_purchase_timestamp::TIMESTAMP, 'Month')
ORDER BY month_number;

/*
RESULTS:
- Highest observed calendar-month order volume: August = 10,843 orders
- Lowest observed calendar-month order volume: September = 4,305 orders

INTERPRETATION:
These counts combine the same month across all years. September and
October are affected by incomplete dataset coverage, so the low
September total should not be interpreted as a reliable seasonal trend.
*/


/* ============================================================
   8. CHRONOLOGICAL MONTHLY ORDER TREND
============================================================ */

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP) AS month,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY 1
ORDER BY 1;

/*
INTERPRETATION:
This query preserves year and month together and provides the
chronological order trend for time-series reporting and dashboarding.

OBSERVATION:
- November 2017 recorded the highest monthly order volume:
  7,544 orders.
- September and October 2018 recorded only 16 and 4 orders,
  respectively, due to incomplete dataset coverage.
*/


/* ============================================================
   9. YEARLY ORDER VOLUME
============================================================ */

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp::TIMESTAMP) AS year,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY 1
ORDER BY 1;

/*
RESULTS:
- 2016: 329 orders (partial year)
- 2017: 45,101 orders
- 2018: 54,011 orders (partial year)

INTERPRETATION:
The 2018 observed total is higher than the 2017 total, but 2018 is
incomplete. Use the comparable-period query below for a more reliable
year-over-year order growth comparison.
*/


/* ============================================================
   10. COMPARABLE-PERIOD ORDER GROWTH (JANUARY–AUGUST)

   This uses the same eight calendar months in 2017 and 2018.
============================================================ */

WITH period_orders AS
(
    SELECT
        EXTRACT(YEAR FROM order_purchase_timestamp::TIMESTAMP) AS year,
        COUNT(*) AS total_orders
    FROM orders
    WHERE
        EXTRACT(YEAR FROM order_purchase_timestamp::TIMESTAMP) IN (2017, 2018)
        AND EXTRACT(MONTH FROM order_purchase_timestamp::TIMESTAMP) BETWEEN 1 AND 8
    GROUP BY 1
),

order_comparison AS
(
    SELECT
        year,
        total_orders,
        LAG(total_orders) OVER (ORDER BY year) AS previous_year_jan_aug_orders
    FROM period_orders
)

SELECT
    year,
    total_orders AS jan_aug_orders,
    previous_year_jan_aug_orders,
    ROUND(
        (
            (total_orders - previous_year_jan_aug_orders)::NUMERIC
            / NULLIF(previous_year_jan_aug_orders, 0) * 100
        ),
        2
    ) AS order_growth_percentage
FROM order_comparison
ORDER BY year;

/*
BUSINESS INSIGHTS:
- Orders increased from 22,968 in Jan-Aug 2017
  to 53,991 in Jan-Aug 2018.
- Like-for-like order growth was approximately 135.07%.
- Revenue grew by approximately 136.96% over the
  same period.
- Revenue growth slightly exceeded order growth,
  suggesting a modest increase in average revenue
  per order.
*/


/* ============================================================
   11. EXECUTIVE SUMMARY
============================================================ */

/*
MARKETPLACE OVERVIEW

Core KPIs:
- Total payment revenue: R$16,008,872.12
- Total orders: 99,441
- Orders with payment records: 99,440
- Order-level average order value (AOV): R$160.99

KEY FINDINGS:

1. The marketplace recorded approximately R$16.01 million in payment
   value across the available dataset.

2. The order-level AOV was R$160.99, calculated by first aggregating
   all payment records for each order.

3. November 2017 was the strongest chronological month for both
   revenue (R$1,194,882.80) and order volume (7,544 orders).

4. January–August revenue increased by approximately 136.96% from
   2017 to 2018, based on a comparable eight-month period.

5. The raw annual totals show R$7.25 million in 2017 and R$8.70 million
   in 2018. Since 2018 is incomplete, this is not a full-year,
   like-for-like growth comparison.

6. September and October at the beginning/end of the dataset have
   incomplete coverage and should be treated cautiously in trend
   analysis and dashboard reporting.

SCOPE NOTE:
These marketplace overview metrics use payment records across the
available dataset. Delivered-order revenue and delivered-order AOV
in 08_dashboard_queries.sql use a different population and revenue
basis; the two sets of metrics should not be mixed without labeling
that difference.
*/
