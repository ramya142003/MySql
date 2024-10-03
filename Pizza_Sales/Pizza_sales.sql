create database pizzahut;
use pizzahut;
select * from pizzas;
select * from pizza_types;
select * from orders1;
create table if not exists orders1 ( 
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));
select * from orders1;

create table order_details(
order_details_id int primary key not null,
order_id int not null,
pizza_id text not null,
quantity int not null);
select * from order_details;

-- Basic questions:
-- 1. Find total number of orders placed
select * from orders1;
select count(*) as total_orders from orders1;

-- 2. Calculate total revenue generated from pizza sales
select * from pizzas;
select * from order_details;
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest price pizza.
select * from pizzas;
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Find most common pizza size ordered.
select * from order_details;
select * from pizzas;
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- 5. top 5 most ordered pizza types along with their quantities.
select * from pizzas;
select * from pizza_types;
select * from order_details;

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate
-- 1. find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 2. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders1.order_time) AS order_per_hour,
    COUNT(order_id) AS orderscount
FROM
    orders1
GROUP BY order_per_hour;

-- 3. find the category_wise distribution of pizzas.
select category,count(name) from pizza_types
group by category;

-- 4. group the orders ny date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders1.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders1
    JOIN order_details ON orders1.order_id = order_details.order_id
    GROUP BY orders1.order_date) AS order_quantity;

-- 5. Top 3 most ordered pizzas types  based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced 
-- 1. calculate the perrcentage contribution of each pizza type to total revenue based on category
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            (ROUND(SUM(order_details.quantity * pizzas.price),
                        2)) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- 2. analyze the cumulative revenue generated over time.

select order_date,sum(revenue) over(order by order_date) as cum_revenue
from
(select orders1.order_date, sum(order_details.quantity*pizzas.price)as revenue
from order_details join pizzas
ON order_details.pizza_id = pizzas.pizza_id
join orders1
on orders1.order_id=order_details.order_id
GROUP BY orders1.order_date)as sales;

-- 3. The top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from 
(select category,name,revenue,rank() over (partition by category order by revenue desc) as rn 
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a)as b
where rn<=3;












