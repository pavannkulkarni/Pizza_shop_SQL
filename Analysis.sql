-- Creating the DB -- 
create database pizz_shop;

-- Selecting the DB for use -- 
use pizz_shop;

-- creating the tables that required manual creation due to data type problems --
create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- Provides Tables view --
select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;

-- Answering Business Questions -- 

-- Q1) Retrieve the total number of orders placed. -- 
select count(order_id) as "Total Orders" from orders;

-- Q2 Calculate the total revenue generated from pizza sales -- 
select 
round(sum(order_details.quantity * pizzas.price),2) as "Total Revenue"
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
select
(pizzas.price) as "Price", pizza_types.name 
from pizzas join
pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc
limit 1;

-- Identify the most common pizza size ordered.
select
pizzas.size as "Pizza Size", count(order_details.order_details_id) as "Quantity Orderd"
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(order_details.order_details_id) desc;

-- List the top 5 most ordered pizza types along with their quantities.
select
pizza_types.name as "Pizza Type", sum(order_details.quantity) as "Pizzas Ordered"
from pizza_types 
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by sum(order_details.quantity) desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select
pizza_types.category as "Pizza Category", sum(order_details.quantity) as "Pizzas Ordered"
from pizza_types 
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(order_details.quantity) desc;

-- Determine the distribution of orders by hour of the day.
select
hour(order_time) as " Hour of the day",
count(order_id) as "Total Orders"
from orders
group by hour(order_time)
order by hour(order_time) asc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select
category as "Pizza Category", count(name) as "Pizza Count"
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(Total_Orders),0) as Average_orders from
(select
orders.order_date as "Order Date", sum(order_details.quantity) as "Total_Orders"
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as avg_orders_per_day;

-- Determine the top 3 most ordered pizza types based on revenue
select
pizza_types.name as "Pizza Type",
round(sum(pizzas.price * order_details.quantity),0) as "Revenue"
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by sum(pizzas.price * order_details.quantity) desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select
pizza_types.category as "Pizza category",
round((round(sum(pizzas.price * order_details.quantity),0) / (select 
round(sum(order_details.quantity * pizzas.price),2) as "Total Revenue"
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id)) *100,2) as "% Contribution"
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by sum(pizzas.price * order_details.quantity) desc;

-- Analyze the cumulative revenue generated over time.
select 
order_date,
sum(revenue) over (order by order_date) as cumulative_revenue
from
(select
orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue
from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select
pizza_types.category,
pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <=3;


-- The above answer as a CTE
with revenue_cte as (
    select
        pt.category,
        pt.name,
        round(sum(od.quantity * p.price),0) as revenue
    from pizza_types pt
    join pizzas p
        on pt.pizza_type_id = p.pizza_type_id
    join order_details od
        on od.pizza_id = p.pizza_id
    group by pt.category, pt.name
),
ranked_cte as (
    select
        category,
        name,
        revenue,
        rank() over(partition by category order by revenue desc) as rn
    from revenue_cte
)
select
    category,
    name,
    revenue
from ranked_cte
where rn <= 3;











