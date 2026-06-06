select top 10 * from online_retail

select COUNT(distinct customer_id) as total_customer from online_retail


select min(invoicedate) as first_purchasedate, 
max(invoicedate) as last_purchasedate
from online_retail

select
YEAR(invoicedate) as year,
ROUND(sum(quantity * price),2) as total_revenue,
count(distinct customer_id) as total_customers,
count(distinct invoice) as total_order
from online_retail
group by year(invoicedate)
order by year;


select 
year(invoicedate) as year,
round(sum(quantity * price),2)as total_revenu,
count(distinct invoice)as total_orders,
round(SUM(quantity * price)/count(distinct invoice),2)as avg_order_value
from online_retail
group by year(invoicedate)
order by year

select
YEAR(invoicedate) as year,
MONTH(invoicedate)as month,
ROUND(sum(quantity * price),2) as total_revenue,
count(distinct customer_id) as total_customers,
count(distinct invoice) as total_order
from online_retail
group by year(invoicedate),month(invoicedate)
order by year,month;



SELECT 
    YEAR(InvoiceDate) AS Year,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Invoice) AS Total_Orders,
    ROUND(COUNT(DISTINCT Invoice) * 1.0 / COUNT(DISTINCT Customer_ID), 2) AS Orders_Per_Customer,
    ROUND(SUM(Quantity * Price), 2) AS Total_Revenue,
    ROUND(SUM(Quantity * Price) / COUNT(DISTINCT Invoice), 2) AS Avg_Order_Value
FROM online_retail
WHERE MONTH(InvoiceDate) = 4
GROUP BY YEAR(InvoiceDate)
ORDER BY Year;


SELECT TOP 10 CUSTOMER_ID,
ROUND(SUM(quantity * price),2)as total_revenue,
ROUND(avg(quantity * price ),2) as avg_order_value
from online_retail
group by customer_id
order by total_revenue desc;



select top 10 * from online_retail;


select 
year(first_purchase) as year,
count(customer_id) as new_customer
from
(select customer_id,
min(invoicedate)as first_purchase
from online_retail
group by customer_id)
as first_purchase_data
group by year(first_purchase)
order by year;


select count(distinct customer_id) as retained_customer
from online_retail
where customer_id in
(
select distinct customer_id 
from online_retail
where YEAR(invoicedate) =2010

)
and YEAR(invoicedate)=2011


SELECT 
    2644 * 100.0 / 4216 AS Retention_Rate_Pct;


select customer_id, 
DATEDIFF(day,max(invoicedate),'2011-12-05')as recency,
count(distinct invoice ) as frequency,
round(sum(quantity * price),2) as monetory
from online_retail
group by customer_id
order by monetory desc

select customer_id,
DATEDIFF(day, MAX(invoicedate),'2011-12-05') as recency,
COUNT(distinct invoice) as frequency,
round(sum(quantity * price),2)as monetory
from online_retail
group by customer_id
order by monetory desc


with rmf_base as(
select customer_id,
DATEDIFF(day, MAX(invoicedate),'2011-12-05') as recency,
COUNT(distinct invoice) as frequency,
round(sum(quantity * price),2)as monetory
from online_retail
group by customer_id
)
select customer_id,
recency,
frequency,
monetory,
NTILE(5) over(order by recency desc) as R_score,
--lower order -- high score
ntile(5)over (order by frequency asc)as f_score,
-- high frequncey hish score
ntile(5) over(order by monetory asc)as m_score
--hgih revenue highscore
from rmf_base
order by monetory desc


select top 10 * from online_retail;

with rmf_base as (
select customer_id,
DATEDIFF(day,max(invoicedate),'2011-12-05')as recency,
count(distinct invoice)as frequency,
round(sum(quantity * price ),2)as monetory 
from
online_retail
group by customer_id),
rmf_score as(
select customer_id,
recency,
frequency,
monetory,
NTILE(5)over(order by recency desc)as r_score,
NTILE(5)over(order by frequency asc)as f_score,
NTILE(5)over(order by monetory asc)as m_score
from rmf_base)
select 
customer_id,
recency,
frequency,
monetory,
r_score,
f_score,
m_score,
concat(r_score,f_score,m_score)as rmf_score,
case
when r_score=5 and f_score=5 and m_score=5 then 'champion'
when r_score>=4 and f_score >=4 and m_score>=5 then 'Loyal'
when r_score >=3 and f_score >=3 and m_score >=3 then 'Promising'
when r_score >=2 and f_score<=2  then 'New customer'
when r_score <=2 and f_score >=3 and m_score >=3 then 'at risk'
when r_score =1 and f_score =1 and m_score=1 then 'lost'
else 'Needs attention'
end as segment
from rmf_score
order by monetory desc



select * from online_retail


with rmf_base as(
	select customer_id,
	DATEDIFF(day,max(invoicedate),'2011-12-05') as recency,
	COUNT(distinct invoice) as frequency,
	round(sum(quantity * price),2)as monetory
	from online_retail
	group by customer_id
	),
rmf_score as (
	select
	customer_id,
	recency, 
	frequency,
	monetory,
	ntile(5)over (order by recency desc)as r_score,
	NTILE(5) over (order by frequency asc)as f_score,
	NTILE(5)over (order by monetory asc)as m_score
	from rmf_base
),
rmf_segment as(
	select 
	customer_id,
	recency,
	frequency,
	monetory,
	NTILE(5)over(order by recency desc)as r_score,
	NTILE(5)over(order by frequency asc)as f_score,
	NTILE(5)over(order by monetory asc)as m_score
	from rmf_base
),
rfma_segment as(
	select 
	customer_id,
	recency,
	frequency,
	monetory,
	r_score,
	f_score,
	m_score,
	concat(r_score,f_score,m_score)as rmf_score,
	case
		when r_score=5 and f_score=5 and m_score=5 then 'champion'
		when r_score>=4 and f_score >=4 and m_score>=5 then 'Loyal'
		when r_score >=3 and f_score >=3 and m_score >=3 then 'Promising'
		when r_score >=2 and f_score<=2  then 'New customer'
		when r_score <=2 and f_score >=3 and m_score >=3 then 'at risk'
		when r_score =1 and f_score =1 and m_score=1 then 'lost'
		else 'Needs attention'
	end as segment
	from rmf_score
)
select segment, 
	count(customer_id) as total_customers,
	round(avg(monetory),2)as avg_monetary,
	round(avg(frequency),2)as avg_frequency,
	round (avg(recency),2)as avg_recency
	from rfma_segment
	group by segment
	order by total_customers desc



select * from online_retail

select top 10
stockcode,
description,
round(sum(quantity * price),2)as total_revenue,
sum(quantity)as total_products_sold,
round(avg(price),2)as avg_price
from online_retail
group by stockcode,description
order by total_revenue desc


select top 10
stockcode,
description,
round(sum(quantity * price),2)as total_revenue,
sum(quantity)as total_products_sold,
round(avg(price),2)as avg_price
from online_retail
group by stockcode,description
order by total_products_sold desc

SELECT TOP 10
    StockCode,
    Description,
    SUM(Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(Quantity * Price), 2) AS Total_Revenue,
    ROUND(AVG(Price), 2) AS Avg_Price
FROM online_retail
GROUP BY StockCode, Description
ORDER BY Total_Quantity_Sold DESC;


SELECT TOP 10
    r.StockCode,
    r.Description,
    SUM(ABS(r.Quantity)) AS Total_Returns,
    ROUND(SUM(ABS(r.Quantity) * r.Price), 2) AS Return_Value,
    ROUND(AVG(r.Price), 2) AS Avg_Price
FROM returns r
GROUP BY r.StockCode, r.Description
ORDER BY Total_Returns DESC;


select * from returns

DELETE FROM returns
WHERE Price = 0
   OR Description IS NULL
   OR Description IN ('given away', 'ebay sales', 
                      'Printing smudges/thrown away', '?')
   OR StockCode IN ('M', 'DOT', 'BANK', 'POST', 'AMAZONFEE');


SELECT 
    Customer_ID,
    YEAR(MIN(InvoiceDate)) AS Acquisition_Year
INTO Customer_First_Purchase
FROM online_retail
GROUP BY Customer_ID;

select * from Customer_First_Purchase