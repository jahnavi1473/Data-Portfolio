/* ============================================================
   OLIST E-COMMERCE ANALYTICS PROJECT
   FILE: 09_revenue_reconciliation.sql

   PURPOSE:
   Reconcile delivered-order revenue calculated from order_items
   against payment revenue recorded in order_payments.

   REVENUE DEFINITIONS:
   - Item-based revenue = SUM(price + freight_value)
   - Payment-based revenue = SUM(payment_value)
   - Difference = payment-based revenue - item-based revenue

   SCOPE:
   Delivered orders only.

   CURRENCY:
   Brazilian Real (BRL / R$).

   TOLERANCE:
   Differences with an absolute value <= R$0.01 are classified
   as matching for order-level reconciliation.

   IMPORTANT:
   Payment revenue and item-based revenue are different source
   measures. A difference is quantified here; its underlying
   business cause is not assumed unless independently verified.
============================================================ */


/* ============================================================
   1. OVERALL DELIVERED-REVENUE RECONCILIATION

   BUSINESS QUESTION:
   How much revenue is recorded from delivered order items,
   and how does it compare with recorded payments?
============================================================ */

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
    COUNT(DISTINCT i.order_id) AS orders_with_items,
    COUNT(DISTINCT p.order_id) AS orders_with_payments,

    ROUND(SUM(i.revenue)::numeric, 2) AS item_based_revenue,
    ROUND(SUM(p.revenue)::numeric, 2) AS payment_based_revenue,

    ROUND(
        (SUM(p.revenue) - SUM(i.revenue))::numeric,
        2
    ) AS payment_minus_item_revenue_difference

FROM delivered_orders d
LEFT JOIN item_revenue i
    ON d.order_id = i.order_id
LEFT JOIN payment_revenue p
    ON d.order_id = p.order_id;

/*
RECORDED RESULT:
- Delivered orders: 96,478
- Item-based delivered revenue: R$15,419,773.75
- Payment-based delivered revenue: R$15,422,461.77
- Payment-minus-item difference: R$2,688.02

INTERPRETATION:
Recorded payment revenue is R$2,688.02 higher than delivered
item-based revenue. The following sections investigate missing
records and order-level differences contributing to this result.
*/


/* ============================================================
   2. CHECK DELIVERED ORDERS WITH ITEM AND PAYMENT RECORDS

   BUSINESS QUESTION:
   Do all delivered orders have corresponding item and payment
   records?
============================================================ */

SELECT
    COUNT(*) AS delivered_orders,

    COUNT(oi.order_id) AS orders_with_items,
    COUNT(op.order_id) AS orders_with_payments,

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

/*
RECORDED RESULT:
- Delivered orders: 96,478
- Orders with item records: 96,478
- Orders with payment records: 96,477
- Orders without item records: 0
- Orders without payment records: 1
*/


/* ============================================================
   3. IDENTIFY THE DELIVERED ORDER WITHOUT A PAYMENT RECORD
============================================================ */

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

/*
IDENTIFIED ORDER:
- Order ID: bfbd0f9bdef84302105ad712db648a6c
- Purchase date: 2016-09-15
*/


/* ============================================================
   4. CALCULATE ITEM REVENUE FOR THE ORDER WITHOUT PAYMENT
============================================================ */

SELECT
    order_id,
    COUNT(*) AS number_of_items,
    ROUND(SUM(price)::numeric, 2) AS item_price,
    ROUND(SUM(freight_value)::numeric, 2) AS freight_value,
    ROUND(SUM(price + freight_value)::numeric, 2)
        AS total_item_revenue
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c'
GROUP BY order_id;

/*
RECORDED RESULT:
- Item price: R$134.97
- Freight: R$8.49
- Total item-based revenue: R$143.46

INTERPRETATION:
This delivered order has R$143.46 in item-based revenue but
no corresponding payment record in order_payments. Its payment
value is therefore absent from the payment-based delivered total.
*/


/* ============================================================
   5. FIND THE LARGEST ORDER-LEVEL REVENUE DIFFERENCES

   Compare delivered orders that have both item and payment
   records. Differences are sorted by absolute amount.
============================================================ */

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
        (pr.payment_revenue - ir.item_revenue)::numeric,
        2
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

/*
INVESTIGATED ORDER:
- Order ID: ce6d150fb29ada17d2082f4847107665
- Item price: R$1,299.00
- Freight: R$104.66
- Item-based order revenue: R$1,403.66
- Payment value: R$1,586.47
- Payment-minus-item difference: R$182.81

The order has a credit-card payment with 10 installments.
This is an observed payment detail, not a proven explanation
for the difference. The cause has not been established by this
reconciliation analysis.
*/


/* ============================================================
   6. INSPECT ITEM AND PAYMENT RECORDS FOR THE INVESTIGATED ORDER
============================================================ */

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


/* ============================================================
   7. CLASSIFY COMPARABLE DELIVERED ORDERS

   Tolerance rule:
   - Matching: difference between -R$0.01 and +R$0.01,
     inclusive.
   - Payment higher: difference > R$0.01.
   - Payment lower: difference < -R$0.01.

   Orders without a payment record are excluded from this
   comparable-order classification and are reported separately.
============================================================ */

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
    JOIN item_revenue ir
        ON o.order_id = ir.order_id
    JOIN payment_revenue pr
        ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    COUNT(*) AS orders_compared,

    COUNT(*) FILTER (
        WHERE ABS(difference) <= 0.01
    ) AS matching_orders,

    COUNT(*) FILTER (
        WHERE difference > 0.01
    ) AS payment_higher_orders,

    COUNT(*) FILTER (
        WHERE difference < -0.01
    ) AS payment_lower_orders

FROM reconciliation;

/*
RECORDED RESULT:
- Orders compared: 96,477
- Matching within R$0.01: 96,103
- Payment higher: 286
- Payment lower: 88

The three categories sum to all 96,477 comparable orders.
*/


/* ============================================================
   8. SUM POSITIVE, NEGATIVE, AND NET DIFFERENCES

   The positive and negative totals below include only differences
   outside the R$0.01 tolerance. The net difference includes every
   comparable order, including differences within tolerance.
============================================================ */

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
    JOIN item_revenue ir
        ON o.order_id = ir.order_id
    JOIN payment_revenue pr
        ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN difference > 0.01 THEN difference
                ELSE 0
            END
        )::numeric,
        2
    ) AS total_payment_higher,

    ROUND(
        SUM(
            CASE
                WHEN difference < -0.01 THEN difference
                ELSE 0
            END
        )::numeric,
        2
    ) AS total_payment_lower,

    ROUND(SUM(difference)::numeric, 2) AS net_difference_all_comparable_orders

FROM reconciliation;

/*
RECORDED RESULT:
- Positive differences outside tolerance: R$3,031.48
- Negative differences outside tolerance: -R$199.57
- Net difference across all comparable orders: R$2,831.48

The net total also includes the combined effect of differences
within the R$0.01 tolerance. Their net contribution was -R$0.43.

Reconciliation:
R$3,031.48 - R$199.57 - R$0.43 = R$2,831.48
*/


/* ============================================================
   9. CHECK FOR NULL REVENUE VALUES IN DELIVERED ORDERS

   Use LEFT JOINs so that missing item/payment aggregates remain
   visible. An inner join would silently exclude missing records.
============================================================ */

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
    COUNT(*) FILTER (
        WHERE ir.order_id IS NULL
    ) AS orders_without_item_revenue,

    COUNT(*) FILTER (
        WHERE pr.order_id IS NULL
    ) AS orders_without_payment_revenue

FROM orders o
LEFT JOIN item_revenue ir
    ON o.order_id = ir.order_id
LEFT JOIN payment_revenue pr
    ON o.order_id = pr.order_id
WHERE o.order_status = 'delivered';

/*
RECORD-RESULT:
- Orders without item revenue: 0
- Orders without payment revenue: 1
*/


/* ============================================================
   10. VERIFY THE WITHIN-TOLERANCE DIFFERENCE

   This query isolates the net difference from orders classified
   as matching within the inclusive R$0.01 tolerance.
============================================================ */

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
        pr.payment_revenue - ir.item_revenue AS difference
    FROM orders o
    JOIN item_revenue ir
        ON o.order_id = ir.order_id
    JOIN payment_revenue pr
        ON o.order_id = pr.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    COUNT(*) AS orders_within_tolerance,
    ROUND(SUM(difference)::numeric, 2)
        AS net_difference_within_tolerance
FROM reconciliation
WHERE ABS(difference) <= 0.01;

/*
RECORDED RESULT:
- Orders within tolerance: 96,103
- Net difference within tolerance: -R$0.43
*/


/* ============================================================
   11. FINAL RECONCILIATION SUMMARY
============================================================ */

/*
FINAL REVENUE RECONCILIATION

SCOPE:
Delivered orders only.

ORDER COVERAGE:
- Delivered orders: 96,478
- Orders with item records: 96,478
- Orders with payment records: 96,477
- Orders without payment records: 1

REVENUE TOTALS:
- Item-based delivered revenue: R$15,419,773.75
- Payment-based delivered revenue: R$15,422,461.77
- Overall payment-minus-item difference: R$2,688.02

COMPARABLE ORDER CLASSIFICATION:
- Orders with both item and payment records: 96,477
- Matching within R$0.01: 96,103
- Payment higher by more than R$0.01: 286
- Payment lower by more than R$0.01: 88

FINANCIAL BREAKDOWN ACROSS COMPARABLE ORDERS:
- Positive differences outside tolerance: R$3,031.48
- Negative differences outside tolerance: -R$199.57
- Net difference within tolerance: -R$0.43
- Net difference across comparable orders: R$2,831.48

MISSING-PAYMENT ORDER:
- Item-based revenue: R$143.46
- Payment record: missing

FINAL BRIDGE:
R$2,831.48 - R$143.46 = R$2,688.02

CONCLUSION:
The difference between delivered item-based revenue and
payment-based revenue has been quantified and reconciled into:
(1) the net difference across orders with both item and payment
records, and (2) one delivered order with no payment record.

The analysis identifies the size and direction of the differences;
it does not establish the underlying cause of every order-level
payment/item discrepancy.
*/


/* ============================================================
   END OF FILE
============================================================ */
