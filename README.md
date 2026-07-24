# Amazon-Redshift-Customer-Orders-ETL
End-to-End ETL Pipeline using Amazon Redshift and Amazon S3


# Amazon Redshift Customer Orders ETL Pipeline

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

```text
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
```

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

## Author

**Pinnamreddy Samagna**
