USE gdb023;

 /* Q1: The list of markets in which customer "Atliq Exclusive" operates its business in the APAC region */

SELECT DISTINCT(market) 
FROM dim_customer
WHERE region = 'APAC' 
AND customer = 'Atliq Exclusive';

/* Q2: What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields,
 # unique_products_2020
 # unique_products_2021
 # percentage_chg */

SELECT 
		FY20.A as Unique_products_2020, 
        FY21.B as Unique_product_2021,
        round((B-A)*100/A,2) as percentage_chg
FROM(
		(SELECT COUNT(DISTINCT product_code) as A 
		FROM fact_sales_monthly 
		WHERE fiscal_year =2020) AS FY20,
        
		(SELECT COUNT(DISTINCT product_code) as B 
		FROM fact_sales_monthly 
		WHERE fiscal_year =2021) AS FY21
);

/* Q3:  Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains 2 fields,
# segment
# product_count */

SELECT  segment, COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

/* Q4: Follow-up: Which segment had the most increase in unique products in
	2021 vs 2020? The final output contains these fields,
	# segment
	# product_count_2020
    # product_count_2021
    # 	difference */

WITH cte1 AS(
SELECT 	dp.segment AS A,
		COUNT(DISTINCT fs.product_code) AS B
FROM fact_sales_monthly AS fs
JOIN dim_product AS dp
ON fs.product_code = dp. product_code
GROUP BY dp.segment , fs.fiscal_year
HAVING fs.fiscal_year=2020
),

 cte2 AS (
SELECT 	dp.segment AS C,
		COUNT(DISTINCT fs.product_code) AS D
FROM fact_sales_monthly AS fs
JOIN dim_product AS dp
ON fs.product_code = dp. product_code
GROUP BY dp.segment, fs.fiscal_year
HAVING fs.fiscal_year= 2021
)

SELECT cte1.A AS segment,
	   cte1.B AS product_code_2020,
	   cte2. D AS product_code_2021,
	   (cte2.D-cte1.B) AS difference
FROM cte1,cte2
WHERE cte1.A=cte2.C;

/* Q5: Get the products that have the highest and lowest manufacturing costs.
 The final output should contain these fields,
# product_code
# product
# manufacturing_cost */

SELECT 
		P.product_code,
        p.product,
        m.manufacturing_cost
FROM dim_product AS p
JOIN fact_manufacturing_cost AS m
ON p.product_code= m.product_code
WHERE manufacturing_cost IN (
		SELECT max(manufacturing_cost) 
		FROM fact_manufacturing_cost
UNION
		SELECT min(manufacturing_cost) 
		FROM fact_manufacturing_cost
)
ORDER BY manufacturing_cost DESC;

/* Q6: Generate a report which contains the top 5 customers who received an
      average high pre_invoice_discount_pct for the fiscal year 2021 and in the
      Indian market. The final output contains these fields,
	  # customer_code
	  # customer
	  # average_discount_percentage */

WITH cte1 AS (
    SELECT customer_code AS A ,  
    AVG(pre_invoice_discount_pct) AS B  
FROM fact_pre_invoice_deductions
WHERE fiscal_year = 2021 
GROUP BY customer_code
),

cte2 AS ( 
	SELECT customer_code AS C, 
	customer AS  D 
FROM dim_customer
WHERE market ="India"
)

SELECT cte2.C AS customer_code,
		cte2.D AS cutsomer,
        round(cte1.B,4) AS Average_discount_percentage
FROM cte1,cte2
WHERE cte1.A= cte2.C
ORDER BY Average_discount_percentage DESC
LIMIT 5;

/* Q7: Get the complete report of the Gross sales amount for the customer “Atliq
	   Exclusive” for each month. This analysis helps to get an idea of low and
	   high-performing months and take strategic decisions.
	   The final report contains these columns:
	   # Month
	   # Year
	   # Gross sales Amount */

WITH cte1 AS (
SELECT 
	MONTHNAME(s.date) AS A,
    YEAR(s.date) AS B ,
    s.fiscal_year,
    (g.gross_price*s.sold_quantity) AS C
FROM fact_sales_monthly AS s
JOIN fact_gross_price g ON s.product_code=g.product_code
JOIN dim_customer c ON s.customer_code=c.customer_code
WHERE c.customer="Atliq Exclusive")

SELECT A AS Month,
       B AS Year, 
       ROUND(SUM(C),2) AS Gross_sales_amount 
FROM cte1
GROUP BY Month,Year
ORDER BY Year;


/* Q8: In which quarter of 2020, got the maximum total_sold_quantity? The final
       output contains these fields sorted by the total_sold_quantity,
       # Quarter
       # total_sold_quantity

SELECT 
 CASE
	WHEN MONTH (date) IN (9,10,11) THEN "Q1"
    WHEN MONTH (date) IN (12,1,2) THEN "Q2"
    WHEN MONTH (date) IN (3,4,5) THEN "Q3"
    WHEN MONTH (date) IN (6,7,8) THEN "Q4"
    END AS Quarter,
    ROUND(SUM(sold_quantity)/1000000,2) as total_sold_quantity_mln
FROM fact_sales_monthly
WHERE fiscal_year=2020
GROUP BY  Quarter;

/* Q9: Which channel helped to bring more gross sales in the fiscal year 2021
       and the percentage of contribution? The final output contains these fields,
	   # channel
       # gross_sales_mln
	   # percentage */

WITH cte1 AS (
SELECT c.channel,
		SUM(s.sold_quantity*g.gross_price) AS total_sales
FROM fact_sales_monthly AS s
JOIN fact_gross_price g ON s.product_code=g.product_code
JOIN  dim_customer c ON s.customer_code=c.customer_code
WHERE s.fiscal_year=2021
GROUP BY c.channel
)
SELECT 
	channel,
    ROUND(total_sales/100000,2) AS gross_sales_mln,
	ROUND((total_sales)/sum(total_sales) OVER () *100,2) AS percentage
FROM cte1
ORDER BY percentage DESC;


/* Q10: Get the Top 3 products in each division that have a high
        total_sold_quantity in the fiscal_year 2021? The final output contains these fields
	    # division
	    # product_code
	    # product
	    # total_sold_quantity
	    # rank_order */

WITH cte1 AS (
SELECT
		p.division,
        s.product_code,
        p.product,
        SUM(s.sold_quantity) AS total_sold_quantity,
        RANK() OVER (PARTITION BY division ORDER BY SUM(s.sold_quantity) DESC) AS rank_order 
FROM fact_sales_monthly AS s
JOIN dim_product p ON s.product_code=p.product_code
WHERE s.fiscal_year=2021
GROUP BY p.product,division,s.product_code)

SELECT * FROM cte1
WHERE rank_order IN (1,2,3);





		