/* ============================================================
   FILE: 05_product_analytics.sql

   PURPOSE:
   Analyze product and product-category performance to identify
   customer demand, sales volume, revenue drivers, pricing
   patterns, and high-performing products.

   KEY BUSINESS QUESTIONS:
   1. Which product categories sell the most items?
   2. Which product categories generate the most revenue?
   3. Which individual products generate the most revenue?
   4. Which product categories have the highest average prices?
   5. Which categories have high sales volume but relatively
      low revenue?
   6. How do product categories perform across sales volume,
      revenue, order count, and average price?

   DATASETS / TABLES USED:
   - order_items
   - products
   - category_translation

   ============================================================ */

/* ============================================================
   SECTION 1: TOP PRODUCT CATEGORIES BY ITEMS SOLD

   Business Question:
   Which product categories have the highest sales volume?
============================================================ */

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS total_items_sold

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation pct
    ON p.product_category_name = pct.product_category_name

GROUP BY
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    )

ORDER BY
    total_items_sold DESC;

-- LIMIT 20;

/* ============================================================
   KEY FINDING

   • bed_bath_table is the highest-selling product category
     with 11,115 items sold.

   • health_beauty and sports_leisure are the next most popular
     categories by sales volume.

   • The top categories indicate strong customer demand for
     home-related, personal care, and lifestyle products.

   • High sales volume does not necessarily mean high revenue.
     Revenue performance will be analyzed in the next section.

   • 1,627 items are classified as 'Unknown' because their
     product category could not be mapped to an English category
     name through the category_translation table.
============================================================ */

/* ============================================================
   SECTION 2: TOP PRODUCT CATEGORIES BY REVENUE

   Business Question:
   Which product categories generate the highest product revenue?

   Revenue Definition:
   Sum of product item prices (excluding freight costs).
============================================================ */

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    ROUND(
        SUM(oi.price)::NUMERIC,
        2
    ) AS total_product_revenue,

    COUNT(*) AS total_items_sold

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation pct
    ON p.product_category_name = pct.product_category_name

GROUP BY
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    )

ORDER BY
    total_product_revenue DESC

LIMIT 20;

/* ============================================================
   KEY FINDING

   • health_beauty is the highest revenue-generating category,
     producing approximately $1.26M in product revenue.

   • watches_gifts ranks second in revenue with approximately
     $1.21M despite ranking seventh in sales volume, suggesting
     a higher average product value.

   • bed_bath_table is the highest-selling category by volume
     but ranks third in product revenue, demonstrating that
     high sales volume does not necessarily translate into the
     highest revenue.

   • Product categories should therefore be evaluated using
     both sales volume and revenue rather than relying on a
     single performance metric.
============================================================ */


/* ============================================================
   SECTION 3: TOP INDIVIDUAL PRODUCTS BY REVENUE

   Business Question:
   Which individual products generate the highest
   product revenue?

   Metrics:
   - Total Product Revenue
   - Units Sold
   - Average Selling Price
============================================================ */

SELECT

    oi.product_id,

    ROUND(
        SUM(oi.price)::NUMERIC,
        2
    ) AS total_product_revenue,

    COUNT(*) AS units_sold,

    ROUND(
        AVG(oi.price)::NUMERIC,
        2
    ) AS average_selling_price

FROM order_items oi

GROUP BY
    oi.product_id

ORDER BY
    total_product_revenue DESC;

LIMIT 20;

/* ============================================================
   KEY FINDING

   • The highest-revenue individual product generated
     approximately $63.89K in product revenue from 195 units.

   • Product revenue is driven by different sales patterns.
     Some products generate substantial revenue through high
     unit volumes, while others achieve high revenue despite
     selling fewer units because of their higher selling prices.

   • For example, one product generated approximately $48.90K
     from only 35 units at an average selling price of $1,397.12,
     demonstrating the contribution of high-value products.

   • Product performance should therefore be evaluated using
     both revenue and sales volume rather than revenue alone.
============================================================ */


/* ============================================================
   SECTION 4: AVERAGE PRODUCT PRICE BY CATEGORY

   Business Question:
   Which product categories have the highest average
   selling price among categories with meaningful sales volume?

   Metric:
   Average product selling price, excluding freight.

   Minimum Volume:
   Categories must have at least 100 items sold to reduce
   distortion from very small sample sizes.
============================================================ */

SELECT

    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS total_items_sold,

    ROUND(
        AVG(oi.price)::NUMERIC,
        2
    ) AS average_product_price

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation pct
    ON p.product_category_name = pct.product_category_name

GROUP BY

    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    )

HAVING
    COUNT(*) >= 100

ORDER BY
    average_product_price DESC

LIMIT 20;

-- avg price of the product if min 100 of them are sold

/* ============================================================
   KEY FINDING

   • computers has the highest average selling price among
     categories with at least 100 observed item sales, at
     approximately $1,098.34.

   • Higher-priced categories generally have lower sales
     volumes, indicating a high-ticket, lower-volume sales
     pattern.

   • watches_gifts is notable for combining a relatively high
     average selling price of $201.14 with substantial volume
     of 5,991 items.

   • The results reinforce that product performance should be
     evaluated using multiple metrics, including sales volume,
     revenue, and average selling price.

   • A minimum sales-volume threshold of 100 items was applied
     to reduce the influence of categories with very small
     sample sizes.
============================================================ */

/* ============================================================
   SECTION 5: SALES VOLUME VS REVENUE PERFORMANCE

   Business Question:
   Which product categories perform strongly in sales volume
   and/or product revenue?

   Classification:
   Categories are compared against the median category
   sales volume and median category revenue.

   Performance Groups:
   • High Volume - High Revenue
   • High Volume - Lower Revenue
   • Lower Volume - High Revenue
   • Lower Volume - Lower Revenue
============================================================ */

WITH category_performance AS
(
    SELECT

        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        ) AS product_category,

        COUNT(*) AS total_items_sold,

        ROUND(
            SUM(oi.price)::NUMERIC,
            2
        ) AS total_product_revenue,

        ROUND(
            AVG(oi.price)::NUMERIC,
            2
        ) AS average_selling_price

    FROM order_items oi

    JOIN products p
        ON oi.product_id = p.product_id

    LEFT JOIN category_translation pct
        ON p.product_category_name =
           pct.product_category_name

    GROUP BY
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        )
),

category_benchmarks AS
(
    SELECT

        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY total_items_sold
        ) AS median_items_sold,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY total_product_revenue
        ) AS median_revenue

    FROM category_performance
)

SELECT

    cp.product_category,

    cp.total_items_sold,

    cp.total_product_revenue,

    cp.average_selling_price,

    CASE

        WHEN cp.total_items_sold >= cb.median_items_sold
         AND cp.total_product_revenue >= cb.median_revenue
            THEN 'High Volume - High Revenue'

        WHEN cp.total_items_sold >= cb.median_items_sold
         AND cp.total_product_revenue < cb.median_revenue
            THEN 'High Volume - Lower Revenue'

        WHEN cp.total_items_sold < cb.median_items_sold
         AND cp.total_product_revenue >= cb.median_revenue
            THEN 'Lower Volume - High Revenue'

        ELSE 'Lower Volume - Lower Revenue'

    END AS performance_group

FROM category_performance cp

CROSS JOIN category_benchmarks cb

WHERE cp.product_category <> 'Unknown'

ORDER BY
    cp.total_product_revenue DESC;


/* ============================================================
   KEY FINDING

   • Several major categories combine strong sales volume with
     strong product revenue, including health_beauty,
     watches_gifts, bed_bath_table, sports_leisure, and
     computers_accessories.

   • Some categories generate relatively high revenue despite
     lower sales volume. computers is the clearest example,
     generating approximately $222.96K from only 203 items,
     indicating a high-value product mix.

   • The analysis demonstrates that category performance can be
     driven by either sales scale or higher-value products.

   • Categories were benchmarked against the median category
     sales volume and median category revenue to reduce the
     influence of highly skewed category distributions.
============================================================ */

/* ============================================================
   SECTION 6: CATEGORY PERFORMANCE SUMMARY

   Business Question:
   How does each product category perform across orders,
   units sold, revenue, average selling price, and
   revenue generated per order?

   Metrics:
   - Total Orders
   - Total Items Sold
   - Total Product Revenue
   - Average Selling Price
   - Revenue per Order

============================================================ */

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS total_items_sold,

    ROUND(
        SUM(oi.price)::NUMERIC,
        2
    ) AS total_product_revenue,

    ROUND(
        AVG(oi.price)::NUMERIC,
        2
    ) AS average_selling_price,

    ROUND(
        (
            SUM(oi.price)
            / NULLIF(COUNT(DISTINCT oi.order_id), 0)
        )::NUMERIC,
        2
    ) AS revenue_per_order

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation pct
    ON p.product_category_name =
       pct.product_category_name

GROUP BY
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    )

ORDER BY
    total_product_revenue DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   • health_beauty is one of the strongest overall categories,
     generating approximately $1.26M in product revenue from
     9,670 items across 8,836 orders.

   • watches_gifts generated approximately $1.21M from
     5,991 items and achieved a high revenue per order of
     approximately $214.26.

   • bed_bath_table recorded the highest sales volume with
     11,115 items sold across 9,417 orders, demonstrating
     strong customer demand despite a relatively lower
     average selling price.

   • computers demonstrates a high-ticket product mix.
     Only 203 items were sold, but the category generated
     approximately $222.96K in product revenue with an
     average selling price of approximately $1,098.34.

   • musical_instruments and small_appliances also show
     relatively high average selling prices while operating
     at lower sales volumes.

   • The results demonstrate why product-category performance
     should be evaluated using multiple metrics rather than
     sales volume alone.

   • The Unknown category was retained to maintain visibility
     into products without a mapped English category.

   BUSINESS IMPLICATION:

   Category strategy should distinguish between high-volume
   categories and high-value categories. High-volume categories
   may benefit from assortment and cross-selling strategies,
   while high-ticket categories may require pricing, inventory,
   and premium merchandising strategies.

============================================================ */

/* ============================================================
   SECTION 7: CATEGORY REVENUE CONTRIBUTION

   Business Question:
   How concentrated is product revenue among the top
   product categories?

   Metrics:
   - Total Product Revenue
   - Revenue Contribution %
   - Cumulative Revenue Contribution %
   - Revenue Rank

============================================================ */

WITH category_revenue AS
(
    SELECT
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        ) AS product_category,

        SUM(oi.price) AS total_product_revenue

    FROM order_items oi

    JOIN products p
        ON oi.product_id = p.product_id

    LEFT JOIN category_translation pct
        ON p.product_category_name =
           pct.product_category_name

    GROUP BY
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        )
),

revenue_contribution AS
(
    SELECT
        product_category,

        ROUND(
            total_product_revenue::NUMERIC,
            2
        ) AS total_product_revenue,

        ROUND(
            (
                total_product_revenue
                / SUM(total_product_revenue) OVER ()
                * 100
            )::NUMERIC,
            2
        ) AS revenue_contribution_pct,

        ROUND(
            (
                SUM(total_product_revenue) OVER (
                    ORDER BY total_product_revenue DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING
                    AND CURRENT ROW
                )
                / SUM(total_product_revenue) OVER ()
                * 100
            )::NUMERIC,
            2
        ) AS cumulative_revenue_pct

    FROM category_revenue
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY total_product_revenue DESC
    ) AS revenue_rank,

    product_category,

    total_product_revenue,

    revenue_contribution_pct,

    cumulative_revenue_pct

FROM revenue_contribution

ORDER BY
    revenue_rank;

/* ============================================================
   RESULTS / KEY FINDINGS

   • The top 5 product categories contribute 39.74% of total
     product revenue.

   • The top 10 categories contribute 62.36% of total product
     revenue, meaning approximately two-thirds of product
     revenue comes from only 10 categories.

   • The top 20 categories contribute 84.01% of total product
     revenue.

   • health_beauty is the largest individual category,
     contributing 9.26% of product revenue, followed by
     watches_gifts at 8.87%.

   • No single category dominates the marketplace, but revenue
     is clearly concentrated among a relatively small group
     of leading categories.

   BUSINESS IMPLICATION:

   High-revenue categories should receive greater attention in
   inventory planning, merchandising, promotions, and category
   management. At the same time, the marketplace has a broad
   long-tail of smaller categories that may provide
   diversification and niche growth opportunities.

============================================================ */

/* ============================================================
   SECTION 8: PRODUCT VOLUME VS REVENUE PERFORMANCE

   Business Question:
   Which individual products combine strong sales volume
   with strong product revenue?

   Performance Groups:
   • High Volume - High Revenue
   • High Volume - Lower Revenue
   • Lower Volume - High Revenue
   • Lower Volume - Lower Revenue

   Classification:
   - High Volume: 50 or more units sold
   - Lower Volume: fewer than 50 units sold
   - High Revenue: revenue at or above the median product
     revenue
   - Lower Revenue: revenue below the median product revenue

   Rationale:
   Product-level sales are highly skewed. An absolute unit
   threshold provides a more intuitive definition of volume,
   while the median provides a robust benchmark for revenue.

   Volume × Total Revenue
   this asks "Are products high/low in sales volume and high/low in total revenue?"

============================================================ */

WITH product_performance AS
(
    SELECT
        oi.product_id,

        COUNT(*) AS units_sold,

        ROUND(
            SUM(oi.price)::NUMERIC,
            2
        ) AS total_product_revenue,

        ROUND(
            AVG(oi.price)::NUMERIC,
            2
        ) AS average_selling_price

    FROM order_items oi

    GROUP BY
        oi.product_id
),

product_benchmarks AS
(
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY total_product_revenue
        ) AS median_revenue

    FROM product_performance
)

SELECT
    pp.product_id,

    pp.units_sold,

    pp.total_product_revenue,

    pp.average_selling_price,

    CASE
        WHEN pp.units_sold >= 50
         AND pp.total_product_revenue >= pb.median_revenue
            THEN 'High Volume - High Revenue'

        WHEN pp.units_sold >= 50
         AND pp.total_product_revenue < pb.median_revenue
            THEN 'High Volume - Lower Revenue'

        WHEN pp.units_sold < 50
         AND pp.total_product_revenue >= pb.median_revenue
            THEN 'Lower Volume - High Revenue'

        ELSE 'Lower Volume - Lower Revenue'
    END AS performance_group

FROM product_performance pp

CROSS JOIN product_benchmarks pb

ORDER BY
    pp.total_product_revenue DESC;


/* ============================================================
   SECTION 8A: PRODUCT PERFORMANCE GROUP SUMMARY

   Business Question:
   How many products fall into each performance group?

============================================================ */

WITH product_performance AS
(
    SELECT
        oi.product_id,

        COUNT(*) AS units_sold,

        ROUND(
            SUM(oi.price)::NUMERIC,
            2
        ) AS total_product_revenue

    FROM order_items oi

    GROUP BY
        oi.product_id
),

product_benchmarks AS
(
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP
        (
            ORDER BY total_product_revenue
        ) AS median_revenue

    FROM product_performance
),

classified_products AS
(
    SELECT
        pp.product_id,
        pp.units_sold,
        pp.total_product_revenue,

        CASE
            WHEN pp.units_sold >= 50
             AND pp.total_product_revenue >= pb.median_revenue
                THEN 'High Volume - High Revenue'

            WHEN pp.units_sold >= 50
             AND pp.total_product_revenue < pb.median_revenue
                THEN 'High Volume - Lower Revenue'

            WHEN pp.units_sold < 50
             AND pp.total_product_revenue >= pb.median_revenue
                THEN 'Lower Volume - High Revenue'

            ELSE 'Lower Volume - Lower Revenue'
        END AS performance_group

    FROM product_performance pp

    CROSS JOIN product_benchmarks pb
)

SELECT
    performance_group,
    COUNT(*) AS product_count,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(total_product_revenue)::NUMERIC,
        2
    ) AS total_product_revenue

FROM classified_products

GROUP BY
    performance_group

ORDER BY
    total_product_revenue DESC;

/* ============================================================
   RESULTS / KEY FINDINGS

   • The product portfolio is highly long-tailed. Most products
     fall into the Lower Volume - High Revenue or Lower Volume -
     Lower Revenue groups.

   • 16,302 products were classified as Lower Volume -
     High Revenue and generated approximately $10.74M in
     product revenue.

   • Only 174 products were classified as High Volume -
     High Revenue, generating approximately $1.78M in
     product revenue.

   • 16,475 products were classified as Lower Volume -
     Lower Revenue and generated approximately $1.07M.

   • No products were classified as High Volume -
     Lower Revenue under the selected 50-unit volume threshold
     and median revenue benchmark.

   • The Lower Volume - High Revenue group represents the
     largest share of product revenue within the classified
     portfolio, indicating that revenue is not driven solely
     by a small number of high-volume products.

   BUSINESS IMPLICATION:

   Product strategy should distinguish between high-volume
   core products and the broader long-tail portfolio.
   High-volume/high-revenue products should receive strong
   inventory and availability management, while lower-volume
   high-revenue products may require targeted merchandising,
   premium positioning, and demand monitoring.

============================================================ */

/* ============================================================
   SECTION 9: PRODUCT PRICE VS SALES VOLUME

   Business Question:
   Do higher-priced products tend to sell fewer units?

   Metrics:
   - Average selling price
   - Units sold
   - Total product revenue

   DATASETS / TABLES USED:
   - order_items

============================================================ */

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS average_selling_price,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_product_revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY average_selling_price DESC;

/* ============================================================
   SECTION 9A: PRICE VS SALES VOLUME CORRELATION

   Business Question:
   Is there a measurable relationship between product price
   and units sold?

============================================================ */

WITH product_metrics AS
(
    SELECT
        product_id,
        COUNT(*) AS units_sold,
        AVG(price) AS average_selling_price
    FROM order_items
    GROUP BY product_id
)

SELECT
    ROUND(
        CORR(average_selling_price, units_sold)::NUMERIC,
        4
    ) AS price_volume_correlation
FROM product_metrics;

/* ============================================================
   RESULTS / KEY FINDINGS

   • The Pearson correlation between average selling price
     and units sold is -0.0321.

   • The correlation is very close to zero, indicating that
     there is virtually no linear relationship between product
     price and sales volume.

   • Although some high-priced products have very low sales
     volumes, this pattern is not consistent enough across the
     full product portfolio to establish a meaningful
     price-volume relationship.

   BUSINESS IMPLICATION:

   Product pricing decisions should not be based solely on
   expected sales volume. Demand appears to depend on factors
   beyond price, such as product category, product appeal,
   customer preferences, and marketplace demand.

   Pricing strategy should therefore be evaluated alongside
   category performance, product demand, and customer behavior
   rather than assuming that lowering price will automatically
   increase sales volume.

============================================================ */

/* ============================================================
   SECTION 10: PRODUCT REVENUE DRIVERS

   Business Question:
   Which products generate revenue primarily through sales
   volume versus higher selling prices?

   Metrics:
   - Units sold
   - Average selling price
   - Total product revenue

   DATASETS / TABLES USED:
   - order_items

============================================================ */

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS average_selling_price,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_product_revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY total_product_revenue DESC
LIMIT 50;

/* ============================================================
   SECTION 10A: PRODUCT REVENUE DRIVER CLASSIFICATION

   Business Question:
   Are products generating revenue primarily through high sales
   volume, higher selling prices, or both?

============================================================ */

WITH product_metrics AS
(
    SELECT
        product_id,
        COUNT(*) AS units_sold,
        AVG(price) AS average_selling_price,
        SUM(price) AS total_product_revenue
    FROM order_items
    GROUP BY product_id
),
benchmarks AS
(
    SELECT
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY units_sold) AS median_units_sold,

        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY average_selling_price) AS median_price
    FROM product_metrics
)
SELECT
    CASE
        WHEN pm.units_sold >= b.median_units_sold
         AND pm.average_selling_price >= b.median_price
            THEN 'High Volume - High Price'

        WHEN pm.units_sold >= b.median_units_sold
         AND pm.average_selling_price < b.median_price
            THEN 'High Volume - Lower Price'

        WHEN pm.units_sold < b.median_units_sold
         AND pm.average_selling_price >= b.median_price
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END AS revenue_driver_group,

    COUNT(*) AS product_count,
    SUM(pm.units_sold) AS total_units_sold,
    ROUND(SUM(pm.total_product_revenue)::NUMERIC, 2)
        AS total_product_revenue,
    ROUND(AVG(pm.average_selling_price)::NUMERIC, 2)
        AS average_product_price

FROM product_metrics pm
CROSS JOIN benchmarks b

GROUP BY
    CASE
        WHEN pm.units_sold >= b.median_units_sold
         AND pm.average_selling_price >= b.median_price
            THEN 'High Volume - High Price'

        WHEN pm.units_sold >= b.median_units_sold
         AND pm.average_selling_price < b.median_price
            THEN 'High Volume - Lower Price'

        WHEN pm.units_sold < b.median_units_sold
         AND pm.average_selling_price >= b.median_price
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END

ORDER BY total_product_revenue DESC;

/* ============================================================
   SECTION 10B: PRODUCT REVENUE DRIVER BENCHMARKS

   Purpose:
   Validate the median units sold and median selling price
   used for product revenue-driver classification.

============================================================ */

WITH product_metrics AS
(
    SELECT
        product_id,
        COUNT(*) AS units_sold,
        AVG(price) AS average_selling_price
    FROM order_items
    GROUP BY product_id
)
SELECT
    COUNT(*) AS total_products,

    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY units_sold) AS median_units_sold,

    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY average_selling_price) AS median_price,

    MIN(units_sold) AS minimum_units_sold,
    MAX(units_sold) AS maximum_units_sold,

    MIN(average_selling_price) AS minimum_price,
    MAX(average_selling_price) AS maximum_price

FROM product_metrics;

/* ============================================================
   SECTION 10C: PRODUCT REVENUE DRIVER CLASSIFICATION

   Business Question:
   Are products generating revenue primarily through high
   sales volume, higher selling prices, or both?

   Benchmarks:
   - High volume: 50+ units sold
   - High price: average selling price >= $79 median

============================================================ */

WITH product_metrics AS
(
    SELECT
        product_id,
        COUNT(*) AS units_sold,
        AVG(price) AS average_selling_price,
        SUM(price) AS total_product_revenue
    FROM order_items
    GROUP BY product_id
)

SELECT
    CASE
        WHEN units_sold >= 50
         AND average_selling_price >= 79
            THEN 'High Volume - High Price'

        WHEN units_sold >= 50
         AND average_selling_price < 79
            THEN 'High Volume - Lower Price'

        WHEN units_sold < 50
         AND average_selling_price >= 79
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END AS revenue_driver_group,

    COUNT(*) AS product_count,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(total_product_revenue)::NUMERIC, 2)
        AS total_product_revenue,
    ROUND(AVG(average_selling_price)::NUMERIC, 2)
        AS average_product_price

FROM product_metrics

GROUP BY
    CASE
        WHEN units_sold >= 50
         AND average_selling_price >= 79
            THEN 'High Volume - High Price'

        WHEN units_sold >= 50
         AND average_selling_price < 79
            THEN 'High Volume - Lower Price'

        WHEN units_sold < 50
         AND average_selling_price >= 79
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END

ORDER BY total_product_revenue DESC;

/* ============================================================
   SECTION 10: PRODUCT REVENUE DRIVERS

   BUSINESS QUESTION:
   Which products generate revenue primarily through sales
   volume versus higher selling prices?

   METHODOLOGY:
   Product performance is classified using two dimensions:

   1. Sales Volume
      - High Volume: >= 50 units sold
      - Lower Volume: < 50 units sold

   2. Average Selling Price
      - High Price: >= $79
      - Lower Price: < $79

   The $79 price benchmark represents the median average
   selling price across products.

   A median volume benchmark was not used because the median
   product sold only 1 unit. Since all products sold at least
   once, a median threshold would classify nearly all products
   as high-volume and would not provide useful segmentation.

   Volume × Average Selling Price
   asks "Are products high/low in sales volume and high/low in price?"

============================================================ */

WITH product_metrics AS
(
    SELECT
        product_id,
        COUNT(*) AS units_sold,
        AVG(price) AS average_selling_price,
        SUM(price) AS total_product_revenue
    FROM order_items
    GROUP BY product_id
)

SELECT
    CASE
        WHEN units_sold >= 50
         AND average_selling_price >= 79
            THEN 'High Volume - High Price'

        WHEN units_sold >= 50
         AND average_selling_price < 79
            THEN 'High Volume - Lower Price'

        WHEN units_sold < 50
         AND average_selling_price >= 79
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END AS revenue_driver_group,

    COUNT(*) AS product_count,

    SUM(units_sold) AS total_units_sold,

    ROUND(
        SUM(total_product_revenue)::NUMERIC,
        2
    ) AS total_product_revenue,

    ROUND(
        AVG(average_selling_price)::NUMERIC,
        2
    ) AS average_product_price

FROM product_metrics

GROUP BY
    CASE
        WHEN units_sold >= 50
         AND average_selling_price >= 79
            THEN 'High Volume - High Price'

        WHEN units_sold >= 50
         AND average_selling_price < 79
            THEN 'High Volume - Lower Price'

        WHEN units_sold < 50
         AND average_selling_price >= 79
            THEN 'Lower Volume - High Price'

        ELSE 'Lower Volume - Lower Price'
    END

ORDER BY total_product_revenue DESC;


/* ============================================================
   RESULTS / KEY FINDINGS

   • The product portfolio is highly long-tailed, with only
     174 products meeting the high-volume threshold of 50+
     units sold.

   • Lower Volume - High Price products are the largest revenue
     driver, generating approximately $9.77M in product revenue.

   • High Volume - High Price products generate approximately
     $1.36M, compared with $418K from High Volume - Lower Price
     products.

   • High sales volume alone does not guarantee strong revenue;
     selling price also influences product revenue contribution.

   • Most products sell at relatively low volumes, suggesting
     that revenue is distributed across a broad product catalog
     rather than being concentrated exclusively in a small group
     of high-volume products.

   BUSINESS IMPLICATION:

   Marketplace merchandising should distinguish between
   high-volume core products and the broader long-tail catalog.

   High-volume products should receive strong inventory and
   availability management, while lower-volume higher-priced
   products may benefit from targeted merchandising and
   premium positioning.

============================================================ */
