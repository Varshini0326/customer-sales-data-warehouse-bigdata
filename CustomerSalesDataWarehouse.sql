-- ========================================================
-- Blue Sky Online Retailer - Master SQL Script
-- Author: varshini konduru
-- Description: Full Data Warehouse Implementation for Blue Sky Online Retailer.
--              Includes database creation, dimension & fact tables,
--              primary & foreign keys, ETL from staging, and sample queries.
-- ========================================================

-- ========================================================
-- PART A: DATABASE CREATION
-- ========================================================

-- Create databases
CREATE DATABASE MainDWDatabase
ON 
( NAME = 'MainDWDatabase_Data', FILENAME = 'Path\MainDWDatabase2016_Data.mdf', SIZE = 1000, FILEGROWTH = 50 )
LOG ON 
( NAME = 'MainDWDatabase_Log', FILENAME = 'Path\MainDWDatabase_Log.ldf', SIZE = 20, FILEGROWTH = 96 );
GO

CREATE DATABASE BlueSkyOnlineDB;
GO

CREATE DATABASE BS_Stagging;
GO

USE BlueSkyOnlineDB;
GO

-- ========================================================
-- PART B: DIMENSION TABLES
-- ========================================================

-- Customer Dimension
CREATE TABLE dbo.CustomerDimension(
    CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerCode VARCHAR(25) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    MaritalStatus VARCHAR(20) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    PostCode VARCHAR(20) NULL,
    City VARCHAR(50) NULL,
    Income INT NULL
);
GO

-- Date Dimension
CREATE TABLE dbo.DatesDimension(
    FullDate DATE NOT NULL PRIMARY KEY,
    MonthOfYear INT NULL,
    CalendarQuarter INT NULL,
    CalendarYear INT NULL
);
GO

-- Payment Type Dimension
CREATE TABLE dbo.PaymentTypeDimension(
    PaymentTypeKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PaymentTypeName VARCHAR(50) NOT NULL,
    PaymentTypeID INT NULL
);
GO

-- Selling Channel Dimension
CREATE TABLE dbo.SellingChannelDimension(
    SellingChannelKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SellingChannelCode VARCHAR(10) NULL,
    SellingChannelName VARCHAR(50) NOT NULL,
    CommissionRate INT NULL
);
GO

-- Furniture Dimension (optional)
CREATE TABLE dbo.FurnitureDimension(
    FurnitureKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Type VARCHAR(25) NOT NULL,
    Category VARCHAR(25) NOT NULL,
    Material VARCHAR(25) NOT NULL
);
GO

-- ========================================================
-- PART C: FACT TABLES
-- ========================================================

-- Customer Sales Transactions Fact Table
CREATE TABLE dbo.CustomerSalesTransactionFactTable(
    TransactionKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullDate DATE NOT NULL,
    InvoiceNumber VARCHAR(20) NULL,
    TotalRetailPrice DECIMAL(15,2) NULL,
    TotalCost DECIMAL(15,2) NULL,
    Commission INT NULL,
    Profit DECIMAL(15,2) NULL,
    CustomerKey INT NOT NULL,
    SellingChannelKey INT NOT NULL,
    PaymentTypeKey INT NOT NULL
);
GO

-- Furniture Sales Fact Table
CREATE TABLE dbo.SalesFact(
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    FurnitureKey INT NOT NULL,
    Quantity INT NOT NULL,
    Income FLOAT NOT NULL,
    Discount FLOAT NOT NULL,
    PRIMARY KEY (DateKey, CustomerKey, FurnitureKey)
);
GO

-- ========================================================
-- PART D: FOREIGN KEYS
-- ========================================================

-- CustomerSalesTransactionFactTable FKs
ALTER TABLE dbo.CustomerSalesTransactionFactTable
ADD CONSTRAINT FK_FullDate FOREIGN KEY (FullDate)
REFERENCES dbo.DatesDimension(FullDate);

ALTER TABLE dbo.CustomerSalesTransactionFactTable
ADD CONSTRAINT FK_Customer FOREIGN KEY (CustomerKey)
REFERENCES dbo.CustomerDimension(CustomerKey);

ALTER TABLE dbo.CustomerSalesTransactionFactTable
ADD CONSTRAINT FK_SellingChannel FOREIGN KEY (SellingChannelKey)
REFERENCES dbo.SellingChannelDimension(SellingChannelKey);

ALTER TABLE dbo.CustomerSalesTransactionFactTable
ADD CONSTRAINT FK_PaymentType FOREIGN KEY (PaymentTypeKey)
REFERENCES dbo.PaymentTypeDimension(PaymentTypeKey);

-- SalesFact FKs
ALTER TABLE dbo.SalesFact
ADD CONSTRAINT FK_Sales_Date FOREIGN KEY (DateKey)
REFERENCES dbo.DatesDimension(FullDate);

ALTER TABLE dbo.SalesFact
ADD CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerKey)
REFERENCES dbo.CustomerDimension(CustomerKey);

ALTER TABLE dbo.SalesFact
ADD CONSTRAINT FK_Sales_Furniture FOREIGN KEY (FurnitureKey)
REFERENCES dbo.FurnitureDimension(FurnitureKey);
GO

-- ========================================================
-- PART E: ETL FROM STAGING TABLES
-- ========================================================

-- Payment Types
INSERT INTO dbo.PaymentTypeDimension(PaymentTypeName, PaymentTypeID)
SELECT Name, RetailerPaymentTypeID
FROM BS_Stagging.dbo.PaymentsData;

-- Selling Channels
INSERT INTO dbo.SellingChannelDimension(SellingChannelName, SellingChannelCode, CommissionRate)
SELECT Name, Code, CommissionRate
FROM BS_Stagging.dbo.[Selling Channels];

-- Dates
INSERT INTO dbo.DatesDimension(FullDate, MonthOfYear, CalendarQuarter, CalendarYear)
SELECT FullDate, MonthOfYear, CalendarQuarter, CalendarYear
FROM BS_Stagging.dbo.[Generated DateTime];

-- Customers
INSERT INTO dbo.CustomerDimension(CustomerCode, FirstName, LastName, BirthDate, MaritalStatus, Gender, PostCode, City, Income)
SELECT c1.CustomerCode, c1.FirstName, c2.LastName, c1.BirthDate, c1.MaritalStatus, c1.Gender, c1.PostCode, c1.City, c1.Income
FROM BS_Stagging.dbo.CustomerDetails1 c1
JOIN BS_Stagging.dbo.CustomerDetails2 c2
ON c1.FirstName = c2.FirstName AND c1.LastName = c2.LastName;

-- Customer Sales Transactions Fact Table
INSERT INTO dbo.CustomerSalesTransactionFactTable(CustomerKey, SellingChannelKey, PaymentTypeKey, FullDate, InvoiceNumber, TotalRetailPrice, TotalCost, Commission)
SELECT cd.CustomerKey, scd.SellingChannelKey, ptd.PaymentTypeKey, dd.FullDate, cst.InvoiceNumber, cst.TotalRetailPrice, cst.TotalCost, scd.CommissionRate
FROM BS_Stagging.dbo.CustomerSaleTransactions cst
JOIN dbo.CustomerDimension cd ON cst.CustomerCode = cd.CustomerCode
JOIN dbo.DatesDimension dd ON cst.Date = dd.FullDate
JOIN dbo.PaymentTypeDimension ptd ON cst.PaymentTypeID = ptd.PaymentTypeID
JOIN dbo.SellingChannelDimension scd ON cst.SellingChannel = scd.SellingChannelCode;

-- Furniture Sales Fact Table
INSERT INTO dbo.SalesFact(DateKey, CustomerKey, FurnitureKey, Quantity, Income, Discount)
SELECT dd.FullDate, cd.CustomerKey, fd.FurnitureKey, fs.Quantity, fs.Income, fs.Discount
FROM BS_Stagging.dbo.FurnitureSales fs
JOIN dbo.DatesDimension dd ON fs.Date = dd.FullDate
JOIN dbo.CustomerDimension cd ON fs.CustomerCode = cd.CustomerCode
JOIN dbo.FurnitureDimension fd ON fs.FurnitureType = fd.Type;
GO

-- ========================================================
-- PART F: SAMPLE QUERIES
-- ========================================================

-- Total Sales by Customer
SELECT cd.FirstName, cd.LastName, SUM(fact.TotalRetailPrice) AS TotalSales
FROM dbo.CustomerSalesTransactionFactTable fact
JOIN dbo.CustomerDimension cd ON fact.CustomerKey = cd.CustomerKey
GROUP BY cd.FirstName, cd.LastName
ORDER BY TotalSales DESC;

-- Sales by Channel
SELECT sc.SellingChannelName, SUM(fact.TotalRetailPrice) AS TotalSales
FROM dbo.CustomerSalesTransactionFactTable fact
JOIN dbo.SellingChannelDimension sc ON fact.SellingChannelKey = sc.SellingChannelKey
GROUP BY sc.SellingChannelName
ORDER BY TotalSales DESC;

-- Profitability by Month
SELECT dd.CalendarYear, dd.MonthOfYear, SUM(fact.Profit) AS MonthlyProfit
FROM dbo.CustomerSalesTransactionFactTable fact
JOIN dbo.DatesDimension dd ON fact.FullDate = dd.FullDate
GROUP BY dd.CalendarYear, dd.MonthOfYear
ORDER BY dd.CalendarYear, dd.MonthOfYear;
GO

-- ========================================================
-- END OF MASTER SCRIPT
-- ========================================================
