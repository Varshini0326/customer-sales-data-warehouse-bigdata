# Customer Sales Data Warehouse & Big Data Project – Blue Sky Online Retailer

**Dimensional Data Warehouse and Big Data Analysis project for Blue Sky Online Retailer.**  
Includes SQL Server implementation, ETL, and placeholders for Hadoop/Hive/Pig analysis.  

---

## Project Description

**Blue Sky Online Retailer** is a consumer electronics retailer operating across the UK and Europe, offering over 500 brands through multiple channels such as Amazon, eBay, Tesco, and its own website.  

The company faced challenges in **customer data management**, including:

- Fragmented customer information across Excel, CSV, and text files  
- Limited ability to analyze customer behavior and preferences  
- Lack of integration across multiple sales channels  

The purpose of this project is to design and implement a **data warehouse** to consolidate customer, sales, payment, and channel data, enabling better analysis, customer relationship management, and sales optimization. Additionally, data is migrated to **Apache Hadoop** for large-scale processing, enabling the use of **Hive** and **Pig** for big data analytics.

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Business Requirements](#business-requirements)  
3. [Data Sources](#data-sources)  
4. [Dimensional Modeling](#dimensional-modeling)  
5. [Star Schema](#star-schema)  
6. [ETL & Big Data Integration](#etl--big-data-integration)  
7. [Sample SQL Queries](#sample-sql-queries)  
8. [Repository Structure](#repository-structure)  
9. [Author](#author)  
10. [License](#license)  

---

## Project Overview

- Designed a **dimensional data model** with fact and dimension tables  
- Implemented a **data warehouse in SQL Server**  
- Migrated data to **Apache Hadoop** for big data processing  
- Performed analysis using **Hive** (SQL-like queries) and **Pig** (data transformations)  

---

## Business Requirements

- Maintain a **customer database** with demographic and transactional details  
- Analyze purchase history based on demographics: age group, income, marital status, postcode, city, country  
- Identify **customer preferences** for selling channels and payment methods  
- Determine the **most profitable customers** over different periods (month, quarter, year)  

**Challenges:**

- Fragmented customer data (Excel, CSV, TXT)  
- Limited utilization of customer behavior insights  
- Lack of integration across multiple sales channels  

---

## Data Sources

- **Customer Details:** CSV & TXT with personal info, income, and demographics  
- **Selling Channel:** TXT with channel name, code, commission  
- **Date/Time:** TXT with date key, calendar/fiscal quarters, month, year  
- **Payment Types:** CSV with payment type name and ID  
- **Customer Sales Transactions:** CSV with invoice, total cost, payment, and channel  

---

## Dimensional Modeling

**Fact Tables:**

- `CustomerSalesTransactionFactTable` – tracks each transaction  
- `CustomerPreferences` – optional for preference analysis  
- `CustomerProfitability` – optional for profit tracking  

**Dimension Tables:**

- `CustomerDimension` – demographics & location  
- `DatesDimension` – full date, month, quarter, year  
- `PaymentTypeDimension` – payment methods  
- `SellingChannelDimension` – channels and commission rates  

**Hierarchies:**

- **Time:** Year → Quarter → Month → Day  
- **Geography:** City → Postcode  

---

## Star Schema

Fact tables are linked to all dimension tables using foreign keys, supporting aggregation for customer sales, profitability, and channel performance.  

![Star Schema](docs/schema_diagram.png)

---

## ETL & Big Data Integration

**SQL Server ETL:** Cleansed and loaded data from staging to dimension and fact tables  

**Big Data Migration:**  

- Exported tables to CSV for Hadoop ingestion  
- Used **HDFS** for distributed storage  
- **Hive** for SQL-like analysis, **Pig** for data transformation  

---

## Sample SQL Queries

```sql
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

Repository Structure
customer-sales-data-warehouse-bigdata/
│
├── SQL/
│   ├── master_sql_script.sql
│   └── sample_queries.sql
│
├── Data/
│   ├── staging/
│   └── processed/
│
├── docs/
│   └── schema.png
│
├── requirements.txt
└── README.md

Author

👩‍💻 Varshini Konduru

GitHub: https://github.com/Varshini0326

LinkedIn: https://www.linkedin.com/in/varshini-konduru

License

This project is licensed under the MIT License
