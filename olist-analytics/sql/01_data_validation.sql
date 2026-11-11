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




