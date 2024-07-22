-- 1.Retrieve total number of order placed

SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;
    
-- 2.Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS total_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;  
    
-- 3.Identify the highest price pizzas

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC;

-- 5.List the top 5 most ordered pizzas type along with their quentity

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

-- 6. Join the neccessary tables to find the total quantity of each pizza ordered

SELECT 
    pizza_types.category, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7. Determine the distribution of orders by hour of the day

SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(orders.order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY order_count DESC;

-- 8. Join relevent tables to find the category wise distribution of pizzas

SELECT 
    pizza_types.category AS category,
    COUNT(pizza_types.category) AS category_count
FROM
    pizza_types
GROUP BY category
ORDER BY category_count DESC;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) average_order_per_day
FROM
    (SELECT 
        DATE(orders.order_date) AS date,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY date) AS quantity;
    
-- 10. Determine the top 3 most ordered pizza types based on revenue

SELECT 
    pizza_types.name AS name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    (pizza_types.category) AS category,
    ROUND((SUM(pizzas.price * order_details.quantity) / (SELECT 
                    SUM(pizzas.price * order_details.quantity)
                FROM
                    pizzas
                        JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS percentage_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY percentage_contribution DESC;

-- 12. Analyze cumulative revenue generated over time

SELECT order_date,
SUM(revenue) 
OVER(ORDER BY order_date) AS cum_revenue 
FROM (SELECT orders.order_date,
SUM(pizzas.price*order_details.quantity) AS revenue
FROM pizzas 
JOIN order_details 
ON pizzas.pizza_id=order_details.pizza_id 
JOIN orders 
ON order_details.order_id=orders.order_id
GROUP BY orders.order_date) AS sales order by order_date desc limit 5;

-- 13. Determine the top 2 most ordered pizza types based on revenue for each pizza category

select category,name,revenue 
from (select category,name,revenue,rank() 
over(partition by category order by revenue desc) as rn 
from (select pizza_types.category as category,
pizza_types.name as name,
sum(pizzas.price*order_details.quantity) as revenue 
from pizzas 
join order_details 
on pizzas.pizza_id=order_details.pizza_id 
join pizza_types 
on pizzas.pizza_type_id=pizza_types.pizza_type_id 
group by category,name) 
as a) 
as b 
where rn<3; 

