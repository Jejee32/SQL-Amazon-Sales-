
-- Total Transaction
SELECT 
        productname,
        COUNT(OrderId) AS Total_Transaction
    FROM sales_order
    GROUP BY productname
    ORDER BY Total_Transaction

    -- Total Product Sales
    SELECT 
        productname,
        country,
        SUM (Quantity) AS total_sale
    FROM sales_order
    GROUP BY 
        productname,
        country
    ORDER BY 
    total_sale DESC

    -- Avarage Order
    SELECT
        productname,
        SUM(totalamount) AS total_revenue,
        SUM(totalamount) / COUNT(orderid) AS AOV
    FROM sales_order
    GROUP BY productname
    ORDER BY AOV DESC

-- AVG revenue per month
    SELECT 
        EXTRACT(MONTH FROM orderdate) AS month,
        AVG(totalamount) AS total_revenue
    FROM sales_order
    GROUP BY month
    ORDER BY month

-- Gross Price And Final Price

SELECT
    *,
    EXTRACT(YEAR FROM orderdate) AS year,
    EXTRACT(MONTH FROM orderdate) AS month,
    quantity * unitprice AS gross_revenue
FROM sales_order;

-- Avarage Order Value
SELECT
    SUM(totalamount) AS total_revenue,
    COUNT(orderid) AS total_orders,
    SUM(quantity) AS total_units_sold,
    SUM(totalamount) / COUNT(orderid) AS aov
FROM sales_order
WHERE orderstatus = 'Delivered';


-- Tier Revenue
WITH percentile AS (
    SELECT
        PERCENTILE_CONT(0.25) 
            WITHIN GROUP (ORDER BY totalamount) AS revenue_25th_percentile,
        PERCENTILE_CONT(0.75) 
            WITHIN GROUP (ORDER BY totalamount) AS revenue_75th_percentile
    FROM sales_order
    WHERE orderdate BETWEEN '2022-01-01' AND '2023-12-31'
),
product_revenue AS (
    SELECT
        productname,
        SUM(totalamount) AS total_revenue
    FROM sales_order
    WHERE orderdate BETWEEN '2022-01-01' AND '2023-12-31'
    GROUP BY productname
)

SELECT
    pr.productname AS product,
    CASE
        WHEN pr.total_revenue <= p.revenue_25th_percentile THEN 'LOW'
        WHEN pr.total_revenue >= p.revenue_75th_percentile THEN 'HIGH'
        ELSE 'MEDIUM'
    END AS revenue_tier,
    pr.total_revenue
FROM product_revenue pr
CROSS JOIN percentile p
ORDER BY pr.productname;



-- Persentage Per Category Product
SELECT
    category,
    SUM(totalamount) AS total_amount,
    ROUND(
        SUM(totalamount) * 100.0 
        / SUM(SUM(totalamount)) OVER (),
        2
    ) AS percentage_total
FROM sales_order
GROUP BY category
ORDER BY percentage_total DESC;









-- Month Per Month Revenue
WITH month_revenue AS(
    SELECT 
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(totalamount) AS revenue
FROM sales_order
GROUP BY month
ORDER BY month
)

SELECT 
*,
LAG(revenue) OVER (ORDER BY month) AS Previus_Revenue,
ROUND((revenue - LAG(revenue) OVER (ORDER BY month))/ 
LAG(revenue) OVER (ORDER BY month)::NUMERIC,2)AS Monthly_grow
FROM month_revenue
