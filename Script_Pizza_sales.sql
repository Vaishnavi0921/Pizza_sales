# Create database

CREATE DATABASE PizzaSales;
-------------------------------------------------------------------------------------------------
# Create table to import data

CREATE TABLE ORDERS(
Order_id INT NOT NULL,
Order_date DATE NOT NULL,
Order_time TIME NOT NULL,
PRIMARY KEY(Order_id) );


CREATE TABLE Order_details(
Order_details_id INT NOT NULL,
Order_id INT NOT NULL,
Pizza_id TEXT NOT NULL,
Quantity INT NOT NULL,
PRIMARY KEY(Order_details_id) );


-------------------------------------------------------------------------------------------------
# Basic questions

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(Order_id) AS Total_Orders
FROM
    ORDERS;
-------------------------------------------------------------------------------------------------
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON P.pizza_id = o.Pizza_id;
-------------------------------------------------------------------------------------------------
-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;
-------------------------------------------------------------------------------------------------
-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.order_details_id) AS COUNT
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.Pizza_id = od.Pizza_id
GROUP BY size
ORDER BY COUNT DESC
LIMIT 1;
-------------------------------------------------------------------------------------------------
-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(quantity) AS Order_count
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY Order_count DESC
LIMIT 5;
-------------------------------------------------------------------------------------------------
# Intermediate questions

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    c.category, SUM(q.quantity) AS Quantity
FROM
    pizza_types AS c
        JOIN
    pizzas AS P ON c.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS q ON q.pizza_id = p.pizza_id
GROUP BY category
ORDER BY Quantity DESC;
-------------------------------------------------------------------------------------------------
-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);
-------------------------------------------------------------------------------------------------
-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Pizza_count
FROM
    pizza_types
GROUP BY category;
-------------------------------------------------------------------------------------------------
-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS Avg_pizza_perday
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.Order_id = od.Order_id
    GROUP BY o.Order_date) AS Order_quantity;
-------------------------------------------------------------------------------------------------    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(p.price * od.quantity) AS Revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY Revenue DESC
LIMIT 3;
-------------------------------------------------------------------------------------------------
# Advanced Questions

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category, CONCAT(ROUND(SUM(p.price * od.quantity) / (SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON P.pizza_id = o.Pizza_id) * 100,2),"%") AS Revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY Revenue DESC;
-------------------------------------------------------------------------------------------------
-- Analyze the cumulative revenue generated over time.

SELECT order_date ,
ROUND(SUM(Revenue) OVER(ORDER BY order_date),2) AS Cum_Revenue
FROM
(SELECT o.order_date , 
SUM(p.price * od.quantity) AS Revenue
from order_details AS od JOIN pizzas AS p ON od.Pizza_id = p.pizza_id
JOIN
orders AS o ON o.Order_id = od.Order_id
GROUP BY o.order_date) AS Sales;
-------------------------------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH Top_3 AS
(SELECT category , name , Revenue , RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS Rnk
FROM
(SELECT pt.category , pt.name , 
SUM(p.price * od.quantity) AS Revenue FROM pizzas AS p JOIN order_details AS od ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id GROUP BY pt.category , pt.name) AS REV)

SELECT category , name , ROUND(Revenue,2) AS Revenue FROM Top_3 WHERE Rnk <= 3;