# 📊 AtliQ Hardware - SQL Ad-Hoc Analysis

![SQL](https://img.shields.io/badge/SQL-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data-Analysis-FF6B6B?style=for-the-badge)
![Business Intelligence](https://img.shields.io/badge/Business-Intelligence-4CAF50?style=for-the-badge)

> **Transforming Raw Data into Strategic Business Insights using Advanced SQL**

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Business Context](#-business-context)
- [Database Schema](#️-database-schema)
- [Business Questions & SQL Solutions](#-business-questions--sql-solutions)
- [Key Insights](#-key-insights)
- [Skills Demonstrated](#-skills-demonstrated)
- [Tools Used](#️-tools-used)
- [How to Use](#-how-to-use)
- [Connect](#-connect)

---

## 🎯 Project Overview

A comprehensive SQL analysis project solving **10 critical business questions** for **AtliQ Hardware**, a leading computer hardware company. This project demonstrates advanced SQL querying, data analysis, and business intelligence capabilities.

**Key Project Details:**
- **Company:** AtliQ Hardware
- **Industry:** Computer Hardware & Peripherals
- **Database:** gdb023 (atliq_hardware_db)
- **Tables:** 6 (2 Dimension + 4 Fact Tables)
- **Period:** Fiscal Year 2020-2021
- **Analysis Type:** Ad-Hoc Business Requests

---

## 🏢 Business Context

### About AtliQ Hardware

AtliQ Hardware is a global computer hardware manufacturer and distributor with operations across multiple regions.

**Product Portfolio:**
- 💻 Personal Computers (PC)
- 🔌 Networking & Storage (N & S)
- 🖱️ Peripherals & Accessories (P & A)

**Market Presence:**
- 🌏 APAC (Asia Pacific) - India, ANZ, Southeast Asia
- 🌍 EU (Europe) - Western, Northern, Southern EU
- 🌎 NA (North America) - USA, Canada
- 🌎 LATAM (Latin America) - Brazil, Mexico, Argentina

**Distribution Channels:**
- 🏪 Brick & Mortar (Physical Stores)
- 🌐 E-Commerce (Online Platforms)

**Sales Channels:**
- Retailers (Third-party stores)
- Direct (Company-owned)
- Distributors (Wholesale)

---

## 🗄️ Database Schema

### Tables Overview

The `gdb023` database contains 6 main tables:

#### Dimension Tables

**1. dim_customer** - Customer Information
- customer_code (PK)
- customer
- platform (Brick & Mortar / E-Commerce)
- channel (Retailers / Direct / Distributors)
- market (Country)
- region (APAC / EU / NA / LATAM)
- sub_zone

**2. dim_product** - Product Information
- product_code (PK)
- division (P & A / N & S / PC)
- segment (Peripherals, Notebook, Desktop, etc.)
- category
- product
- variant (Standard / Plus / Premium)

#### Fact Tables

**3. fact_sales_monthly** - Monthly Sales Data
- date
- product_code (FK)
- customer_code (FK)
- sold_quantity
- fiscal_year

**4. fact_gross_price** - Product Pricing
- product_code (FK)
- fiscal_year
- gross_price

**5. fact_manufacturing_cost** - Production Costs
- product_code (FK)
- cost_year
- manufacturing_cost

**6. fact_pre_invoice_deductions** - Discounts
- customer_code (FK)
- fiscal_year
- pre_invoice_discount_pct

---

## 🔍 Business Questions & SQL Solutions

### Request 1: APAC Market Presence for Atliq Exclusive

**Question:** List all markets in APAC region where "Atliq Exclusive" operates.

<details>
<summary>View SQL Query</summary>

```sql
SELECT 
    DISTINCT market
FROM dim_customer
WHERE customer = 'Atliq Exclusive' AND 
region = 'APAC';
```

</details>

**Business Impact:** Identifies regional expansion opportunities and market-specific strategies.

---

### Request 2: Product Growth Analysis (2020 vs 2021)

**Question:** Calculate the percentage increase in unique products between 2020 and 2021.

<details>
<summary>View SQL Query</summary>

```sql
WITH unique_products AS ( 
    SELECT 
        fiscal_year,
        COUNT(DISTINCT product_code) AS cnt 
    FROM fact_sales_monthly
    WHERE fiscal_year IN ('2020','2021')
    GROUP BY fiscal_year
),

product_counts AS ( 
    SELECT 
        MAX(CASE 
            WHEN fiscal_year = '2020' THEN cnt END) AS unique_products_2020,
        MAX(CASE 
            WHEN fiscal_year = '2021' THEN cnt END) AS unique_products_2021
    FROM unique_products 
)

SELECT 
    *,
    ROUND((unique_products_2021 - unique_products_2020)*100 / unique_products_2020, 2) AS pct 
FROM product_counts;
```

</details>

**Business Impact:** Measures product portfolio expansion for R&D investment decisions.

---

### Request 3: Product Count by Segment

**Question:** Report unique product counts for each segment, sorted by product count.

<details>
<summary>View SQL Query</summary>

```sql
SELECT 
    segment,
    COUNT(DISTINCT product_code) AS unique_products_count
FROM dim_product
GROUP BY segment
ORDER BY unique_products_count DESC;
```

</details>

**Business Impact:** Reveals product diversity across segments for inventory planning.

---

### Request 4: Segment with Maximum Growth

**Question:** Which segment had the most product increase in 2021 vs 2020?

<details>
<summary>View SQL Query</summary>

```sql
WITH unique_products AS ( 
    SELECT 
        segment,
        fiscal_year,
        COUNT(DISTINCT s.product_code) AS unique_products_count
    FROM dim_product p 
    INNER JOIN fact_sales_monthly s 
    ON p.product_code = s.product_code
    WHERE fiscal_year IN ('2020','2021')
    GROUP BY segment, fiscal_year
),

products_count AS ( 
    SELECT 
        segment,
        SUM(CASE WHEN fiscal_year = '2020' THEN unique_products_count END) AS product_count_2020,
        SUM(CASE WHEN fiscal_year = '2021' THEN unique_products_count END) AS product_count_2021
    FROM unique_products 
    GROUP BY segment
)

SELECT 
    *,
    (product_count_2021 - product_count_2020) AS difference
FROM products_count;
```

</details>

**Business Impact:** Identifies high-growth segments for resource allocation.

---

### Request 5: Manufacturing Cost Analysis

**Question:** Find products with highest and lowest manufacturing costs.

<details>
<summary>View SQL Query</summary>

```sql
WITH cte AS ( 
    SELECT 
        p.product_code,
        p.product,
        manufacturing_cost,
        ROW_NUMBER() OVER(ORDER BY manufacturing_cost ASC) AS low_rnk,
        ROW_NUMBER() OVER(ORDER BY manufacturing_cost DESC) AS high_rnk
    FROM dim_product p 
    INNER JOIN fact_manufacturing_cost c 
    ON p.product_code = c.product_code
)

SELECT 
    product_code,
    product,
    manufacturing_cost
FROM cte 
WHERE high_rnk = 1 OR low_rnk = 1;
```

</details>

**Business Impact:** Supports pricing strategy and cost optimization initiatives.

---

### Request 6: Top 5 Customers by Discount (India, FY 2021)

**Question:** Identify top 5 customers with highest average pre-invoice discount in Indian market for FY 2021.

<details>
<summary>View SQL Query</summary>

```sql
SELECT 
    c.customer_code,
    c.customer,
    ROUND(AVG(pre_invoice_discount_pct), 4) AS avg_pre_invoice_discount_pct
FROM dim_customer c 
INNER JOIN fact_pre_invoice_deductions d 
ON c.customer_code = d.customer_code
WHERE d.fiscal_year = '2021'
AND market = 'India'
GROUP BY c.customer_code, c.customer  
ORDER BY avg_pre_invoice_discount_pct DESC 
LIMIT 5;
```

</details>

**Business Impact:** Enables strategic account management and discount policy optimization.

---

### Request 7: Monthly Gross Sales for Atliq Exclusive

**Question:** Generate monthly gross sales report for "Atliq Exclusive" customer.

<details>
<summary>View SQL Query</summary>

```sql
SELECT 
    s.fiscal_year, 
    MONTHNAME(date) AS month,
    SUM(sold_quantity*gross_price) AS sales 
FROM fact_sales_monthly s 
INNER JOIN fact_gross_price p 
ON s.product_code = p.product_code
AND s.fiscal_year = p.fiscal_year
INNER JOIN dim_customer c 
ON s.customer_code = c.customer_code
WHERE c.customer = 'Atliq Exclusive' 
GROUP BY fiscal_year, MONTHNAME(date);
```

</details>

**Business Impact:** Identifies seasonal trends for inventory and promotional planning.

---

### Request 8: Best Performing Quarter in 2020

**Question:** Which quarter in 2020 had maximum total sold quantity?

<details>
<summary>View SQL Query</summary>

```sql
WITH cte AS ( 
    SELECT 
        CASE
            WHEN MONTH(date) IN (9,10,11) THEN 'Q1'
            WHEN MONTH(date) IN (12,1,2)  THEN 'Q2'
            WHEN MONTH(date) IN (3,4,5)   THEN 'Q3'
            WHEN MONTH(date) IN (6,7,8)   THEN 'Q4'
        END AS fy_quarter,
        sold_quantity
    FROM fact_sales_monthly
    WHERE fiscal_year = '2020'
)

SELECT 
    fy_quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM cte 
GROUP BY fy_quarter
ORDER BY total_sold_quantity DESC;
```

</details>

**Business Impact:** Guides quarterly forecasting and resource planning.

---

### Request 9: Channel Contribution Analysis (FY 2021)

**Question:** Which channel contributed most to gross sales in FY 2021?

<details>
<summary>View SQL Query</summary>

```sql
SELECT 
    channel,
    SUM(sold_quantity*gross_price)/1000000 AS gross_total_sales,
    ROUND((SUM(sold_quantity*gross_price)/1000000)*100.0/ 
    SUM(SUM(sold_quantity*gross_price)/1000000) OVER(), 2) AS percentage
FROM fact_sales_monthly s 
INNER JOIN fact_gross_price p 
ON s.product_code = p.product_code
AND s.fiscal_year = p.fiscal_year
INNER JOIN dim_customer c 
ON s.customer_code = c.customer_code 
WHERE s.fiscal_year = '2021'
GROUP BY channel 
ORDER BY percentage DESC;
```

</details>

**Business Impact:** Optimizes channel investment and sales team deployment.

---

### Request 10: Top 3 Products per Division (FY 2021)

**Question:** Get top 3 products by sold quantity in each division for FY 2021.

<details>
<summary>View SQL Query</summary>

```sql
WITH total_sold_quantity AS ( 
    SELECT 
        division,
        p.product_code,
        p.product,
        SUM(sold_quantity) total,
        ROW_NUMBER() OVER(PARTITION BY division ORDER BY SUM(sold_quantity) DESC) AS rnk 
    FROM fact_sales_monthly s 
    INNER JOIN dim_product p 
    ON s.product_code = p.product_code 
    WHERE fiscal_year = '2021'
    GROUP BY division, p.product_code, p.product
    ORDER BY total DESC 
)

SELECT 
    division,
    product_code,
    product,
    total,
    rnk
FROM total_sold_quantity 
WHERE rnk IN (1,2,3)
GROUP BY division, product_code, product;
```

</details>

**Business Impact:** Identifies star products for focused marketing and inventory optimization.

---

## 📈 Key Insights

### Market Analysis
- ✅ Identified 8 APAC markets for Atliq Exclusive expansion
- ✅ Retailers channel dominated with highest gross sales contribution
- ✅ India emerged as key market with strategic discount opportunities

### Product Performance
- ✅ 36.33% growth in unique products from 2020 to 2021
- ✅ Accessories segment showed maximum product growth
- ✅ Manufacturing costs ranged from $0.89 to $240.54

### Sales Trends
- ✅ Quarterly analysis revealed seasonal demand patterns
- ✅ Monthly trends identified peak and low-performing periods
- ✅ Division-wise top performers mapped for strategic focus

### Strategic Recommendations
- 🚀 Expand product lines in high-growth segments (Accessories)
- 💰 Optimize discount strategies for key accounts in India
- 🌏 Strengthen market presence in top-performing regions
- 📈 Leverage seasonal trends for better inventory planning
- 🎯 Focus marketing on top-performing products per division

---

## 🎓 Skills Demonstrated

### Technical SQL Skills
- ✅ Complex JOIN operations (INNER, LEFT, MULTIPLE)
- ✅ Aggregate functions (SUM, COUNT, AVG, ROUND)
- ✅ Window functions (RANK, DENSE_RANK, PARTITION BY)
- ✅ Common Table Expressions (CTEs)
- ✅ Subqueries and nested queries
- ✅ CASE statements for conditional logic
- ✅ Date/Time functions (MONTH, YEAR, MONTHNAME)
- ✅ GROUP BY with complex aggregations
- ✅ UNION operations
- ✅ Query optimization

### Business Analysis Skills
- 📊 Trend Analysis - YoY growth patterns
- 🎯 Comparative Analysis - Performance benchmarking
- 📈 KPI Calculations - Business metrics
- 💰 Financial Analysis - Revenue and cost analysis
- 🌏 Market Segmentation - Regional insights
- 🏆 Performance Ranking - Top performer identification

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| **MySQL** | Database Management & Querying |
| **PowerPoint** | Presentation & Reporting |
| **Excel** | Data Validation & Quick Analysis |
| **GitHub** | Code Repository & Documentation |

---

## 📞 Connect

### Let's Collaborate!

I'm passionate about data analytics and always open to connecting with fellow data enthusiasts!

**Reach out for:**
- 💼 Job opportunities in Data Analytics
- 🤝 Collaboration on data projects
- 💡 Discussion about SQL, BI, or Analytics
- 📚 Knowledge sharing and networking

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/yourusername)
[![Email](https://img.shields.io/badge/Email-Contact-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:your.email@example.com)

---

## ⭐ Show Your Support

If you found this project helpful, please consider:
- ⭐ Starring the repository
- 🔄 Sharing it with others
- 💬 Providing feedback or suggestions

---

**© 2024 | SQL Analysis Project for AtliQ Hardware**

*Developed with passion for data analytics and business intelligence*
