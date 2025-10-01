# Customer Sales Data Warehouse & Big Data - Blue Sky Online Retailer

## Project Description

**Blue Sky Online Retailer** is a consumer electronics retailer operating across the UK and Europe, offering over 500 brands through multiple channels like Amazon, eBay, Tesco, and its own website.  

The company faced challenges in customer data management, including:

- Fragmented customer information across Excel, CSV, and text files  
- Limited ability to analyze customer behavior and preferences  
- Lack of integration across multiple sales channels  

The purpose of this project is to design and implement a **data warehouse** to consolidate customer, sales, payment, and channel data, enabling **better analysis, customer relationship management, and sales optimization**. Additionally, data is migrated to **Apache Hadoop** for large-scale processing, enabling the use of **Hive** and **Pig** for big data analytics.

---

## Project Overview

- Designed a **dimensional data model** with fact and dimension tables  
- Implemented a **data warehouse in SQL Server**  
- Migrated data to **Apache Hadoop** for big data processing  
- Performed analysis using **Hive** (SQL-like queries) and **Pig** (data transformations)  

---

## Business Requirements

1. Maintain a **customer database** with demographic and transactional details  
2. Analyze purchase history based on demographics: age group, income, marital status, postcode, city, country  
3. Identify **customer preferences** for selling channels and payment methods  
4. Determine the **most profitable customers** over different periods (month, quarter, year)  

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

![Star Schema](https://github.com/Varshini0326/customer-sales-data-warehouse-bigdata/blob/main/Schema.png)  

Fact tables are linked to all dimension tables using foreign keys, supporting aggregation for customer sales, profitability, and channel performance.

---

## ETL & Big Data Integration

- **SQL Server ETL:** Cleansed and loaded data from staging to dimension and fact tables  
- **Big Data Migration:**  
  - Exported tables to CSV for Hadoop ingestion  
  - Used **HDFS** for distributed storage  
  - **Hive** for SQL-like analysis, **Pig** for data transformation  

---

## License

This project is licensed under the [MIT License](LICENSE).

## Author

👩‍💻 **Varshini Konduru**

- [GitHub](https://github.com/Varshini0326)  
- [LinkedIn](https://www.linkedin.com/in/varshini-konduru-310767195/)
