# E-Commerce Customer Intelligence & Retention Analysis

## Project Overview

This project uses PostgreSQL and SQL to analyze e-commerce transactions, customer purchasing behavior, product performance, payment methods, delivery performance, and customer satisfaction.

Using the Brazilian Olist e-commerce dataset, the project transforms raw relational data into business insights that can help an e-commerce business understand its revenue drivers, identify customer retention patterns, evaluate delivery performance, and assess customer experience.

The analysis focuses on answering practical business questions through SQL queries, data validation, aggregations, joins, and window functions.

## Business Problem

E-commerce businesses need to understand not only how much revenue they generate, but also how customers purchase, which product categories perform well, whether orders arrive on time, and how customers evaluate their experience.

This project investigates these areas using transactional data to identify patterns and highlight potential opportunities for improving customer retention and operational performance.

## Project Objectives

- Analyze monthly revenue and order volume.
- Identify top-performing product categories by revenue.
- Examine customer repeat-purchase behavior and purchase frequency.
- Evaluate delivery performance and late-delivery rates.
- Compare payment methods by transaction volume and payment value.
- Analyze customer review scores and overall satisfaction.
- Evaluate seller performance and rank sellers within each state.
- Identify high-value customers based on recorded payment values.
- Validate data quality, row counts, primary keys, and relationships between tables.

## Tools & Technologies

- **Database:** PostgreSQL 17
- **SQL Environment:** pgAdmin 4
- **Languages:** SQL
- **Key SQL Concepts:** Joins, aggregations, Common Table Expressions (CTEs), subqueries, window functions, ranking, date-based analysis, data validation, and constraints


## Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist. The dataset contains e-commerce order, customer, product, seller, payment, review, and geographic information.

The project uses nine relational tables:

| Table | Description |
|---|---|
| `customers` | Customer identifiers and location details |
| `orders` | Order status and purchase, approval, and delivery timestamps |
| `order_items` | Products purchased, seller identifiers, prices, and freight values |
| `order_payments` | Payment methods, installments, and payment values |
| `order_reviews` | Customer review information and scores |
| `products` | Product identifiers, categories, and physical attributes |
| `sellers` | Seller identifiers and location details |
| `geolocation` | Geographic coordinates associated with postal-code prefixes |
| `product_category_translation` | Product category names translated into English |

## Project Structure

```text
SQL Project/
├── data/
│   └── raw/
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_data_validation.sql
│   ├── 03_row_count_validation.sql
│   ├── 04_business_analysis.sql
│   └── 05_schema_updates.sql
├── results/
└── README.md
```

## Analysis Workflow

1. **Database setup:** Create the tables and define the required data types and relationships.
2. **Data validation:** Check missing values, duplicate identifiers, and unmatched relationships.
3. **Row-count validation:** Confirm that the imported tables contain the expected data.
4. **Schema updates:** Apply the composite primary key to the `order_reviews` table.
5. **Business analysis:** Execute SQL queries to study revenue, customers, products, payments, delivery performance, reviews, and sellers.
6. **Documentation:** Record the key findings, metric definitions, and limitations of the analysis.


## Key Business Findings & Insights

### 1. Revenue and Order Trends
- November 2017 recorded approximately **R$1.01 million in product revenue** across 7,451 distinct orders.
- The dataset covers September 2016 to September 2018. The first and last months contain very few orders, so they should be treated as partial periods when comparing monthly performance.

### 2. Top Product Categories
The leading product categories by product revenue included:

| Product Category | Product Revenue |
|---|---:|
| Health & Beauty | R$1,258,681.34 |
| Watches & Gifts | R$1,205,005.68 |
| Bed Bath & Table | R$1,036,988.68 |
| Sports & Leisure | R$988,048.97 |
| Computers & Accessories | R$911,954.32 |

**Insight:** Health & Beauty and Watches & Gifts were the highest-revenue categories in this analysis. These categories could be investigated further for inventory planning and category-level marketing decisions.

### 3. Customer Retention and Repeat Purchases
- Unique customers analyzed: **96,096**
- Customers with one order: **93,099**
- Customers with repeat purchases: **2,997**
- Repeat-purchase rate: **3.12%**

**Insight:** Repeat purchases account for a relatively small share of unique customers under this project's definition. This suggests an opportunity to investigate customer retention strategies, while recognizing that the dataset's observation period and customer identification method may affect the result.

### 4. Delivery Performance
- Delivered orders analyzed: **96,470**
- Orders delivered after the estimated date: **7,826**
- On-time or early deliveries: **88,644**
- Late-delivery rate: **8.11%**
- Average delivery duration: **12.56 days**

**Insight:** Most analyzed orders arrived on or before the estimated delivery date. Further analysis could examine whether late deliveries vary by seller, customer location, product category, or order period.

### 5. Payment Method Analysis
Credit cards accounted for the largest recorded payment value, at approximately **R$12.54 million**, followed by boleto payments at approximately **R$2.87 million**.

**Insight:** Credit cards were the dominant payment method by recorded payment value. Payment-record totals should be interpreted carefully because an order may have multiple payment records.

### 6. Customer Purchase Frequency
Customers were grouped according to their number of orders:

| Customer Segment | Customers | Share of Customers |
|---|---:|---:|
| One-time | 93,099 | 96.88% |
| Occasional (2–3 orders) | 2,948 | 3.07% |
| Frequent (4+ orders) | 49 | 0.05% |

Average recorded customer payment value increased across the segments:
- One-time customers: **R$161.82**
- Occasional customers: **R$307.14**
- Frequent customers: **R$787.13**

**Insight:** Customers with more orders had higher average total payment values in this analysis. This is an association, not proof that increasing purchase frequency will cause a particular increase in spending.

### 7. Data Quality and Validation
- Primary-key duplicate checks were completed for the customers, orders, products, and sellers tables.
- Relationship checks were performed between orders and customers, order items and their related tables, and payments and orders.
- Missing values were checked for selected important fields.
- A composite primary key was added to `order_reviews` using `review_id` and `order_id`.

**Insight:** Data validation helps make the business analysis more reliable. The checks documented here cover specific fields and relationships; they do not guarantee that every possible data-quality issue has been eliminated.

## Notes on Interpretation

- Revenue figures represent product revenue based on the `order_items` price field, unless otherwise specified. They should not automatically be interpreted as profit or total customer spending.
- Customer purchase frequency is based on distinct orders grouped by customer identifier.
- Payment analysis uses recorded payment values, which may include multiple payment records for one order.
- The first and last months in the dataset may be incomplete and should be interpreted cautiously.
- Findings describe the dataset analyzed and should not be assumed to represent every e-commerce business.


## How to Run the Project

### Prerequisites
- PostgreSQL 17 or a compatible PostgreSQL version
- pgAdmin 4
- The Olist dataset files used by this project

### Setup and Execution

1. Create a PostgreSQL database named `ecommerce_analytics`.
2. Open pgAdmin 4 and connect to the database.
3. Execute the SQL scripts in the following order:

| Script | Purpose |
|---|---|
| `01_create_tables.sql` | Create the database tables |
| `02_data_validation.sql` | Check data quality and relationships |
| `03_row_count_validation.sql` | Validate table row counts |
| `04_business_analysis.sql` | Run the business analysis queries |
| `05_schema_updates.sql` | Apply documented schema changes, if not already applied |

**Note:** Run `05_schema_updates.sql` only if its changes have not already been applied. If the composite primary key on `order_reviews` is already present, do not execute the same `ALTER TABLE` statement again.

## Limitations

- The analysis is based on the available historical dataset and may not reflect current e-commerce trends.
- Customer repeat-purchase rates depend on the dataset's observation period and customer identifier.
- Revenue calculated from item prices does not represent profit because business costs and other expenses are not included.
- Payment-record totals can differ from order counts because an order may have multiple payment records.
- Data validation checks cover selected fields and relationships rather than every possible data-quality issue.

## Future Improvements

- Create a Power BI or Tableau dashboard for interactive business reporting.
- Perform cohort analysis to investigate customer retention over time.
- Analyze delivery delays by seller, location, and product category.
- Develop customer segmentation using RFM (Recency, Frequency, Monetary) analysis.
- Explore customer lifetime value and factors associated with repeat purchases.

## Conclusion

This project demonstrates how PostgreSQL and SQL can be used to transform relational e-commerce data into business insights. It covers data validation, revenue analysis, customer purchasing behavior, delivery performance, payment methods, customer reviews, and seller performance.

The project provides a foundation for further work in data analytics, customer retention analysis, and business intelligence.