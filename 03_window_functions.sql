-- =====================================================
-- PART B: WINDOW FUNCTIONS IMPLEMENTATION
-- =====================================================

-- CATEGORY 1: RANKING FUNCTIONS
-- =====================================================

-- 1.1 ROW_NUMBER, RANK, DENSE_RANK
-- Purpose: Rank customers by total spending
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) as total_spent,
    ROW_NUMBER() OVER (ORDER BY SUM(o.total_amount) DESC) as row_num,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as rank,
    DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as dense_rank
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- Business Interpretation:
-- Identifies top-spending customers for VIP programs and loyalty rewards.
-- ROW_NUMBER provides unique ranking even for ties.


-- 1.2 PERCENT_RANK
-- Purpose: Calculate percentile rank of products by sales volume
SELECT 
    p.product_name,
    SUM(o.quantity) as total_quantity_sold,
    PERCENT_RANK() OVER (ORDER BY SUM(o.quantity)) as percentile_rank
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

-- Business Interpretation:
-- Shows relative performance of each product in the catalog.
-- Products with percentile > 0.75 are top performers.


-- 1.3 Top 3 Products per Region
-- Purpose: Identify best-selling products in each region
WITH regional_sales AS (
    SELECT 
        r.region_name,
        p.product_name,
        SUM(o.total_amount) as revenue,
        RANK() OVER (PARTITION BY r.region_name ORDER BY SUM(o.total_amount) DESC) as rank
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN regions r ON c.region_id = r.region_id
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY r.region_name, p.product_name
)
SELECT region_name, product_name, revenue, rank
FROM regional_sales
WHERE rank <= 3;

-- Business Interpretation:
-- Enables region-specific inventory planning and marketing strategies.
-- Reveals regional product preferences for targeted promotions.


-- CATEGORY 2: AGGREGATE WINDOW FUNCTIONS
-- =====================================================

-- 2.1 Running Total (ROWS frame)
-- Purpose: Calculate cumulative revenue over time
SELECT 
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total
FROM orders
ORDER BY order_date;

-- Business Interpretation:
-- Tracks cumulative revenue growth to monitor business trajectory.
-- Helps identify acceleration or deceleration in sales trends.


-- 2.2 Moving Average (RANGE frame)
-- Purpose: Calculate 3-order moving average
SELECT 
    order_id,
    order_date,
    total_amount,
    AVG(total_amount) OVER (
        ORDER BY order_id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3orders
FROM orders
ORDER BY order_id;

-- Business Interpretation:
-- Smooths out fluctuations to reveal underlying sales trends.
-- Useful for forecasting and identifying seasonal patterns.


-- 2.3 MIN and MAX Window Functions
-- Purpose: Compare each order to min/max in same month
SELECT 
    order_id,
    order_date,
    total_amount,
    MIN(total_amount) OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
    ) as min_monthly_order,
    MAX(total_amount) OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
    ) as max_monthly_order
FROM orders
ORDER BY order_date;

-- Business Interpretation:
-- Highlights order value variance within each month.
-- Identifies high-value transactions for upselling analysis.


-- CATEGORY 3: NAVIGATION FUNCTIONS
-- =====================================================

-- 3.1 LAG and LEAD
-- Purpose: Calculate month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) as year,
        EXTRACT(MONTH FROM order_date) as month,
        SUM(total_amount) as revenue
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    year,
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) as prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY year, month) as revenue_change,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY year, month)) / 
        LAG(revenue) OVER (ORDER BY year, month) * 100)::NUMERIC, 2
    ) as growth_percentage
FROM monthly_revenue
ORDER BY year, month;

-- Business Interpretation:
-- Measures business growth momentum month-over-month.
-- Negative growth indicates need for promotional interventions.


-- 3.2 Customer Purchase Intervals
-- Purpose: Analyze time between customer purchases
WITH customer_orders AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as prev_order_date
    FROM orders
)
SELECT 
    c.customer_name,
    co.order_date,
    co.prev_order_date,
    co.order_date - co.prev_order_date as days_between_orders
FROM customer_orders co
INNER JOIN customers c ON co.customer_id = c.customer_id
WHERE co.prev_order_date IS NOT NULL
ORDER BY c.customer_name, co.order_date;

-- Business Interpretation:
-- Identifies customer purchase frequency patterns.
-- Long intervals suggest need for re-engagement campaigns.


-- CATEGORY 4: DISTRIBUTION FUNCTIONS
-- =====================================================

-- 4.1 NTILE - Customer Segmentation
-- Purpose: Segment customers into quartiles by spending
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) as total_spent
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent) as quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 4 THEN 'Premium'
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 3 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 2 THEN 'Silver'
        ELSE 'Bronze'
    END as customer_tier
FROM customer_spending
ORDER BY total_spent DESC;

-- Business Interpretation:
-- Creates customer tiers for differentiated service levels.
-- Premium customers receive priority support and exclusive offers.


-- 4.2 CUME_DIST - Cumulative Distribution
-- Purpose: Calculate cumulative distribution of product prices
SELECT 
    product_name,
    price,
    CUME_DIST() OVER (ORDER BY price) as cumulative_dist,
    ROUND((CUME_DIST() OVER (ORDER BY price) * 100)::NUMERIC, 2) as percentile
FROM products
ORDER BY price;

-- Business Interpretation:
-- Shows price positioning of products in catalog.
-- Products below 50th percentile are budget-friendly options.
