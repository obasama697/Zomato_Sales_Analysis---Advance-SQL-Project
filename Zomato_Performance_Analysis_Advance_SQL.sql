-- Zomato Data Analysis

## Exploratory Data Analysis
SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;

SELECT COUNT(*) FROM customers
WHERE 
	customer_name IS NULL
    OR
    reg_date IS NULL;
    
SELECT COUNT(*) FROM restaurants
WHERE 
	restaurant_name IS NULL
    OR city IS NULL
    OR opening_hours IS NULL;
    
SELECT COUNT(*) 
FROM restaurants
WHERE 
    restaurant_id IS NULL
    OR restaurant_name IS NULL
    OR city IS NULL
    OR opening_hours IS NULL;
    
SELECT COUNT(*) 
FROM riders
WHERE 
    rider_id IS NULL
    OR rider_name IS NULL
    OR sign_up IS NULL;

SELECT COUNT(*) 
FROM orders
WHERE 
    order_id IS NULL
    OR customer_id IS NULL
    OR restaurant_id IS NULL
    OR order_item IS NULL
    OR order_date IS NULL
    OR order_time IS NULL
    OR order_status IS NULL
    OR quantity IS NULL
    OR total_amount IS NULL;

SELECT COUNT(*) 
FROM deliveries
WHERE 
    delivery_id IS NULL
    OR order_id IS NULL
    OR delivery_status IS NULL
    OR delivery_time IS NULL
    OR rider_id IS NULL;


### Analysis & Reporting

-- Q1 Find the top 5 most frequently ordered dishes by customer called Harsh Vora in the last 3 years.

-- join customer and orders table
-- filter for last 3 years
-- Filter 'Harsh Vora'
-- group by customer id, dishes, count

SELECT 
    customer_name,
    dishes,
    total_orders
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_item AS dishes,
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS `rank`
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
    WHERE 
        o.order_date >= CURDATE() - INTERVAL 3 YEAR
        AND c.customer_name = 'Harsh Vora'
    GROUP BY 
        c.customer_id, c.customer_name, o.order_item
) AS t1
WHERE `rank` <= 5
ORDER BY total_orders DESC LIMIT 5;

-- 2. Popular Time Slots
-- Q: Identify the time slots during which the most orders are place based on 2-hour intervals.  

SELECT 
    CASE
        WHEN HOUR(order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN HOUR(order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN HOUR(order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN HOUR(order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN HOUR(order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN HOUR(order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN HOUR(order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN HOUR(order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN HOUR(order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN HOUR(order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN HOUR(order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN HOUR(order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY time_slot
ORDER BY order_count DESC;

-- 3. Order Value Analysis
-- Q: Find the avergae order value per customer who has placed more than 20 orders.
-- Return customer_name, and aov
SELECT
	c.customer_name,
    AVG(o.total_amount) as aov
FROM orders as o
	JOIN customers as c
    ON c.customer_id = o.customer_id
GROUP BY 1
HAVING COUNT(order_id) > 20;

-- 4. High-Value Customer
-- Q: List the customers who have spent more than 5K in total on food orders.
-- Return customer_name, and customer_id
SELECT
	c.customer_name,
    SUM(o.total_amount) as total_spent
FROM orders as o
	JOIN customers as c
    ON c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 5000;

-- 5. Order without Delivery
-- Q: Find orders that were placed but not delivered.
-- Return each restaurant name, city and number of not delivered orders
SELECT * from orders as o
JOIN deliveries as d
ON o.order_id = d.order_id;
    
SELECT 
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS not_delivered_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status <> 'Delivered'
GROUP BY r.restaurant_name, r.city
ORDER BY not_delivered_orders DESC
LIMIT 2000;


-- 6. Restaurant Revenue Ranking:
-- Q. Rank restaurants by their revenue from the 2 last years, including their name,
-- total revenue, and rank within their city


WITH revenue_table AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        r.city,
        SUM(o.total_amount) AS total_revenue
    FROM orders o
    JOIN restaurants r 
        ON r.restaurant_id = o.restaurant_id
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR) 
    GROUP BY r.restaurant_id, r.restaurant_name, r.city
)
SELECT
    restaurant_name,
    city,
    total_revenue,
    RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS rank_within_city
FROM revenue_table
ORDER BY city, rank_within_city;

-- Q7. Most popular Dish by City:
-- Identify most popular dish in each city based on the number of orders.
SELECT * FROM
(
    SELECT 
        r.city,
        o.order_item AS dish,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS dish_rank
    FROM orders o
    JOIN restaurants r 
        ON o.restaurant_id = r.restaurant_id
    GROUP BY r.city, o.order_item
)
as t1
WHERE dish_rank = 1
ORDER BY city, dish_rank;

-- Q8. Customer Churn:
-- Find customers who haven't placed an order in 2024 but did in 2023.

-- find customers who ordered in 2023
-- find customer who did not order in 2024
-- compare 1 & 2

SELECT 
    c.customer_id,
    c.customer_name
FROM customers c
JOIN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE YEAR(order_date) = 2023
) AS o23
    ON c.customer_id = o23.customer_id
LEFT JOIN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE YEAR(order_date) = 2024
) AS o24
    ON c.customer_id = o24.customer_id
WHERE o24.customer_id IS NULL;

-- since there is no churn we will check all the customers name who ordered in both years 2024 & 2025.

WITH c2023 AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE YEAR(order_date) = 2023
),
c2024 AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE YEAR(order_date) = 2024
)
SELECT 
    c.customer_id,
    c.customer_name
FROM customers c
JOIN c2023 ON c.customer_id = c2023.customer_id
JOIN c2024 ON c.customer_id = c2024.customer_id;

-- Q9. Compare the number of orders placed by each customer in 2023 & 2024. 

WITH freq_2023 AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS orders_2023
    FROM orders
    WHERE YEAR(order_date) = 2023
    GROUP BY customer_id
),
freq_2024 AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS orders_2024
    FROM orders
    WHERE YEAR(order_date) = 2024
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.customer_name,
    COALESCE(f23.orders_2023, 0) AS orders_in_2023,
    COALESCE(f24.orders_2024, 0) AS orders_in_2024,
    (COALESCE(f24.orders_2024, 0) - COALESCE(f23.orders_2023, 0)) AS order_difference
FROM customers c
LEFT JOIN freq_2023 f23 ON c.customer_id = f23.customer_id
LEFT JOIN freq_2024 f24 ON c.customer_id = f24.customer_id
ORDER BY order_difference DESC;

-- Q10. Cancellation Rate Comparison:
-- Calculate and compare the order cancellation rate for each restaurant between 2023 and 2024.

WITH stats_2023 AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        r.city,
        COUNT(o.order_id) AS total_orders_2023,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders_2023
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE YEAR(o.order_date) = 2023
    GROUP BY r.restaurant_id, r.restaurant_name, r.city
),
stats_2024 AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        r.city,
        COUNT(o.order_id) AS total_orders_2024,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders_2024
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE YEAR(o.order_date) = 2024
    GROUP BY r.restaurant_id, r.restaurant_name, r.city
)

SELECT 
    COALESCE(s23.restaurant_id, s24.restaurant_id) AS restaurant_id,
    COALESCE(s23.restaurant_name, s24.restaurant_name) AS restaurant_name,
    COALESCE(s23.city, s24.city) AS city,

    -- cancellation rate 2023
    CASE 
        WHEN s23.total_orders_2023 IS NULL OR s23.total_orders_2023 = 0 
            THEN NULL
        ELSE ROUND((s23.cancelled_orders_2023 / s23.total_orders_2023) * 100, 2)
    END AS cancellation_rate_2023,

    -- cancellation rate 2024
    CASE 
        WHEN s24.total_orders_2024 IS NULL OR s24.total_orders_2024 = 0 
            THEN NULL
        ELSE ROUND((s24.cancelled_orders_2024 / s24.total_orders_2024) * 100, 2)
    END AS cancellation_rate_2024

FROM stats_2023 s23
LEFT JOIN stats_2024 s24 ON s23.restaurant_id = s24.restaurant_id

UNION

SELECT 
    COALESCE(s23.restaurant_id, s24.restaurant_id),
    COALESCE(s23.restaurant_name, s24.restaurant_name),
    COALESCE(s23.city, s24.city),

    CASE 
        WHEN s23.total_orders_2023 IS NULL OR s23.total_orders_2023 = 0 
            THEN NULL
        ELSE ROUND((s23.cancelled_orders_2023 / s23.total_orders_2023) * 100, 2)
    END,

    CASE 
        WHEN s24.total_orders_2024 IS NULL OR s24.total_orders_2024 = 0 
            THEN NULL
        ELSE ROUND((s24.cancelled_orders_2024 / s24.total_orders_2024) * 100, 2)
    END

FROM stats_2024 s24
LEFT JOIN stats_2023 s23 ON s24.restaurant_id = s23.restaurant_id

ORDER BY restaurant_name;

-- Q.11 Monthly Restaurant Growth Ratio:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.
WITH monthly_orders AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN restaurants r
        ON r.restaurant_id = o.restaurant_id
    JOIN deliveries d
        ON d.order_id = o.order_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY r.restaurant_id, r.restaurant_name, month
),
monthly_growth AS (
    SELECT
        restaurant_id,
        restaurant_name,
        month,
        total_orders,
        LAG(total_orders) OVER(PARTITION BY restaurant_id ORDER BY month) AS prev_month_orders
    FROM monthly_orders
)
SELECT
    restaurant_id,
    restaurant_name,
    month,
    total_orders,
    prev_month_orders,
    CASE 
        WHEN prev_month_orders IS NULL THEN NULL
        ELSE ROUND((total_orders - prev_month_orders) / prev_month_orders * 100, 2)
    END AS growth_ratio_percent
FROM monthly_growth
ORDER BY restaurant_id, month;

-- Q.12 Customer Segmentation:
-- Segment customers into 'Gold' or 'Silver' groups based on their total spending
-- compare to the average order value(AOV). If a customer's total spending exceeds AOV,
-- label them as 'Gold' otherwise lable them as 'Silver'.
-- determine each segment's total number of orders and total revenue

-- Step 1: Calculate the overall average order value (AOV)
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_spending,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
aov AS (
    SELECT AVG(total_spending) AS avg_order_value
    FROM customer_spending
),
customer_segments AS (
    SELECT
        cs.customer_id,
        cs.customer_name,
        cs.total_spending,
        cs.total_orders,
        CASE
            WHEN cs.total_spending > a.avg_order_value THEN 'Gold'
            ELSE 'Silver'
        END AS segment
    FROM customer_spending cs
    CROSS JOIN aov a
)
SELECT
    segment,
    COUNT(customer_id) AS total_customers,
    SUM(total_orders) AS total_orders,
    SUM(total_spending) AS total_revenue
FROM customer_segments
GROUP BY segment;

-- Q13. Riders Monthly Earnings:
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.
WITH rider_monthly AS (
    SELECT
        d.rider_id,
        r.rider_name,
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(o.total_amount) AS total_orders_amount
    FROM deliveries d
    JOIN orders o
        ON o.order_id = d.order_id
    JOIN riders r
        ON r.rider_id = d.rider_id
    WHERE d.delivery_time IS NOT NULL  -- Only delivered orders
    GROUP BY d.rider_id, r.rider_name, month
)
SELECT
    rider_id,
    rider_name,
    month,
    total_orders_amount,
    ROUND(total_orders_amount * 0.08, 2) AS monthly_earnings
FROM rider_monthly
ORDER BY rider_id, month;

-- Q14. Rider Rating Analysis:
-- Find the number of 5-star, 4-star and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 20 minutes of order received time the rider get 5 star rating.
-- if they deliver 20 and 30 minutes they get 4 star rating
-- if they deliver after 30 minutes they get 3 star rating
SELECT
    r.rider_id,
    r.rider_name,
    SUM(CASE 
            WHEN TIMESTAMPDIFF(MINUTE, o.order_time, d.delivery_time) < 20 THEN 1
            ELSE 0
        END) AS five_stars,
    SUM(CASE 
            WHEN TIMESTAMPDIFF(MINUTE, o.order_time, d.delivery_time) BETWEEN 20 AND 30 THEN 1
            ELSE 0
        END) AS four_stars,
    SUM(CASE 
            WHEN TIMESTAMPDIFF(MINUTE, o.order_time, d.delivery_time) > 30 THEN 1
            ELSE 0
        END) AS three_stars
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
JOIN riders r
    ON r.rider_id = d.rider_id
WHERE d.delivery_time IS NOT NULL
GROUP BY r.rider_id, r.rider_name
ORDER BY r.rider_id;

-- Q15. Order Frequency by Day:
-- Analyze order frequency per day of the week and identify the peak day for each restaurant
WITH orders_per_day AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        DAYNAME(o.order_date) AS day_of_week,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN restaurants r
        ON r.restaurant_id = o.restaurant_id
    GROUP BY r.restaurant_id, r.restaurant_name, day_of_week
),
ranked_days AS (
    SELECT
        restaurant_id,
        restaurant_name,
        day_of_week,
        total_orders,
        RANK() OVER(PARTITION BY restaurant_id ORDER BY total_orders DESC) AS rank_day
    FROM orders_per_day
)
SELECT
    restaurant_id,
    restaurant_name,
    day_of_week AS peak_day,
    total_orders AS orders_on_peak_day
FROM ranked_days
WHERE rank_day = 1
ORDER BY restaurant_id;

-- Q.16 Customer Lifetime Value(CLV):
-- Calculate the total revenue generated by each customer over all their orders.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;

-- Q17. Monthly Sales Trends:
-- Identify sales trends by comparing each month's totl sales to the previous month
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY month
),
sales_trends AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER(ORDER BY month) AS prev_month_sales
    FROM monthly_sales
)
SELECT
    month,
    total_sales,
    prev_month_sales,
    CASE
        WHEN prev_month_sales IS NULL THEN NULL
        ELSE ROUND((total_sales - prev_month_sales) / prev_month_sales * 100, 2)
    END AS growth_percentage
FROM sales_trends
ORDER BY month;

-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
WITH rider_delivery_durations AS (
    SELECT
        r.rider_id,
        r.rider_name,
        -- Calculate delivery duration in minutes, handling cross-midnight
        CASE
            WHEN TIME_TO_SEC(d.delivery_time) >= TIME_TO_SEC(o.order_time) THEN
                (TIME_TO_SEC(d.delivery_time) - TIME_TO_SEC(o.order_time)) / 60
            ELSE
                ((TIME_TO_SEC(d.delivery_time) + 24*3600) - TIME_TO_SEC(o.order_time)) / 60
        END AS delivery_duration_minutes
    FROM riders r
    JOIN deliveries d
        ON r.rider_id = d.rider_id
    JOIN orders o
        ON o.order_id = d.order_id
    WHERE d.delivery_time IS NOT NULL
)
SELECT
    rider_id,
    rider_name,
    ROUND(AVG(delivery_duration_minutes), 2) AS avg_delivery_time
FROM rider_delivery_durations
GROUP BY rider_id, rider_name
ORDER BY avg_delivery_time ASC;  -- fastest riders first

-- calculating average delivery time minimum and maximum

WITH rider_avg_times AS (
    SELECT
        r.rider_id,
        r.rider_name,
        -- Calculate delivery duration in minutes, handling cross-midnight
        CASE
            WHEN TIME_TO_SEC(d.delivery_time) >= TIME_TO_SEC(o.order_time) THEN
                (TIME_TO_SEC(d.delivery_time) - TIME_TO_SEC(o.order_time)) / 60
            ELSE
                ((TIME_TO_SEC(d.delivery_time) + 24*3600) - TIME_TO_SEC(o.order_time)) / 60
        END AS delivery_duration_minutes
    FROM riders r
    JOIN deliveries d
        ON r.rider_id = d.rider_id
    JOIN orders o
        ON o.order_id = d.order_id
    WHERE d.delivery_time IS NOT NULL
),
rider_avg AS (
    SELECT
        rider_id,
        rider_name,
        ROUND(AVG(delivery_duration_minutes), 2) AS avg_delivery_time_minutes
    FROM rider_avg_times
    GROUP BY rider_id, rider_name
)
SELECT
    MIN(avg_delivery_time_minutes) AS min_avg_delivery_time_minutes,
    MAX(avg_delivery_time_minutes) AS max_avg_delivery_time_minutes
FROM rider_avg;

-- Fastest vs. Slowest riders based on average delivery time:
WITH rider_delivery_durations AS (
    SELECT
        r.rider_id,
        r.rider_name,
        -- Calculate delivery duration in minutes, handling cross-midnight
        CASE
            WHEN TIME_TO_SEC(d.delivery_time) >= TIME_TO_SEC(o.order_time) THEN
                (TIME_TO_SEC(d.delivery_time) - TIME_TO_SEC(o.order_time)) / 60
            ELSE
                ((TIME_TO_SEC(d.delivery_time) + 24*3600) - TIME_TO_SEC(o.order_time)) / 60
        END AS delivery_duration_minutes
    FROM riders r
    JOIN deliveries d
        ON r.rider_id = d.rider_id
    JOIN orders o
        ON o.order_id = d.order_id
    WHERE d.delivery_time IS NOT NULL
),
rider_avg AS (
    SELECT
        rider_id,
        rider_name,
        ROUND(AVG(delivery_duration_minutes), 2) AS avg_delivery_time
    FROM rider_delivery_durations
    GROUP BY rider_id, rider_name
)
-- Get fastest and slowest rider
SELECT *
FROM rider_avg
WHERE avg_delivery_time = (SELECT MIN(avg_delivery_time) FROM rider_avg)
   OR avg_delivery_time = (SELECT MAX(avg_delivery_time) FROM rider_avg);


-- Q.19 Order Time Popularity:
-- Track the popularity of specific order items over time and identify seasonal demand spikes
WITH item_season_orders AS (
    SELECT
        o.order_item,
        CASE
            WHEN MONTH(o.order_date) BETWEEN 3 AND 6 THEN 'Summer'
            WHEN MONTH(o.order_date) BETWEEN 11 AND 12 OR MONTH(o.order_date) <= 2 THEN 'Winter'
            ELSE 'Spring'
        END AS season,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN deliveries d
        ON o.order_id = d.order_id
    WHERE d.delivery_time IS NOT NULL
    GROUP BY o.order_item, season
),
item_peak_season AS (
    SELECT t1.order_item, t1.season, t1.total_orders
    FROM item_season_orders t1
    LEFT JOIN item_season_orders t2
        ON t1.order_item = t2.order_item AND t1.total_orders < t2.total_orders
    WHERE t2.order_item IS NULL
)
SELECT *
FROM item_peak_season
ORDER BY order_item;

-- Q20. Rank each city based on the total revenue for year 2023
    SELECT
    r.city,
    SUM(o.total_amount) AS total_revenue,
    RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS city_rank
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE YEAR(o.order_date) = 2023
GROUP BY r.city
ORDER BY city_rank;
