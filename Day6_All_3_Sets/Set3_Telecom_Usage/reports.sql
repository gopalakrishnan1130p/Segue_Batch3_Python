-- Day 6 Assignment - Set 3: Telecom Usage and Billing Reporting
-- SQL Server 2025 (Reference Date: 2026-10-14)

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    monthly_fee DECIMAL(10, 2),
    data_limit_gb DECIMAL(6, 2)
);

CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    msisdn VARCHAR(15),
    circle VARCHAR(50),
    plan_id INT FOREIGN KEY REFERENCES plans(plan_id)
);

CREATE TABLE call_records (
    record_id INT PRIMARY KEY,
    subscriber_id INT FOREIGN KEY REFERENCES subscribers(subscriber_id),
    call_date DATE,
    call_minutes INT,
    data_used_gb DECIMAL(6, 2)
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    subscriber_id INT FOREIGN KEY REFERENCES subscribers(subscriber_id),
    billing_month VARCHAR(10),
    due_date DATE,
    amount_due DECIMAL(10, 2),
    paid_status VARCHAR(15)
);

INSERT INTO plans VALUES
(1, 'Starter 299', 299.00, 30.00),
(2, 'Power 599', 599.00, 75.00),
(3, 'Unlimited 999', 999.00, 150.00);

INSERT INTO subscribers VALUES
(1001, 'Naveen Kumar', '9840111001', 'Tamil Nadu', 2),
(1002, 'Lakshmi Priya', '9840111002', 'Tamil Nadu', 3),
(1003, 'Rahul Nair', '9840111003', 'Kerala', 1),
(1004, 'Sneha Reddy', '9840111004', 'Karnataka', 2),
(1005, 'Gautam Menon', '9840111005', 'Kerala', 3),
(1006, 'Harini S', '9840111006', 'Tamil Nadu', 1);

INSERT INTO call_records VALUES
(1, 1001, '2026-09-05', 320, 45.50),
(2, 1001, '2026-09-20', 280, 42.00),
(3, 1002, '2026-09-10', 510, 95.00),
(4, 1002, '2026-09-25', 440, 65.00),
(5, 1003, '2026-09-12', 190, 34.20),
(6, 1004, '2026-09-15', 210, 50.00),
(7, 1005, '2026-09-18', 600, 110.00);

INSERT INTO invoices VALUES
(9001, 1001, '2026-08', '2026-09-10', 599.00, 'Paid'),
(9002, 1001, '2026-09', '2026-10-10', 649.00, 'Unpaid'),
(9003, 1002, '2026-08', '2026-09-10', 999.00, 'Paid'),
(9004, 1002, '2026-09', '2026-10-10', 999.00, 'Paid'),
(9005, 1003, '2026-08', '2026-09-10', 299.00, 'Unpaid'),
(9006, 1004, '2026-09', '2026-10-10', 599.00, 'Paid'),
(9007, 1005, '2026-08', '2026-09-15', 999.00, 'Unpaid'),
(9008, 1006, '2026-09', '2026-10-20', 299.00, 'Unpaid');

-- 1. Total call minutes per plan
SELECT pl.plan_name, ISNULL(SUM(cr.call_minutes), 0) AS total_minutes
FROM plans pl
LEFT JOIN subscribers s ON pl.plan_id = s.plan_id
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY pl.plan_name
ORDER BY total_minutes DESC;

-- 2. Subscribers exceeding their data limit
SELECT s.subscriber_id, s.full_name, pl.plan_name, pl.data_limit_gb, SUM(cr.data_used_gb) AS used_gb
FROM subscribers s
JOIN plans pl ON s.plan_id = pl.plan_id
JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.full_name, pl.plan_name, pl.data_limit_gb
HAVING SUM(cr.data_used_gb) > pl.data_limit_gb;

-- 3. Month-wise revenue
SELECT billing_month, SUM(amount_due) AS total_billed
FROM invoices
GROUP BY billing_month
ORDER BY billing_month;

-- 4. Invoices overdue by more than 15 days
SELECT i.invoice_id, s.full_name, i.due_date, DATEDIFF(DAY, i.due_date, '2026-10-14') AS overdue_days, i.amount_due
FROM invoices i
JOIN subscribers s ON i.subscriber_id = s.subscriber_id
WHERE i.paid_status = 'Unpaid' AND DATEDIFF(DAY, i.due_date, '2026-10-14') > 15;

-- 5. Subscribers with no usage
SELECT s.subscriber_id, s.full_name, s.circle
FROM subscribers s
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
WHERE cr.record_id IS NULL;

-- 6. ARPU by circle
SELECT s.circle, ROUND(SUM(i.amount_due) / COUNT(DISTINCT s.subscriber_id), 2) AS arpu
FROM subscribers s
JOIN invoices i ON s.subscriber_id = i.subscriber_id
GROUP BY s.circle
ORDER BY arpu DESC;

-- 7. Plan popularity
SELECT pl.plan_name, COUNT(s.subscriber_id) AS total_subscribers
FROM plans pl
LEFT JOIN subscribers s ON pl.plan_id = s.plan_id
GROUP BY pl.plan_name;

-- 8. Top 10 data consumers
SELECT TOP 10 s.subscriber_id, s.full_name, ISNULL(SUM(cr.data_used_gb), 0) AS total_data_gb
FROM subscribers s
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.full_name
ORDER BY total_data_gb DESC;

-- Task 2: Formatted invoice numbers and due-date status
SELECT CONCAT('INV-', REPLACE(i.billing_month, '-', ''), '-', i.invoice_id) AS invoice_no,
       UPPER(s.full_name) AS subscriber,
       CASE
         WHEN i.paid_status = 'Paid' THEN 'Paid'
         WHEN DATEDIFF(DAY, i.due_date, '2026-10-14') > 0 THEN CONCAT('Overdue (', DATEDIFF(DAY, i.due_date, '2026-10-14'), ' days)')
         ELSE 'Upcoming'
       END AS status
FROM invoices i
JOIN subscribers s ON i.subscriber_id = s.subscriber_id;

-- Task 3: Effect of NULL on SUM and AVG
SELECT SUM(cr.call_minutes) AS total_mins,
       ROUND(AVG(CAST(cr.call_minutes AS FLOAT)), 2) AS avg_without_nulls,
       ROUND(AVG(CAST(ISNULL(cr.call_minutes, 0) AS FLOAT)), 2) AS avg_with_null_as_zero
FROM subscribers s
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id;
