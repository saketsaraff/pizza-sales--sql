Create database pizza_sales
use  pizza_sales

-- 1 Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;



---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(d.quantity * p.price), 3) AS totalsales
FROM
    order_details d
        JOIN
    pizzas p USING (pizza_id)


------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- 3 Identify the highest-priced pizza.
 
 
SELECT 
    t.name, t.category, p.price
FROM
    pizza_types t
        JOIN
    pizzas p USING (pizza_type_id)
ORDER BY p.price DESC
LIMIT 1 ;


------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4 Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(d.quantity) 'no of orders'
FROM
    pizzas p
        JOIN
    order_details d USING (pizza_id)
GROUP BY p.size
ORDER BY COUNT(d.quantity) DESC


------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    t.pizza_type_id, t.name, SUM(d.quantity) AS 'no of orders'
FROM
    pizza_types t
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details d USING (pizza_id)
GROUP BY t.name , t.pizza_type_id
ORDER BY 'no of orders' DESC
LIMIT 5


------------------------------------------------------------------------------------------------------------------------------------------------------------

--6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    t.category, SUM(d.quantity) AS quantity
FROM
    pizza_types t
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details d USING (pizza_id)
GROUP BY t.category
ORDER BY quantity DESC

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 7 Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) Distribution from pizza_types
group by category 
order by distribution desc

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8 Group the orders by date and calculate the average number of pizzas ordered per day.



--- way 1 by CTE

with data as(select o.order_date ,   sum(d.quantity) as quantity  from orders o
join order_details  d using(order_id) 
group by o.order_date 
order by o.order_date)

select round(avg(quantity),0) 'avg. order per day' from data


--- way 2 BY SUBQUERY

select round(avg(quantity),0) 'avg. order per day' from 
(select orders.order_date ,   sum(order_details.quantity) as quantity  
from orders 
join order_details   using(order_id) 
group by orders.order_date ) as order_quantity

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9 Determine the top 3 most ordered pizza types based on revenue.


SELECT 
    t.name, SUM(p.price * d.quantity) AS Revenue
FROM
    pizzas p
        JOIN
    pizza_types t USING (pizza_type_id)
        JOIN
    order_details d USING (pizza_id)
GROUP BY t.name
ORDER BY Revenue DESC
LIMIT 3


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 10 Calculate the percentage contribution of each pizza type to total revenue.



SELECT 
    t.category AS category,
   ( SUM(p.price * d.quantity)  / (SELECT 
    ROUND(SUM(d.quantity * p.price), 3) AS totalsales
FROM
    order_details d
        JOIN
    pizzas p USING (pizza_id)))*100 as revenue
    from pizza_types t
        JOIN
     pizzas p USING (pizza_type_id)
        JOIN
    order_details d USING (pizza_id)
GROUP BY t.category 
order by revenue desc


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 11 Analyze the cumulative revenue generated over time.

select order_date , sum(revenue) over (order by order_date) as cum_revenue from 
(select o.order_date , sum(d.quantity*p.price) as revenue from orders o
join order_details d using (order_id)
join pizzas p using (pizza_id)
group by o.order_date) as sales_data




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 12 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * FROM 
(SELECT CATEGORY , NAME , REVENUE , RANK() OVER( PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RN
FROM
(SELECT T.CATEGORY , T.NAME ,SUM(D.QUANTITY*P.PRICE) AS REVENUE 
FROM PIZZA_TYPES T JOIN PIZZAS P USING (PIZZA_TYPE_ID)
JOIN ORDER_DETAILS D  USING (PIZZA_ID)
GROUP BY T.CATEGORY, T.NAME) AS A) AS B 
WHERE RN <= 3
