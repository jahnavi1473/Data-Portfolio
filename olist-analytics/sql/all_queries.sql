SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue
FROM order_payments;

SELECT
    COUNT(*) AS total_orders
FROM orders;

SELECT
    ROUND(AVG(payment_value)::numeric, 2) AS average_order_value
FROM order_payments;


-- monthly revenue
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS month,
    ROUND(SUM(op.payment_value)::numeric, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

-- yearly revenue
SELECT
	EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) AS year,
	ROUND(SUM(op.payment_value)::numeric, 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

--yearly orders
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
    COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;


--orders segmentation 
-- example how many customers placed 1 order, 2 orders etc...
-- we ain't dng cust a and his no. of orders thing

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


--- Repeat Customer Rate
--- repeat cust / total cust
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


-- products brought by customers
SELECT
    pct.product_category_name_english,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_items_sold DESC
LIMIT 20;


SELECT
    ROUND(AVG(customer_revenue)::numeric,2) AS avg_customer_spend
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