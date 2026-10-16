--Basic row counts and sample records

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT *
FROM customers
LIMIT 5;


SELECT
    'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'product_category_translation', COUNT(*) FROM product_category_translation
ORDER BY table_name;


--Missing-value checks
SELECT 'Missing customer IDs in orders' AS check_name,
       COUNT(*) AS issue_count
FROM orders
WHERE customer_id IS NULL

UNION ALL

SELECT 'Missing purchase timestamps',
       COUNT(*)
FROM orders
WHERE order_purchase_timestamp IS NULL

UNION ALL

SELECT 'Missing product categories',
       COUNT(*)
FROM products
WHERE product_category_name IS NULL

UNION ALL

SELECT 'Missing prices',
       COUNT(*)
FROM order_items
WHERE price IS NULL

UNION ALL

SELECT 'Missing freight values',
       COUNT(*)
FROM order_items
WHERE freight_value IS NULL

UNION ALL

SELECT 'Missing review scores',
       COUNT(*)
FROM order_reviews
WHERE review_score IS NULL

UNION ALL

SELECT 'Missing customer unique IDs',
       COUNT(*)
FROM customers
WHERE customer_unique_id IS NULL

UNION ALL

SELECT 'Missing review IDs',
       COUNT(*)
FROM order_reviews
WHERE review_id IS NULL

UNION ALL

SELECT 'Missing payment values',
       COUNT(*)
FROM order_payments
WHERE payment_value IS NULL

UNION ALL

SELECT 'Missing seller IDs in order items',
       COUNT(*)
FROM order_items
WHERE seller_id IS NULL

UNION ALL

SELECT 'Missing product IDs in order items',
       COUNT(*)
FROM order_items
WHERE product_id IS NULL;


-- Check duplicate customer IDs
SELECT 'customers' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT customer_id
    FROM customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

-- Check duplicate order IDs
SELECT 'orders', COUNT(*)
FROM (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

-- Check duplicate product IDs
SELECT 'products', COUNT(*)
FROM (
    SELECT product_id
    FROM products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

-- Check duplicate seller IDs
SELECT 'sellers', COUNT(*)
FROM (
    SELECT seller_id
    FROM sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) AS duplicates;


SELECT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length
FROM products
WHERE product_category_name IS NULL
LIMIT 20;



SELECT 'Orders without matching customers' AS check_name,
       COUNT(*) AS issue_count
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'Order items without matching orders',
       COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Order items without matching products',
       COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'Order items without matching sellers',
       COUNT(*)
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT 'Payments without matching orders',
       COUNT(*)
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT
    review_id,
    COUNT(*) AS occurrence_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS missing_review_ids
FROM order_reviews
WHERE review_id IS NULL;

SELECT *
FROM order_reviews
WHERE review_id IN (
    SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
)
ORDER BY review_id;

SELECT
    review_id,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT review_score) AS distinct_scores
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;

SELECT
    review_id,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT review_score) AS distinct_scores,
    COUNT(DISTINCT review_comment_title) AS distinct_titles,
    COUNT(DISTINCT review_comment_message) AS distinct_messages,
    COUNT(DISTINCT review_creation_date) AS distinct_creation_dates,
    COUNT(DISTINCT review_answer_timestamp) AS distinct_answer_dates
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;

SELECT *
FROM order_reviews
WHERE review_id IN (
    SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
)
ORDER BY review_id, order_id;

SELECT
    review_id,
    order_id,
    COUNT(*) AS occurrence_count
FROM order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) FILTER (WHERE review_id IS NULL) AS missing_review_ids,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_ids
FROM order_reviews;

SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'order_reviews'
  AND constraint_type = 'PRIMARY KEY';


 -- Check orders without payment records

SELECT
    COUNT(*) AS orders_without_payment_records
FROM orders o
LEFT JOIN order_payments op
    ON o.order_id = op.order_id
WHERE op.order_id IS NULL;


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