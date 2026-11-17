USE Day5_RetailInventory;
GO

INSERT INTO dbo.Supplier (SupplierName, SupplierPhone) VALUES
('Apex Distributors','9876501001'),
('Bright Supplies','9876501002'),
('City Wholesale','9876501003'),
('Delta Traders','9876501004'),
('Evergreen Supply','9876501005'),
('Future Goods','9876501006'),
('Global Merchants','9876501007'),
('Horizon Suppliers','9876501008'),
('Iconic Distributors','9876501009'),
('Jupiter Wholesale','9876501010');

INSERT INTO dbo.Category (CategoryName) VALUES
('Electronics'),('Stationery'),('Furniture'),('Kitchen'),
('Sports'),('Clothing'),('Footwear'),('Books'),('Toys'),('Home Care');

INSERT INTO dbo.Warehouse (WarehouseName, WarehouseLocation) VALUES
('Chennai Central','Chennai'),('Tambaram Store','Tambaram'),
('Guindy Depot','Guindy'),('Avadi Warehouse','Avadi'),
('Velachery Hub','Velachery'),('Porur Storage','Porur'),
('Ambattur Depot','Ambattur'),('Poonamallee Store','Poonamallee'),
('OMR Warehouse','OMR'),('T Nagar Store','T Nagar');

INSERT INTO dbo.Product
    (SKU, ProductName, CategoryID, SupplierID, ReorderLevel, IsDiscontinued) VALUES
('SKU1001','Wireless Mouse',1,1,10,0),
('SKU1002','USB Keyboard',1,2,8,0),
('SKU1003','A4 Notebook',2,3,20,0),
('SKU1004','Office Chair',3,4,5,0),
('SKU1005','Water Bottle',4,5,12,0),
('SKU1006','Cricket Bat',5,6,4,0),
('SKU1007','Cotton T-Shirt',6,7,15,0),
('SKU1008','Running Shoes',7,8,6,0),
('SKU1009','SQL Basics Book',8,9,10,0),
('SKU1010','Old Wired Mouse',1,10,5,1);

INSERT INTO dbo.Inventory (ProductID, WarehouseID, Quantity) VALUES
(1,1,45),(2,2,32),(3,3,100),(4,4,18),(5,5,60),
(6,6,12),(7,7,40),(8,8,22),(9,9,35),(10,10,0);
GO

PRINT '10 rows inserted into each SQL table.';
GO

-- Demonstrate the four deliberately failing inserts.
-- Each error is caught so the remaining demonstrations still run.
BEGIN TRY
    INSERT INTO dbo.Product (SKU, ProductName, CategoryID, SupplierID)
    VALUES ('SKU1001','Duplicate SKU Product',1,1);
END TRY
BEGIN CATCH
    PRINT 'Expected failure – duplicate SKU: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    INSERT INTO dbo.Product (SKU, ProductName, CategoryID, SupplierID)
    VALUES ('SKU9001','Missing Parent Product',999,1);
END TRY
BEGIN CATCH
    PRINT 'Expected failure – missing category parent: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    INSERT INTO dbo.Inventory (ProductID, WarehouseID, Quantity)
    VALUES (1,2,-5);
END TRY
BEGIN CATCH
    PRINT 'Expected failure – negative quantity: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    INSERT INTO dbo.Supplier (SupplierName, SupplierPhone)
    VALUES (NULL,'9876599999');
END TRY
BEGIN CATCH
    PRINT 'Expected failure – NULL mandatory supplier name: ' + ERROR_MESSAGE();
END CATCH;
GO

-- UPDATE: show the supplier phone before and after.
SELECT SupplierID, SupplierName, SupplierPhone
FROM dbo.Supplier WHERE SupplierID = 1;

UPDATE dbo.Supplier
SET SupplierPhone = '9000012345'
WHERE SupplierID = 1;

SELECT SupplierID, SupplierName, SupplierPhone
FROM dbo.Supplier WHERE SupplierID = 1;
GO

-- DELETE discontinued SKU(s): show the row before and after.
SELECT ProductID, SKU, ProductName, IsDiscontinued
FROM dbo.Product WHERE IsDiscontinued = 1;

-- Inventory rows are removed automatically because FK_Inventory_Product uses ON DELETE CASCADE.
DELETE FROM dbo.Product
WHERE IsDiscontinued = 1;

SELECT ProductID, SKU, ProductName, IsDiscontinued
FROM dbo.Product WHERE IsDiscontinued = 1;
GO

-- Basic retrieval examples.
SELECT p.SKU, p.ProductName, c.CategoryName, s.SupplierName,
       w.WarehouseName, i.Quantity, p.ReorderLevel
FROM dbo.Product AS p
JOIN dbo.Category AS c ON p.CategoryID = c.CategoryID
JOIN dbo.Supplier AS s ON p.SupplierID = s.SupplierID
JOIN dbo.Inventory AS i ON p.ProductID = i.ProductID
JOIN dbo.Warehouse AS w ON i.WarehouseID = w.WarehouseID
ORDER BY p.SKU;
GO
