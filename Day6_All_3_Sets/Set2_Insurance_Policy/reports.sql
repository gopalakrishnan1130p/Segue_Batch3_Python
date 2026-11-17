-- Day 6 Assignment - Set 2: Insurance Policy Reporting
-- SQL Server 2025 (Reference Date: 2026-10-14)

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    dob DATE,
    city VARCHAR(50)
);

CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    policy_number VARCHAR(25),
    customer_id INT FOREIGN KEY REFERENCES customers(customer_id),
    product_name VARCHAR(50),
    agent_name VARCHAR(50),
    issue_date DATE,
    expiry_date DATE,
    status VARCHAR(20)
);

CREATE TABLE premiums (
    premium_id INT PRIMARY KEY,
    policy_id INT FOREIGN KEY REFERENCES policies(policy_id),
    payment_date DATE,
    amount DECIMAL(10, 2)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT FOREIGN KEY REFERENCES policies(policy_id),
    claim_date DATE,
    claim_amount DECIMAL(10, 2),
    claim_status VARCHAR(20)
);

INSERT INTO customers VALUES
(1, 'Vikram Sethi', '1998-04-12', 'Chennai'),
(2, 'Meera Krishnan', '1984-09-20', 'Bengaluru'),
(3, 'Suresh Babu', '1968-01-15', 'Coimbatore'),
(4, 'Ananya Das', '1992-07-08', 'Hyderabad'),
(5, 'Prashanth Rao', '1979-11-30', 'Pune');

INSERT INTO policies VALUES
(201, 'POL-2025-88412', 1, 'Term Life Shield', 'Arjun Mehta', '2025-10-25', '2026-10-25', 'Active'),
(202, 'POL-2025-88419', 1, 'Health Care Plus', 'Arjun Mehta', '2025-12-01', '2026-12-01', 'Active'),
(203, 'POL-2025-88425', 2, 'Health Care Plus', 'Kavita Nair', '2025-11-05', '2026-11-05', 'Active'),
(204, 'POL-2026-91002', 2, 'Motor Comprehensive', 'Rakesh Sharma', '2026-01-15', '2027-01-15', 'Active'),
(205, 'POL-2026-91015', 3, 'Senior Health Guard', 'Kavita Nair', '2026-02-10', '2027-02-10', 'Active'),
(206, 'POL-2026-91028', 4, 'Term Life Shield', 'Deepa Verma', '2026-03-18', '2027-03-18', 'Active'),
(207, 'POL-2026-91040', 5, 'Motor Comprehensive', 'Sanjay Gupta', '2026-04-22', '2027-04-22', 'Active'),
(208, 'POL-2026-91055', 3, 'Travel Secure', 'Neha Kapoor', '2026-05-12', '2027-05-12', 'Active');

INSERT INTO premiums VALUES
(1, 201, '2025-10-25', 18000.00),
(2, 202, '2025-12-01', 14500.00),
(3, 203, '2025-11-05', 22000.00),
(4, 204, '2026-01-15', 12000.00),
(5, 205, '2026-02-10', 32000.00),
(6, 206, '2026-03-18', 19500.00),
(7, 207, '2026-04-22', 13500.00),
(8, 208, '2026-05-12', 6500.00);

INSERT INTO claims VALUES
(501, 202, '2026-04-10', 8500.00, 'Settled'),
(502, 203, '2026-06-15', 15000.00, 'Settled'),
(503, 204, '2026-07-20', 9000.00, 'Settled'),
(504, 205, '2026-08-05', 24000.00, 'In Review');

-- 1. Policies expiring in the next 30 days
SELECT p.policy_number, c.full_name, p.product_name, p.expiry_date, DATEDIFF(DAY, '2026-10-14', p.expiry_date) AS days_left
FROM policies p
JOIN customers c ON p.customer_id = c.customer_id
WHERE p.status = 'Active' AND p.expiry_date BETWEEN '2026-10-14' AND DATEADD(DAY, 30, '2026-10-14');

-- 2. Premium collected per product
SELECT p.product_name, SUM(pr.amount) AS total_premium
FROM policies p
JOIN premiums pr ON p.policy_id = pr.policy_id
GROUP BY p.product_name
ORDER BY total_premium DESC;

-- 3. Customers with more than 1 active policy
SELECT c.customer_id, c.full_name, COUNT(p.policy_id) AS active_policies
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
WHERE p.status = 'Active'
GROUP BY c.customer_id, c.full_name
HAVING COUNT(p.policy_id) > 1;

-- 4. Claim ratio per product
SELECT p.product_name,
       SUM(pr.amount) AS total_premium,
       ISNULL(SUM(cl.claim_amount), 0) AS total_claims,
       ROUND(ISNULL(SUM(cl.claim_amount), 0) * 100.0 / SUM(pr.amount), 2) AS claim_ratio_pct
FROM policies p
JOIN premiums pr ON p.policy_id = pr.policy_id
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY p.product_name;

-- 5. Policies without claims
SELECT p.policy_id, p.policy_number, c.full_name, p.product_name
FROM policies p
JOIN customers c ON p.customer_id = c.customer_id
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
WHERE cl.claim_id IS NULL;

-- 6. Average premium by age band
SELECT CASE
         WHEN DATEDIFF(YEAR, c.dob, '2026-10-14') < 30 THEN 'Under 30'
         WHEN DATEDIFF(YEAR, c.dob, '2026-10-14') BETWEEN 30 AND 44 THEN '30-44'
         ELSE '45+'
       END AS age_band,
       ROUND(AVG(pr.amount), 2) AS avg_premium
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
JOIN premiums pr ON p.policy_id = pr.policy_id
GROUP BY CASE
         WHEN DATEDIFF(YEAR, c.dob, '2026-10-14') < 30 THEN 'Under 30'
         WHEN DATEDIFF(YEAR, c.dob, '2026-10-14') BETWEEN 30 AND 44 THEN '30-44'
         ELSE '45+'
       END;

-- 7. Monthly new policies
SELECT FORMAT(issue_date, 'yyyy-MM') AS issue_month, COUNT(*) AS new_policies
FROM policies
GROUP BY FORMAT(issue_date, 'yyyy-MM')
ORDER BY issue_month;

-- 8. Top 5 agents by premium
SELECT TOP 5 p.agent_name, SUM(pr.amount) AS premium_collected
FROM policies p
JOIN premiums pr ON p.policy_id = pr.policy_id
GROUP BY p.agent_name
ORDER BY premium_collected DESC;

-- Task 2: DATEADD, DATEDIFF, CASE and String Functions
SELECT p.policy_id,
       CONCAT(LEFT(p.policy_number, 9), 'XXXXX') AS masked_policy_no,
       UPPER(c.full_name) AS customer_name,
       CASE
         WHEN DATEDIFF(DAY, p.issue_date, '2026-10-14') < 180 THEN 'New (<6M)'
         ELSE 'Established (6M+)'
       END AS policy_age_band,
       DATEADD(DAY, -15, p.expiry_date) AS renewal_notice_date
FROM policies p
JOIN customers c ON p.customer_id = c.customer_id;
