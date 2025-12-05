# 🍕 Zomato Performance Analysis - Advanced SQL Project


**Comprehensive Zomato data analysis using 20+ advanced SQL queries** covering revenue trends, customer segmentation, rider performance, cancellation rates, and operational insights.

## 🚀 Featured Analytics

| **Analysis** | **Key Metrics** | **SQL Techniques** |
|--------------|----------------|-------------------|
| **Revenue Ranking** | City-wise restaurant revenue | `RANK() OVER PARTITION`, CTEs  |
| **Customer Churn** | 2023→2024 retention | `LEFT JOIN`, `YEAR()` filtering |
| **Rider Efficiency** | Delivery time analysis | `TIMESTAMPDIFF()`, Cross-midnight logic |
| **Cancellation Rates** | 2023 vs 2024 comparison | `CASE WHEN`, `UNION` |
| **Peak Time Slots** | 2-hour order intervals | `HOUR()`, `CASE` statements |
| **Customer Lifetime Value** | Total revenue per customer | `GROUP BY`, `SUM()` |

## 📊 Key Insights Uncovered

🥇 Top 5 Dishes for High-Value Customers
⏰ Peak ordering: 18:00-21:00 (Dinner Rush!)
💰 High-value customers (>₹5K spend)
📈 Monthly growth ratios per restaurant
⭐ Rider ratings (5⭐ <20min, 4⭐ 20-30min)
🏆 City revenue rankings 2023


## 🛠️ Tech Stack
🔹 MySQL / PostgreSQL
🔹 Window Functions (RANK, LAG)
🔹 CTEs & Subqueries
🔹 Date/Time Functions
🔹 Complex JOINs (5+ tables)
🔹 Business Intelligence Queries


## 🚀 Quick Start

### 1. **Setup Database**
-- Import these tables: customers, restaurants, riders, orders, deliveries
-- Run the SQL file directly in MySQL Workbench / pgAdmin



### 2. **Run Analysis**
mysql -u username -p zomato_db < Zomato_Performance_Analysis_Advance_SQL.sql



### 3. **Visualize (Recommended)**
- **Power BI**: Connect to database, use provided queries
- **Tableau**: Import results as CSV
- **Google Data Studio**: Free visualization


## 🎯 Business Applications

- **Revenue Optimization**: Identify top-performing restaurants
- **Operational Efficiency**: Rider performance benchmarking
- **Customer Retention**: Churn analysis & segmentation
- **Peak Hour Planning**: Staff scheduling optimization
- **Menu Engineering**: Popular dishes by city

## 📊 Next Steps - Power BI Integration

1. **Connect** Power BI to your MySQL database
2. **Import** key queries as tables
3. **Build** interactive dashboard with:
   - Revenue heatmaps by city
   - Rider performance scatter plots
   - Time-series cancellation trends

## 🤝 Contributing

1. Fork the repo
2. Add new SQL analytics queries
3. Update README with new insights
4. Submit PR! 🎉


---

**Built with** 🛠️ **SQL** **|** **Ready for** 📊 **Power BI/Tableau** **|** **Zomato Business Intelligence**

⭐ **Star if you found these queries useful!**
