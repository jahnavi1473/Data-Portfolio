/* ============================================================
   FILE: 06_operations_analytics.sql

   PURPOSE:
   Analyze order delivery and operational performance to identify
   delivery efficiency, delays, freight cost patterns, regional
   operational differences, and seller-level fulfillment risks.

   KEY BUSINESS QUESTIONS:
   1. What is the overall delivery performance of the marketplace?
   2. How many orders are delivered on time versus late?
   3. How long does it take to deliver orders?
   4. How large are delivery delays when orders arrive late?
   5. How does delivery performance vary across customer states?
   6. What are the major freight cost patterns?
   7. How does freight cost relate to delivery performance?
   8. Which sellers show strong or weak fulfillment performance?
   9. Which high-revenue sellers have elevated delivery risk?
   10. Is seller revenue associated with late-delivery performance?
   11. How can sellers be segmented based on revenue and
       delivery risk?

   DATASETS / TABLES USED:
   - orders
   - order_items
   - order_payments
   - customers
   - sellers

   ============================================================ */



SELECT * FROM ORDERS;

/* ============================================================
   SECTION 1A: ORDER DELIVERY DATA VALIDATION

   Purpose:
   Understand order statuses and availability of delivery
   timestamps before calculating operational KPIs.

============================================================ */

SELECT
    order_status,
    COUNT(*) AS order_count,

    COUNT(order_purchase_timestamp) AS purchase_date_count,

    COUNT(order_delivered_customer_date)
        AS delivered_customer_date_count,

    COUNT(order_estimated_delivery_date)
        AS estimated_delivery_date_count

FROM orders

GROUP BY order_status

ORDER BY order_count DESC;

/* ============================================================
   SECTION 1B: DELIVERY DATE RANGE VALIDATION

   Purpose:
   Check the available delivery dates and identify potential
   invalid delivery durations.

============================================================ */

SELECT
    MIN(order_purchase_timestamp) AS earliest_purchase,
    MAX(order_purchase_timestamp) AS latest_purchase,

    MIN(order_delivered_customer_date)
        AS earliest_delivery,

    MAX(order_delivered_customer_date)
        AS latest_delivery,

    MIN(order_estimated_delivery_date)
        AS earliest_estimated_delivery,

    MAX(order_estimated_delivery_date)
        AS latest_estimated_delivery

FROM orders;


/* ============================================================
   SECTION 1: OVERALL DELIVERY PERFORMANCE

   Business Question:
   How quickly are delivered orders reaching customers?

   Definition:
   Delivery time = customer delivery timestamp
                    order purchase timestamp

   Population:
   Delivered orders with a valid customer delivery timestamp.

============================================================ */

SELECT
    COUNT(*) AS delivered_orders_with_delivery_date,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_purchase_timestamp::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS average_delivery_days,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_purchase_timestamp::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS median_delivery_days,

    ROUND(
        MIN(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_purchase_timestamp::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS minimum_delivery_days,

    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_purchase_timestamp::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS maximum_delivery_days

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

/* ============================================================
   RESULTS / KEY FINDINGS

   • 96,470 delivered orders had a valid customer delivery
     timestamp and were included in deliverytime analysis.

   • Average delivery time was 12.56 days.

   • Median delivery time was 10.22 days, meaning 50% of
     delivered orders were completed within approximately
     10.22 days.

   • The average delivery time is higher than the median,
     indicating a rightskewed deliverytime distribution
     caused by a smaller number of very long deliveries.

   • Minimum observed delivery time was 0.53 days
     (approximately 12.7 hours).

   • Maximum observed delivery time was 209.63 days,
     indicating the presence of extreme longduration
     deliveries that should be investigated separately.

   BUSINESS IMPLICATION:

   Most orders were delivered within approximately two weeks,
   but the large gap between median and maximum delivery time
   suggests that a subset of orders experienced exceptionally
   long fulfillment or delivery durations.

============================================================ */

/* ============================================================
   SECTION 2: ONTIME VS LATE DELIVERY

   Business Question:
   How often are customers receiving orders by the estimated
   delivery date?

   Definition:
   On Time = actual delivery date <= estimated delivery date
   Late    = actual delivery date > estimated delivery date

============================================================ */

SELECT
    CASE
        WHEN order_delivered_customer_date::timestamp
             <= order_estimated_delivery_date::timestamp
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_performance,

    COUNT(*) AS order_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN order_delivered_customer_date::timestamp
             <= order_estimated_delivery_date::timestamp
            THEN 'On Time'
        ELSE 'Late'
    END

ORDER BY order_count DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   • 96,470 delivered orders had both actual and estimated
     delivery dates available for comparison.

   • 88,644 orders (91.89%) were delivered on or before the
     estimated delivery date.

   • 7,826 orders (8.11%) were delivered after the estimated
     delivery date.

   • Approximately 9 out of 10 delivered orders met the
     estimated delivery date.

   BUSINESS IMPLICATION:

   Overall delivery reliability was relatively high, with
   most delivered orders meeting the estimated delivery date.
   However, the 7,826 late deliveries represent a meaningful
   operational population that should be investigated further
   to understand the magnitude and distribution of delays.

============================================================ */

/* ============================================================
   SECTION 3: DELIVERY DELAY ANALYSIS

   Business Question:
   When orders are delivered late, how many days beyond the
   estimated delivery date do they arrive?

   Definition:
   Delay = actual delivery timestamp
            estimated delivery date

   Population:
   Delivered orders where actual delivery occurred after the
   estimated delivery date.

============================================================ */

SELECT
    COUNT(*) AS late_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_estimated_delivery_date::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS average_delay_days,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_estimated_delivery_date::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS median_delay_days,

    ROUND(
        MIN(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_estimated_delivery_date::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS minimum_delay_days,

    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::timestamp
                     order_estimated_delivery_date::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS maximum_delay_days

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date::timestamp
      > order_estimated_delivery_date::timestamp;

/* ============================================================
   RESULTS / KEY FINDINGS

   • 7,826 delivered orders were classified as late.

   • Average delivery delay among late orders was 9.55 days.

   • Median delay was 5.81 days, indicating that the typical
     late order was delayed by approximately 6 days.

   • The average delay was substantially higher than the median,
     indicating a rightskewed delay distribution with a smaller
     number of extremely delayed orders.

   • Maximum observed delay was 188.98 days, indicating the
     presence of extreme latedelivery cases that may require
     further investigation.

   • The minimum delay rounds to 0.00 days because the estimated
     delivery date is stored at midnight while the actual
     delivery timestamp includes timeofday information.

   BUSINESS IMPLICATION:

   Although only 8.11% of delivered orders were late, the
   severity of delays varies substantially. Most late orders
   experienced relatively moderate delays, while a small number
   of extreme cases significantly increased the average delay.
   Further analysis should identify where these extreme delays
   occur geographically and whether they are concentrated among
   specific sellers or operational conditions.

============================================================ */

/* ============================================================
   SECTION 4 — DELIVERY DELAY DISTRIBUTION

   BUSINESS QUESTION:
   How severe are late deliveries?

   PURPOSE:
   Categorize late orders by the number of days they exceeded
   the estimated delivery date.

   DELAY BUCKETS:
   0–3 days   → Minor Delay
   4–7 days   → Moderate Delay
   8–14 days  → Significant Delay
   15–30 days → Severe Delay
   30+ days   → Extreme Delay

============================================================ */

WITH late_orders AS
(
    SELECT
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date::timestamp
                 order_estimated_delivery_date::timestamp
            )
        ) / 86400 AS delay_days

    FROM orders

    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL

       Only analyze orders that were actually late
      AND order_delivered_customer_date::timestamp
          > order_estimated_delivery_date::timestamp
),

delay_distribution AS
(
    SELECT
        CASE
            WHEN delay_days <= 3
                THEN '03 Days'

            WHEN delay_days <= 7
                THEN '47 Days'

            WHEN delay_days <= 14
                THEN '814 Days'

            WHEN delay_days <= 30
                THEN '1530 Days'

            ELSE '30+ Days'
        END AS delay_bucket

    FROM late_orders
)

SELECT
    delay_bucket,

    COUNT(*) AS late_order_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_late_orders

FROM delay_distribution

GROUP BY delay_bucket

ORDER BY
    CASE delay_bucket
        WHEN '03 Days' THEN 1
        WHEN '47 Days' THEN 2
        WHEN '814 Days' THEN 3
        WHEN '1530 Days' THEN 4
        WHEN '30+ Days' THEN 5
    END;

/* ============================================================
   RESULTS / KEY FINDINGS

   • 7,826 delivered orders were classified as late.

   • 2,662 late orders (34.01%) were delayed by 0–3 days.

   • 1,819 late orders (23.24%) were delayed by 4–7 days.

   • 1,790 late orders (22.87%) were delayed by 8–14 days.

   • 1,195 late orders (15.27%) were delayed by 15–30 days.

   • 360 late orders (4.60%) experienced delays of more
     than 30 days.

   • 57.25% of late orders were delayed by 7 days or less.

   • 80.12% of late orders were delayed by 14 days or less.

   • The remaining 19.87% experienced delays greater than
     14 days.

   BUSINESS IMPLICATION:

   Most late deliveries involved relatively short delays,
   with more than half of late orders arriving within seven
   days after the estimated delivery date.

   However, a meaningful minority experienced delays exceeding
   two weeks, including 360 orders delayed by more than
   30 days. These extreme cases should be investigated
   separately because they may represent specific operational,
   seller, geographic, or fulfillment issues.

============================================================ */


/* ============================================================
   SECTION 5 — DELIVERY PERFORMANCE BY CUSTOMER STATE

   BUSINESS QUESTION:
   Does delivery performance vary across customer states?

   PURPOSE:
   Compare delivery speed and delivery reliability across
   customer states.

   METRICS:
    Delivered orders
    Average delivery days
    Ontime orders
    Late orders
    Ontime delivery %
    Late delivery %

   DATASETS / TABLES USED:
    orders
    customers

============================================================ */

SELECT
    c.customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date::timestamp
                     o.order_purchase_timestamp::timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS average_delivery_days,

    COUNT(*) FILTER
    (
        WHERE
            o.order_delivered_customer_date::timestamp
            <= o.order_estimated_delivery_date::timestamp
    ) AS on_time_orders,

    COUNT(*) FILTER
    (
        WHERE
            o.order_delivered_customer_date::timestamp
            > o.order_estimated_delivery_date::timestamp
    ) AS late_orders,

    ROUND(
        COUNT(*) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                <= o.order_estimated_delivery_date::timestamp
        ) * 100.0
        / COUNT(*),
        2
    ) AS on_time_percentage,

    ROUND(
        COUNT(*) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                > o.order_estimated_delivery_date::timestamp
        ) * 100.0
        / COUNT(*),
        2
    ) AS late_percentage

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    c.customer_state

ORDER BY
    late_percentage DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   • Delivery performance varies considerably across customer
     states.

   • AL recorded the highest latedelivery percentage in the
     dataset at 23.93%, based on 397 delivered orders.

   • MA recorded the secondhighest latedelivery percentage
     at 19.67%, based on 717 delivered orders.

   • Several highvolume states also showed meaningful
     differences in delivery performance.

   • SP had 40,494 delivered orders, an average delivery time
     of 8.76 days, and a latedelivery rate of 5.89%.

   • MG had 11,354 delivered orders, an average delivery time
     of 12.01 days, and a latedelivery rate of 5.61%.

   • PR had 4,923 delivered orders, an average delivery time
     of 11.99 days, and a latedelivery rate of 5.00%.

   • RS had 5,344 delivered orders, an average delivery time
     of 15.30 days, and a latedelivery rate of 7.15%.

   • States with small order volumes can show large percentage
     differences from a relatively small number of orders.
     Therefore, latedelivery percentage should be interpreted
     together with deliveredorder volume.

   BUSINESS IMPLICATION:

   Delivery performance is not uniform across geographic
   regions. The variation suggests that regional delivery
   performance should be investigated further.

   However, statelevel latedelivery percentages alone do
   not explain the underlying cause. Further analysis of
   freight costs, seller performance, and other operational
   factors is required before drawing conclusions about the
   drivers of regional differences.

============================================================ */

/* ============================================================
   SECTION 6 — FREIGHT COST ANALYSIS

   BUSINESS QUESTION:
   How much freight value is associated with each order,
   and how does freight compare with product value?

   IMPORTANT:
   order_items contains one row per product item.
   Therefore, freight is first aggregated to the order level
   before calculating orderlevel metrics.

   DATASETS / TABLES USED:
    orders
    order_items

============================================================ */

WITH order_level_freight AS
(
    SELECT
        o.order_id,

        SUM(oi.price) AS order_item_value,

        SUM(oi.freight_value) AS order_freight_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        o.order_id
)

SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        SUM(order_item_value)::NUMERIC,
        2
    ) AS total_item_value,

    ROUND(
        SUM(order_freight_value)::NUMERIC,
        2
    ) AS total_freight_value,

    ROUND(
        AVG(order_item_value)::NUMERIC,
        2
    ) AS average_item_value_per_order,

    ROUND(
        AVG(order_freight_value)::NUMERIC,
        2
    ) AS average_freight_per_order,

    ROUND(
        (
            SUM(order_freight_value)
            / NULLIF(SUM(order_item_value), 0)
        )::NUMERIC * 100,
        2
    ) AS freight_percentage_of_item_value

FROM order_level_freight;

/* ============================================================
   RESULTS / KEY FINDINGS

   • 96,478 delivered orders were included in the freight
     analysis.

   • Total product/item value across these orders was
     13,221,498.11.

   • Total freight value was 2,198,275.64.

   • Average product/item value per delivered order was
     137.04.

   • Average freight value per delivered order was 22.79.

   • Freight value represented 16.63% of total item value.

   BUSINESS IMPLICATION:

   Freight represents a meaningful component of marketplace
   transaction value, accounting for approximately 16.63% of
   total item value in the deliveredorder population.

   Because freight costs can vary substantially by geography,
   order size, and product characteristics, further analysis
   should examine freight variation across customer states
   and determine whether higher freight values are associated
   with longer delivery times.

   NOTE:

   Item value and freight value are based on the corresponding
   fields in order_items. These metrics should not be directly
   interpreted as total customer payment or marketplace revenue.

============================================================ */


/* ============================================================
   SECTION 6B — FREIGHT PERFORMANCE BY CUSTOMER STATE

   BUSINESS QUESTION:
   How does freight value vary across customer states?

============================================================ */

WITH order_level_freight AS
(
    SELECT
        o.order_id,
        o.customer_id,

        SUM(oi.price) AS order_item_value,

        SUM(oi.freight_value) AS order_freight_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        o.order_id,
        o.customer_id
)

SELECT
    c.customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(olf.order_item_value)::NUMERIC,
        2
    ) AS average_item_value,

    ROUND(
        AVG(olf.order_freight_value)::NUMERIC,
        2
    ) AS average_freight,

    ROUND(
        (
            SUM(olf.order_freight_value)
            / NULLIF(SUM(olf.order_item_value), 0)
        )::NUMERIC * 100,
        2
    ) AS freight_percentage_of_item_value

FROM order_level_freight olf

JOIN customers c
    ON olf.customer_id = c.customer_id

GROUP BY
    c.customer_state

ORDER BY
    freight_percentage_of_item_value DESC;


/* ============================================================
   RESULTS / KEY FINDINGS

   • Freighttoitemvalue ratios varied considerably across
     customer states.

   • RR recorded the highest freighttoitemvalue ratio at
     28.08%, based on 41 delivered orders.

   • MA recorded a freighttoitemvalue ratio of 26.32%
     across 717 delivered orders.

   • RO recorded 24.70% across 243 delivered orders.

   • Several states with larger order volumes also showed
     relatively high freight ratios. For example, PE recorded
     22.66% across 1,593 orders and BA recorded 19.76% across
     3,256 orders.

   • Among the largest customer markets, SP had 40,501 delivered
     orders and the lowest freighttoitemvalue ratio in the
     dataset at 13.85%.

   • The overall marketplace freighttoitemvalue ratio was
     16.63%.

   • Statelevel freight ratios should be interpreted together
     with order volume because small populations can produce
     unstable percentage estimates.

   BUSINESS IMPLICATION:

   Freight burden varies meaningfully across customer states.
   The variation may reflect differences in shipping distance,
   order composition, logistics conditions, or other operational
   factors.

   The statelevel analysis identifies geographic differences
   that warrant further investigation, but it does not by
   itself establish the cause of those differences.

============================================================ */

/* ============================================================
   SECTION 7A — FREIGHT VS DELIVERY PERFORMANCE

   BUSINESS QUESTION:
   Do states with higher freighttoitemvalue ratios also
   tend to have higher latedelivery rates?

   PURPOSE:
   Combine statelevel delivery reliability and freight metrics
   so that their relationship can be evaluated.

============================================================ */

WITH order_level_freight AS
(
    SELECT
        o.order_id,
        o.customer_id,

        SUM(oi.price) AS order_item_value,

        SUM(oi.freight_value) AS order_freight_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        o.order_id,
        o.customer_id
),

state_metrics AS
(
    SELECT
        c.customer_state,

        COUNT(*) AS delivered_orders,

        ROUND(
            COUNT(*) FILTER
            (
                WHERE
                    o.order_delivered_customer_date::timestamp
                    > o.order_estimated_delivery_date::timestamp
            ) * 100.0
            / COUNT(*),
            2
        ) AS late_percentage,

        ROUND(
            (
                SUM(olf.order_freight_value)
                / NULLIF(SUM(olf.order_item_value), 0)
            )::NUMERIC * 100,
            2
        ) AS freight_percentage_of_item_value

    FROM order_level_freight olf

    JOIN orders o
        ON olf.order_id = o.order_id

    JOIN customers c
        ON olf.customer_id = c.customer_id

    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        c.customer_state
)

SELECT
    customer_state,
    delivered_orders,
    late_percentage,
    freight_percentage_of_item_value

FROM state_metrics

ORDER BY late_percentage DESC;


/* ============================================================
   SECTION 7B — STATELEVEL CORRELATION

   Calculate the Pearson correlation between freight burden
   and latedelivery rate across customer states.

============================================================ */

WITH order_level_freight AS
(
    SELECT
        o.order_id,
        o.customer_id,

        SUM(oi.price) AS order_item_value,

        SUM(oi.freight_value) AS order_freight_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        o.order_id,
        o.customer_id
),

state_metrics AS
(
    SELECT
        c.customer_state,

        COUNT(*) AS delivered_orders,

        COUNT(*) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                > o.order_estimated_delivery_date::timestamp
        ) * 100.0 / COUNT(*) AS late_percentage,

        SUM(olf.order_freight_value)
        / NULLIF(SUM(olf.order_item_value), 0)
        * 100 AS freight_percentage_of_item_value

    FROM order_level_freight olf

    JOIN orders o
        ON olf.order_id = o.order_id

    JOIN customers c
        ON olf.customer_id = c.customer_id

    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        c.customer_state
)

SELECT
    ROUND(
        CORR(
            freight_percentage_of_item_value,
            late_percentage
        )::NUMERIC,
        4
    ) AS freight_late_correlation

FROM state_metrics;


/* ============================================================
   SECTION 7B — RESULTS / KEY FINDINGS

   • The Pearson correlation between freighttoitemvalue
     ratio and latedelivery percentage was 0.2284.

   • This indicates a weak positive association between
     freight burden and latedelivery rates at the state level.

   • States with higher freighttoitemvalue ratios tended
     to have somewhat higher latedelivery rates, but the
     relationship was weak.

   • The relationship is not consistent across all states.
     For example, RO had a relatively high freight ratio of
     24.70% but a low latedelivery rate of 2.88%.

   • SP had a lower freight ratio of 13.85% and a latedelivery
     rate of 5.89%.

   BUSINESS IMPLICATION:

   Freight burden alone does not appear to explain delivery
   delays strongly at the state level. Other operational
   factors such as delivery distance, logistics conditions,
   seller location, product characteristics, and order
   processing time may also contribute to delivery performance.

   LIMITATION:

   The correlation is based on statelevel aggregated data,
   so it measures association across states rather than
   relationships between individual orders. It does not
   establish causation.

============================================================ */

/* ============================================================
   SECTION 8 — SELLER / FULFILLMENT PERFORMANCE

   BUSINESS QUESTION:
   How does seller performance vary in terms of order volume
   and delivery reliability?

============================================================ */

/* ------------------------------------------------------------
   STEP 8A — SELLER DELIVERY PERFORMANCE
------------------------------------------------------------ */

WITH seller_orders AS
(
    SELECT
        oi.seller_id,
        o.order_id,

        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

      AND o.order_delivered_customer_date IS NOT NULL

      AND o.order_estimated_delivery_date IS NOT NULL
),

seller_performance AS
(
    SELECT

        seller_id,

        COUNT(DISTINCT order_id) AS delivered_orders,

        COUNT(DISTINCT order_id) FILTER
        (
            WHERE
                order_delivered_customer_date::timestamp
                >
                order_estimated_delivery_date::timestamp
        ) AS late_orders,

        ROUND(
            AVG(
                EXTRACT(
                    EPOCH FROM (
                        order_delivered_customer_date::timestamp
                        -
                        order_purchase_timestamp::timestamp
                    )
                ) / 86400.0
            )::NUMERIC,
            2
        ) AS average_delivery_days

    FROM seller_orders

    GROUP BY
        seller_id
)

SELECT

    seller_id,

    delivered_orders,

    late_orders,

    ROUND(
        late_orders * 100.0
        / NULLIF(delivered_orders, 0),
        2
    ) AS late_percentage,

    average_delivery_days

FROM seller_performance

WHERE delivered_orders >= 20

ORDER BY
    late_percentage DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   Among 804 sellers with at least 20 delivered orders,
   the average late-delivery rate was 7.76%, with rates
   ranging from 0% to 37.5%.

   Average delivery time was 12.2 days, ranging from
   4.66 to 31.73 days.

   This indicates substantial variation in fulfillment
   performance across sellers.

 ==============================================================*/

/* ------------------------------------------------------------
   STEP 8B — SELLER REVENUE & ORDER PERFORMANCE

   Business Question:
   Which sellers generate the most revenue, and how does
   their order volume compare with their average order value?

   Purpose:
   Evaluate seller-level commercial performance using
   delivered orders, revenue, and average order value.
------------------------------------------------------------ */

WITH seller_performance AS
(
    SELECT

        oi.seller_id,

        COUNT(DISTINCT o.order_id) AS delivered_orders,

        ROUND(
            SUM(op.payment_value)::NUMERIC,
            2
        ) AS total_revenue

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT

    seller_id,

    delivered_orders,

    total_revenue,

    ROUND(
        total_revenue
        / NULLIF(delivered_orders, 0),
        2
    ) AS average_order_value

FROM seller_performance

WHERE delivered_orders >= 20

ORDER BY
    total_revenue DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   Among 804 sellers with at least 20 delivered orders,
   the median seller processed 52.5 delivered orders and
   generated $9,724.03 in revenue.

   The median average order value was $161.62.

   Seller performance varied substantially:
   the highest-volume seller processed 1,819 delivered orders,
   while the highest-revenue seller generated $505,437.16.

   Average order value also varied considerably, ranging from
   $22.16 to $1,869.17.

   This indicates substantial variation in seller scale,
   revenue generation, and order-value profiles.

============================================================ */

/* ------------------------------------------------------------
   STEP 8C — SELLER DELIVERY VS REVENUE PERFORMANCE

   Business Question:
   Do high-revenue sellers also maintain good delivery
   performance?

   Purpose:
   Combine seller commercial performance with delivery
   reliability to identify operational patterns.
------------------------------------------------------------ */

WITH seller_performance AS
(
    SELECT

        oi.seller_id,

        COUNT(DISTINCT o.order_id) AS delivered_orders,

        COUNT(DISTINCT o.order_id) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                >
                o.order_estimated_delivery_date::timestamp
        ) AS late_orders,

        ROUND(
            SUM(op.payment_value)::NUMERIC,
            2
        ) AS total_revenue,

        ROUND(
            AVG(
                EXTRACT(
                    EPOCH FROM (
                        o.order_delivered_customer_date::timestamp
                        -
                        o.order_purchase_timestamp::timestamp
                    )
                ) / 86400.0
            )::NUMERIC,
            2
        ) AS average_delivery_days

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

      AND o.order_delivered_customer_date IS NOT NULL

      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        oi.seller_id
),

seller_metrics AS
(
    SELECT

        seller_id,

        delivered_orders,

        late_orders,

        total_revenue,

        ROUND(
            late_orders * 100.0
            / NULLIF(delivered_orders, 0),
            2
        ) AS late_percentage,

        average_delivery_days,

        ROUND(
            total_revenue
            / NULLIF(delivered_orders, 0),
            2
        ) AS average_order_value

    FROM seller_performance
)

SELECT

    seller_id,

    delivered_orders,

    total_revenue,

    average_order_value,

    late_orders,

    late_percentage,

    average_delivery_days

FROM seller_metrics

WHERE delivered_orders >= 20

ORDER BY
    total_revenue DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   Among 804 sellers with at least 20 delivered orders,
   seller revenue was strongly associated with delivered
   order volume (correlation ≈ 0.79).

   Late-delivery percentage showed a moderate positive
   relationship with average delivery time (correlation ≈ 0.55).

   Delivered order volume had almost no relationship with
   late-delivery percentage (correlation ≈ 0.02), indicating
   that high-volume sellers were not necessarily more likely
   to experience late deliveries.

   Average order value also had little relationship with
   order volume (correlation ≈ -0.08).

   Overall, seller revenue was primarily associated with
   order volume, while delivery reliability varied
   independently of seller scale.

============================================================ */

/* ------------------------------------------------------------
   STEP 8D — SELLER PERFORMANCE SEGMENTATION

   Business Question:
   How can sellers be classified based on commercial
   performance and delivery reliability?

   Purpose:
   Identify seller performance patterns using order volume,
   revenue, average order value, and delivery reliability.
------------------------------------------------------------ */

WITH seller_performance AS
(
    SELECT

        oi.seller_id,

        COUNT(DISTINCT o.order_id) AS delivered_orders,

        COUNT(DISTINCT o.order_id) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                >
                o.order_estimated_delivery_date::timestamp
        ) AS late_orders,

        ROUND(
            SUM(op.payment_value)::NUMERIC,
            2
        ) AS total_revenue,

        ROUND(
            AVG(
                EXTRACT(
                    EPOCH FROM (
                        o.order_delivered_customer_date::timestamp
                        -
                        o.order_purchase_timestamp::timestamp
                    )
                ) / 86400.0
            )::NUMERIC,
            2
        ) AS average_delivery_days

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

      AND o.order_delivered_customer_date IS NOT NULL

      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        oi.seller_id
),

seller_metrics AS
(
    SELECT

        seller_id,

        delivered_orders,

        late_orders,

        total_revenue,

        ROUND(
            late_orders * 100.0
            / NULLIF(delivered_orders, 0),
            2
        ) AS late_percentage,

        average_delivery_days,

        ROUND(
            total_revenue
            / NULLIF(delivered_orders, 0),
            2
        ) AS average_order_value

    FROM seller_performance
)

SELECT

    seller_id,

    delivered_orders,

    total_revenue,

    average_order_value,

    late_percentage,

    average_delivery_days

FROM seller_metrics

WHERE delivered_orders >= 20

ORDER BY
    total_revenue DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   Among 804 sellers with at least 20 delivered orders,
   seller performance varied substantially across both
   commercial and operational metrics.

   Median delivered orders: 52.5
   Median total revenue: $9,724.03
   Median average order value: $161.62
   Median late-delivery rate: 6.67%
   Median average delivery time: 11.95 days

   Delivered orders ranged from 20 to 1,819, while total
   seller revenue ranged from $731.36 to $505,437.16.

   Late-delivery rates ranged from 0% to 37.5%, and average
   delivery times ranged from 4.66 to 30.44 days.

   These distributions provide benchmarks for identifying
   meaningful seller performance groups.

============================================================ */

/* ------------------------------------------------------------
   STEP 8E — SELLER PERFORMANCE SEGMENTATION

   Business Question:
   How do sellers differ when commercial performance and
   delivery reliability are considered together?

   Segmentation is based on median seller revenue and
   median late-delivery percentage.
------------------------------------------------------------ */

WITH seller_performance AS
(
    SELECT

        oi.seller_id,

        COUNT(DISTINCT o.order_id) AS delivered_orders,

        COUNT(DISTINCT o.order_id) FILTER
        (
            WHERE
                o.order_delivered_customer_date::timestamp
                >
                o.order_estimated_delivery_date::timestamp
        ) AS late_orders,

        ROUND(
            SUM(op.payment_value)::NUMERIC,
            2
        ) AS total_revenue

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

      AND o.order_delivered_customer_date IS NOT NULL

      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        oi.seller_id
),

seller_metrics AS
(
    SELECT

        seller_id,

        delivered_orders,

        late_orders,

        total_revenue,

        ROUND(
            late_orders * 100.0
            / NULLIF(delivered_orders, 0),
            2
        ) AS late_percentage

    FROM seller_performance

    WHERE delivered_orders >= 20
),

benchmarks AS
(
    SELECT

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_revenue)
        AS median_revenue,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY late_percentage)
        AS median_late_percentage

    FROM seller_metrics
)

SELECT

    CASE

        WHEN sm.total_revenue > b.median_revenue
             AND sm.late_percentage <= b.median_late_percentage
            THEN 'High Performer'

        WHEN sm.total_revenue > b.median_revenue
             AND sm.late_percentage > b.median_late_percentage
            THEN 'High Revenue - Delivery Risk'

        WHEN sm.total_revenue <= b.median_revenue
             AND sm.late_percentage <= b.median_late_percentage
            THEN 'Low Revenue - Reliable'

        ELSE 'Low Performer - Delivery Risk'

    END AS performance_segment,

    COUNT(*) AS seller_count,

    ROUND(
        AVG(sm.delivered_orders)::NUMERIC,
        2
    ) AS avg_delivered_orders,

    ROUND(
        AVG(sm.total_revenue)::NUMERIC,
        2
    ) AS avg_revenue,

    ROUND(
        AVG(sm.late_percentage)::NUMERIC,
        2
    ) AS avg_late_percentage

FROM seller_metrics sm

CROSS JOIN benchmarks b

GROUP BY
    performance_segment

ORDER BY
    performance_segment;

/* ============================================================
   RESULTS / KEY FINDINGS — STEP 8E

   Among 804 sellers with at least 20 delivered orders,
   sellers were segmented using median seller revenue and
   median late-delivery percentage.

   High Performer:
   201 sellers | Avg Revenue: $29,526.33
   Avg Late Rate: 3.95%

   High Revenue - Delivery Risk:
   201 sellers | Avg Revenue: $40,902.78
   Avg Late Rate: 11.82%

   Low Revenue - Reliable:
   204 sellers | Avg Revenue: $5,108.54
   Avg Late Rate: 2.83%

   Low Performer - Delivery Risk:
   198 sellers | Avg Revenue: $5,419.50
   Avg Late Rate: 12.56%

   KEY INSIGHT:
   High revenue does not necessarily correspond to reliable
   delivery performance. The High Revenue - Delivery Risk group
   generated the highest average revenue but also had a substantially
   higher late-delivery rate than the High Performer group.

   The segmentation highlights the need to evaluate seller
   commercial performance and operational reliability together.

============================================================ */

/* ------------------------------------------------------------
   STEP 8F — SELLER REVENUE CONCENTRATION

   Business Question:
   How concentrated is marketplace revenue among sellers?

   Purpose:
   Measure how much of total marketplace revenue is generated
   by the top 10, 20, and 50 sellers.
------------------------------------------------------------ */

/* ------------------------------------------------------------
   STEP 8F — SELLER REVENUE CONCENTRATION

   Seller revenue is calculated from order_items using:
   price + freight_value

   This avoids duplicating order-level payment values when
   an order contains multiple products.
------------------------------------------------------------ */

WITH seller_revenue AS
(
    SELECT

        oi.seller_id,

        SUM(
            oi.price + oi.freight_value
        ) AS total_revenue

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

ranked_sellers AS
(
    SELECT

        seller_id,

        total_revenue,

        RANK() OVER
        (
            ORDER BY total_revenue DESC
        ) AS revenue_rank

    FROM seller_revenue
),

marketplace_total AS
(
    SELECT
        SUM(total_revenue) AS marketplace_revenue

    FROM seller_revenue
)

SELECT

    COUNT(*) AS total_sellers,

    ROUND(
        mt.marketplace_revenue::NUMERIC,
        2
    ) AS total_marketplace_revenue,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 10
                THEN total_revenue
                ELSE 0
            END
        )::NUMERIC,
        2
    ) AS top_10_revenue,

    ROUND(
        (
            SUM(
                CASE
                    WHEN revenue_rank <= 10
                    THEN total_revenue
                    ELSE 0
                END
            ) * 100.0
            / NULLIF(mt.marketplace_revenue, 0)
        )::NUMERIC,
        2
    ) AS top_10_revenue_percentage,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 20
                THEN total_revenue
                ELSE 0
            END
        )::NUMERIC,
        2
    ) AS top_20_revenue,

    ROUND(
        (
            SUM(
                CASE
                    WHEN revenue_rank <= 20
                    THEN total_revenue
                    ELSE 0
                END
            ) * 100.0
            / NULLIF(mt.marketplace_revenue, 0)
        )::NUMERIC,
        2
    ) AS top_20_revenue_percentage,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 50
                THEN total_revenue
                ELSE 0
            END
        )::NUMERIC,
        2
    ) AS top_50_revenue,

    ROUND(
        (
            SUM(
                CASE
                    WHEN revenue_rank <= 50
                    THEN total_revenue
                    ELSE 0
                END
            ) * 100.0
            / NULLIF(mt.marketplace_revenue, 0)
        )::NUMERIC,
        2
    ) AS top_50_revenue_percentage

FROM ranked_sellers rs

CROSS JOIN marketplace_total mt

GROUP BY
    mt.marketplace_revenue;

/* ============================================================
   RESULTS / KEY FINDINGS — STEP 8F

   Seller revenue concentration was analyzed using seller-
   attributed revenue calculated from product price plus
   freight value.

   Among 2,970 sellers:

   Top 10 sellers:
   Revenue = $1,993,154.99
   Contribution = 12.93%

   Top 20 sellers:
   Revenue = $3,243,893.84
   Contribution = 21.04%

   Top 50 sellers:
   Revenue = $5,018,121.11
   Contribution = 32.54%

   KEY INSIGHT:
   The top 10 sellers contributed 12.93% of seller-attributed
   revenue, while the top 50 contributed 32.54%.

   This indicates that revenue is distributed across a broad
   seller base, although the highest-revenue sellers represent
   a meaningful share of seller-attributed revenue.

   NOTE:
   Seller-attributed revenue is based on price + freight_value
   from order_items and should not be directly compared with
   payment-based marketplace revenue without accounting for
   the different revenue definitions.

this analysis uses:
product revenue = price + freight_value
from order_items, whereas the earlier marketplace figure(16M) used payment_value.
============================================================ */



SELECT
    oi.seller_id,

    SUM() AS total_revenue

FROM order_items oi

JOIN orders o
    ON oi.order_id__

WHERE o.order_status = 'delivered'

GROUP BY
    __________

ORDER BY
    total_revenue DESC;