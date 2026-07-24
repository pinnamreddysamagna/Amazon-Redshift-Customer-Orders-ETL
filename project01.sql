--==========================================
-- PROJECT- REDSHIFT ETL PIPELINE
--==========================================

CREATE DATABASE customer_orders_db;

--==========================================
-- BRONZE LAYER (STAGING)
--==========================================

CREATE TABLE stg_customers
(
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    gender VARCHAR(10),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE,
    customer_status VARCHAR(20)
);

CREATE TABLE stg_orders
(
    order_id INT,
    customer_id INT,
    order_date DATE,
    product_id INT,
    product_category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    order_amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    order_status VARCHAR(30),
    sales_region VARCHAR(50)
);

-- Check current database

SELECT CURRENT_DATABASE();

--==========================================
-- LOAD CUSTOMER DATA
--==========================================

COPY stg_customers
FROM 's3://redshift-project-01/input/customers_1000.csv'
IAM_ROLE 'arn:aws:iam::162504351662:role/Customer_project'
CSV
IGNOREHEADER 1;

--==========================================
-- LOAD ORDERS DATA
--==========================================

COPY stg_orders
FROM 's3://redshift-project-01/input/orders_5000.csv'
IAM_ROLE 'arn:aws:iam::162504351662:role/Customer_project'
CSV
IGNOREHEADER 1;

--==========================================
-- VALIDATION
--==========================================

SELECT COUNT(*) AS total_customers
FROM stg_customers;

SELECT *
FROM stg_customers
LIMIT 10;

SELECT COUNT(*) AS total_orders
FROM stg_orders;

SELECT *
FROM stg_orders
LIMIT 10;

--==========================================
-- BRONZE VALIDATION
--==========================================

-- Customers with NULL customer_id

SELECT *
FROM stg_customers
WHERE customer_id IS NULL;

-- Orders with NULL order_id

SELECT *
FROM stg_orders
WHERE order_id IS NULL;

-- Duplicate customer_ids

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM stg_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate order_ids

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--==========================================
-- SILVER LAYER 
--==========================================

DROP TABLE IF EXISTS customers_clean;

CREATE TABLE customers_clean AS
SELECT
    customer_id,

    COALESCE(NULLIF(TRIM(first_name), ''), 'None') AS first_name,
    COALESCE(NULLIF(TRIM(last_name), ''), 'None') AS last_name,

    CASE
        WHEN email IS NULL
          OR TRIM(email) = ''
          OR TRIM(email) = 'None@gmail.com'
        THEN 'unknown@example.com'
        ELSE TRIM(email)
    END AS email,

    COALESCE(NULLIF(TRIM(phone), ''), 'None') AS phone,
    COALESCE(NULLIF(TRIM(gender), ''), 'None') AS gender,
    COALESCE(NULLIF(TRIM(city), ''), 'None') AS city,
    COALESCE(NULLIF(TRIM(state), ''), 'UNKNOWN') AS state,
    COALESCE(NULLIF(TRIM(country), ''), 'None') AS country,

    registration_date,

    COALESCE(NULLIF(TRIM(customer_status), ''), 'None') AS customer_status

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY customer_id
           ) AS rn
    FROM stg_customers
) t
WHERE rn = 1
  AND customer_id >= 0;

--CHECKING DUPLICATES FROM CLEANED CUSTOMERS--
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*) > 1;

---OREDERS--

DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT
    order_id,
    customer_id,
    order_date,
    product_id,

    COALESCE(NULLIF(TRIM(product_category), ''), 'None') AS product_category,

    quantity,
    unit_price,
    discount,
    tax,
    shipping_cost,

    COALESCE(order_amount, 0) AS order_amount,

    COALESCE(NULLIF(TRIM(payment_method), ''), 'None') AS payment_method,
    COALESCE(NULLIF(TRIM(order_status), ''), 'None') AS order_status,
    COALESCE(NULLIF(TRIM(sales_region), ''), 'None') AS sales_region

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY order_id
           ) AS rn
    FROM stg_orders
) t
WHERE rn = 1
  AND order_id > 0
  AND customer_id > 0
  AND product_id > 0
  AND quantity >= 0
  AND unit_price >= 0
  AND discount >= 0
  AND tax >= 0
  AND shipping_cost >= 0
  AND order_amount >= 0;

----CHECKING DUPLICATES FROM CLEANED ORDERS---

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders_clean
GROUP BY order_id
HAVING COUNT(*) > 1;
--==========================================
-- GOLD LAYER
--==========================================

DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders AS
SELECT

    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.gender,
    c.city,
    c.state,
    c.country,
    c.registration_date,
    c.customer_status,

    o.order_id,
    o.order_date,
    o.product_id,
    o.product_category,
    o.quantity,
    o.unit_price,
    o.discount,
    o.tax,
    o.shipping_cost,
    o.order_amount,
    o.payment_method,
    o.order_status,
    o.sales_region

FROM customers_clean c
JOIN orders_clean o
ON c.customer_id = o.customer_id;

SELECT COUNT(*) FROM customer_orders;

SELECT * FROM customer_orders
LIMIT 10;

----COUNT OF ALL THE TABLES--

SELECT 'stg_customers' AS table_name, COUNT(*) FROM stg_customers

UNION ALL

SELECT 'stg_orders', COUNT(*) FROM stg_orders

UNION ALL

SELECT 'customers_clean', COUNT(*) FROM customers_clean

UNION ALL

SELECT 'orders_clean', COUNT(*) FROM orders_clean

UNION ALL

SELECT 'customer_orders', COUNT(*) FROM customer_orders;

-- Check for NULL Customer IDs
SELECT *
FROM customer_orders
WHERE customer_id IS NULL;
-- Check for NULL Order IDs
SELECT *
FROM customer_orders
WHERE order_id IS NULL;
-- Check for Unknown Email
SELECT *
FROM customer_orders
WHERE email = 'unknown@example.com';
-- Check for Negative Values
SELECT *
FROM customer_orders
WHERE quantity < 0
   OR unit_price < 0
   OR discount < 0
   OR tax < 0
   OR shipping_cost < 0
   OR order_amount < 0;
-- Count Final Records
SELECT COUNT(*) AS total_records
FROM customer_orders;

-----BUSINESS RULE----

-- Business Rule 1: One customer per customer_id

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Business Rule 2: Revenue per Customer

SELECT
    customer_id,
    SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- Business Rule 3: Average Order Value

SELECT
    customer_id,
    AVG(order_amount) AS average_order_value
FROM customer_orders
GROUP BY customer_id
ORDER BY average_order_value DESC;

-- Business Rule 4: Top Customers Ranked by Revenue

SELECT
    customer_id,
    first_name,
    last_name,
    SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY customer_id, first_name, last_name
ORDER BY total_revenue DESC
LIMIT 10;

---ANALYTICS--

-- 1. Top 10 Customers by Revenue

SELECT
    customer_id,
    first_name,
    last_name,
    SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY customer_id, first_name, last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Revenue by State

SELECT
    state,
    SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY state
ORDER BY total_revenue DESC;

-- 3. Average Order Value by Customer

SELECT
    customer_id,
    AVG(order_amount) AS average_order_value
FROM customer_orders
GROUP BY customer_id
ORDER BY average_order_value DESC;

-- 4. Customers with No Valid Email

SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customer_orders
WHERE email = 'unknown@example.com';

-- 5. Monthly Sales Trend

SELECT
    DATE_TRUNC('month', order_date) AS sales_month,
    SUM(order_amount) AS total_sales
FROM customer_orders
GROUP BY sales_month
ORDER BY sales_month;

-- 6. Duplicate Detection Report

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customer_orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 7. Orders with Zero Amount After Cleansing

SELECT *
FROM customer_orders
WHERE order_amount = 0;
