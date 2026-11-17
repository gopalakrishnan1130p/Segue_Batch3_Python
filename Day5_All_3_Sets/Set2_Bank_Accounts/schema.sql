IF DB_ID(N'Day5_BankAccounts') IS NULL
    CREATE DATABASE Day5_BankAccounts;
GO
USE Day5_BankAccounts;
GO

CREATE TABLE dbo.Customer (
    CustomerID INT IDENTITY(1,1) CONSTRAINT PK_Customer PRIMARY KEY,
    FullName NVARCHAR(120) NOT NULL,
    AddressLine NVARCHAR(200) NOT NULL,
    City NVARCHAR(80) NOT NULL,
    PostalCode VARCHAR(10) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    CONSTRAINT UQ_Customer_Email UNIQUE (Email)
);
GO

CREATE TABLE dbo.Branch (
    BranchID INT IDENTITY(1,1) CONSTRAINT PK_Branch PRIMARY KEY,
    BranchName NVARCHAR(100) NOT NULL,
    BranchAddress NVARCHAR(200) NOT NULL,
    City NVARCHAR(80) NOT NULL,
    CONSTRAINT UQ_Branch_Name_City UNIQUE (BranchName, City)
);
GO

CREATE TABLE dbo.AccountType (
    AccountTypeName VARCHAR(30) CONSTRAINT PK_AccountType PRIMARY KEY,
    Description NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE dbo.RelationshipManager (
    ManagerID INT IDENTITY(1,1) CONSTRAINT PK_RelationshipManager PRIMARY KEY,
    ManagerName NVARCHAR(120) NOT NULL,
    BranchID INT NOT NULL,
    CONSTRAINT UQ_Manager_Branch UNIQUE (ManagerID, BranchID),
    CONSTRAINT FK_Manager_Branch FOREIGN KEY (BranchID)
        REFERENCES dbo.Branch(BranchID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.Account (
    AccountID INT IDENTITY(1,1) CONSTRAINT PK_Account PRIMARY KEY,
    AccountNumber VARCHAR(20) NOT NULL,
    AccountTypeName VARCHAR(30) NOT NULL,
    BranchID INT NOT NULL,
    ManagerID INT NOT NULL,
    Balance DECIMAL(14,2) NOT NULL CONSTRAINT DF_Account_Balance DEFAULT (0),
    OpenedDate DATE NOT NULL CONSTRAINT DF_Account_OpenedDate DEFAULT (CONVERT(date, GETDATE())),
    CONSTRAINT UQ_Account_Number UNIQUE (AccountNumber),
    CONSTRAINT CK_Account_SavingsBalance CHECK
        (AccountTypeName <> 'Savings' OR Balance >= 0),
    CONSTRAINT FK_Account_Type FOREIGN KEY (AccountTypeName)
        REFERENCES dbo.AccountType(AccountTypeName),
    CONSTRAINT FK_Account_ManagerBranch FOREIGN KEY (ManagerID, BranchID)
        REFERENCES dbo.RelationshipManager(ManagerID, BranchID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Bridge table supports single-owner and joint accounts.
-- Its composite primary key prevents the same customer/account pair being repeated.
CREATE TABLE dbo.AccountCustomer (
    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,
    HolderRole VARCHAR(20) NOT NULL CONSTRAINT DF_AccountCustomer_Role DEFAULT ('Primary'),
    CONSTRAINT PK_AccountCustomer PRIMARY KEY (AccountID, CustomerID),
    CONSTRAINT CK_AccountCustomer_Role CHECK (HolderRole IN ('Primary','Joint')),
    CONSTRAINT FK_AccountCustomer_Account FOREIGN KEY (AccountID)
        REFERENCES dbo.Account(AccountID) ON DELETE CASCADE,
    CONSTRAINT FK_AccountCustomer_Customer FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customer(CustomerID) ON DELETE NO ACTION
);
GO
