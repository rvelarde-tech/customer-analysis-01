-- Retail Analytics SQL Queries
-- Use with DuckDB, PostgreSQL, BigQuery, Snowflake, etc.
-- IMPORTANT: Always use LIMIT/SAMPLE for exploration queries on large tables

-- ============================================================================
-- SALES OVERVIEW QUERIES
-- ============================================================================

-- Daily Sales Summary
SELECT
    DATE(order_date) as date,
    COUNT(DISTINCT order_id) as order_count,
    SUM(sales_amount) as total_sales,
    AVG(sales_amount) as avg_order_value,
    SUM(quantity) as total_units,
    COUNT(DISTINCT customer_id) as unique_customers
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 90 DAY
GROUP BY DATE(order_date)
ORDER BY date DESC
LIMIT 100;

-- Monthly Trends (YoY Comparison)
SELECT
    DATE_TRUNC('month', order_date) as month,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customers,
    ROUND(SUM(sales_amount) / COUNT(DISTINCT order_id), 2) as aov
FROM sales
WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 24 MONTH)
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- ============================================================================
-- PRODUCT PERFORMANCE
-- ============================================================================

-- Top 20 Products by Revenue
SELECT
    product_id,
    product_name,
    category,
    SUM(sales_amount) as total_revenue,
    SUM(quantity) as units_sold,
    COUNT(DISTINCT order_id) as order_count,
    ROUND(SUM(sales_amount) / COUNT(DISTINCT order_id), 2) as avg_sale_value,
    ROUND(SUM(sales_amount) / SUM(quantity), 2) as avg_unit_price
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 90 DAY
GROUP BY product_id, product_name, category
ORDER BY total_revenue DESC
LIMIT 20;

-- Product Growth Analysis (vs Previous Period)
SELECT
    product_id,
    product_name,
    SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END) as current_month_sales,
    SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 1 MONTH)
             AND order_date < DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END) as previous_month_sales,
    ROUND(
        (SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END) -
         SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 1 MONTH)
                  AND order_date < DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END))
        / NULLIF(SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 1 MONTH)
                          AND order_date < DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END), 0) * 100, 2
    ) as growth_pct
FROM sales
WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 1 MONTH)
GROUP BY product_id, product_name
HAVING SUM(CASE WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL 1 MONTH)
                AND order_date < DATE_TRUNC('month', CURRENT_DATE) THEN sales_amount ELSE 0 END) > 0
ORDER BY growth_pct DESC
LIMIT 20;

-- Low Performing Products (Consider Discounting/Removing)
SELECT
    product_id,
    product_name,
    category,
    SUM(quantity) as units_sold,
    SUM(sales_amount) as total_revenue,
    DAYS_SINCE_LAST_SALE,
    inventory_level
FROM (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(s.quantity) as quantity,
        SUM(s.sales_amount) as sales_amount,
        DATEDIFF(DAY, MAX(s.order_date), CURRENT_DATE) as days_since_last_sale,
        inv.inventory_level
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    LEFT JOIN inventory inv ON p.product_id = inv.product_id
    WHERE s.order_date >= CURRENT_DATE - INTERVAL 180 DAY
    GROUP BY p.product_id, p.product_name, p.category, inv.inventory_level
)
WHERE units_sold < 10 OR days_since_last_sale > 30
ORDER BY days_since_last_sale DESC
LIMIT 50;

-- ============================================================================
-- CUSTOMER ANALYTICS
-- ============================================================================

-- RFM Analysis (Recency, Frequency, Monetary)
WITH rfm_calc AS (
    SELECT
        customer_id,
        MAX(order_date) as last_purchase_date,
        COUNT(DISTINCT order_id) as purchase_frequency,
        SUM(sales_amount) as total_spent,
        DATEDIFF(DAY, MAX(order_date), CURRENT_DATE) as recency_days
    FROM sales
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        last_purchase_date,
        purchase_frequency,
        total_spent,
        recency_days,
        NTILE(4) OVER (ORDER BY recency_days DESC) as r_score,
        NTILE(4) OVER (ORDER BY purchase_frequency) as f_score,
        NTILE(4) OVER (ORDER BY total_spent) as m_score
    FROM rfm_calc
)
SELECT
    customer_id,
    last_purchase_date,
    recency_days,
    purchase_frequency,
    ROUND(total_spent, 2) as lifetime_value,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) as rfm_segment,
    CASE
        WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 3 AND f_score <= 1 THEN 'At Risk'
        WHEN r_score = 1 AND f_score = 1 THEN 'Lost'
        ELSE 'Other'
    END as customer_segment
FROM rfm_scores
ORDER BY total_spent DESC
LIMIT 1000;

-- Top Customers by Lifetime Value
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(sales_amount) as lifetime_value,
    ROUND(AVG(sales_amount), 2) as avg_order_value,
    MIN(order_date) as first_purchase,
    MAX(order_date) as last_purchase,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) as customer_days,
    ROUND(SUM(sales_amount) / NULLIF(DATEDIFF(DAY, MIN(order_date), MAX(order_date)), 0), 2) as daily_avg_spend
FROM sales
GROUP BY customer_id, customer_name
HAVING SUM(sales_amount) > 1000
ORDER BY lifetime_value DESC
LIMIT 50;

-- Customer Churn Risk (No purchases in 60+ days)
SELECT
    customer_id,
    customer_name,
    SUM(sales_amount) as lifetime_value,
    COUNT(DISTINCT order_id) as total_orders,
    MAX(order_date) as last_purchase_date,
    DATEDIFF(DAY, MAX(order_date), CURRENT_DATE) as days_since_purchase
FROM sales
GROUP BY customer_id, customer_name
HAVING DATEDIFF(DAY, MAX(order_date), CURRENT_DATE) > 60
AND SUM(sales_amount) > 500  -- Was a valuable customer
ORDER BY lifetime_value DESC
LIMIT 100;

-- ============================================================================
-- SALES FORECAST PREPARATION
-- ============================================================================

-- Daily Sales for Forecasting
SELECT
    DATE(order_date) as date,
    DAYOFWEEK(order_date) as day_of_week,
    MONTH(order_date) as month,
    SUM(sales_amount) as daily_sales,
    COUNT(DISTINCT order_id) as orders,
    SUM(quantity) as units
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 365 DAY
GROUP BY DATE(order_date)
ORDER BY date DESC;

-- Seasonal Decomposition Prep
SELECT
    MONTH(order_date) as month,
    DAYOFWEEK(order_date) as day_of_week,
    COUNT(DISTINCT DATE(order_date)) as sales_days,
    ROUND(SUM(sales_amount), 2) as total_sales,
    ROUND(AVG(SUM(sales_amount)) OVER (PARTITION BY MONTH(order_date)), 2) as avg_monthly_sales,
    ROUND(SUM(sales_amount) / COUNT(DISTINCT DATE(order_date)), 2) as avg_daily_sales
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 365 DAY
GROUP BY MONTH(order_date), DAYOFWEEK(order_date)
ORDER BY month, day_of_week;

-- ============================================================================
-- INVENTORY & SALES HEALTH
-- ============================================================================

-- Stock-Out Analysis
SELECT
    product_id,
    product_name,
    category,
    current_inventory,
    CASE WHEN current_inventory = 0 THEN 'CRITICAL'
         WHEN current_inventory < 10 THEN 'LOW'
         ELSE 'OK' END as stock_status,
    SUM(quantity) as units_sold_30d,
    ROUND(SUM(sales_amount), 2) as revenue_30d,
    ROUND(current_inventory / NULLIF(SUM(quantity), 0), 1) as days_of_inventory
FROM sales s
JOIN inventory i ON s.product_id = i.product_id
WHERE s.order_date >= CURRENT_DATE - INTERVAL 30 DAY
GROUP BY s.product_id, product_name, category, current_inventory
ORDER BY stock_status DESC, days_of_inventory ASC
LIMIT 50;

-- ============================================================================
-- KPI DASHBOARD QUERIES
-- ============================================================================

-- Daily/Weekly/Monthly Metrics
SELECT
    DATE_TRUNC('day', order_date) as period,
    'Daily' as period_type,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(SUM(sales_amount) / COUNT(DISTINCT order_id), 2) as aov
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 90 DAY
GROUP BY DATE_TRUNC('day', order_date)

UNION ALL

SELECT
    DATE_TRUNC('week', order_date) as period,
    'Weekly' as period_type,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(SUM(sales_amount) / COUNT(DISTINCT order_id), 2) as aov
FROM sales
WHERE order_date >= CURRENT_DATE - INTERVAL 90 DAY
GROUP BY DATE_TRUNC('week', order_date)

ORDER BY period DESC;
