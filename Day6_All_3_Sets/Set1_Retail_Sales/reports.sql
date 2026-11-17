-- Day 6 Assignment - Set 1: Retail Sales Reporting
-- SQL Server 2025

-- Table Creation
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    joined_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10, 2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES customers(customer_id),
    order_date DATE,
    payment_status VARCHAR(20),
    payment_amount DECIMAL(10, 2)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES orders(order_id),
    product_id INT FOREIGN KEY REFERENCES products(product_id),
    quantity INT,
    unit_price DECIMAL(10, 2)
);

-- Sample Data
INSERT INTO customers VALUES
(101, 'Aarav Sharma', 'aarav@gmail.com', 'Chennai', '2025-11-10'),
(102, 'Priya Nair', 'priya@gmail.com', 'Bengaluru', '2025-12-05'),
(103, 'Karthik Raja', 'karthik@gmail.com', 'Chennai', '2026-01-12'),
(104, 'Divya Menon', 'divya@gmail.com', 'Mumbai', '2026-02-20'),
(105, 'Rohan Verma', 'rohan@gmail.com', 'Bengaluru', '2026-03-15'),
(106, 'Sneha Iyer', 'sneha@gmail.com', 'Chennai', '2026-05-01');

INSERT INTO products VALUES
(1, 'Wireless Keyboard', 'Electronics', 4500.00),
(2, 'ANC Headphones', 'Electronics', 8000.00),
(3, 'Office Chair', 'Furniture', 12000.00),
(4, 'Steel Water Bottle', 'Lifestyle', 800.00),
(5, 'USB-C Dock', 'Electronics', 3500.00),
(6, 'Desk Organizer', 'Furniture', 1500.00);

INSERT INTO orders VALUES
(1001, 101, '2026-08-05', 'Paid', 12500.00),
(1002, 101, '2026-08-18', 'Paid', 4500.00),
(1003, 101, '2026-09-10', 'Paid', 8000.00),
(1004, 101, '2026-10-02', NULL, NULL),
(1005, 102, '2026-08-18', 'Paid', 20000.00),
(1006, 102, '2026-09-22', 'Paid', 5100.00),
(1007, 103, '2026-09-14', 'Paid', 12000.00),
(1008, 104, '2026-10-05', NULL, NULL),
(1009, 105, '2026-10-12', 'Paid', 9500.00);

INSERT INTO order_items VALUES
(1, 1001, 1, 1, 4500.00),
(2, 1001, 2, 1, 8000.00),
(3, 1002, 1, 1, 4500.00),
(4, 1003, 2, 1, 8000.00),
(5, 1004, 5, 1, 3500.00),
(6, 1005, 2, 1, 8000.00),
(7, 1005, 3, 1, 12000.00),
(8, 1006, 5, 1, 3500.00),
(9, 1006, 4, 2, 800.00),
(10, 1007, 3, 1, 12000.00),
(11, 1008, 6, 2, 1500.00),
(12, 1009, 2, 1, 8000.00),
(13, 1009, 6, 1, 1500.00);

-- 1. Top 5 products by revenue
SELECT TOP 5 p.product_name, SUM(oi.quantity) AS units_sold, SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- 2. Month-wise sales
SELECT FORMAT(o.order_date, 'yyyy-MM') AS sales_month, COUNT(DISTINCT o.order_id) AS total_orders, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY sales_month;

-- 3. Customers with more than 3 orders
SELECT c.customer_id, c.full_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 3;

-- 4. Average basket value per city
SELECT c.city, ROUND(AVG(t.order_total), 2) AS avg_basket_value
FROM customers c
JOIN (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) t ON c.customer_id = t.customer_id
GROUP BY c.city
ORDER BY avg_basket_value DESC;

-- 5. Orders without payment (LEFT JOIN)
SELECT o.order_id, c.full_name, o.order_date, o.payment_status
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.payment_amount IS NULL;

-- 6. Customers with no orders
SELECT c.customer_id, c.full_name, c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 7. Product-category revenue share
SELECT p.category,
       SUM(oi.quantity * oi.unit_price) AS category_revenue,
       ROUND(SUM(oi.quantity * oi.unit_price) * 100.0 / (SELECT SUM(quantity * unit_price) FROM order_items), 2) AS revenue_share_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 8. Day with the highest sales
SELECT TOP 1 o.order_date, SUM(oi.quantity * oi.unit_price) AS daily_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY daily_sales DESC;

-- Task 2: String, Date & Math Functions
SELECT o.order_id,
       CONCAT(UPPER(c.full_name), ' - ', UPPER(c.city)) AS customer_info,
       FORMAT(o.order_date, 'dd-MMM-yyyy') AS order_date_fmt,
       DATEDIFF(DAY, c.joined_date, o.order_date) AS days_after_joining,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS bill_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.full_name, c.city, o.order_date, c.joined_date;

-- Task 3: NULL Behaviour in COUNT(*), COUNT(column) and AVG
SELECT COUNT(*) AS all_rows,
       COUNT(payment_amount) AS paid_rows,
       ROUND(AVG(payment_amount), 2) AS avg_ignoring_null,
       ROUND(AVG(ISNULL(payment_amount, 0)), 2) AS avg_with_zero
FROM orders;
