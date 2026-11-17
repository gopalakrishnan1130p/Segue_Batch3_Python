USE Day5_BankAccounts;
GO

INSERT INTO dbo.Customer (FullName,AddressLine,City,PostalCode,Email) VALUES
('Arun Kumar','12 Lake Road','Chennai','600001','arun@example.com'),
('Bala S','24 Park Street','Chennai','600002','bala@example.com'),
('Charan R','8 Market Road','Coimbatore','641001','charan@example.com'),
('Divya M','15 Gandhi Street','Madurai','625001','divya@example.com'),
('Ezhil K','4 School Road','Salem','636001','ezhil@example.com'),
('Farah A','18 Beach Road','Chennai','600004','farah@example.com'),
('Ganesh P','21 Main Road','Trichy','620001','ganesh@example.com'),
('Harini V','9 Temple Street','Vellore','632001','harini@example.com'),
('Imran N','31 North Street','Erode','638001','imran@example.com'),
('Jaya L','6 South Street','Chennai','600005','jaya@example.com');

INSERT INTO dbo.Branch (BranchName,BranchAddress,City) VALUES
('Chennai Main','1 Bank Road','Chennai'),
('Tambaram','2 GST Road','Chennai'),
('Coimbatore Central','3 Avinashi Road','Coimbatore'),
('Madurai East','4 East Masi Street','Madurai'),
('Salem Main','5 Bazaar Street','Salem'),
('Trichy Cantonment','6 Williams Road','Trichy'),
('Vellore Fort','7 Fort Road','Vellore'),
('Erode Main','8 Brough Road','Erode'),
('Anna Nagar','9 Second Avenue','Chennai'),
('Velachery','10 Velachery Main Road','Chennai');

INSERT INTO dbo.AccountType (AccountTypeName,Description) VALUES
('Savings','Personal savings account'),
('Current','Business current account'),
('Salary','Salary account');

INSERT INTO dbo.RelationshipManager (ManagerName,BranchID) VALUES
('Meena R',1),('Karthik S',2),('Naveen P',3),('Priya M',4),('Ravi K',5),
('Sathya V',6),('Uma S',7),('Vijay R',8),('Yamini P',9),('Zahir A',10);

INSERT INTO dbo.Account
    (AccountNumber,AccountTypeName,BranchID,ManagerID,Balance,OpenedDate) VALUES
('AC100001','Savings',1,1,65000,'2026-08-05'),
('AC100002','Current',2,2,120000,'2026-08-12'),
('AC100003','Savings',3,3,45000,'2026-09-01'),
('AC100004','Salary',4,4,72000,'2026-09-15'),
('AC100005','Savings',5,5,89000,'2026-10-02'),
('AC100006','Current',6,6,250000,'2026-10-08'),
('AC100007','Savings',7,7,54000,'2026-10-11'),
('AC100008','Salary',8,8,38000,'2026-10-19'),
('AC100009','Savings',9,9,105000,'2026-11-02'),
('AC100010','Current',10,10,175000,'2026-11-05');

INSERT INTO dbo.AccountCustomer (AccountID,CustomerID,HolderRole) VALUES
(1,1,'Primary'),(2,2,'Primary'),(3,3,'Primary'),(4,4,'Primary'),(5,5,'Primary'),
(6,6,'Primary'),(7,7,'Primary'),(8,8,'Primary'),(9,9,'Primary'),(10,10,'Primary'),
(1,2,'Joint');
GO

-- CRUD examples.
UPDATE dbo.Customer SET AddressLine = '14 Lake Road' WHERE CustomerID = 1;
SELECT * FROM dbo.Customer WHERE CustomerID = 1;
DELETE FROM dbo.AccountCustomer WHERE AccountID = 10 AND CustomerID = 10;
-- Restore the sample mapping so later joins still show all ten accounts.
INSERT INTO dbo.AccountCustomer (AccountID,CustomerID,HolderRole) VALUES (10,10,'Primary');
GO

-- WHERE with AND, OR, IN and BETWEEN.
DECLARE @BalanceThreshold DECIMAL(14,2) = 50000;

SELECT a.AccountNumber, a.AccountTypeName, a.Balance, a.OpenedDate,
       b.BranchName, rm.ManagerName, c.FullName
FROM dbo.Account AS a
JOIN dbo.Branch AS b ON a.BranchID = b.BranchID
JOIN dbo.RelationshipManager AS rm ON a.ManagerID = rm.ManagerID
JOIN dbo.AccountCustomer AS ac ON a.AccountID = ac.AccountID
JOIN dbo.Customer AS c ON ac.CustomerID = c.CustomerID
WHERE a.OpenedDate >= DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()) - 1, 0)
  AND a.OpenedDate <  DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0)
  AND a.Balance > @BalanceThreshold
  AND (a.AccountTypeName = 'Savings' OR a.AccountTypeName = 'Salary')
  AND a.BranchID IN (1,2,9,10)
  AND a.Balance BETWEEN 50000 AND 200000;
GO

-- DROP, TRUNCATE and DELETE demonstration on an isolated test table.
IF OBJECT_ID('dbo.CommandDemo','U') IS NOT NULL DROP TABLE dbo.CommandDemo;
CREATE TABLE dbo.CommandDemo (
    DemoID INT IDENTITY(1,1) PRIMARY KEY,
    DemoName VARCHAR(30) NOT NULL
);

INSERT INTO dbo.CommandDemo (DemoName) VALUES ('One'),('Two');
SELECT 'Initial rows' AS Stage, * FROM dbo.CommandDemo;

DELETE FROM dbo.CommandDemo;
INSERT INTO dbo.CommandDemo (DemoName) VALUES ('After DELETE');
SELECT 'DELETE does not reset identity' AS Stage, * FROM dbo.CommandDemo;

TRUNCATE TABLE dbo.CommandDemo;
INSERT INTO dbo.CommandDemo (DemoName) VALUES ('After TRUNCATE');
SELECT 'TRUNCATE resets identity' AS Stage, * FROM dbo.CommandDemo;

BEGIN TRANSACTION;
DELETE FROM dbo.CommandDemo WHERE DemoName = 'After TRUNCATE';
ROLLBACK TRANSACTION;
SELECT 'DELETE rollback restores row' AS Stage, * FROM dbo.CommandDemo;

BEGIN TRANSACTION;
DROP TABLE dbo.CommandDemo;
ROLLBACK TRANSACTION;
SELECT 'DROP rollback restores table' AS Stage, * FROM dbo.CommandDemo;
GO
