# Customer Acquisition Analysis
![image](https://github.com/user-attachments/assets/61d95b0d-8ccb-4c3d-b1ab-6248ebdfa11b)

🧠 Customer Lifetime Value Segmentation

An RFM segmentation and acquisition analysis project powered by SQL and Power BI. This work surfaces behavioural insights to support commercial strategy, retention efforts, and audience targeting.

🎯 Project Objective

To identify and interpret key customer segments based on purchasing behaviour and acquisition patterns, using an RFM (Recency, Frequency, Monetary) framework. The insights help commercial stakeholders prioritise high-value customers and uncover retention opportunities.


📈 Overview

Transactional and user-level data were modelled in BigQuery, with behavioural scoring applied through percentile-based banding. The analysis was visualised in Power BI to bring to life customer value, trends, and acquisition performance.

🔍 Key Insights

- The Engaged Shoppers and Trendy segments — while small — contribute disproportionately to overall revenue.
- Customer value declines sharply after 90 days, indicating a crucial retention window.
- Acquisition via Push channels drives traffic, but not always high-value users.
- Segmentation by gender and location offers scope for better personalisation and campaign targeting.

🧩 Segmentation Logic
<br>Each customer was assigned an RFM score:

- Recency: Based on months since latest transaction.
- Frequency: Derived from transaction count, benchmarked via percentiles.
- Monetary: Total customer spend, ranked into score bands.
  <br>These were summed into an RFM total score (range: 3–9), then used to classify customers:

- 3–4 score: 1 - Trendy 
- 5–6 score: 2 - Engaged Shoppers  
- 7 score: 3 - Casual Buyers 
- 8 score: 4 - At-Risk Customers 
- 9 score: 5 - Lost Causes 

Full logic can be found in Sprint 3 - Queries.pdf.


🧰 Data & Tools
- BigQuery: For scoring logic, segmentation, and cohort joins.
- Power BI: For interactive visual reporting and storytelling.

📊 Visuals
Power BI dashboard include:
- Segment contribution to overall revenue
- CLV decay over time
- Acquisition channel breakdown
- Segment distribution by demographic

🧠 Next Steps
- Introduce CLV uplift modelling across campaign cohorts.
- Add acquisition spend data to calculate ROI by channel.
- Enhance granularity by integrating product categories or customer preferences.
