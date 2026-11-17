IF DB_ID(N'Day5_HospitalRecords') IS NULL
    CREATE DATABASE Day5_HospitalRecords;
GO
USE Day5_HospitalRecords;
GO

CREATE TABLE dbo.Patient (
    PatientID INT IDENTITY(1,1) CONSTRAINT PK_Patient PRIMARY KEY,
    PatientName NVARCHAR(120) NOT NULL,
    AddressLine NVARCHAR(200) NOT NULL,
    City NVARCHAR(80) NOT NULL,
    Phone VARCHAR(15) NOT NULL
);
GO

CREATE TABLE dbo.Department (
    DepartmentID INT IDENTITY(1,1) CONSTRAINT PK_Department PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Department_Name UNIQUE (DepartmentName)
);
GO

CREATE TABLE dbo.Doctor (
    DoctorID INT IDENTITY(1,1) CONSTRAINT PK_Doctor PRIMARY KEY,
    DoctorName NVARCHAR(120) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_Doctor_Department FOREIGN KEY (DepartmentID)
        REFERENCES dbo.Department(DepartmentID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.Visit (
    VisitID INT IDENTITY(1,1) CONSTRAINT PK_Visit PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    Diagnosis NVARCHAR(200) NOT NULL,
    Prescription NVARCHAR(500) NULL,
    CONSTRAINT CK_Visit_VisitDate CHECK
        (VisitDate >= '20000101' AND VisitDate <= CONVERT(date, GETDATE())),
    CONSTRAINT FK_Visit_Patient FOREIGN KEY (PatientID)
        REFERENCES dbo.Patient(PatientID)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_Visit_Doctor FOREIGN KEY (DoctorID)
        REFERENCES dbo.Doctor(DoctorID)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.Billing (
    BillingID INT IDENTITY(1,1) CONSTRAINT PK_Billing PRIMARY KEY,
    VisitID INT NOT NULL,
    BillAmount DECIMAL(12,2) NOT NULL,
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Billing_Status DEFAULT ('Open'),
    CONSTRAINT UQ_Billing_Visit UNIQUE (VisitID),
    CONSTRAINT CK_Billing_BillAmount CHECK (BillAmount >= 0),
    CONSTRAINT CK_Billing_Status CHECK (Status IN ('Open','Paid','Pending')),
    CONSTRAINT FK_Billing_Visit FOREIGN KEY (VisitID)
        REFERENCES dbo.Visit(VisitID)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO
