/* ============================================================
   OLIST E-COMMERCE ANALYTICS PROJECT
   FILE: 03_customer_analytics.sql

   PURPOSE:
   Analyze customer behavior including:

   - Customer Base
   - Repeat Customers
   - Customer Spending
   - Customer Segmentation
   - Customer Retention

============================================================ */

/* ============================================================
   TOTAL CUSTOMERS
============================================================ */

SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers; --96096

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers; --99441

/*
Finding:

Total Customers = 96,096

customer_unique_id represents the actual customer.

customer_id should not be used for customer-level analysis because
one customer may have multiple customer_id records.
*/

/* ============================================================
   REPEAT CUSTOMER RATE
============================================================ */

WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN total_orders > 1
            THEN 1
            ELSE 0
        END
    ) AS repeat_customers,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN total_orders > 1
                THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;

/*
Finding:

Total Customers = 96,096

Repeat Customers = 2,997

Repeat Customer Rate = 3.12%

Approximately 97% of customers purchased only once.
*/

/* ============================================================
   CUSTOMER ORDER DISTRIBUTION
============================================================ */

SELECT
    COUNT(*) AS customers,
    total_orders
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t
GROUP BY total_orders
ORDER BY total_orders;

/*
Finding:

93,099 customers placed exactly one order.

Only a very small percentage of customers placed 3 or more orders.

Customer purchasing behavior is heavily skewed toward
one-time purchases.
*/

/* ============================================================
   AVERAGE CUSTOMER SPEND
============================================================ */

SELECT
    ROUND(AVG(customer_revenue)::NUMERIC,2)
    AS avg_customer_spend
FROM
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS customer_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
) t;

/*
Finding:

Average Customer Spend = $166.59 (revenue/total customers 96096)

This is only slightly higher than Average Order Value ($154.10),
which further supports the finding that most 
customers purchase only once.
*/

/* ============================================================
   TOP 10 CUSTOMERS BY REVENUE
============================================================ */

SELECT
    c.customer_unique_id,
    ROUND(
        SUM(op.payment_value)::NUMERIC,
        2
    ) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

/*
Business Question:

Who are our highest-value customers?

These customers may represent:
- VIP Customers
- Loyalty Program Candidates
- High Lifetime Value Customers
*/



SELECT
    COUNT(DISTINCT c.customer_unique_id)
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id; --96096

SELECT
    COUNT(DISTINCT c.customer_unique_id)
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id; --96095

-- payment cleared so no log in payment

(SELECT DISTINCT
    c.customer_unique_id
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

EXCEPT

SELECT DISTINCT
    c.customer_unique_id
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id); --830d5b7aaa3b6f1e9ad63703bec97d23 is the customer 


SELECT
    o.order_id,
    o.customer_id,
    o.order_status
FROM orders o

LEFT JOIN order_payments op
    ON o.order_id = op.order_id

WHERE op.order_id IS NULL; --"bfbd0f9bdef84302105ad712db648a6c"	"86dc2ffce2dfff336de2f386a786e574"	"delivered"


SELECT *
FROM orders
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';

SELECT *
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';

SELECT *
FROM order_reviews
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';
-- "I haven't received the product and haven't received any response from the company either was the review written."


/* ============================================================
   CUSTOMER REVENUE DISTRIBUTION
============================================================ */

WITH customer_revenue AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    MIN(revenue) AS min_customer_revenue,
    ROUND(AVG(revenue)::NUMERIC,2) AS avg_customer_revenue,
    ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY revenue)::NUMERIC,2) AS median_customer_revenue,
    MAX(revenue) AS max_customer_revenue
FROM customer_revenue;

/* 
Results:

Minimum Customer Revenue = $0.00

Average Customer Revenue = $166.59

Median Customer Revenue = $108.00

Maximum Customer Revenue = $13,664.08


Finding:

Customer revenue distribution is heavily
right-skewed.

The median customer spends only $108,
while the average customer spends $166.59.

This indicates that a relatively small
group of high-value customers spend
significantly more than the typical customer.

The highest-spending customer generated
$13,664.08 in revenue, which is over
126 times higher than the median customer spend.

This suggests substantial variation in
customer value across the marketplace.

Business Implication:

Not all customers contribute equally
to revenue generation.

A customer segmentation strategy may help
identify high-value customers and better
understand purchasing behavior.
*/


/* ============================================================
   CUSTOMER SPEND DISTRIBUTION
============================================================ */


WITH customer_revenue AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN revenue < 100 THEN '$0 - $99'
        WHEN revenue < 300 THEN '$100 - $299'
        WHEN revenue < 500 THEN '$300 - $499'
        WHEN revenue < 1000 THEN '$500 - $999'
        ELSE '$1000+'
    END AS spending_band,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS customer_percentage

FROM customer_revenue
GROUP BY 1
ORDER BY
    MIN(revenue);

/*
Results:

$0 - $99       : 44,390 customers (46.19%)

$100 - $299    : 40,937 customers (42.60%)

$300 - $499    : 6,279 customers (6.53%)

$500 - $999    : 3,271 customers (3.40%)

$1000+         : 1,218 customers (1.27%)


Major insight

88.79% of customers spent below $300.

This means the marketplace has a broad base of relatively lower-spending customers and a much smaller high-value customer segment.

Finding:

The customer base is heavily concentrated
in lower spending ranges.

Approximately 88.79% of customers spend
less than $300 throughout their lifetime
on the marketplace.

Only 1.27% of customers spend more than
$1,000, indicating a very small but
high-value customer segment.

The spending distribution confirms the
earlier finding that customer revenue is
right-skewed, where a small percentage
of customers contribute disproportionately
high revenue.

Business Implication:

Most customers are low-value or occasional
buyers, while a small group of high-value
customers may represent important retention
and loyalty opportunities.

Future analyses should focus on identifying
the characteristics of high-value customers
and understanding what differentiates them
from the broader customer base.
*/


/* ============================================================
   CUSTOMER VALUE SEGMENTATION
============================================================ */

/* created:

Low: < $100
Medium: $100–299
High: ≥ $500
VIP: ≥ $1,000 */


WITH customer_revenue AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN revenue >= 1000 THEN 'VIP'
        WHEN revenue >= 500 THEN 'High Value'
        WHEN revenue >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS customer_percentage,

    ROUND(
        AVG(revenue)::NUMERIC,
        2
    ) AS avg_customer_revenue

FROM customer_revenue
GROUP BY 1
ORDER BY avg_customer_revenue DESC;


/*
Results:

VIP Customers:
1,218 customers (1.27%)
Average Revenue: $1,600.10

High Value Customers:
3,271 customers (3.40%)
Average Revenue: $680.41

Medium Value Customers:
47,216 customers (49.13%)
Average Revenue: $193.88

Low Value Customers:
44,390 customers (46.19%)
Average Revenue: $60.38


Finding:

The customer base is dominated by
Medium Value and Low Value customers,
which together account for 95.32%
of all customers.

Only 4.67% of customers belong to the
High Value and VIP segments.

Despite their small population,
VIP customers generate significantly
higher revenue than the average customer.

The average VIP customer spends
approximately $1,600, which is nearly:

- 10x the average customer spend ($166.59)
- 26x the average Low Value customer spend ($60.38)

This highlights a strong concentration
of customer value within a small subset
of the customer base.

Business Implication:

Customer retention and loyalty strategies
should prioritize VIP and High Value customers,
as losing a small number of these customers
could have a disproportionate impact on revenue.

At the same time, there may be opportunities
to convert Medium Value customers into
High Value customers through targeted
marketing and engagement initiatives.
*/

/* ============================================================
   REVENUE CONTRIBUTION BY CUSTOMER SEGMENT
============================================================ */

WITH customer_revenue AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
),
customer_segments AS
(
    SELECT
        customer_unique_id,
        revenue,
        CASE
            WHEN revenue >= 1000 THEN 'VIP'
            WHEN revenue >= 500 THEN 'High Value'
            WHEN revenue >= 100 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_revenue
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        SUM(revenue)::NUMERIC,
        2
    ) AS segment_revenue,
ROUND(
    (
        SUM(revenue) * 100.0 /
        SUM(SUM(revenue)) OVER ()
    )::NUMERIC,
    2
) AS revenue_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

/*
Results:

Medium Value Customers:
47,216 customers (49.13%)
Revenue: $9,154,175.65 (57.18%)

Low Value Customers:
44,390 customers (46.19%)
Revenue: $2,680,143.21 (16.74%)

High Value Customers:
3,271 customers (3.40%)
Revenue: $2,225,629.75 (13.90%)

VIP Customers:
1,218 customers (1.27%)
Revenue: $1,948,923.51 (12.17%)

Finding:

Medium Value customers are the primary
revenue drivers, contributing 57.18%
of the marketplace revenue while
representing approximately half of the
customer base.

Although VIP customers account for only
1.27% of customers, they contribute
12.17% of total revenue.

Similarly, High Value and VIP customers
combined represent just 4.67% of the
customer base but contribute 26.07%
of the marketplace revenue.

Conversely, Low Value customers comprise
46.19% of customers but contribute only
16.74% of revenue.

Business Implication:

Medium Value customers should be nurtured
to improve retention and gradually move
them into the High Value segment.

VIP and High Value customers require
targeted loyalty and retention strategies
because a relatively small number of
customers contribute a significant share
of the marketplace revenue.

Low Value customers present an opportunity
for personalized campaigns aimed at
increasing purchase frequency and
customer lifetime value.
*/