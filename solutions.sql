-- Retrieve the total number of orders placed.
select count(order_id) as total_orders 
from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(p.price* od.quantity),2) as revenue from pizzas p
join order_details od on p.pizza_id=od.pizza_id;

-- Identify the highest-priced pizza.

select pt.name,p.price
from pizza_types pt join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
order by p.price desc limit 1;

-- Identify the most common pizza size ordered.

select p.size, count(od.order_details_id) as order_count
from pizzas p join order_details od
on p.pizza_id=od.pizza_id
group by p.size
order by order_count desc
limit 1;

-- List the top 5 most ordered pizza types
-- along with their quantities.

select pizza_types.name, 
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name 
order by quantity desc
limit 5;

-- Join the necessary tables to find the total 
-- quantity of each pizza category ordered.

select pt.category as category , sum(od.quantity)
from pizza_types pt join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details od 
on od.pizza_id=p.pizza_id
group by category;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour,count(order_id) as order_count
from orders
group by hour(order_time)
order by order_count desc;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as average_per_day_sales from 
(select orders.order_date,
 sum(order_details.quantity) quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category,ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue,
ROUND((SUM(order_details.quantity * pizzas.price) / SUM(SUM(order_details.quantity * pizzas.price)) OVER()), 2) * 100 AS percentage
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

--  Analyze the cumulative revenue generated over time.

select order_date,sum(revenue) over(order by order_date) as cum_revenue
from (select orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
(select category , name , revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category,pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category ,pizza_types.name) as a ) as b
where rn<=3;