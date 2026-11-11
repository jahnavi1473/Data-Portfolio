/* ============================================================
   VIEW: vw_rfm_base

   Purpose:
   Build the base customer-level RFM dataset.
============================================================ */

CREATE OR REPLACE VIEW vw_rfm_base AS

WITH reference_date AS
(
    SELECT
        MAX(order_purchase_timestamp::DATE) AS analysis_date
    FROM orders
)

SELECT

    c.customer_unique_id,

    (
        (SELECT analysis_date FROM reference_date)
        -
        MAX(o.order_purchase_timestamp::DATE)
    ) AS recency_days,

    COUNT(DISTINCT o.order_id) AS frequency,

    ROUND(
        SUM(op.payment_value)::NUMERIC,
        2
    ) AS monetary

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_payments op
    ON o.order_id = op.order_id

GROUP BY
    c.customer_unique_id;

SELECT *
FROM vw_rfm_base
LIMIT 5;


/* ============================================================
   VIEW: vw_rfm_scores

   Purpose:
   Calculate Recency, Frequency and Monetary Scores.
============================================================ */

CREATE OR REPLACE VIEW vw_rfm_scores AS

SELECT

    customer_unique_id,

    recency_days,

    frequency,

    monetary,

    6 - NTILE(5) OVER
    (
        ORDER BY recency_days ASC
    ) AS r_score,

    CASE

        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency BETWEEN 3 AND 5 THEN 3
        WHEN frequency BETWEEN 6 AND 10 THEN 4
        ELSE 5

    END AS f_score,

    NTILE(5) OVER
    (
        ORDER BY monetary DESC
    ) AS m_score

FROM vw_rfm_base;

SELECT *
FROM vw_rfm_scores
LIMIT 5;