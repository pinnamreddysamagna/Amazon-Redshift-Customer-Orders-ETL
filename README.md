# Amazon-Redshift-Customer-Orders-ETL
End-to-End ETL Pipeline using Amazon Redshift and Amazon S3


## Project Overview

This project demonstrates an end-to-end ETL pipeline using Amazon Redshift and Amazon S3.

The pipeline loads customer and order data from CSV files stored in Amazon S3 into Amazon Redshift, performs data cleaning and validation, applies business rules, and creates a final reporting table.

---

## Technologies Used

- Amazon Redshift
- Amazon S3
- SQL
- GitHub

---

# Project Architecture


             customers_1000.csv
               orders_5000.csv
                     │
                     ▼
                 Amazon S3
                     │
                     ▼
          Redshift COPY Command
                     │
                     ▼
      Bronze Layer (Staging Tables)
      ├── stg_customers
      └── stg_orders
                     │
                     ▼
      Data Quality Checks
      ├── Duplicate Check
      ├── NULL Check
      └── Negative Value Check
                     │
                     ▼
      Silver Layer (Data Cleaning)
      ├── customers_clean
      └── orders_clean
                     │
                     ▼
      Gold Layer (Reporting)
      └── customer_orders
                     │
                     ▼
      Business Analysis using SQL

---

## Dataset

### Customers
- customers_1000.csv

### Orders
- orders_5000.csv

---

## Bronze Layer

Created staging tables:

- stg_customers
- stg_orders

Loaded data using the COPY command from Amazon S3.

---

## Silver Layer

Performed data cleaning:

- Removed duplicate customer records
- Removed duplicate order records
- Replaced NULL values
- Removed blank spaces using TRIM()
- Standardized email values
- Removed invalid and negative values
- Applied business validation rules

Created cleaned tables:

- customers_clean
- orders_clean

---

## Gold Layer

Created final reporting table:

customer_orders

Joined customer and order information for reporting and analytics.

---

## SQL Concepts Used

- CREATE DATABASE
- CREATE TABLE
- COPY
- SELECT
- WHERE
- CASE
- COALESCE
- NULLIF
- TRIM
- ROW_NUMBER()
- PARTITION BY
- GROUP BY
- HAVING
- INNER JOIN
- COUNT
- ORDER BY

---

## Business Rules

- Customer ID must be unique.
- Order ID must be unique.
- Remove duplicate records.
- Replace NULL or blank text values.
- Standardize email values.
- Remove negative IDs.
- Remove negative quantity and amount values.
- Create clean reporting data.

---

## Files Included

- project01.sql
- customers_1000.csv
- orders_5000.csv
- Redshift_Case_Study_Customer_Orders.docx
- README.md

---

## Project Outcome

Successfully built an end-to-end ETL pipeline in Amazon Redshift by:

- Loading data from Amazon S3
- Cleaning and validating data
- Applying business rules
- Creating Bronze, Silver, and Gold layers
- Preparing analytics-ready data for reporting

---

## Learning Outcomes

Through this project, the following concepts were implemented:

- Amazon Redshift ETL Pipeline
- Amazon S3 Integration
- Redshift COPY Command
- Bronze, Silver, and Gold Layer Architecture
- Data Quality Validation
- Duplicate Detection and Removal
- NULL Value Handling
- Data Cleansing using SQL
- SQL Window Functions (`ROW_NUMBER`)
- SQL Aggregate Functions (`COUNT`, `SUM`, `AVG`)
- SQL Joins for Data Integration
- Business Rule Implementation
- Business Analytics using SQL
- GitHub Version Control

---

## Future Enhancements

The following improvements can be added in future versions of the project:

- Automate the ETL pipeline using AWS Glue or Apache Airflow
- Implement Incremental Data Loading (CDC)
- Optimize Redshift tables using Distribution Styles and Sort Keys
- Add Logging and Error Handling
- Monitor ETL jobs using Amazon CloudWatch
- Create interactive dashboards using Amazon QuickSight or Power BI
- Schedule automated ETL jobs
- Implement data auditing and validation before loading into Gold tables
- Integrate with Databricks or AWS Lambda for advanced data processing
- Enhance the pipeline with performance optimization techniques

---

## Author

**Pinnamreddy Samagna**

B.Tech – Information Technology

Data Engineering | Amazon Redshift | SQL | AWS | GitHub

