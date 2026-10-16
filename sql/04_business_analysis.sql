
-- 1. Monthly revenue and order volume

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date
        AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS freight_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY order_month;



-- 2. Top product categories by revenue

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown / untranslated'
    ) AS product_category,
    COUNT(*) AS item_records,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name =
       pct.product_category_name
GROUP BY
    COALESCE(
        pct.product_category_name_english,
        'Unknown / untranslated'
    )
ORDER BY product_revenue DESC
LIMIT 15;



-- Average item price by product category

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown / untranslated'
    ) AS product_category,
    COUNT(*) AS item_records,
    ROUND(AVG(oi.price)::numeric, 2) AS average_item_price,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name =
       pct.product_category_name
GROUP BY
    COALESCE(
        pct.product_category_name_english,
        'Unknown / untranslated'
    )
ORDER BY average_item_price DESC
LIMIT 10;


-- Customer repeat-purchase analysis

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE total_orders = 1
    ) AS one_time_customers,
    COUNT(*) FILTER (
        WHERE total_orders > 1
    ) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE total_orders > 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- 4. Delivery performance analysis

WITH delivery_data AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date,

        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date
                - order_purchase_timestamp
            )
        ) / 86400.0 AS delivery_days

    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_purchase_timestamp IS NOT NULL
)
SELECT
    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              > order_estimated_delivery_date
    ) AS late_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              <= order_estimated_delivery_date
    ) AS on_time_or_early_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date
                  > order_estimated_delivery_date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage,

    ROUND(AVG(delivery_days)::numeric, 2)
        AS average_delivery_days

FROM delivery_data;


-- 5. Payment method analysis

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric, 2)
        AS total_payment_value,
    ROUND(AVG(payment_value)::numeric, 2)
        AS average_payment_record_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 6. Customer review score distribution

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC;



-- 7. Overall customer satisfaction

SELECT
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_score)::numeric, 2)
        AS average_review_score,
    COUNT(*) FILTER (
        WHERE review_score >= 4
    ) AS positive_reviews,
    COUNT(*) FILTER (
        WHERE review_score <= 2
    ) AS negative_reviews
FROM order_reviews;



-- 8. Seller performance analysis

SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS item_records,
    ROUND(SUM(oi.price)::numeric, 2)
        AS total_product_revenue,
    ROUND(AVG(oi.price)::numeric, 2)
        AS average_item_price
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_state
ORDER BY total_product_revenue DESC
LIMIT 10;


-- 9. Top 3 sellers by revenue in each state

WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_state,
        SUM(oi.price) AS total_revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
),
ranked_sellers AS (
    SELECT
        seller_id,
        seller_state,
        total_revenue,
        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY total_revenue DESC
        ) AS seller_rank
    FROM seller_revenue
)
SELECT
    seller_id,
    seller_state,
    ROUND(total_revenue::numeric, 2)
        AS total_revenue,
    seller_rank
FROM ranked_sellers
WHERE seller_rank <= 3
ORDER BY seller_state, seller_rank;


-- 10. Customer purchase frequency segmentation

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(op.payment_value) AS total_payment_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
),
customer_segments AS (
    SELECT
        customer_unique_id,
        total_orders,
        total_payment_value,
        CASE
            WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional'
            ELSE 'Frequent'
        END AS customer_segment
    FROM customer_orders
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,
    ROUND(AVG(total_payment_value)::numeric, 2)
        AS average_customer_payment
FROM customer_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- 11. Top 10 customers by total payment value

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(op.payment_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    ROUND(total_spending::numeric, 2) AS total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 10;




--VALIDATION

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(op.payment_value)::numeric, 2) AS total_payment_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id;


SELECT
    COUNT(DISTINCT c.customer_unique_id)
        AS customers_without_payment_records
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_payments op
    ON o.order_id = op.order_id
WHERE op.order_id IS NULL;

SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_payments op
    ON o.order_id = op.order_id
WHERE op.order_id IS NULL;

SELECT
    customer_segment,
    SUM(customer_count) AS total_customers,
    SUM(customer_percentage) AS total_percentage
FROM (
    WITH customer_orders AS (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS total_orders,
            SUM(op.payment_value) AS total_payment_value
        FROM customers c
        JOIN orders o
            ON c.customer_id = o.customer_id
        LEFT JOIN order_payments op
            ON o.order_id = op.order_id
        GROUP BY c.customer_unique_id
    ),
    customer_segments AS (
        SELECT
            customer_unique_id,
            total_orders,
            total_payment_value,
            CASE
                WHEN total_orders = 1 THEN 'One-time'
                WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional'
                ELSE 'Frequent'
            END AS customer_segment
        FROM customer_orders
    )
    SELECT
        customer_segment,
        COUNT(*) AS customer_count,
        ROUND(
            100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
            2
        ) AS customer_percentage
    FROM customer_segments
    GROUP BY customer_segment
) AS segment_summary
GROUP BY customer_segment
ORDER BY customer_segment;