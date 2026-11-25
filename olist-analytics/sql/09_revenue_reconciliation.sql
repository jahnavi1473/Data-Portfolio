-- =====================================================
-- 09. REVENUE RECONCILIATION
-- Purpose: Compare delivered-order revenue calculated
-- from order_items against revenue recorded in payments.
-- =====================================================

WITH delivered_orders AS
(
    SELECT order_id
    FROM orders
    WHERE order_status = 'delivered'
),

item_revenue AS
(
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM order_items oi
    JOIN delivered_orders d
        ON oi.order_id = d.order_id
    GROUP BY oi.order_id
),

payment_revenue AS
(
    SELECT
        op.order_id,
        SUM(op.payment_value) AS revenue
    FROM order_payments op
    JOIN delivered_orders d
        ON op.order_id = d.order_id
    GROUP BY op.order_id
)

SELECT
    COUNT(DISTINCT d.order_id) AS delivered_orders,

    ROUND(
        SUM(i.revenue)::numeric, 2
    ) AS item_based_revenue,

    ROUND(
        SUM(p.revenue)::numeric, 2
    ) AS payment_based_revenue,

    ROUND(
        (SUM(p.revenue) - SUM(i.revenue))::numeric, 2
    ) AS revenue_difference

FROM delivered_orders d

LEFT JOIN item_revenue i
    ON d.order_id = i.order_id

LEFT JOIN payment_revenue p
    ON d.order_id = p.order_id;




SELECT
    COUNT(*) AS delivered_orders,

    COUNT(DISTINCT oi.order_id) AS orders_with_items,

    COUNT(DISTINCT op.order_id) AS orders_with_payments,

    COUNT(*) FILTER (
        WHERE oi.order_id IS NULL
    ) AS orders_without_items,

    COUNT(*) FILTER (
        WHERE op.order_id IS NULL
    ) AS orders_without_payments

FROM orders o

LEFT JOIN (
    SELECT DISTINCT order_id
    FROM order_items
) oi
    ON o.order_id = oi.order_id

LEFT JOIN (
    SELECT DISTINCT order_id
    FROM order_payments
) op
    ON o.order_id = op.order_id

WHERE o.order_status = 'delivered';



SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.customer_id
FROM orders o
LEFT JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
  AND op.order_id IS NULL;


SELECT
    order_id,
    COUNT(*) AS number_of_items,
    ROUND(SUM(price)::numeric, 2) AS item_price,
    ROUND(SUM(freight_value)::numeric, 2) AS freight_value,
    ROUND(SUM(price + freight_value)::numeric, 2) AS total_item_revenue
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c'
GROUP BY order_id;


-- Our overall reconciliation difference was 2,688.02.

-- The missing payment order accounts for 143.46 of that difference.
-- Remaining unexplained difference
-- 2,544.56 (2,688.02 − 143.461)


WITH item_revenue AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),

payment_revenue AS
(
    SELECT
        order_id,
        SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
)

SELECT
    o.order_id,
    ROUND(ir.item_revenue::numeric, 2) AS item_revenue,
    ROUND(pr.payment_revenue::numeric, 2) AS payment_revenue,
    ROUND(
        (pr.payment_revenue - ir.item_revenue)::numeric, 2
    ) AS difference

FROM orders o
JOIN item_revenue ir
    ON o.order_id = ir.order_id
JOIN payment_revenue pr
    ON o.order_id = pr.order_id

WHERE o.order_status = 'delivered'
  AND ABS(pr.payment_revenue - ir.item_revenue) > 0.01

ORDER BY ABS(pr.payment_revenue - ir.item_revenue) DESC
LIMIT 10;





SELECT
    order_id,
    'ORDER_ITEM' AS record_type,
    order_item_id::text AS record_id,
    NULL::text AS payment_type,
    NULL::integer AS installments,
    price,
    freight_value,
    price + freight_value AS record_value
FROM order_items
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665'

UNION ALL

SELECT
    order_id,
    'PAYMENT' AS record_type,
    payment_sequential::text AS record_id,
    payment_type,
    payment_installments AS installments,
    NULL::numeric AS price,
    NULL::numeric AS freight_value,
    payment_value AS record_value
FROM order_payments
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665'

ORDER BY record_type, record_id;



SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.price,
    oi.freight_value,
    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_id = 'ce6d150fb29ada17d2082f4847107665';


WITH item_revenue AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),

payment_revenue AS
(
    SELECT
        order_id,
        SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
),

reconciliation AS
(
    SELECT
        o.order_id,
        ir.item_revenue,
        pr.payment_revenue
    FROM orders o
    JOIN item_revenue ir ON o.order_id = ir.order_id
    JOIN payment_revenue pr ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    COUNT(*) AS orders_compared,

    COUNT(*) FILTER (
        WHERE ABS(payment_revenue - item_revenue) <= 0.01
    ) AS matching_orders,

    COUNT(*) FILTER (
        WHERE payment_revenue > item_revenue + 0.01
    ) AS payment_higher_orders,

    COUNT(*) FILTER (
        WHERE payment_revenue < item_revenue - 0.01
    ) AS payment_lower_orders

FROM reconciliation;


WITH item_revenue AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),

payment_revenue AS
(
    SELECT
        order_id,
        SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
),

reconciliation AS
(
    SELECT
        o.order_id,
        ir.item_revenue,
        pr.payment_revenue,
        pr.payment_revenue - ir.item_revenue AS difference
    FROM orders o
    JOIN item_revenue ir ON o.order_id = ir.order_id
    JOIN payment_revenue pr ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    ROUND(SUM(
        CASE WHEN difference > 0.01
        THEN difference ELSE 0 END
    )::numeric, 2) AS total_payment_higher,

    ROUND(SUM(
        CASE WHEN difference < -0.01
        THEN difference ELSE 0 END
    )::numeric, 2) AS total_payment_lower,

    ROUND(SUM(difference)::numeric, 2) AS net_difference

FROM reconciliation;


SELECT
    COUNT(*) AS orders_with_null_difference
FROM orders o
JOIN (
    SELECT order_id, SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
) ir ON o.order_id = ir.order_id
JOIN (
    SELECT order_id, SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
) pr ON o.order_id = pr.order_id
WHERE o.order_status = 'delivered'
  AND (ir.item_revenue IS NULL OR pr.payment_revenue IS NULL);



WITH item_revenue AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),

payment_revenue AS
(
    SELECT
        order_id,
        SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
),

reconciliation AS
(
    SELECT
        o.order_id,
        ir.item_revenue,
        pr.payment_revenue,
        pr.payment_revenue - ir.item_revenue AS difference
    FROM orders o
    JOIN item_revenue ir ON o.order_id = ir.order_id
    JOIN payment_revenue pr ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    COUNT(*) FILTER (
        WHERE difference > -0.01
          AND difference < 0.01
    ) AS within_tolerance,

    COUNT(*) FILTER (
        WHERE difference = 0.01
    ) AS exactly_positive_boundary,

    COUNT(*) FILTER (
        WHERE difference = -0.01
    ) AS exactly_negative_boundary

FROM reconciliation;



WITH item_revenue AS
(
    SELECT order_id, SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),
payment_revenue AS
(
    SELECT order_id, SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
),
reconciliation AS
(
    SELECT
        o.order_id,
        COALESCE(pr.payment_revenue, 0)
          - COALESCE(ir.item_revenue, 0) AS difference
    FROM orders o
    JOIN item_revenue ir ON o.order_id = ir.order_id
    JOIN payment_revenue pr ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    CASE
        WHEN ABS(difference) <= 0.01 THEN 'Matching'
        WHEN difference > 0.01 THEN 'Payment higher'
        WHEN difference < -0.01 THEN 'Payment lower'
        ELSE 'Unclassified'
    END AS category,
    COUNT(*) AS order_count
FROM reconciliation
GROUP BY 1
ORDER BY 1;


WITH item_revenue AS
(
    SELECT order_id, SUM(price + freight_value) AS item_revenue
    FROM order_items
    GROUP BY order_id
),
payment_revenue AS
(
    SELECT order_id, SUM(payment_value) AS payment_revenue
    FROM order_payments
    GROUP BY order_id
),
reconciliation AS
(
    SELECT
        ir.order_id,
        pr.payment_revenue - ir.item_revenue AS difference
    FROM orders o
    JOIN item_revenue ir ON o.order_id = ir.order_id
    JOIN payment_revenue pr ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    COUNT(*) AS matching_orders,
    ROUND(SUM(difference)::numeric, 2) AS net_difference_within_tolerance
FROM reconciliation
WHERE ABS(difference) <= 0.01;


/*
FINAL REVENUE RECONCILIATION

Delivered orders: 96,478

Orders with both item and payment records: 96,477
Orders without payment records: 1

Among the 96,477 comparable orders:
- Matching within 0.01: 96,103
- Payment higher: 286
- Payment lower: 88

Financial reconciliation:
- Positive differences: 3,031.48
- Negative differences: -199.57
- Differences within tolerance: -0.43
- Net difference: 2,831.48

Missing payment order item revenue: 143.46

Final overall difference: 2,688.02

Conclusion:
The difference between delivered item-based revenue
and payment-based revenue has been fully quantified.
*/


