-- =====================================================
-- PART A: SQL JOINS IMPLEMENTATION
-- =====================================================

-- 1. INNER JOIN
-- Purpose: Retrieve all orders with customer and product details
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    o.order_date,
    o.quantity,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id = p.product_id
ORDER BY o.order_date;

-- Business Interpretation:
-- Shows complete transaction history with valid customer and product information.
-- Useful for sales reporting and revenue analysis.


-- 2. LEFT JOIN
-- Purpose: Find customers who have never placed an order
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.join_date,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Business Interpretation:
-- Identifies inactive customers who registered but never purchased.
-- Target these customers with promotional campaigns to drive first purchase.


-- 3. RIGHT JOIN
-- Purpose: Identify products that have never been sold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    o.order_id
FROM orders o
RIGHT JOIN products p ON o.product_id = p.product_id
WHERE o.order_id IS NULL;

-- Business Interpretation:
-- Reveals unsold inventory that may need price adjustments or removal.
-- Helps optimize product catalog and reduce storage costs.


-- 4. FULL OUTER JOIN
-- Purpose: Compare all customers and products including unmatched records
SELECT 
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    COUNT(o.order_id) as order_count
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id
FULL OUTER JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, p.product_id, p.product_name;

-- Business Interpretation:
-- Comprehensive view showing both active and inactive customers/products.
-- Identifies gaps in customer engagement and product performance.


-- 5. SELF JOIN
-- Purpose: Find customers from the same region who joined in the same month
SELECT 
    c1.customer_name AS customer1,
    c2.customer_name AS customer2,
    r.region_name,
    c1.join_date
FROM customers c1
INNER JOIN customers c2 ON c1.region_id = c2.region_id 
    AND c1.customer_id < c2.customer_id
    AND EXTRACT(YEAR FROM c1.join_date) = EXTRACT(YEAR FROM c2.join_date)
    AND EXTRACT(MONTH FROM c1.join_date) = EXTRACT(MONTH FROM c2.join_date)
INNER JOIN regions r ON c1.region_id = r.region_id
ORDER BY r.region_name, c1.join_date;

-- Business Interpretation:
-- Identifies customer acquisition patterns by region and time period.
-- Helps evaluate marketing campaign effectiveness in specific regions.
