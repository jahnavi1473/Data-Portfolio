/* ============================================================
   FILE: 08_dashboard_queries.sql

   PURPOSE:
   Create clean, dashboard-ready SQL queries for the BI report.+

   These queries consolidate the most important KPIs and
   analytical outputs from the marketplace analysis into
   structures suitable for Power BI / BI visualizations.

   ============================================================ */


/* ============================================================
   SECTION 8.1 — EXECUTIVE KPI SUMMARY

   BUSINESS QUESTION:
   What are the core marketplace KPIs that should appear at
   the top of the dashboard?

   METRICS:
   - Total Revenue
   - Delivered Orders
   - Average Order Value
   - Unique Customers
   - Repeat Customers
   - Repeat Customer Rate

   CUSTOMER DEFINITION:
   customer_unique_id is used for customer-level metrics because
   it represents the unique customer across multiple orders.

   ORDER SCOPE:
   Only delivered orders are included.

============================================================ */

WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,

        COUNT(
            DISTINCT o.order_id
        ) AS delivered_orders

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        c.customer_unique_id
)

SELECT
    SUM(
        oi.price + oi.freight_value
    ) AS total_revenue,

    COUNT(
        DISTINCT o.order_id
    ) AS total_orders,

    ROUND(
        (
            SUM(
                oi.price + oi.freight_value
            )
            /
            NULLIF(
                COUNT(DISTINCT o.order_id),
                0
            )
        )::numeric,
        2
    ) AS average_order_value,

    COUNT(
        DISTINCT c.customer_unique_id
    ) AS total_customers,

    COUNT(
        DISTINCT co.customer_unique_id
    ) FILTER (
        WHERE co.delivered_orders > 1
    ) AS repeat_customers,

    ROUND(
        (
            COUNT(
                DISTINCT co.customer_unique_id
            ) FILTER (
                WHERE co.delivered_orders > 1
            )
            * 100.0
            /
            NULLIF(
                COUNT(
                    DISTINCT c.customer_unique_id
                ),
                0
            )
        )::numeric,
        2
    ) AS repeat_customer_rate

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN customer_orders co
    ON c.customer_unique_id = co.customer_unique_id

WHERE o.order_status = 'delivered';


/* ============================================================
   KEY FINDINGS:

   The marketplace generated approximately 15.42M in revenue
   from 96,478 delivered orders.

   Average Order Value was 159.83.

   The delivered-order population contained 93,358 unique
   customers.

   2,801 customers made more than one delivered purchase,
   resulting in a repeat customer rate of 3.00%.

   BUSINESS IMPLICATION: 

   The marketplace generates substantial transaction volume,
   but the relatively low repeat customer rate indicates that
   customer retention and repeat purchasing represent important
   areas for further analysis.

   ============================================================ */


/* ============================================================
   SECTION 8.2 — Revenue Trend

   BUSINESS QUESTION:
   How has marketplace revenue changed month by month?

   METRICS:
   - Revenue Month
   - Total Orders
   - Total Revenue
   - Average Order Value

   ============================================================ */

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS revenue_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) 
	AS total_revenue,

    ROUND(
        (
            SUM(oi.price + oi.freight_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'

GROUP BY 1
ORDER BY 1;

	
/*============================================================
KEY FINDINGS:

1. Total delivered revenue across all months was approximately
   15,419,773.75.

2. Total delivered orders across all months were 96,478.

3. November 2017 recorded the highest monthly revenue,
   approximately 1,153,364.20.

4. November 2017 also recorded the highest delivered order
   volume, with 7,289 orders.

5. Monthly Average Order Value (AOV) fluctuated throughout
   the observation period. It ranged from 143.46 to 175.44
   in the months returned by this analysis.

6. The monthly revenue and order totals reconcile with the
   Executive KPI Summary (Section 8.1), confirming consistency
   between the two dashboard queries.

BUSINESS IMPLICATION:

- November 2017 was the strongest month in terms of both
  revenue and delivered order volume.
- Monthly revenue trends help identify peak business periods
  and changes in marketplace performance.
- Monitoring AOV alongside revenue and order volume helps
  distinguish growth driven by higher order volumes from
  changes in average order value.

============================================================*/

/* ============================================================
   SECTION 8.3 — Product & Category Performance

   Business question: Which product categories and 
   products generate the highest revenue and 
   sales volume?

   METRICS

   - Product category
   - Total revenue
   - Total quantity sold
   
============================================================*/

/* =============================================================
					Category Revenue
============================================================= */
SELECT
    pct.product_category_name,
    COALESCE(pc.product_category_name_english, 'Unknown') AS product_category,

    ROUND(
        SUM(oi.price + oi.freight_value)::numeric, 2
    ) AS total_revenue,

    COUNT(*) AS total_items_sold

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products pct
    ON oi.product_id = pct.product_id

LEFT JOIN category_translation pc
    ON pct.product_category_name = pc.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    pct.product_category_name,
    pc.product_category_name_english

ORDER BY total_revenue DESC;


/* =============================================================
					Top 10 Products by Revenue
============================================================= */

SELECT
    pct.product_id,
	
	pct.product_category_name,
	
    COALESCE(pc.product_category_name_english, 'Unknown') AS product_category,

    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
	
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products pct
    ON oi.product_id = pct.product_id

LEFT JOIN category_translation pc
    ON pct.product_category_name = pc.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    pct.product_id,
	pct.product_category_name,
	pc.product_category_name_english

ORDER BY total_revenue DESC
LIMIT 10;

/*============================================================

KEY FINDINGS:

1. The highest-revenue individual product generated 63,560.00
   in product revenue.

2. The second-highest product generated 53,652.30.

3. Health & Beauty had the strongest representation in the
   Top 10, with two products appearing in the ranking.

4. Computers and Computers Accessories also had products
   among the top revenue-generating products.

5. The results show that a small number of individual products
   generate substantial revenue across multiple categories.

BUSINESS IMPLICATION:

- Identify high-revenue products for inventory planning.
- Monitor the performance of top-selling products.
- Use product-level revenue rankings to support merchandising
  and product assortment decisions.
- Analyse category and product performance together to identify
  important revenue contributors.

================================================================ */


/* =============================================================
					Quantity Sold by Product Category
============================================================= */

SELECT
    pct.product_category_name,
    COALESCE(pc.product_category_name_english, 'Unknown') AS product_category,

    COUNT(*) AS total_items_sold

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products pct
    ON oi.product_id = pct.product_id

LEFT JOIN category_translation pc
    ON pct.product_category_name = pc.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    pct.product_category_name,
    pc.product_category_name_english

ORDER BY total_items_sold DESC;


/* ============================================================
KEY FINDINGS:

1. Bed, Bath & Table recorded the highest sales volume,
   with 10,953 items sold.

2. Health & Beauty ranked second, with 9,465 items sold.

3. Sports & Leisure ranked third, with 8,431 items sold.

4. Computers & Accessories recorded 7,644 items sold.

5. The Unknown category accounted for 1,537 items due to
   missing product category information.

BUSINESS IMPLICATION:

- High-volume categories can help guide inventory planning.
- Compare sales volume with revenue to understand differences
  in product pricing and category performance.
- Monitor missing category information to improve reporting
  accuracy.

============================================================= */


/* =============================================================
					Category Revenue Contribution (%)

Business question: What percentage of total revenue does each 
product category contribute?
============================================================= */

SELECT
    pct.product_category_name,
    COALESCE(pc.product_category_name_english, 'Unknown') 
	AS product_category,

    ROUND(SUM(oi.price)::numeric, 2) AS category_revenue,

    ROUND(
        (
            SUM(oi.price) * 100.0 /
            SUM(SUM(oi.price)) OVER ()
        )::numeric,
        2
    ) AS revenue_contribution_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products pct
    ON oi.product_id = pct.product_id

LEFT JOIN category_translation pc
    ON pct.product_category_name = pc.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    pct.product_category_name,
    pc.product_category_name_english

ORDER BY category_revenue DESC;

/* ==============================================================
KEY FINDINGS:

1. Health & Beauty contributed the highest share of product
   revenue at 9.33%.

2. Watches & Gifts ranked second, contributing 8.82%.

3. Bed, Bath & Table ranked third, contributing 7.74%.

4. The top 10 product categories collectively contributed
   approximately 56.05% of total product revenue.

5. Revenue is distributed across multiple product categories,
   with no single category dominating the marketplace.

6. Some categories contributed less than 0.10% of total
   product revenue, indicating a long-tail category distribution.

BUSINESS IMPLICATION:

- Identify high-contribution categories for merchandising
  and inventory planning.
- Monitor category-level revenue concentration.
- Explore growth opportunities in lower-contribution categories.
- Use revenue contribution percentages to compare category
  performance in the Power BI dashboard.

===================================================================== */


/* =============================================================
					Average Product Price by Category
================================================================= */

SELECT
    pct.product_category_name,
    COALESCE(pc.product_category_name_english, 'Unknown') 
	AS product_category,

    ROUND(AVG(oi.price)::numeric, 2) AS avg_product_price

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products pct
    ON oi.product_id = pct.product_id

LEFT JOIN category_translation pc
    ON pct.product_category_name = pc.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    pct.product_category_name,
    pc.product_category_name_english

ORDER BY avg_product_price DESC;	


/* ===========================================================
KEY FINDINGS:

1. Computers recorded the highest average product price
   at 1,098.92.

2. Small Appliances (Home Oven & Coffee) ranked second
   at 638.21.

3. Home Appliances 2 ranked third at 467.33.

4. Home Comfort 2 recorded the lowest average product
   price at 25.34.

5. Health & Beauty generated the highest category revenue,
   but its average product price was 130.28.

6. Bed, Bath & Table recorded the highest sales volume,
   while its average product price was 93.44.

BUSINESS IMPLICATION:

- Compare average prices with revenue and sales volume
  to understand category performance.
- Identify premium-priced categories and high-volume
  categories for inventory and pricing decisions.

========================================================== */

/* ============================================================
   SECTION 8.4 — Customer & RFM Dashboard Queries

   Business question: How many customers belong to each 
   RFM segment, and what percentage of the customer base 
   does each segment represent?

============================================================ */


WITH customer_segments AS 
(
	SELECT 
		customer_unique_id,
		r_score,
		frequency,
		m_score,

		CASE
            WHEN r_score >= 4
             AND frequency >= 2
             AND m_score >= 3
                THEN 'Champions'

            WHEN r_score <= 2
             AND frequency >= 2
                THEN 'At Risk'

            WHEN frequency >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
             AND frequency = 1
                THEN 'Promising'

            WHEN r_score = 1
             AND frequency = 1
                THEN 'Lost Customers'

            ELSE 'Hibernating'
        END AS customer_segment

    FROM vw_rfm_scores
)

SELECT 
	customer_segment,
	COUNT(*) AS segment_customers_count,
	SUM(COUNT(*)) OVER() AS total_customers,

	ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS segment_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_customers_count DESC;


/*=========================================================================

KEY FINDINGS:
1. Hibernating customers form the largest segment (38.73%).
2. Promising customers account for 38.64%.
3. Hibernating and Promising segments together represent 77.37%.
4. Lost customers account for 19.52%.
5. Champions represent only 0.25% of customers.

BUSINESS IMPLICATION:
The marketplace has a large inactive and one-time customer base.
Customer reactivation and repeat-purchase strategies could
help improve retention.

========================================================================== */


/* ================================================
	 Revenue Contribution by RFM Segment
================================================= */

-- Which customer segment contributes the most revenue?

WITH customer_segments AS 
(
	SELECT 
		customer_unique_id,
		r_score,
		frequency,
		m_score,
		monetary,

		CASE
            WHEN r_score >= 4
             AND frequency >= 2
             AND m_score >= 3
                THEN 'Champions'

            WHEN r_score <= 2
             AND frequency >= 2
                THEN 'At Risk'

            WHEN frequency >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
             AND frequency = 1
                THEN 'Promising'

            WHEN r_score = 1
             AND frequency = 1
                THEN 'Lost Customers'

            ELSE 'Hibernating'
        END AS customer_segment

    FROM vw_rfm_scores
)

SELECT 
	customer_segment,
	COUNT(*) AS segment_customers_count,
	SUM(COUNT(*)) OVER() AS total_customers,

	ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS segment_percentage,

	ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(AVG(monetary)::numeric, 2) AS average_monetary
	
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_customers_count DESC;


/* ==================================================================
KEY FINDINGS:
1. Promising customers generate the highest revenue (6.15M).
2. Hibernating customers form the largest segment but generate
   lower revenue (5.88M).
3. Loyal customers have the highest average monetary value (354.26).
4. At Risk customers have an average monetary value of 301.30.
5. Champions account for only 240 customers.

BUSINESS IMPLICATION:
Promising customers represent an opportunity for retention
and repeat purchases. At Risk and Hibernating customers
may need targeted reactivation campaigns.
====================================================================== */


/* ============================================================
	 Revenue Contribution Percentage by RFM Segment.
============================================================ */

WITH customer_segments AS 
(
	SELECT 
		customer_unique_id,
		r_score,
		frequency,
		m_score,
		monetary,

		CASE
            WHEN r_score >= 4
             AND frequency >= 2
             AND m_score >= 3
                THEN 'Champions'

            WHEN r_score <= 2
             AND frequency >= 2
                THEN 'At Risk'

            WHEN frequency >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
             AND frequency = 1
                THEN 'Promising'

            WHEN r_score = 1
             AND frequency = 1
                THEN 'Lost Customers'

            ELSE 'Hibernating'
        END AS customer_segment

    FROM vw_rfm_scores
)

SELECT 
	customer_segment,
	COUNT(*) AS segment_customers_count,
	SUM(COUNT(*)) OVER() AS total_customers,

	ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS segment_percentage,

	ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(AVG(monetary)::numeric, 2) AS average_monetary,

	ROUND(
    SUM(monetary) * 100.0
    / SUM(SUM(monetary)) OVER (),
    2
) AS revenue_contribution_percentage
	
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_customers_count DESC;

/* ================================================================
KEY FINDINGS:
1. Promising customers contribute the highest revenue (38.41%).
2. Hibernating customers contribute 36.75%.
3. Lost customers account for 18.95% of monetary value.
4. Loyal customers contribute 3.76% despite representing
   only 1.77% of customers.
5. The top three segments contribute 94.11% of total
   monetary value.

BUSINESS IMPLICATION:
Retention and reactivation strategies targeting Promising,
Hibernating and Lost customers may have significant impact.
================================================================ */

/* ============================================================
	 Average Order Frequency by RFM Segment
============================================================ */

WITH customer_segments AS 
(
	SELECT 
		customer_unique_id,
		r_score,
		frequency,
		m_score,
		monetary,

		CASE
            WHEN r_score >= 4
             AND frequency >= 2
             AND m_score >= 3
                THEN 'Champions'

            WHEN r_score <= 2
             AND frequency >= 2
                THEN 'At Risk'

            WHEN frequency >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
             AND frequency = 1
                THEN 'Promising'

            WHEN r_score = 1
             AND frequency = 1
                THEN 'Lost Customers'

            ELSE 'Hibernating'
        END AS customer_segment

    FROM vw_rfm_scores
)

SELECT 
	customer_segment,
	COUNT(*) AS segment_customers_count,
	SUM(COUNT(*)) OVER() AS total_customers,

	ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS segment_percentage,

	ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(AVG(monetary)::numeric, 2) AS average_monetary,

	ROUND(
    SUM(monetary) * 100.0
    / SUM(SUM(monetary)) OVER (),
    2
) AS revenue_contribution_percentage,

	ROUND(AVG(frequency)::numeric, 2) AS average_order_frequency
	
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_customers_count DESC;


/* =================================================================

KEY FINDINGS:
1. Hibernating, Promising and Lost customers average one order.
2. Loyal customers have the highest average frequency (2.15).
3. At Risk customers average 2.08 orders.
4. Champions average 2.02 orders.

BUSINESS IMPLICATION:
The marketplace has an opportunity to improve repeat purchases.
Retention campaigns and customer engagement strategies could
encourage one-time buyers to purchase again.

=====================================================================*/

/* ============================================================
	 Customer Value Analysis
============================================================ */

WITH customer_segments AS 
(
	SELECT 
		customer_unique_id,
		r_score,
		frequency,
		m_score,
		monetary,

		CASE
            WHEN r_score >= 4
             AND frequency >= 2
             AND m_score >= 3
                THEN 'Champions'

            WHEN r_score <= 2
             AND frequency >= 2
                THEN 'At Risk'

            WHEN frequency >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
             AND frequency = 1
                THEN 'Promising'

            WHEN r_score = 1
             AND frequency = 1
                THEN 'Lost Customers'

            ELSE 'Hibernating'
        END AS customer_segment

    FROM vw_rfm_scores
)

SELECT 
	customer_segment,
	ROUND(AVG(monetary)::numeric, 2) AS average_monetary,
	ROUND(AVG(frequency)::numeric, 2) AS average_order_frequency
	
FROM customer_segments
GROUP BY customer_segment
ORDER BY average_monetary DESC;

/* ==================================================================
KEY FINDINGS:
1. Loyal customers have the highest average monetary value (354.26).
2. At Risk customers have the second-highest average (301.30).
3. Champions have an average monetary value of 97.13.
4. Promising, Lost and Hibernating customers average one order.
5. Loyal customers average 2.15 orders.

BUSINESS IMPLICATION:
Prioritise retention of Loyal customers and investigate
the low average monetary value of the Champions segment.
================================================================= */

/* ============================================================
	8.5.1 — Delivery KPI Summary.

	Business question: How efficiently is the marketplace 
	delivering orders?

	- Total delivered orders.
	- Average delivery time (days).
	- On-time delivery percentage.
	- Late delivery percentage.
============================================================ */

WITH delivery_metrics AS
(
    SELECT
        order_id,
        order_status,

        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date::timestamp
                - order_purchase_timestamp::timestamp
            )
        ) / 86400.0 AS delivery_duration_days,

        order_delivered_customer_date,
        order_estimated_delivery_date

    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    COUNT(DISTINCT order_id) AS total_delivered_orders,

    ROUND(
        AVG(delivery_duration_days)::numeric,
        2
    ) AS average_delivery_days,

	ROUND(
    COUNT(
        CASE
            WHEN order_delivered_customer_date::timestamp
                 <= order_estimated_delivery_date::timestamp
            THEN order_id
        END
    ) * 100.0 / COUNT(DISTINCT order_id),
    2
) AS on_time_delivery_percentage,

ROUND(
    COUNT(
        CASE
            WHEN order_delivered_customer_date::timestamp
                 > order_estimated_delivery_date::timestamp
            THEN order_id
        END
    ) * 100.0 / COUNT(DISTINCT order_id),
    2
) AS late_delivery_percentage

FROM delivery_metrics;


/* ========================================================
KEY FINDINGS:
1. Total delivered orders: 96,478.
2. Average delivery time: 12.56 days.
3. On-time delivery rate: 91.88%.
4. Late delivery rate: 8.11%.

BUSINESS IMPLICATION:
Although the marketplace achieves a high on-time
delivery rate, approximately 8% of delivered orders
miss their estimated delivery dates.

Further investigation is required to identify
geographic and operational causes of delays.
========================================================= */

/* ========================================================
  				Delivery Delay Analysis

When an order is delivered late, how many days late is it on average?
========================================================= */


WITH delivery_metrics AS
(
    SELECT
        order_id,
        order_status,

        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date::timestamp
                - order_purchase_timestamp::timestamp
            )
        ) / 86400.0 AS delivery_duration_days,

        order_delivered_customer_date,
        order_estimated_delivery_date

    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    COUNT(DISTINCT order_id) AS total_late_orders,

    ROUND(
        AVG(EXTRACT(
    EPOCH FROM (
        order_delivered_customer_date::timestamp
        - order_estimated_delivery_date::timestamp
    )
) / 86400.0)::numeric,
        2
    ) AS average_delay_days,

	 ROUND(
        MAX(EXTRACT(
    EPOCH FROM (
        order_delivered_customer_date::timestamp
        - order_estimated_delivery_date::timestamp
    )
) / 86400.0)::numeric,
        2
    ) AS maximum_delay_days

FROM delivery_metrics
WHERE order_delivered_customer_date::timestamp
      > order_estimated_delivery_date::timestamp;


/* ==========================================================
KEY FINDINGS:
1. Total late orders: 7,826.
2. Average delay among late orders: 9.55 days.
3. Maximum delivery delay: 188.98 days.

BUSINESS IMPLICATION:
Late orders experience an average delay of approximately
9.55 days beyond the estimated delivery date.

The maximum delay of nearly 189 days indicates an
extreme delivery case that requires further investigation.

Further analysis can identify whether delays are
concentrated in specific states, sellers, or time periods.
========================================================= */

/* ==========================================================
		Delivery Performance by Customer State

Business question: Which Brazilian states have the longest 
average delivery times?
========================================================= */

SELECT
    c.customer_state,
	COUNT(DISTINCT o.order_id) AS total_delivered_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date::timestamp
                    - o.order_purchase_timestamp::timestamp
                )
            ) / 86400.0
        )::numeric,
        2
    ) AS average_delivery_days
	

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_state
ORDER BY average_delivery_days DESC;

/* =====================================================
KEY FINDINGS:
1. São Paulo (SP) has the lowest average delivery duration
   at 8.76 days, across 40,501 delivered orders.

2. Roraima (RR) has the highest average delivery duration
   at 29.39 days, across only 41 delivered orders.

3. Minas Gerais (MG) averages 12.01 days across
   11,354 delivered orders.

4. São Paulo contributes the largest delivered-order volume.

BUSINESS IMPLICATION:
Delivery duration varies considerably across customer states.
High averages in low-volume states should be interpreted
cautiously.

Further investigation should examine late-delivery rates
and geographic delivery patterns.
========================================================== */

