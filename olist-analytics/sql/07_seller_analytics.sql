/* ============================================================
   FILE: 07_seller_analytics.sql

   PURPOSE:
   Analyze seller-level commercial and customer-performance
   metrics to identify revenue contribution, order volume,
   average order value, customer satisfaction, and differences
   between high-performing and problematic sellers.

   KEY BUSINESS QUESTIONS:
   1. Which sellers generate the most revenue?
   2. Which sellers handle the highest number of orders?
   3. What is the average order value for each seller?
   4. Which sellers receive the highest customer review scores?
   5. How does seller revenue relate to customer satisfaction?
   6. Are high-revenue sellers also strong in customer reviews?
   7. Which sellers combine strong commercial performance with
      strong customer satisfaction?
   8. Which sellers may require attention because of weak
      revenue, low order volume, or poor customer reviews?
   9. How concentrated is marketplace revenue among sellers?
   10. Which sellers are the most commercially important to
       the marketplace?

   DATASETS / TABLES USED:
   - order_items
   - orders
   - order_reviews
   - sellers

   ============================================================ */


/* ============================================================
   SECTION 7.1 & 7.2— SELLER REVENUE, ORDER VOLUME & AOV

   BUSINESS QUESTION:
   Which sellers generate the most revenue and order volume,
   and what is their average revenue per delivered order?

   METRICS:
   - Seller Revenue
   - Unique Delivered Orders
   - Seller Average Order Value (AOV)

   ============================================================ */

WITH seller_metrics AS
(
    SELECT
        oi.seller_id,

        SUM(oi.price + oi.freight_value) AS seller_revenue,

        COUNT(DISTINCT oi.order_id) AS unique_orders

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT
    seller_id,
    seller_revenue,
    unique_orders,

    ROUND(
        (seller_revenue / NULLIF(unique_orders, 0))::numeric,
        2
    ) AS seller_aov

FROM seller_metrics

ORDER BY
    seller_revenue DESC;


/* ============================================================
   KEY FINDINGS:

   Seller revenue is influenced by both order volume and
   average order value.

   High-revenue sellers do not necessarily have the highest
   order volume or highest AOV.

   For example, seller 5324... generated approximately $231K
   from only 348 delivered orders, resulting in an AOV of
   approximately $663, while other high-revenue sellers
   generated similar revenue through substantially higher
   order volumes.

   This indicates that seller revenue can be driven by either
   high transaction volume, high order value, or a combination
   of both.

   NOTE:
   The query is ordered by seller revenue, so the observed
   AOV values represent top-revenue sellers rather than the
   highest-AOV sellers across the entire marketplace.

   ============================================================ */


/* ============================================================
   SECTION 7.3 — SELLER REVIEW PERFORMANCE

   BUSINESS QUESTION:
   How are sellers performing from the customer's perspective?

   METRICS:
   - Reviewed Orders
   - Average Review Score
   - Median Seller Review Score

   ============================================================ */


/* --- Seller Review Coverage & Average Review Score */

SELECT
    oi.seller_id,

    COUNT(DISTINCT r.order_id) AS reviewed_orders,

    AVG(r.review_score) AS average_review_score

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    oi.seller_id;


/* --- Seller Review Coverage */

WITH seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(DISTINCT r.order_id) AS reviewed_orders,

        AVG(r.review_score) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT
    COUNT(*) AS total_sellers,

    COUNT(*) FILTER (
        WHERE reviewed_orders >= 20
    ) AS sellers_with_20_plus_reviews,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE reviewed_orders >= 20
            ) * 100.0
            / COUNT(*)
        )::numeric,
        2
    ) AS percentage_with_20_plus_reviews

FROM seller_reviews;


/* --- Seller Review Ranking (20+ Reviewed Orders) */

WITH seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(DISTINCT r.order_id) AS reviewed_orders,

        AVG(r.review_score) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT
    seller_id,
    reviewed_orders,
    ROUND(
        average_review_score::numeric,
        2
    ) AS average_review_score

FROM seller_reviews

WHERE reviewed_orders >= 20

ORDER BY
    average_review_score DESC;


/* --- Overall Seller Review Statistics (20+ Reviews) */

WITH seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(DISTINCT r.order_id) AS reviewed_orders,

        AVG(r.review_score) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT
    COUNT(*) AS sellers_analyzed,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY average_review_score
        )::numeric,
        2
    ) AS median_review_score,

    ROUND(
        AVG(average_review_score)::numeric,
        2
    ) AS average_seller_review_score

FROM seller_reviews

WHERE reviewed_orders >= 20;


/* ============================================================
   KEY FINDINGS:

   Among the 800 sellers with at least 20 reviewed orders,
   the average seller review score was 4.13 out of 5 and
   the median seller review score was 4.16.

   Only 800 of the 2,965 sellers with reviews (26.98%) had
   at least 20 reviewed orders.

   Therefore, seller review comparisons should be interpreted
   cautiously for sellers with limited review volume.

   ============================================================ */

/* ============================================================
   SECTION 7.4 — SELLER REVENUE VS CUSTOMER SATISFACTION

   BUSINESS QUESTION:
   Do sellers generating more revenue also receive better
   customer review scores?

   METRICS:
   - Seller Revenue
   - Unique Delivered Orders
   - Reviewed Orders
   - Average Review Score
   - Revenue-to-Review Correlation

   ANALYSIS:
   Seller revenue and customer review performance were first
   calculated separately and then joined at the seller level.
   This prevents revenue from being duplicated when orders
   contain multiple order-item records.

   Sellers with fewer than 20 reviewed orders were excluded
   from the correlation analysis to reduce the impact of
   unreliable averages based on very small review samples.

   ============================================================ */


/* --- Seller Revenue vs Review Score Correlation */

WITH seller_revenue AS
(
    SELECT
        oi.seller_id,

        SUM(
            oi.price + oi.freight_value
        ) AS seller_revenue,

        COUNT(
            DISTINCT oi.order_id
        ) AS unique_orders

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(
            DISTINCT r.order_id
        ) AS reviewed_orders,

        AVG(
            r.review_score
        ) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
)

SELECT
    CORR(
        sr.seller_revenue,
        sv.average_review_score
    ) AS revenue_review_correlation

FROM seller_revenue sr

JOIN seller_reviews sv
    ON sr.seller_id = sv.seller_id

WHERE sv.reviewed_orders >= 20;


/* ============================================================
   KEY FINDINGS:

   The correlation between seller revenue and average customer
   review score was -0.0448.

   This correlation is very close to zero, indicating that
   there is essentially no meaningful linear relationship
   between seller revenue and customer review performance
   among sellers with at least 20 reviewed orders.

   Therefore, high-revenue sellers do not necessarily receive
   better customer ratings.

   The slightly negative correlation is extremely weak and
   should not be interpreted as evidence that higher revenue
   causes lower customer satisfaction.

   BUSINESS IMPLICATION:
   Seller commercial success and customer satisfaction appear
   to represent largely different dimensions of performance.
   High-revenue sellers should therefore not automatically be
   considered high-quality sellers based on revenue alone.

   ============================================================ */


WITH seller_revenue AS
(
    SELECT
        oi.seller_id,

        SUM(oi.price + oi.freight_value) AS seller_revenue,

        COUNT(DISTINCT oi.order_id) AS unique_orders

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(DISTINCT r.order_id) AS reviewed_orders,

        AVG(r.review_score) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

seller_metrics AS
(
    SELECT
        sr.seller_id,
        sr.seller_revenue,
        sr.unique_orders,
        sv.reviewed_orders,
        sv.average_review_score

    FROM seller_revenue sr

    JOIN seller_reviews sv
        ON sr.seller_id = sv.seller_id

    WHERE sv.reviewed_orders >= 20
)

SELECT *
FROM seller_metrics;



/* ============================================================
   SECTION 7.5 — SELLER PERFORMANCE SEGMENTATION

   BUSINESS QUESTION:
   Can sellers be segmented based on commercial performance
   and customer satisfaction?

   METRICS:
   - Seller Revenue
   - Unique Delivered Orders
   - Reviewed Orders
   - Average Review Score
   - Median Seller Revenue
   - Median Seller Review Score
   - Seller Performance Group

   SEGMENTATION LOGIC:
   Sellers were classified using the median seller revenue
   (7,761.59) and median seller review score (4.16).

   Seller groups:
   - High Performer
   - High Revenue - Satisfaction Risk
   - Low Revenue - Potential
   - Low Performer

   REVIEW THRESHOLD:
   Only sellers with at least 20 reviewed orders were included
   to reduce the effect of small review samples.

   ============================================================ */


/* --- Seller Performance Segmentation */

WITH seller_revenue AS
(
    SELECT
        oi.seller_id,

        SUM(
            oi.price + oi.freight_value
        ) AS seller_revenue,

        COUNT(
            DISTINCT oi.order_id
        ) AS unique_orders

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

seller_reviews AS
(
    SELECT
        oi.seller_id,

        COUNT(
            DISTINCT r.order_id
        ) AS reviewed_orders,

        AVG(
            r.review_score
        ) AS average_review_score

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

seller_metrics AS
(
    SELECT
        sr.seller_id,
        sr.seller_revenue,
        sr.unique_orders,
        sv.reviewed_orders,
        sv.average_review_score

    FROM seller_revenue sr

    JOIN seller_reviews sv
        ON sr.seller_id = sv.seller_id

    WHERE sv.reviewed_orders >= 20
),

median_values AS
(
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY seller_revenue
        ) AS median_revenue,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY average_review_score
        ) AS median_review_score

    FROM seller_metrics
),

seller_groups AS
(
    SELECT
        sm.seller_id,
        sm.seller_revenue,
        sm.unique_orders,
        sm.reviewed_orders,
        sm.average_review_score,

        CASE
            WHEN sm.seller_revenue >= mv.median_revenue
                 AND sm.average_review_score >= mv.median_review_score
                THEN 'High Performer'

            WHEN sm.seller_revenue >= mv.median_revenue
                 AND sm.average_review_score < mv.median_review_score
                THEN 'High Revenue - Satisfaction Risk'

            WHEN sm.seller_revenue < mv.median_revenue
                 AND sm.average_review_score >= mv.median_review_score
                THEN 'Low Revenue - Potential'

            ELSE 'Low Performer'
        END AS seller_group

    FROM seller_metrics sm

    CROSS JOIN median_values mv
)

SELECT
    seller_group,

    COUNT(*) AS seller_count,

    ROUND(
        SUM(seller_revenue)::numeric,
        2
    ) AS total_revenue,

    ROUND(
        AVG(average_review_score)::numeric,
        2
    ) AS average_review_score

FROM seller_groups

GROUP BY
    seller_group

ORDER BY
    total_revenue DESC;


/* ============================================================
   KEY FINDINGS:

   1. HIGH REVENUE — SATISFACTION RISK
   212 sellers generated approximately 6.19M in combined
   revenue but had an average review score of 3.88.

   These sellers represent an important commercial segment
   where customer satisfaction may require attention.

   2. HIGH PERFORMER
   188 sellers generated approximately 4.86M in combined
   revenue while maintaining an average review score of 4.35.

   These sellers demonstrate strong commercial performance
   combined with strong customer satisfaction.

   3. LOW REVENUE — POTENTIAL
   212 sellers generated approximately 0.86M in revenue but
   achieved the highest average review score of 4.42.

   These sellers may represent opportunities for growth or
   increased marketplace exposure because they demonstrate
   strong customer satisfaction despite lower revenue.

   4. LOW PERFORMER
   188 sellers generated approximately 0.85M in revenue and
   had the lowest average review score of 3.85.

   These sellers represent the weakest combined commercial
   and customer-satisfaction segment.

   BUSINESS IMPLICATION:
   Seller performance should not be evaluated using revenue
   alone. Combining commercial performance with customer
   satisfaction identifies strategically different seller
   groups that require different business actions.

   ============================================================ */

/* ============================================================
   SECTION 7.6 — SELLER REVENUE CONCENTRATION / PARETO ANALYSIS

   BUSINESS QUESTION:
   How concentrated is marketplace revenue among the highest-
   performing sellers?

   METRICS:
   - Total Sellers
   - Total Seller Revenue
   - Top 10% Seller Count
   - Top 10% Seller Revenue
   - Top 10% Revenue Contribution

   ============================================================ */


/* --- Seller Revenue Concentration */

WITH seller_revenue AS
(
    SELECT
        oi.seller_id,

        SUM(
            oi.price + oi.freight_value
        ) AS seller_revenue,

        COUNT(
            DISTINCT oi.order_id
        ) AS unique_orders

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
        seller_revenue,

        PERCENT_RANK() OVER (
            ORDER BY seller_revenue DESC
        ) AS revenue_percentile

    FROM seller_revenue
)

SELECT
    COUNT(*) AS total_sellers,

    ROUND(
        SUM(seller_revenue)::numeric,
        2
    ) AS total_revenue,

    COUNT(*) FILTER (
        WHERE revenue_percentile <= 0.10
    ) AS top_10_sellers,

    ROUND(
        SUM(seller_revenue) FILTER (
            WHERE revenue_percentile <= 0.10
        )::numeric,
        2
    ) AS top_10_revenue,

    ROUND(
        (
            SUM(seller_revenue) FILTER (
                WHERE revenue_percentile <= 0.10
            ) * 100.0
            / NULLIF(SUM(seller_revenue), 0)
        )::numeric,
        2
    ) AS top_10_revenue_percentage

FROM ranked_sellers;


/* ============================================================
   KEY FINDINGS:

   The marketplace generated approximately 15.42M in delivered
   seller revenue across 2,970 sellers.

   The top 10% of sellers, representing 297 sellers, generated
   approximately 10.22M in revenue.

   Therefore, the top 10% of sellers contributed approximately
   66.29% of total seller revenue.

   BUSINESS IMPLICATION:

   Marketplace revenue is highly concentrated among a relatively
   small group of high-performing sellers.

   This creates a strong dependency on the top seller segment,
   making seller retention and relationship management important
   for revenue stability.

   At the same time, the remaining seller base represents an
   opportunity to diversify marketplace revenue by identifying
   sellers with growth potential and helping them scale.

   ============================================================ */
   