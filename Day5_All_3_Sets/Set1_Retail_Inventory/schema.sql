IF DB_ID(N'Day5_RetailInventory') IS NULL
    CREATE DATABASE Day5_RetailInventory;
GO
USE Day5_RetailInventory;
GO

CREATE TABLE dbo.Supplier (
    SupplierID INT IDENTITY(1,1) CONSTRAINT PK_Supplier PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    SupplierPhone VARCHAR(15) NOT NULL,
    CONSTRAINT UQ_Supplier_Name UNIQUE (SupplierName)
);
GO

CREATE TABLE dbo.Category (
    CategoryID INT IDENTITY(1,1) CONSTRAINT PK_Category PRIMARY KEY,
    CategoryName NVARCHAR(60) NOT NULL,
    CONSTRAINT UQ_Category_Name UNIQUE (CategoryName)
);
GO

CREATE TABLE dbo.Warehouse (
    WarehouseID INT IDENTITY(1,1) CONSTRAINT PK_Warehouse PRIMARY KEY,
    WarehouseName NVARCHAR(100) NOT NULL,
    WarehouseLocation NVARCHAR(150) NOT NULL,
    CONSTRAINT UQ_Warehouse_Name UNIQUE (WarehouseName)
);
GO

CREATE TABLE dbo.Product (
    ProductID INT IDENTITY(1,1) CONSTRAINT PK_Product PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL,
    ProductName NVARCHAR(120) NOT NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    ReorderLevel INT NOT NULL CONSTRAINT DF_Product_ReorderLevel DEFAULT (5),
    IsDiscontinued BIT NOT NULL CONSTRAINT DF_Product_IsDiscontinued DEFAULT (0),
    CONSTRAINT UQ_Product_SKU UNIQUE (SKU),
    CONSTRAINT CK_Product_ReorderLevel CHECK (ReorderLevel >= 0),
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Category(CategoryID)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_Product_Supplier FOREIGN KEY (SupplierID)
        REFERENCES dbo.Supplier(SupplierID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.Inventory (
    InventoryID INT IDENTITY(1,1) CONSTRAINT PK_Inventory PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    Quantity INT NOT NULL CONSTRAINT DF_Inventory_Quantity DEFAULT (0),
    CONSTRAINT CK_Inventory_Quantity CHECK (Quantity >= 0),
    CONSTRAINT UQ_Inventory_Product_Warehouse UNIQUE (ProductID, WarehouseID),
    CONSTRAINT FK_Inventory_Product FOREIGN KEY (ProductID)
        REFERENCES dbo.Product(ProductID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Inventory_Warehouse FOREIGN KEY (WarehouseID)
        REFERENCES dbo.Warehouse(WarehouseID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Review documents are stored in MongoDB, not in these relational tables.
