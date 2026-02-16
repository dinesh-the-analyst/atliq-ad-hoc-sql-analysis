/* ATLIQ HARDWARE – AD-HOC SQL ANALYSIS */
/* Fiscal Year: 2020–2021 */
/* Author: Dinesh */


/* Request 01: APAC markets for "Atliq Exclusive" */

SELECT DISTINCT market
FROM dim_customer
WHERE customer = 'Atliq Exclusive'
  AND region = 'APAC';



/* Request 02: Percentage increase in unique products (2021 vs 2020) */

WITH unique_products AS (
    SELECT fiscal_year,
           COUNT(DISTINCT product_code) AS cnt
    FROM fact_sales_monthly
    WHERE fiscal_year IN ('2020','2021')
    GROUP BY fiscal_year
),
product_counts AS (
    SELECT MAX(CASE WHEN fiscal_year = '2020' THEN cnt END) AS unique_products_2020,
           MAX(CASE WHEN fiscal_year = '2021' THEN cnt END) AS unique_products_2021
    FROM unique_products
)

SELECT *,
       ROUND((unique_products_2021 - unique_products_2020) * 100
             / unique_products_2020, 2) AS pct
FROM product_counts;



/* Request 03: Unique product count by segment */

SELECT segment,
       COUNT(DISTINCT product_code) AS unique_products_count
FROM dim_product
GROUP BY segment
ORDER BY unique_products_count DESC;



/* Request 04: Segment-wise product growth (2021 vs 2020) */

WITH unique_products AS (
    SELECT segment,
           fiscal_year,
           COUNT(DISTINCT s.product_code) AS unique_products_count
    FROM dim_product p
    INNER JOIN fact_sales_monthly s
        ON p.product_code = s.product_code
    WHERE fiscal_year IN ('2020','2021')
    GROUP BY segment, fiscal_year
),
products_count AS (
    SELECT segment,
           SUM(CASE WHEN fiscal_year = '2020'
                    THEN unique_products_count END) AS product_count_2020,
           SUM(CASE WHEN fiscal_year = '2021'
                    THEN unique_products_count END) AS product_count_2021
    FROM unique_products
    GROUP BY segment
)

SELECT *,
       (product_count_2021 - product_count_2020) AS difference
FROM products_count;



/* Request 05: Highest and lowest manufacturing cost products */

WITH cte AS (
    SELECT p.product_code,
           p.product,
           manufacturing_cost,
           ROW_NUMBER() OVER (ORDER BY manufacturing_cost ASC) AS low_rnk,
           ROW_NUMBER() OVER (ORDER BY manufacturing_cost DESC) AS high_rnk
    FROM dim_product p
    INNER JOIN fact_manufacturing_cost c
        ON p.product_code = c.product_code
)

SELECT product_code,
       product,
       manufacturing_cost
FROM cte
WHERE high_rnk = 1 OR low_rnk = 1;



/* Request 06: Top 5 customers with highest average discount (India, FY2021) */

SELECT c.customer_code,
       c.customer,
       ROUND(AVG(pre_invoice_discount_pct),4)
           AS avg_pre_invoice_discount_pct
FROM dim_customer c
INNER JOIN fact_pre_invoice_deductions d
    ON c.customer_code = d.customer_code
WHERE d.fiscal_year = '2021'
  AND market = 'India'
GROUP BY c.customer_code, c.customer
ORDER BY avg_pre_invoice_discount_pct DESC
LIMIT 5;



/* Request 07: Monthly gross sales for "Atliq Exclusive" */

SELECT s.fiscal_year,
       MONTHNAME(date) AS month,
       SUM(sold_quantity * gross_price) AS sales
FROM fact_sales_monthly s
INNER JOIN fact_gross_price p
    ON s.product_code = p.product_code
   AND s.fiscal_year = p.fiscal_year
INNER JOIN dim_customer c
    ON s.customer_code = c.customer_code
WHERE c.customer = 'Atliq Exclusive'
GROUP BY fiscal_year, MONTHNAME(date);



/* Request 08: Quarter with maximum total_sold_quantity (FY2020) */

WITH cte AS (
    SELECT CASE
               WHEN MONTH(date) IN (9,10,11) THEN 'Q1'
               WHEN MONTH(date) IN (12,1,2)  THEN 'Q2'
               WHEN MONTH(date) IN (3,4,5)   THEN 'Q3'
               WHEN MONTH(date) IN (6,7,8)   THEN 'Q4'
           END AS fy_quarter,
           sold_quantity
    FROM fact_sales_monthly
    WHERE fiscal_year = '2020'
)

SELECT fy_quarter,
       SUM(sold_quantity) AS total_sold_quantity
FROM cte
GROUP BY fy_quarter
ORDER BY total_sold_quantity DESC;



/* Request 09: Channel contribution to gross sales (FY2021) */

SELECT channel,
       SUM(sold_quantity * gross_price) / 1000000 AS gross_total_sales,
       ROUND(
           (SUM(sold_quantity * gross_price) / 1000000) * 100.0
           / SUM(SUM(sold_quantity * gross_price) / 1000000) OVER(),
           2
       ) AS percentage
FROM fact_sales_monthly s
INNER JOIN fact_gross_price p
    ON s.product_code = p.product_code
   AND s.fiscal_year = p.fiscal_year
INNER JOIN dim_customer c
    ON s.customer_code = c.customer_code
WHERE s.fiscal_year = '2021'
GROUP BY channel
ORDER BY percentage DESC;



/* Request 10: Top 3 products by division (FY2021) */

WITH total_sold_quantity AS (
    SELECT division,
           p.product_code,
           p.product,
           SUM(sold_quantity) total,
           ROW_NUMBER() OVER (
               PARTITION BY division
               ORDER BY SUM(sold_quantity) DESC
           ) AS rnk
    FROM fact_sales_monthly s
    INNER JOIN dim_product p
        ON s.product_code = p.product_code
    WHERE fiscal_year = '2021'
    GROUP BY division, p.product_code, p.product
    ORDER BY total DESC
)

SELECT division,
       product_code,
       product,
       total,
       rnk
FROM total_sold_quantity
WHERE rnk IN (1,2,3)
GROUP BY division, product_code, product;
