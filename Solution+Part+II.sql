use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		

With monthly_orders as 
(SELECT DATE_FORMAT(order_date, '%Y-%m') as Month_date, Order_Id from orders
order by Month_date)
select m.Month_date, sum(oi.Quantity) as Quantities_Sold, sum(oi.Sales) as Sales 
from monthly_orders m
left join ordered_items oi
on m.Order_Id = oi.Order_Id
inner join product_info p   
on oi.Item_Id = p.Product_Id
where p.Product_Name like '%Nike%'
group by m.Month_date;



-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/

 select p.Product_Id as Product_Id, p.Product_Name as Product_Name, 
 c.name as Category_Name,
 d.name as Department_Name, p.Product_Price as Product_Price 
 from product_info p
 inner join category c
 on p.Category_Id = c.Id
 inner join department d
 on p.Department_Id = d.Id
 order by p.Product_Price desc;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
select p.Product_Name, sum(oi.Sales) as Sales, count(o.Order_Id) as Order_Counts from orders o
inner join ordered_items oi
on o.Order_Id = oi.Order_Id
inner join product_info p
on oi.Item_Id = p.Product_Id
where o.Type = 'Cash'
group by p.Product_Name
order by Order_Counts desc , sales desc
limit 10;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
select * from orders o
inner join customer_info ci
on o.Customer_Id = ci.Id
where ci.State = 'TX' and ci.Street like '%Plaza%' and ci.Street Not in ('Mountain')
order by Order_id;


-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/

select count(o.Order_id) as Order_Count from orders o
inner join ordered_items oi
on o.Order_Id = oi.Order_Id
inner join product_info pi
on oi.Item_Id = pi.Product_Id
inner join customer_info ci
on o.Customer_Id = ci.Id
inner join department d
on pi.Department_Id = d.Id
where ci.Segment = 'Home Office'
and d.Name = 'Apparel' or 'Outdoors';




-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
select o.Order_State, o.Order_City, count(o.Order_Id) as Order_Count, 
dense_rank() over (partition by o.Order_State order by count(o.Order_Id) desc, o.Order_City asc) as City_rank 
from orders o
inner join ordered_items oi
on o.Order_Id = oi.Order_Id
inner join product_info pi
on oi.Item_Id = pi.Product_Id
inner join customer_info ci
on o.Customer_Id = ci.Id
inner join department d
on pi.Department_Id = d.Id
where ci.Segment = 'Home Office'
and d.Name = 'Apparel' or 'Outdoors'
group by o.Order_State, o.Order_City
order by o.Order_State;
-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
With yearly_orders as 
(SELECT DATE_FORMAT(order_date, '%Y') as Year, count(Order_Id), Shipping_Mode, Order_Id from orders
where Order_Status in ('Closed','Completed') and Scheduled_Shipping_Days < Real_Shipping_Days
group by Year, Shipping_Mode
order by Year)
Select yi.Shipping_Mode, count(yi.Order_Id) as Shipping_Underestimated_Order_Count, 
row_number() over (order by count(yi.Order_Id) desc) as Shipping_Mode_Rank
from yearly_orders yi
inner join orders o
on o.Order_Id = yi.Order_Id
inner join customer_info ci
on o.Customer_Id = ci.Id
where ci.Segment = 'Consumer'
group by o.Shipping_Mode;




-- **********************************************************************************************************************************





