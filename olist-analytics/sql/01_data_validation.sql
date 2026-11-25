SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'; --gives all table names

SELECT COUNT(*) AS total_orders FROM orders; --99441
SELECT COUNT(*) AS total_customers FROM customers; --99441
SELECT COUNT(*) AS total_orders_items FROM order_items; --112650
SELECT COUNT(*) AS total_payments FROM order_payments; --103886
SELECT SUM(payment_value) AS total_revenue FROM order_payments; --16008872.119998764

SELECT COUNT(*) AS total_orders_reviews FROM order_reviews; --99224
SELECT COUNT(*) AS total_products FROM products; --32951
SELECT COUNT(*) AS total_sellers FROM sellers; --3095
SELECT COUNT(*) AS total_categories FROM category_translation; --71
SELECT * FROM category_translation; --71
SELECT COUNT(DISTINCT product_category_name_english) 
FROM category_translation; --71

--- ord
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS non_null_order_ids,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(order_id) AS null_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders;
-- Every order has a unique, non-null order_id. No primary-key issues found.

SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_ids,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS null_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_purchase_dates,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivery_dates,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS null_estimated_dates
FROM orders;

/* 
1. Every order has a customer, status and purchase timestamp.
2. 2,965 orders have no actual delivery date.
3. This is not automatically a data-quality issue. Orders that were cancelled, 
unavailable or still in progress may not have a delivery date.
*/

SELECT
    order_status,
    COUNT(*) AS orders_without_delivery_date
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY orders_without_delivery_date DESC;

-- Interpretation:
-- - Most missing delivery dates belong to orders that haven't reached the delivered stage. That's expected.
-- - However, 8 orders marked delivered have no actual delivery date. These need investigation.
-- - The 1,107 shipped orders also warrant attention: they may simply be in transit, 
-- but we should understand their delivery status.

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

 -- Identified 8 orders marked as delivered with missing order_delivered_customer_date. 
 -- These records were excluded from delivery-duration calculations where an actual delivery timestamp was required.

 SELECT
    COUNT(*) FILTER (
        WHERE order_approved_at < order_purchase_timestamp
    ) AS approval_before_purchase,

    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date < order_approved_at
    ) AS carrier_before_approval,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date < order_delivered_carrier_date
    ) AS customer_delivery_before_carrier,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date < order_purchase_timestamp
    ) AS delivery_before_purchase

FROM orders;

/*
2. Carrier handover before approval — 1,359
Investigate
For 1,359 records, the carrier handover timestamp is earlier than the approval timestamp.

Normally, we expect:
Purchase → Approval → Carrier handover → Customer delivery.

3. Customer delivery before carrier handover — 23
Investigate
For 23 records, the customer delivery timestamp is earlier than the carrier handover timestamp.

That is chronologically inconsistent.

*/

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_carrier_date < order_approved_at
ORDER BY order_approved_at
LIMIT 10;


-- 1,359 orders have carrier handover timestamps before approval.
-- Initial sample inspection confirms the inconsistency.
-- The underlying cause cannot be established from these timestamps alone.
-- Original records should remain unchanged.

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date
ORDER BY order_delivered_customer_date
LIMIT 10;


SELECT
    COUNT(*) AS affected_orders,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_delivered_carrier_date::timestamp
                - order_delivered_customer_date::timestamp
            )) / 86400
        )::numeric, 2
    ) AS avg_inconsistency_days,

    ROUND(
        MAX(
            EXTRACT(EPOCH FROM (
                order_delivered_carrier_date::timestamp
                - order_delivered_customer_date::timestamp
            )) / 86400
        )::numeric, 2
    ) AS max_inconsistency_days

FROM orders
WHERE order_delivered_customer_date::timestamp
    < order_delivered_carrier_date::timestamp;