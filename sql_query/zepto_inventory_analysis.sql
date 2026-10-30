/*
PROJECT: Zepto Inventory & Product Analysis
DATABASE: MySQL 8.0
PURPOSE: Data exploration, cleaning, transformation and business analysis

LEARNING REFERENCE:
"Build SQL Data Analyst Portfolio Project Step-by-Step Guide with Real Zepto Data"
by Amlan Mohanty

BEFORE RUNNING:
1. Update the CSV path in LOAD DATA INFILE.
2. Verify the source price unit before converting prices.
   If both price columns are stored in paise, divide BOTH by 100.
   Do not run the conversion more than once.
3. Keep an untouched copy of the original CSV/raw data.
4. DROP TABLE IF EXISTS deletes the existing table and its data.
*/


-- ============================================================
-- 01. DATABASE AND TABLE SETUP
-- Purpose: Create a database and structured table for the CSV.
-- ============================================================

CREATE DATABASE IF NOT EXISTS zepto_sql_project;
USE zepto_sql_project;

-- WARNING: This removes the existing table and its data.
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    Category VARCHAR(120),
    Name VARCHAR(150) NOT NULL,
    mrp NUMERIC(12,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INT,
    discountedSellingPrice NUMERIC(12,2),
    weightGrams INT,
    outOfStock BOOLEAN,
    quantity INT
);


-- ============================================================
-- 02. CSV DATA IMPORT
-- Purpose: Load source CSV records into the MySQL table.
-- ============================================================

SHOW VARIABLES LIKE 'secure_file_priv';

-- Change this path to the location of your CSV file.
LOAD DATA INFILE 'D:/MySQL/MySQL Server 8.0/Uploads/zepto_v2.csv'
INTO TABLE zepto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Category, Name, mrp, discountPercent, availableQuantity,
 discountedSellingPrice, weightGrams, @outOfStockVar, quantity)
SET outOfStock = CASE
    WHEN UPPER(TRIM(@outOfStockVar)) = 'FALSE' THEN 0
    WHEN UPPER(TRIM(@outOfStockVar)) = 'TRUE' THEN 1
    ELSE NULL
END;


-- ============================================================
-- 03. DATA EXPLORATION
-- Purpose: Understand the dataset before changing or analysing it.
-- ============================================================

-- 3.1 Inspect records for a particular product.
SELECT *
FROM zepto
WHERE Name = 'Onion';

-- 3.2 Count all imported records.
SELECT COUNT(*) AS total_records
FROM zepto;

-- 3.3 Preview the first 10 records.
SELECT *
FROM zepto
LIMIT 10;

-- 3.4 Identify the available product categories.
SELECT DISTINCT Category
FROM zepto
ORDER BY Category;

-- 3.5 Check important columns for NULL values.
SELECT *
FROM zepto
WHERE Category IS NULL
   OR Name IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL
   OR weightGrams IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- 3.6 Count products by stock status.
-- GROUP BY creates one result group for each stock-status value.
SELECT
    outOfStock,
    COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outOfStock;

-- 3.7 Find product names associated with multiple SKU records.
-- Repeated names are investigated, not automatically deleted.
SELECT
    Name,
    COUNT(sku_id) AS sku_count
FROM zepto
GROUP BY Name
HAVING COUNT(sku_id) > 1
ORDER BY sku_count DESC;


-- ============================================================
-- 04. DATA QUALITY CHECKS AND CLEANING
-- Purpose: Identify invalid price records and prepare data.
-- ============================================================

-- 4.1 Inspect records with zero MRP or zero selling price.
SELECT *
FROM zepto
WHERE mrp = 0
   OR discountedSellingPrice = 0;

-- 4.2 Remove records with zero MRP.
-- Review first and retain a backup before deleting.
SET SQL_SAFE_UPDATES = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- 4.3 Recheck zero-price records.
-- This does not delete zero selling-price records.
SELECT *
FROM zepto
WHERE mrp = 0
   OR discountedSellingPrice = 0;

-- 4.4 Convert paise to rupees ONLY if source values are confirmed
-- to be stored in paise. Run once only.
--
-- The pasted script used /1000 for MRP and /10000 for selling price.
-- These factors are inconsistent. If BOTH source columns are in paise,
-- the conversion is /100 for BOTH columns.
--
-- Uncomment only after verifying the raw source values and units.
--
-- UPDATE zepto
-- SET
--     mrp = mrp / 100,
--     discountedSellingPrice = discountedSellingPrice / 100;


-- ============================================================
-- 05. CORE PRODUCT AND INVENTORY ANALYSIS
-- Purpose: Answer the original project questions using SQL.
-- ============================================================

-- 5.1 Top 10 products by listed discount percentage.
-- ORDER BY ranks discounts; LIMIT returns the first 10 records.
SELECT
    Name,
    mrp,
    discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;


-- 5.2 High-MRP products currently marked out of stock.
-- Finds products with MRP above 300 and outOfStock = 1.
SELECT
    Name,
    mrp,
    outOfStock
FROM zepto
WHERE outOfStock = 1
  AND mrp > 300
ORDER BY mrp DESC;


-- 5.3 Estimated listed inventory value by category.
-- Formula: discounted selling price x available quantity.
-- This is NOT actual sales revenue.
SELECT
    Category,
    SUM(discountedSellingPrice * availableQuantity) AS estimated_inventory_value
FROM zepto
GROUP BY Category
ORDER BY estimated_inventory_value DESC;


-- 5.4 Products with MRP above 500 and discount below 10%.
SELECT
    Name,
    mrp,
    discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;


-- 5.5 Top five categories by average listed discount.
SELECT
    Category,
    AVG(discountPercent) AS average_discount_percent
FROM zepto
GROUP BY Category
ORDER BY average_discount_percent DESC
LIMIT 5;


-- 5.6 Discounted price per gram for products weighing at least 100g.
-- A lower unit price supports comparison, but does not prove
-- that a product is better value overall.
SELECT
    Name,
    discountedSellingPrice,
    weightGrams,
    ROUND(discountedSellingPrice / weightGrams, 2) AS price_per_gram
FROM zepto
WHERE weightGrams >= 100
  AND weightGrams > 0
ORDER BY price_per_gram ASC;


-- 5.7 Classify products by weight using CASE WHEN.
-- These are project-defined groups, not official logistics categories.
SELECT
    Name,
    weightGrams,
    CASE
        WHEN weightGrams < 1000 THEN 'Low'
        WHEN weightGrams < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM zepto;


-- 5.8 Estimated total available inventory weight by category.
-- Formula: available quantity x product weight in grams.
SELECT
    Category,
    SUM(availableQuantity * weightGrams) AS total_inventory_weight_grams
FROM zepto
GROUP BY Category
ORDER BY total_inventory_weight_grams DESC;


-- ============================================================
-- 06. ADDITIONAL BUSINESS INSIGHT 9
-- Question: Which categories have the highest stockout rates?
-- Purpose: Compare unavailable-product proportions by category.
-- ============================================================

-- Step 1: Count all products in each category.
SELECT
    Category,
    COUNT(*) AS total_products
FROM zepto
GROUP BY Category;

-- Step 2: Count out-of-stock products in each category.
SELECT
    Category,
    COUNT(*) AS out_of_stock_products
FROM zepto
WHERE outOfStock = 1
GROUP BY Category;

-- Step 3: Combine both counts and calculate the stockout rate.
-- COUNT(CASE WHEN ...) counts only non-NULL results from the CASE.
-- Stockout rate = out-of-stock products / total products x 100.
SELECT
    Category,
    COUNT(*) AS total_products,
    COUNT(CASE WHEN outOfStock = 1 THEN 1 END) AS out_of_stock_products,
    ROUND(
        COUNT(CASE WHEN outOfStock = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS stockout_rate_percentage
FROM zepto
GROUP BY Category
ORDER BY stockout_rate_percentage DESC;


-- ============================================================
-- 07. ADDITIONAL BUSINESS INSIGHT 10
-- Question: Are higher discounts associated with stock availability?
-- Purpose: Compare stockout rates across discount ranges.
-- ============================================================

-- CASE WHEN places products into discount groups.
-- Each group is compared by product count and stockout rate.
SELECT
    CASE
        WHEN discountPercent <= 10 THEN '0-10%'
        WHEN discountPercent <= 20 THEN 'Above 10-20%'
        WHEN discountPercent <= 30 THEN 'Above 20-30%'
        ELSE 'Above 30%'
    END AS discount_group,
    COUNT(*) AS total_products,
    COUNT(CASE WHEN outOfStock = 1 THEN 1 END) AS out_of_stock_products,
    ROUND(
        COUNT(CASE WHEN outOfStock = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS stockout_rate_percentage
FROM zepto
WHERE discountPercent IS NOT NULL
GROUP BY discount_group
ORDER BY
    CASE
        WHEN discount_group = '0-10%' THEN 1
        WHEN discount_group = 'Above 10-20%' THEN 2
        WHEN discount_group = 'Above 20-30%' THEN 3
        ELSE 4
    END;


-- ============================================================
-- 08. ADDITIONAL BUSINESS INSIGHT 11
-- Question: Do listed discounts agree with discounts calculated
--            from the actual prices?
-- Purpose: Compare the provided discount with a price-derived value.
-- ============================================================

-- Initial sample check: first 30 records with a positive MRP.
-- This is NOT a full-dataset validation.
SELECT
    Name,
    mrp,
    discountedSellingPrice,
    discountPercent AS listed_discount_percent,
    ROUND(
        ((mrp - discountedSellingPrice) * 100.0) / mrp,
        2
    ) AS calculated_discount_percent
FROM zepto
WHERE mrp > 0
LIMIT 30;


-- ============================================================
-- END OF PROJECT SCRIPT
-- ============================================================
