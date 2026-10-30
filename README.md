# Zepto Inventory & Product Analysis
### SQL Data Exploration, Data Cleaning, Transformation and Business Analysis

**Project Type:** Exploratory Data Analysis  
**Database:** MySQL 8.0  
**SQL Environment:** MySQL Workbench  
**Dataset:** Zepto Product and Inventory Dataset  
**Project Reference:** Amlan Mohanty's Data Analytics Portfolio Project Tutorial  
**Additional Analysis:** Three independently explored SQL business questions

---

## 1. Project Overview

This project focuses on analysing a Zepto product and inventory dataset using MySQL.

The objective was to understand the dataset, identify data-quality issues, perform necessary cleaning and transformation, and use SQL to investigate product pricing, discounts, inventory availability and category-level patterns.

The project follows these stages:

1. Database creation and CSV import
2. Data exploration
3. Data quality checks
4. Data cleaning and transformation
5. SQL-based product and inventory analysis
6. Additional business insight exploration
7. Interpretation and documentation of findings

## 2. Dataset Description

The dataset contains product-level information.

| Column | Description |
|---|---|
| sku_id | Unique identifier generated for each imported record |
| Category | Product category |
| Name | Product name |
| mrp | Maximum Retail Price |
| discountPercent | Listed discount percentage |
| availableQuantity | Available product quantity |
| discountedSellingPrice | Discounted selling price |
| weightGrams | Product weight in grams |
| outOfStock | Stock availability indicator |
| quantity | Product quantity information |

**Important:** Repeated product names do not automatically indicate duplicate records. Different package sizes or product variants may have the same name but different SKUs.

## 3. Database Creation and Table Structure

Created the database:

`CREATE DATABASE zepto_sql_project;`

Selected the database using:

`USE zepto_sql_project;`

Created a table with suitable data types for product names, categories, prices, quantities and stock status.

### Why was this step necessary?

A relational database provides a structured environment for storing and querying data. Selecting appropriate data types helps SQL interpret and process the information correctly.

### Advantages

- Structured data storage.
- Easier filtering and aggregation.
- Better handling of numerical and categorical information.
- Supports repeatable analysis.

### Considerations

- Incorrect data types can cause import or calculation issues.
- Numeric precision should be suitable for financial values.
- An automatically generated SKU identifier represents an imported record, not necessarily the original product identifier.


## 4. CSV Data Import

Imported the CSV file using MySQL's `LOAD DATA INFILE` statement.

The import specified:

- The file location.
- Comma-separated fields.
- Double quotes around enclosed values.
- The header row to skip.
- The column mapping.
- A transformation of the source stock-status value into a Boolean-style indicator.

The import mapped `FALSE` to `0` and other values to `1` through the `IF()` expression.

### Why?

The source CSV needs to be converted into structured table records before SQL analysis can begin.

### Advantages

- Efficient import of a large number of records.
- Avoids manual row-by-row insertion.
- Allows source columns to be mapped to database columns.

### Considerations

The import expression treats every non-`FALSE` value as `1`. If the source contains unexpected text or blank values, these should be checked separately rather than automatically assumed to mean true.


## 5. Data Exploration

Data exploration was performed before cleaning or changing the dataset.

### 5.1 Inspecting records

Used `SELECT *` and `LIMIT` to inspect the complete table structure and sample records.

**Why?** To understand the available columns, data formats and example values.

### 5.2 Counting records

Used `COUNT(*)` to determine the total number of imported records.

**Why?** The total record count provides a baseline for understanding the dataset and checking the effect of later cleaning operations.

### 5.3 Checking NULL values

Used `IS NULL` conditions across the important columns.

**Why?** Missing values can affect calculations, comparisons and grouping.

**Advantage:** Helps identify incomplete records before analysis.

**Limitation:** A NULL check does not identify all data-quality problems. Zero prices, invalid categories and incorrect units require separate checks.

### 5.4 Identifying categories

Used `SELECT DISTINCT(Category)` to identify the different product categories.

**Why?** This helps understand the categorical structure of the dataset and the groups that can be analysed later.

### 5.5 Comparing stock availability

Grouped records by `outOfStock` and counted the associated SKUs.

**Why?** To understand the overall distribution of available and unavailable products.

### 5.6 Investigating repeated product names

Used `GROUP BY Name` with `COUNT(sku_id)` and `HAVING` to find names appearing more than once.

**Why?** To investigate repeated product names and understand whether they represent multiple SKUs or product variants.

**Important:** Repeated names were not automatically deleted because a repeated product name does not necessarily mean a duplicate product record.


## 6. Data Cleaning and Transformation

### 6.1 Identifying zero-price records

Used conditions to identify records where either MRP or discounted selling price was zero.

**Why?** Zero-price records may affect average prices, discount calculations and price-based analysis.

The cleaning script subsequently deleted records where `mrp = 0`.

**Consideration:** The initial investigation also checked zero discounted selling prices, but the deletion statement shown in the project only removed zero-MRP records. Zero selling-price records should be investigated separately before deciding how to handle them.

### 6.2 Price conversion: paise to rupees

Updated the price columns by dividing MRP and discounted selling price by 100.

**Why?** The source values were treated as paise, so conversion was necessary to make the prices readable and interpretable in rupees.

**Advantage:** Makes price comparisons and financial calculations easier to understand.

**Limitation:** This transformation depends on the source unit being paise. It should be applied only once; running the update repeatedly would incorrectly reduce the prices again.

### 6.3 Safe update mode

Temporarily disabled MySQL safe-update restrictions to perform the cleaning update and delete operations.

**Why?** MySQL Workbench can restrict certain UPDATE and DELETE operations when safe-update mode is enabled.

**Consideration:** Safe-update mode is a protective feature. Disabling it should be done carefully, ideally after reviewing the affected records and keeping a backup or raw copy.

**[SCREENSHOT PLACEHOLDER: Zero-price investigation and price conversion]**

## 7. SQL Analysis: Original Project Questions

### 7.1 Top 10 products by discount percentage

**SQL concepts:** `SELECT`, `ORDER BY`, `DESC`, `LIMIT`.

**Purpose:** Identify the products with the highest listed discount percentages.

**Why this matters:** Helps compare promotional discounts across products.

**Limitation:** A high discount percentage does not automatically mean a product is the cheapest or offers the best value. MRP and selling price should also be considered.

### 7.2 High-MRP products that are out of stock

**SQL concepts:** `WHERE`, `AND`, `ORDER BY`.

**Purpose:** Identify products with MRP above ₹300 that are marked out of stock.

**Why this matters:** Highlights higher-priced unavailable products that may deserve further investigation.

**Limitation:** MRP alone does not indicate sales importance, profitability or customer demand.

### 7.3 Estimated inventory value by category

**SQL concepts:** `SUM()`, multiplication, `GROUP BY`, `ORDER BY`.

**Calculation:**

`SUM(discountedSellingPrice * availableQuantity)`

**Purpose:** Estimate the listed selling-price value of available inventory within each category.

**Why this matters:** Provides a category-level view of the estimated monetary value of current inventory.

**Important distinction:** This is estimated inventory value, not actual sales revenue. The dataset does not provide completed sales transactions.

### 7.4 Products with MRP above ₹500 and discounts below 10%

**SQL concepts:** `WHERE`, comparison operators, `AND`, `ORDER BY`.

**Purpose:** Identify relatively expensive products with low listed discounts.

**Why this matters:** Helps investigate products that have a higher listed price but offer a comparatively small discount.

**Limitation:** It does not establish whether these products are overpriced or less attractive to customers.

### 7.5 Top five categories by average discount

**SQL concepts:** `AVG()`, `GROUP BY`, `ORDER BY`, `LIMIT`.

**Purpose:** Calculate and rank categories according to their average listed discount.

**Why this matters:** Makes it possible to compare discount patterns between categories.

**Limitation:** An average can hide differences between individual products. Category sizes should also be considered.

### 7.6 Price per gram

**SQL concepts:** Arithmetic calculations, `ROUND()`, `WHERE`, `DISTINCT`, `ORDER BY`.

**Calculation:**

`discountedSellingPrice / weightGrams`

**Purpose:** Compare the discounted price relative to product weight for products weighing at least 100 grams.

**Why this matters:** Helps compare the relative price of products with different weights.

**Limitation:** Price per gram is not a complete measure of product value. Product quality, brand, packaging and product type may differ.

### 7.7 Product weight classification

**SQL concepts:** `CASE WHEN`.

Created three weight groups:

- Low: below 1,000 grams
- Medium: 1,000 to below 5,000 grams
- Bulk: 5,000 grams and above

**Purpose:** Categorise products according to their weight.

**Why this matters:** Makes weight-based comparisons and future grouping easier.

**Limitation:** These are analytical categories selected for this project, not official logistics or warehouse classifications.

### 7.8 Total inventory weight by category

**SQL concepts:** `SUM()`, multiplication, `GROUP BY`, `ORDER BY`.

**Calculation:**

`SUM(availableQuantity * weightGrams)`

**Purpose:** Estimate the total weight of available inventory in each category.

**Why this matters:** Provides a category-level estimate that could help support further storage and logistics analysis.

**Limitation:** It assumes the recorded available quantity and product weight are accurate. It does not include packaging weight or other warehouse factors.

## 8. Additional Business Insights Explored Independently

The following three questions were explored as additional SQL practice beyond the initial tutorial workflow.

### Insight 9 — Which categories have the highest stockout rates?

**Business question:**

Which categories have the highest proportion of products marked out of stock?

**SQL concepts:**

- `COUNT(*)`
- Conditional aggregation using `CASE WHEN`
- `GROUP BY`
- `ROUND()`
- Percentage calculation

**Calculation:**

`Out-of-stock products / Total products × 100`

**Why did I calculate a percentage instead of only counting out-of-stock products?**

Categories can have very different numbers of products. A category with more products may naturally have a larger out-of-stock count.

Stockout percentage provides a more useful comparison of the proportion unavailable within each category.

**Advantage:** Makes category-level comparisons more meaningful.

**Limitation:** A high stockout rate does not explain why the products are unavailable or how long they have been out of stock.

**[SCREENSHOT PLACEHOLDER: Actual category-wise stockout results]**

### Insight 10 — Are higher discounts associated with stock availability?

**Business question:**

Do products with higher discounts have higher or lower stockout rates?

**Approach:**

Used `CASE WHEN` to group discount percentages into:

- 0–10%
- 11–20%
- 21–30%
- Above 30%

Then calculated the total products, out-of-stock products and stockout percentage within each group.

**Why did I create discount groups?**

Grouping makes it easier to compare broader discount levels instead of examining many individual discount percentages.

**Actual results:**

| Discount group | Total products | Out of stock | Stockout rate |
|---|---:|---:|---:|
| 0–10% | 2,919 | 399 | 13.67% |
| 11–20% | 579 | 38 | 6.56% |
| 21–30% | 146 | 5 | 3.42% |
| Above 30% | 87 | 11 | 12.64% |

**Finding:**

The stockout rate does not consistently increase as the discount level increases.

The 0–10% group has the highest stockout rate at 13.67%, while the 21–30% group has the lowest at 3.42%. The above-30% group rises again to 12.64%.

**Advantage:** Provides a way to investigate whether discount groups and stock availability vary together.

**Limitation:** The result shows an association in a dataset snapshot. It cannot establish that discounts cause stockouts. Group sizes also differ considerably, so the smaller groups should be interpreted carefully.



### Insight 11 — Do listed discounts agree with discounts calculated from actual prices?

**Business question:**

Does the listed discount percentage match the percentage calculated using MRP and discounted selling price?

**Calculation:**

`((MRP - Discounted Selling Price) / MRP) * 100`

**SQL concepts:**

- Arithmetic calculations
- `ROUND()`
- `WHERE`
- Calculated columns
- Comparison of numerical values

**Why did I calculate a new discount percentage?**

The dataset already contains a discount percentage. Calculating it independently from the two price columns allows us to compare the two values and investigate potential inconsistencies.

**Example from the initial sample:**

| Product | Listed discount | Calculated discount |
|---|---:|---:|
| Onion | 16% | 16.00% |
| Tomato Hybrid | 16% | 16.67% |
| Tender Coconut | 15% | 15.69% |
| Coriander Leaves | 15% | 15.00% |

**Finding so far:**

Some values match exactly, while others differ. These differences may be related to how the source calculates or rounds its listed discount.

**Advantage:** Helps investigate the consistency of pricing-related fields.

**Limitation:** The initial query uses `LIMIT 30`, so it is only a sample-based investigation. A full-dataset comparison and an appropriate tolerance for rounding differences are required before making an overall conclusion about pricing accuracy.



## 9. Overall Learning Outcomes

Through this project, I practised:

- Creating databases and structured tables.
- Importing CSV data into MySQL.
- Selecting suitable data types.
- Exploring records and checking missing values.
- Investigating repeated product names.
- Cleaning and transforming numerical data.
- Working with aggregate functions.
- Applying filtering and sorting conditions.
- Using `GROUP BY` and `HAVING`.
- Creating conditional calculations using `CASE WHEN`.
- Calculating percentages and derived metrics.
- Comparing numerical values to investigate possible data inconsistencies.
- Interpreting analytical results with appropriate limitations.

The biggest learning was understanding that a SQL query should have a purpose. The result needs to be interpreted in the context of the dataset and the business question.

## 10. Project Limitations

The dataset is a product and inventory snapshot rather than a transaction-level sales dataset.

Therefore, this project cannot independently calculate:

- Actual sales revenue.
- Profit margins.
- Sales velocity.
- Historical stockout duration.
- Customer demand over time.
- The reasons behind stock shortages.

The inventory value calculations are estimates based on listed selling prices and available quantities.

The discount analysis shows observed patterns, not cause-and-effect relationships.

## 11. Future Improvements

Potential next steps include:

1. Complete the discount consistency comparison across the entire dataset.
2. Investigate zero discounted selling prices separately.
3. Cross-check important calculations independently.
4. Build a Power BI dashboard if the project scope is expanded.
5. Compare SQL results with Python-based analysis in a future end-to-end project.

## 12. Tools and Technologies

- MySQL 8.0
- MySQL Workbench
- SQL
- CSV dataset
- Gamma AI for presentation organisation and visual design

## 13. Learning Resource and Acknowledgement

Credit to **Amlan Mohanty** for the YouTube tutorial:

*COMPLETE Data Analytics Portfolio Project in 6 EASY Steps | Python + SQL + Power BI.*

The tutorial was used as a learning reference for understanding the project workflow. The three additional business questions documented in Section 8 were explored separately as part of my own SQL practice.

Gamma AI was used to assist with organising the project presentation. The analysis and findings are based on the SQL work documented in this repository.

---

**Project status:** SQL exploration, cleaning and core analysis completed. Further validation of the discount comparison remains a possible improvement.
