# Retail-Operations-Analytics
operations data, providing insights into product performance, inventory management, supplier and procurement operations, customer behavior, and sales channel performance through interactive dashboards and business analytics

## Table of Contents
- Project Overview  
- Business Objectives  
- Dataset  
- Tools &   Methodology  
- Executive Dashboard  
- Customer Analysis  
- Product Analysis  
- User Performance  
- ⁠Retention Analysis 
- Key Findings  
- Recommendations  
- ⁠Project demonstrations 
- Data Limitation  
- Contact

## Project Overview
This project analyzes retail and operational performance data from 2016–2022 to uncover trends in business growth, product performance, supplier reliability, channel efficiency, customer purchasing behavior, and inventory management.
The analysis focuses on identifying key revenue drivers, evaluating supplier and procurement performance, monitoring inventory health, and generating actionable business insights through data visualization and analytics.


## Business Objectives
* Analyze year-over-year business growth and revenue trends
* Evaluate product and category performance across the analysis period
* Measure SKU-level profitability after incorporating landed costs
* Identify supplier risk indicators and procurement inefficiencies
* Assess channel allocation efficiency and sales performance
* Perform Pareto analysis to identify key revenue-driving products and channels
* Monitor purchase order (PO) trends and procurement activity over time
* Evaluate supplier reliability based on delivery and operational performance
* Analyze customer purchasing behavior and revenue contribution patterns

## Detaset
* <a href=https://github.com/Debbyjones99/Retail-Operations-Analytics/tree/main/Datasets > Retail-Operations-Analytics Data</a>

## Tools & Techniques
* Advanced SQL for data extraction, transformation, and analytical querying
* Power BI for interactive dashboard development and business visualization
* Advanced DAX measures for KPI calculations, YOY growth analysis, procurement trends, and inventory analytics
* Multi-fact Star Schema data modeling for integrating sales, inventory, and procurement datasets
* KPI development and executive performance reporting
* Pareto (80/20) analysis for identifying key revenue-driving products and channels
* Time intelligence analysis for yearly and seasonal performance tracking
* Inventory and procurement analytics for stock monitoring and supplier performance evaluation
* Conditional formatting and business-driven visual storytelling for executive dashboards
* Power Query for data cleaning, transformation, and preprocessing

## Dashboard Overview

### Executive Dashboard Overview
This dashboard provides a high-level overview of business performance from 2016–2022, focusing on revenue growth, customer behaviour, sales channels, and purchasing trends.

<img width="622" height="372" alt="Executive_dashboard" src="https://github.com/Debbyjones99/Retail-Operations-Analytics/blob/main/Dashboard%20Screenshots/Executive_dashboard.PNG" />

Key Metrics
* Total Revenue: $5.1M
* Total Orders: 251K
* Total Orders: 159K
* Average Order Value (AOV): $32.5

Key Insights
* Amazon was the top-performing sales channel, contributing approximately 40% of total revenue.
* Sports & Lifestyle generated the highest revenue across most years.
* Credit card transactions accounted for the highest share of revenue among payment methods.
* Customers in the “Under Value” segment contributed nearly 40% of total revenue.

Yearly Performance Trend
* Revenue grew significantly from $365.9k in 2016 to $884.5K in 2022.
* 2022 recorded the highest sales quantity (48K units) and strongest overall revenue performance.
* Sales consistently peaked during December, indicating strong seasonal demand patterns.

### Product & Inventory Overview
<img width="662" height="372" alt="Prouct_inventory_dashboard" src="https://github.com/Debbyjones99/Retail-Operations-Analytics/blob/main/Dashboard%20Screenshots/Product_dashboard.PNG" />

Key Insights
* Total product returns reached 1,612 orders, representing a relatively low return rate of 1.01% across all products.
* Decathlon Water Bottle generated the highest revenue, contributing $525,226.7 in sales.
* Mijo Bedsheets Set Single generated the lowest revenue at $1.083.4
* Most products maintained healthy inventory levels; however, Nescafé Bottled Water 1.5L and Mijo Bedsheets Set Single showed low stock availability, indicating potential stockout risk.
* Persil Air Freshener 300ml recorded the highest product returns with 90 returned units, suggesting possible quality or customer satisfaction concerns.

Yearly Inventory Insight
* Inventory analysis revealed a high number of stockout cases in 2016, likely due to early-stage operational limitations and weaker inventory planning.
* By 2022, stock management efficiency improved significantly, with only one product experiencing stockout, indicating stronger inventory control and supply planning processes.

### Supplier Performance & Procurement Analytics
<img width="662" height="372" alt="Supplier_procurement_dashboard" src="https://github.com/Debbyjones99/Retail-Operations-Analytics/blob/main/Dashboard%20Screenshots/Supplier%20dashboard.png" />

Key Insights
* A total of 1,063purchase orders experienced delivery delays, highlighting potential supplier and logistics inefficiencies.
* The business recorded an average supplier lead time of 68.52 days, indicating relatively long procurement cycles.
* Average landed cost across all purchase orders was approximately $88.51 per unit.
* Maker Innovations Electronics emerged as the top-performing vendor, generating $558,937 in sales revenue. Notably, the supplier provided the Decathlon Water Bottle, which was also identified as the highest revenue-generating product, showing a strong supplier-to-product revenue correlation.
* Procter & Gamble EMEA generated the lowest supplier-related sales revenue at $6.478.6.
* Procurement activity peaked in March, with a total of 384 purchase orders, making it the busiest procurement month across the analysis period.

Yearly Procurement Insights
* 2019 recorded the highest number of delayed purchase orders, suggesting operational or supplier fulfillment challenges during that year.
* 2017 had the highest average supplier lead time, indicating slower procurement and delivery performance compared to other years.


### Channel & Customer Insights
<img width="662" height="372" alt="Supplier_procurement_dashboard" src="https://github.com/Debbyjones99/Retail-Operations-Analytics/blob/main/Dashboard%20Screenshots/Channel%20Performance.png" />

Key Insights
* The Value Customer segment generated the highest revenue contribution, accounting for approximately $2.1M in total sales.
* The Amazon sales channel recorded the highest number of product returns (509 returns), which aligns with its position as the highest-performing sales channel by overall sales volume.
* Amazon also contributed the highest revenue and sales quantity across all channels, reinforcing its importance as the business’s primary sales platform.
* Credit Card was the most frequently used payment method and generated the highest share of total revenue, indicating strong customer preference for card-based transactions.

## Business Insights

* Revenue increased by over **141.7%** from the first year of operations, indicating significant business growth over the analysis period.
* Supplier risk analysis conducted in SQL identified **Nike Retail Partners** as the highest-risk supplier based on delivery delays, late purchase orders, and lead time performance.
* Sales and profitability consistently peaked during **December**, revealing strong seasonal purchasing trends and holiday demand patterns.

## Recommendations

* Supplier risk analysis revealed that **Nike Retail Partners** recorded the highest supplier risk score (**22.276**), significantly higher than the next supplier (**14.803**). The risk score was calculated using:

  * 40% Delivery Delay
  * 30% Late Purchase Orders
  * 30% Lead Time

  Despite being one of the largest suppliers by product quantity, the supplier demonstrated substantial operational inefficiencies. In comparison, **IKEA Home Furnishings**, the highest supplier by product quantity, maintained a lower supplier risk score (**11.818**), indicating more reliable procurement performance. Supplier relationships and procurement dependency on high-risk vendors should be reviewed.

* Introduce loyalty incentives and exclusive offers for **Premium Customers** to improve retention and maximize high-value customer engagement.

* Implement reward programs and targeted discounts for **Value** and **Budget Customers** to encourage repeat purchases and strengthen customer loyalty.

* **Decathlon Water Bottle** inventory should be restocked promptly to reduce potential stockout risk due to its strong sales performance.

* Inventory levels for **Mijo Bedsheets Set Single** should be reviewed and potentially reduced due to low sales performance and weaker inventory movement.

## What This Project Demonstrates
•	End-to-end retail and operations analytics using SQL and Power BI 

•	Advanced DAX calculations for KPI development, YOY growth analysis, inventory monitoring, and supplier performance evaluation

•	Multi-fact star schema data modeling across sales, procurement, and inventory datasets

•	Business intelligence reporting through interactive executive dashboards and operational analytics 

•	Supplier risk analysis using procurement metrics such as delivery delays, lead times, and late purchase orders 
•	Inventory and stockout analysis for operational efficiency monitoring 
•	Customer segmentation and channel performance analysis for revenue optimization 
•	Data storytelling and business-driven insight generation through visual analytics

## Limitations
•	Return analysis focused on return volumes and rates; detailed return reasons and customer satisfaction metrics were unavailable
•	Supplier risk analysis was based on delivery delays, lead times, and late purchase orders; additional operational factors such as supplier quality ratings and contract performance were not available in the dataset. 

## Contact

Open to Data Analyst opportunities.

- Email: deborahjonah06@gmail.com
- LinkedIn: https://www.linkedin.com/in/deborah-jonah-220210327



