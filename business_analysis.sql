SHOW DATABASES;
USE retail_consumer_analytics;
SHOW TABLES;
SELECT COUNT(*) 
FROM shopping_data;
SELECT *  from  customer_id limit 20
USE retail_consumer_analytics;

SELECT *
FROM shopping_data
LIMIT 20;
SELECT customer_id
FROM shopping_data
LIMIT 20;
-- Question: What is the total revenue by gender?
 select gender , sum(purchase_amount_usd)as revenue
 from shopping_data
 group by gender;
 -- Question: Which customers used a discount and still spent more than the average purchase amount?

SELECT
    customer_id,
    item_purchased,
    category,
    purchase_amount_usd,
    discount_applied
FROM shopping_data
WHERE discount_applied = 'Yes'
  AND purchase_amount_usd > (
      SELECT AVG(purchase_amount_usd)
      FROM shopping_data
  )
ORDER BY purchase_amount_usd DESC;
-- Question: Which are the top 5 products with the highest average review rating?

SELECT
    item_purchased,
    AVG(review_rating) AS average_review_rating
FROM shopping_data
GROUP BY item_purchased
ORDER BY average_review_rating DESC
LIMIT 5;
-- Question: Compare the average purchase amount between Standard and Express shipping.

SELECT
    shipping_type,
    AVG(purchase_amount_usd) AS average_purchase_amount
FROM shopping_data
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY average_purchase_amount DESC;
-- Question: Do subscribed customers spend more on average than non-subscribed customers?

SELECT
    subscription_status,
    AVG(purchase_amount_usd) AS average_spending
FROM shopping_data
GROUP BY subscription_status
ORDER BY average_spending DESC;
-- Question: Which 5 products have the highest percentage of purchases with a discount applied?

SELECT
    item_purchased,
    COUNT(*) AS total_purchases,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_purchases,
    ROUND(
        SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS discount_percentage
FROM shopping_data
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;
-- Question: Segment customers into New, Returning, and Loyal based on previous purchases and count each segment.

SELECT
    CASE
        WHEN previous_purchases <= 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 5 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(DISTINCT customer_id) AS customer_count
FROM shopping_data
GROUP BY customer_segment
ORDER BY customer_count DESC;
-- Question: What are the top 3 purchased products in each category?

WITH product_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS product_rank
    FROM shopping_data
    GROUP BY category, item_purchased
)

SELECT
    category,
    item_purchased,
    purchase_count
FROM product_counts
WHERE product_rank <= 3
ORDER BY category, product_rank;
-- Question: Are repeat buyers more likely to subscribe?

SELECT 
    CASE
        WHEN previous_purchases <= 1 THEN 'New Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN subscription_status = 'Yes' THEN 1
        ELSE 0
    END) AS subscribed_customers,
    ROUND(SUM(CASE
                WHEN subscription_status = 'Yes' THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),
            2) AS subscription_rate
FROM
    shopping_data
GROUP BY customer_type
ORDER BY subscription_rate DESC;
-- Question: What is the revenue contribution of each age group?

SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    SUM(purchase_amount_usd) AS total_revenue,

    ROUND(
        SUM(purchase_amount_usd) * 100.0 /
        (SELECT SUM(purchase_amount_usd) FROM shopping_data),
        2
    ) AS revenue_percentage

FROM shopping_data

GROUP BY age_group

ORDER BY total_revenue DESC;
