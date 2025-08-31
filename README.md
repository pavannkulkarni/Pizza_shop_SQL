# Pizza Shop SQL Project

A SQL Project that explores the data provided by a Pizza Shop.

## Introduction

- Objective: Analyze pizza sales data to uncover business insights.
- Approach: SQL queries addressing **basic, intermediate, and advanced** business questions.
- Data Sources: Orders, Order Details, Pizzas, Pizza Types.

## Key Business Questions

- **Basic:** Total orders, revenue, top pizzas, size preferences.

Q1) Retrieve the total number of orders placed.

```sql
select count(order_id) as "Total Orders" from orders;
```

Q2) Calculate the total revenue generated from pizza sales

```sql
select 
round(sum(order_details.quantity * pizzas.price),2) as "Total Revenue"
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id;
```
Q3) Identify the highest-priced pizza
```sql
select
(pizzas.price) as "Price", pizza_types.name 
from pizzas join
pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc
limit 1;
```
Q4) Identify the most common pizza size ordered
```sql
select
pizzas.size as "Pizza Size", count(order_details.order_details_id) as "Quantity Orderd"
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(order_details.order_details_id) desc;
```

Q5) Join relevant tables to find the category-wise distribution of pizzas
```sql
select
category as "Pizza Category", count(name) as "Pizza Count"
from pizza_types
group by category;
```

Q6) Determine the distribution of orders by hour of the day
```sql
select
hour(order_time) as " Hour of the day",
count(order_id) as "Total Orders"
from orders
group by hour(order_time)
order by hour(order_time) asc;
```

- **Intermediate:** Category trends, time-based patterns, daily averages.
  
Q1) Join the necessary tables to find the total quantity of each pizza category ordered
```sql
select
pizza_types.category as "Pizza Category", sum(order_details.quantity) as "Pizzas Ordered"
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(order_details.quantity) desc;
```
Q2) Group the orders by date and calculate the average number of pizzas ordered per day
```sql
select round(avg(Total_Orders),0) as Average_orders from
(select
orders.order_date as "Order Date", sum(order_details.quantity) as "Total_Orders"
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as avg_orders_per_day;
```

Q3) List the top 5 most ordered pizza types along with their quantities
```sql
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
```

- **Advanced:** Revenue contributions, cumulative trends, top 3 by category.
Q1) Calculate the percentage contribution of each pizza type to total revenue
```sql
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
```
Q2) Analyze the cumulative revenue generated over time
```sql
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
```
Q3) Determine the top 3 most ordered pizza types based on revenue for each pizza category
```sql
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
```

Solving the Q3 using CTE
```sql
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
```
