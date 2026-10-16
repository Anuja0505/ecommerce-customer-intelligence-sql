
-- Project: E-Commerce Customer Intelligence
-- Stage 2: Schema Validation

-- 1. List all project tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Check column definitions
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'customers',
      'orders',
      'order_items',
      'order_payments',
      'order_reviews',
      'products',
      'sellers',
      'geolocation',
      'product_category_translation'
  )
ORDER BY table_name, ordinal_position;
