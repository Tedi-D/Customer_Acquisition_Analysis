--UPDATED segmentation:


-- Recency calculation
WITH recency_data AS (
   SELECT
       user_crm_id,
       latest_purchase_date,
       DATE_DIFF((SELECT MAX(latest_purchase_date) FROM `prism-insights.warehouse_PT.users`), latest_purchase_date, MONTH) AS Recency
   FROM `prism-insights.warehouse_PT.users`
),
recency_score_data AS (
   SELECT
       user_crm_id,
       latest_purchase_date,
       CASE
           WHEN Recency BETWEEN 0 AND 2 THEN 1  
           WHEN Recency BETWEEN 3 AND 6 THEN 2  
           ELSE 3                                
       END AS recency_score
   FROM recency_data
),


-- Frequency calculation
frequency_data AS (
   SELECT
       user_crm_id,
       COUNT(DISTINCT transaction_id) AS purchase_count
   FROM `prism-insights.warehouse_PT.transactions`
   WHERE user_crm_id IS NOT NULL
   GROUP BY user_crm_id
),
frequency_score_data AS (
   SELECT
       user_crm_id,
       CASE
           WHEN purchase_count > PERCENTILE_CONT(purchase_count, 0.90) OVER() THEN 1  
           WHEN purchase_count > PERCENTILE_CONT(purchase_count, 0.7) OVER() THEN 2  
           ELSE 3  
       END AS frequency_score
   FROM frequency_data
),


-- Monetary value calculation
monetary_data AS (
   SELECT
       user_crm_id,
       ROUND(SUM(transaction_total), 0) AS total_spent
   FROM `prism-insights.warehouse_PT.transactions`
   WHERE user_crm_id IS NOT NULL
   GROUP BY user_crm_id
),
monetary_score_data AS (
   SELECT
       user_crm_id,
       total_spent,
       CASE
           WHEN total_spent > PERCENTILE_CONT(total_spent, 0.80) OVER() THEN 1  
           WHEN total_spent > PERCENTILE_CONT(total_spent, 0.50) OVER() THEN 2  
           ELSE 3  
       END AS monetary_score
   FROM monetary_data
),


-- Combined RFM segments
combined_rfm AS (
   SELECT
       r.user_crm_id,
       r.recency_score,
       f.frequency_score,
       m.monetary_score,
       (r.recency_score + f.frequency_score + m.monetary_score) AS total_score
   FROM recency_score_data r
   LEFT JOIN frequency_score_data f ON r.user_crm_id = f.user_crm_id
   LEFT JOIN monetary_score_data m ON r.user_crm_id = m.user_crm_id
),


-- Segment classification 
segment_data AS (
   SELECT
       user_crm_id,
       CASE
           WHEN total_score BETWEEN 3 AND 4 THEN '1 - Trendy'
           WHEN total_score BETWEEN 5 AND 6 THEN '2 - Engaged Shoppers'
           WHEN total_score = 7 THEN '3 - Casual Buyers'
           WHEN total_score = 8 THEN '4 - At-Risk Customers'
           ELSE '5 - Lost Causes'
       END AS segment
   FROM combined_rfm
),


-- Final output
main AS (
   SELECT
       u.user_crm_id,
       s.total_spent,
       u.city,
       u.user_gender,
       freq.purchase_count,
       u.latest_purchase_date,
       seg.segment
   FROM `prism-insights.warehouse_PT.users` u
   LEFT JOIN monetary_data s ON u.user_crm_id = s.user_crm_id
   LEFT JOIN segment_data seg ON u.user_crm_id = seg.user_crm_id
   LEFT JOIN frequency_data freq ON u.user_crm_id = freq.user_crm_id
   ORDER BY user_crm_id
)


SELECT segment, COUNT(*)
FROM main
GROUP BY segment
ORDER BY segment;


PER USER:

-- Recency calculation
WITH recency_data AS (
   SELECT
       user_crm_id,
       latest_purchase_date,
       DATE_DIFF((SELECT MAX(latest_purchase_date) FROM `prism-insights.warehouse_PT.users`), latest_purchase_date, MONTH) AS Recency
   FROM `prism-insights.warehouse_PT.users`
),
recency_score_data AS (
   SELECT
       user_crm_id,
       latest_purchase_date,
       CASE
           WHEN Recency BETWEEN 0 AND 2 THEN 1  
           WHEN Recency BETWEEN 3 AND 6 THEN 2  
           ELSE 3                                
       END AS recency_score
   FROM recency_data
),


-- Frequency calculation
frequency_data AS (
   SELECT
       user_crm_id,
       COUNT(DISTINCT transaction_id) AS purchase_count
   FROM `prism-insights.warehouse_PT.transactions`
   WHERE user_crm_id IS NOT NULL
   GROUP BY user_crm_id
),
frequency_score_data AS (
   SELECT
       user_crm_id,
       CASE
           WHEN purchase_count > PERCENTILE_CONT(purchase_count, 0.90) OVER() THEN 1  
           WHEN purchase_count > PERCENTILE_CONT(purchase_count, 0.7) OVER() THEN 2  
           ELSE 3  
       END AS frequency_score
   FROM frequency_data
),


-- Monetary value calculation
monetary_data AS (
   SELECT
       user_crm_id,
       ROUND(SUM(transaction_total), 0) AS total_spent
   FROM `prism-insights.warehouse_PT.transactions`
   WHERE user_crm_id IS NOT NULL
   GROUP BY user_crm_id
),
monetary_score_data AS (
   SELECT
       user_crm_id,
       total_spent,
       CASE
           WHEN total_spent > PERCENTILE_CONT(total_spent, 0.80) OVER() THEN 1  
           WHEN total_spent > PERCENTILE_CONT(total_spent, 0.50) OVER() THEN 2  
           ELSE 3  
       END AS monetary_score
   FROM monetary_data
),


-- Combined RFM segments
combined_rfm AS (
   SELECT
       r.user_crm_id,
       r.recency_score,
       f.frequency_score,
       m.monetary_score,
       (r.recency_score + f.frequency_score + m.monetary_score) AS total_score
   FROM recency_score_data r
   LEFT JOIN frequency_score_data f ON r.user_crm_id = f.user_crm_id
   LEFT JOIN monetary_score_data m ON r.user_crm_id = m.user_crm_id
),


-- Segment classification
segment_data AS (
   SELECT
       user_crm_id,
       CASE
           WHEN total_score BETWEEN 3 AND 4 THEN '1 - Trendy'
           WHEN total_score BETWEEN 5 AND 6 THEN '2 - Engaged Shoppers'
           WHEN total_score = 7 THEN '3 - Casual Buyers'
           WHEN total_score = 8 THEN '4 - At-Risk Customers'
           ELSE '5 - Lost Causes'
       END AS segment
   FROM combined_rfm
),


-- Final output
main AS (
   SELECT
       u.user_crm_id,
       s.total_spent,
       u.city,
       u.user_gender,
       freq.purchase_count,
       u.latest_purchase_date,
       seg.segment
   FROM `prism-insights.warehouse_PT.users` u
   LEFT JOIN monetary_data s ON u.user_crm_id = s.user_crm_id
   LEFT JOIN segment_data seg ON u.user_crm_id = seg.user_crm_id
   LEFT JOIN frequency_data freq ON u.user_crm_id = freq.user_crm_id
   ORDER BY user_crm_id
)


SELECT
    user_crm_id,
    total_spent,
    city,
    user_gender,
    purchase_count,
    latest_purchase_date,
    segment
FROM main
ORDER BY user_crm_id;



SELECT -- CLV/lifetime value
    user_crm_id,
    SUM(transaction_total) AS total_spent,
    COUNT(DISTINCT transaction_id) AS purchase_count,
    AVG(transaction_total) AS avg_order_value,
    DATE_DIFF(MAX(date), MIN(date), DAY) AS customer_lifespan,
    SUM(transaction_total) / COUNT(DISTINCT transaction_id) * (COUNT(DISTINCT transaction_id) / NULLIF(DATE_DIFF(MAX(date), MIN(date), DAY) / 30, 0)) AS estimated_CLV
FROM `prism-insights.warehouse_PT.transactions`
GROUP BY user_crm_id;



SELECT -- MONTHLY CLV
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    user_crm_id,
    SUM(transaction_total) AS total_spent,
    COUNT(DISTINCT transaction_id) AS purchase_count,
    AVG(transaction_total) AS avg_order_value,
    DATE_DIFF(MAX(date), MIN(date), DAY) AS customer_lifespan,
    SUM(transaction_total) / COUNT(DISTINCT transaction_id) *
    (COUNT(DISTINCT transaction_id) / NULLIF(DATE_DIFF(MAX(date), MIN(date), DAY) / 30, 0)) AS estimated_CLV
FROM `prism-insights.warehouse_PT.transactions`
WHERE user_crm_id IS NOT NULL
GROUP BY year, month, user_crm_id
ORDER BY year, month, user_crm_id;


SELECT --lifespan
    user_crm_id,
    MIN(date) AS first_purchase_date,
    MAX(date) AS latest_purchase_date,
    DATE_DIFF(MAX(date), MIN(date), DAY) AS customer_lifespan
FROM `prism-insights.warehouse_PT.transactions`


GROUP BY user_crm_id;

SELECT -- acquisition channels
  user_crm_id,
  session_id,


  CASE
    WHEN LOWER(traffic_source) IN ('facebook', 'm.facebook.com', 'l.facebook.com', 'lm.facebook.com', 'facebook.com') THEN 'Facebook'
    WHEN LOWER(traffic_source) IN ('instagram', 'intstagram.com', 'l.instagram.com') THEN 'Instagram'
    WHEN LOWER(traffic_source) IN ('twitter', 'twitter.com') THEN 'Twitter'
    WHEN LOWER(traffic_source) IN ('tiktok', 'tiktok.com') THEN 'TikTok'
    WHEN LOWER(traffic_source) IN ('youtube', 'youtube.com') THEN 'YouTube'
    WHEN LOWER(traffic_source) = '(direct)' THEN 'Organic'
    ELSE traffic_source
  END AS normalized_traffic_source
FROM
  `prism-insights.warehouse_PT.sessions`
WHERE
  user_crm_id IS NOT NULL;

SELECT -- lifespan bins
    user_crm_id,
    MIN(date) AS first_purchase_date,
    MAX(date) AS latest_purchase_date,
    DATE_DIFF(MAX(date), MIN(date), DAY) AS customer_lifespan,
    CASE 
        WHEN DATE_DIFF(MAX(date), MIN(date), DAY) BETWEEN 0 AND 90 THEN '0-90 days'
        WHEN DATE_DIFF(MAX(date), MIN(date), DAY) BETWEEN 91 AND 365 THEN '91-365 days'
        ELSE '366+ days'
    END AS lifespan_bin
FROM `prism-insights.warehouse_PT.transactions`
WHERE user_crm_id IS NOT NULL
GROUP BY user_crm_id
ORDER BY customer_lifespan;



