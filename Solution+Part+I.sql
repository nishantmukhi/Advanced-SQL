use supply_db ;
/*

Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.
*/
 select p.Product_Name,p.Product_Id from product_info p
 inner join category c
 on p.Category_Id = c.Id
 where c.Name like '%golf%'
 order by p.Product_Id;

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/
select distinct p.Product_Name,sum(o.Sales) as Sales from ordered_items o
 inner join product_info p
 on o.Item_Id = p.Product_Id
 inner join category c
 on p.Category_Id = c.Id
 where c.Name like '%golf%'
 group by p.Product_Name
 order by Sales desc
 limit 10;
 
-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
 select c.Segment as customer_segment, count(o.Order_Id) as Orders from 
 orders o inner join customer_info c
 on o.Customer_Id = c.Id
 group by c.Segment
 order by Orders desc

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/
 With count_orders as (
 select c.Segment as customer_segment, count(o.Order_Id) as Orders
 from orders o 
 inner join customer_info c
 on o.Customer_Id = c.Id
 where o.Real_Shipping_Days = 6
 group by c.Segment
 ) 
 select a.customer_segment, round(a.Orders/sum(b.Orders)*100,1) as percentage_order_split
 from count_orders as a
 join
 count_orders as b
 group by customer_segment
 order by percentage_order_split desc;
-- **********************************************************************************************************************************
