
# Brazilian E-Commerce Analytics

**SQL | PostgreSQL | Data Analysis | Customer Analytics | Business Intelligence**

## Project Overview

An end-to-end SQL analytics project exploring the Brazilian e-commerce marketplace using the Olist dataset.

The project analyzes transactional, customer, product, seller, payment, review, and delivery data to understand marketplace performance, customer purchasing behavior, product contribution, seller performance, and operational efficiency.

Using PostgreSQL, the raw relational datasets were loaded into an analytical database and explored through structured SQL queries to derive business insights and identify opportunities for improvement.

## Business Problem

E-commerce marketplaces generate large volumes of transactional data across customers, orders, products, sellers, payments, and logistics. However, analyzing these datasets independently makes it difficult to understand overall marketplace performance and identify factors affecting revenue, customer retention, and operational efficiency.

This project addresses the need to consolidate and analyze these interconnected datasets to answer key business questions:

- How is the marketplace performing in terms of revenue and order growth?
- What does customer purchasing behavior reveal about retention and customer value?
- Which product categories contribute most to marketplace revenue?
- How do sellers contribute to revenue, and how concentrated is marketplace performance?
- How efficiently are orders being delivered, and where do delivery delays occur?
- How do payment records reconcile with revenue calculated from order items?

## Project Objectives

1. Build a structured PostgreSQL analytical database from the Olist relational datasets.
2. Perform data profiling, validation, and relationship checks to assess data quality.
3. Develop SQL analyses to evaluate marketplace, customer, product, seller, and operational performance.
4. Apply customer segmentation techniques, including Recency, Frequency, and Monetary (RFM) analysis.
5. Reconcile item-level and payment-level revenue to investigate financial discrepancies.
6. Translate analytical findings into actionable business insights.

## Dataset

This project uses the **Brazilian E-Commerce Public Dataset by Olist**, which contains anonymized e-commerce transactions from a Brazilian online marketplace.

The dataset covers approximately 100K orders placed between 2016 and 2018 and includes information about customers, orders, products, sellers, payments, reviews, and delivery.

### Core Dataset Tables

| Table | Records | Description |
|---|---:|---|
| Customers | 99,441 | Customer identifiers and location details |
| Orders | 99,441 | Order status and purchase, approval, and delivery timestamps |
| Order Items | 112,650 | Products, sellers, prices, and freight per order item |
| Order Payments | 103,886 | Payment methods, values, and installments |
| Products | 32,951 | Product attributes and category information |
| Sellers | 3,095 | Seller identifiers and location details |
| Reviews | 99,224 | Customer review scores and timestamps |

### Supporting Datasets

| Dataset | Records | Main business information |
|---|---:|---|
| Geolocation | 1,000,163 | ZIP-code-level geographic coordinates and location information |
| Category Translation | 71 | Portuguese-to-English product category mappings |


### Data Model

The project uses the relationships between these tables to perform multi-table analysis.

Key relationships include:

- `orders` connects customers to their purchases through `customer_id`.
- `order_items` connects orders with products and sellers.
- `order_payments` connects payment transactions to orders.
- `order_reviews` connects customer reviews to orders.
- `customer_unique_id` identifies distinct customers across multiple orders.

The analysis uses PostgreSQL joins and aggregations to combine these datasets at the appropriate analytical level.

## Tools & Technologies

| Category | Tools / Concepts |
|---|---|
| Database | PostgreSQL |
| Query Language | SQL |
| Data Processing | Python, Pandas, SQLAlchemy |
| Development Environment | VS Code, Jupyter Notebook |
| Version Control | Git, GitHub, GitHub Desktop |

### SQL Concepts Applied

- Data validation and quality checks
- Multi-table JOINs
- Aggregate functions and GROUP BY
- Common Table Expressions (CTEs)
- CASE WHEN statements
- Window functions
- Subqueries and date-based analysis
- Revenue calculations and reconciliation
- Customer segmentation using RFM analysis

## Project Structure

```text
olist-analytics/
│
├── data/
│   └── raw/
│
├── etl/
│   ├── test_connection.py
│   ├── data_inventory.py
│   ├── column_inventory.py
│   ├── relationship_analysis.py
│   ├── key_analysis.py
│   ├── repeat_customer_analysis.py
│   ├── load_to_postgres.py
│   └── create_database.py
│
├── notebooks/
│   └── 01_business_understanding.ipynb
│
├── sql/
│   ├── 01_data_validation.sql
│   ├── 02_marketplace_overview.sql
│   ├── 03_customer_analytics.sql
│   ├── 04_01_create_rfm_views.sql
│   ├── 04_02_rfm_analysis.sql
│   ├── 05_product_analytics.sql
│   ├── 06_operations_analytics.sql
│   ├── 07_seller_analytics.sql
│   ├── 08_dashboard_queries.sql
│   └── 09_revenue_reconciliation.sql
│
├── app/
│
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

## Analysis & Methodology

The project was divided into the following analytical areas:

### 1. Data Validation & Quality Assessment

- Examined record counts, missing values, duplicate records, and key constraints.
- Validated primary and composite keys across the core datasets.
- Checked relationships between orders, customers, products, sellers, payments, and reviews.
- Investigated timestamp inconsistencies and missing delivery information.

### 2. Marketplace Performance Analysis

- Calculated total revenue, order volume, and Average Order Value (AOV).
- Analyzed monthly and yearly revenue and order trends.
- Evaluated year-over-year and like-for-like growth.
- Examined revenue distribution across the observation period.

### 3. Customer Analytics & RFM Segmentation

- Identified unique customers using `customer_unique_id`.
- Analyzed repeat purchasing behavior and customer revenue contribution.
- Evaluated customer recency, frequency, and monetary value.
- Developed RFM-based customer segments to identify high-value, promising, and at-risk customers.

### 4. Product & Category Analytics

- Evaluated revenue contribution by product category.
- Identified top-performing products by revenue and sales volume.
- Compared product revenue contribution with quantity sold.
- Examined average product prices across categories.

### 5. Operations & Delivery Analytics

- Evaluated average delivery duration and on-time delivery performance.
- Identified late deliveries and calculated delivery delays.
- Compared delivery performance across customer states.
- Investigated regional differences in logistics performance.

### 6. Seller Performance Analytics

- Analyzed seller revenue contribution and sales distribution.
- Evaluated revenue concentration among top-performing sellers.
- Examined customer review scores associated with seller orders.

### 7. Dashboard-Oriented SQL Analysis

- Developed consolidated SQL queries for key marketplace KPIs.
- Prepared analytical outputs for business overview, customer, product, seller, and operations reporting.

### 8. Revenue Reconciliation

- Compared delivered revenue calculated from order items against delivered payment records.
- Investigated orders with missing payment records.
- Identified order-level revenue differences using a tolerance of R$0.01.
- Quantified positive, negative, and net revenue differences.

## Key Business Findings

The SQL analysis revealed the following insights:

### Marketplace Performance

- Total recorded payment revenue across all order statuses was approximately R$16.01 million, covering 99,441 orders.
- Order-level AOV was approximately **R$160.99** for orders with payment records.
- November 2017 recorded the highest observed monthly revenue.
- Comparing January–August 2018 with the same period in 2017, revenue increased by approximately **136.96%**, while order volume increased by **135.07%**.

### Customer Behavior

- Identified **96,096 unique customers**.
- Overall repeat-customer rate was approximately **3.12%**.
- RFM segmentation highlighted an opportunity to improve customer retention and re-engagement.
- Hibernating and Promising customers together represented approximately **77.37%** of the analyzed RFM segments.

### Product Performance

- Health & Beauty contributed approximately **9.33%** of category revenue.
- Watches & Gifts contributed approximately **8.82%**.
- Bed Bath & Table contributed approximately **7.74%**.
- The top 10 product categories accounted for approximately **56.05%** of category revenue.

### Delivery & Operational Performance

- Analyzed **96,478 delivered orders**.
- Average delivery duration was approximately **12.56 days**.
- Approximately **91.88%** of analyzed delivered orders were delivered on time.
- Late deliveries represented approximately **8.11%** of the analyzed delivered orders.

### Seller Performance

- The top 10 sellers contributed approximately **12.93%** of seller revenue.
- The top 100 sellers contributed approximately **44.81%**.
- The top 551 sellers contributed approximately **80.01%**.

### Revenue Reconciliation

- Delivered item-based revenue was **R$15,419,773.75**.
- Delivered payment-based revenue was **R$15,422,461.77**.
- The net difference between the two revenue calculations was **R$2,688.02**, with payment-based revenue higher.
- One delivered order had no corresponding payment record.
- Among orders with both item and payment records, 286 had higher payment values and 88 had lower payment values than their item-based totals, using a R$0.01 matching tolerance.

## Technical Approach

The project followed a structured analytics workflow:

1. **Business Understanding:** Identified marketplace performance, customer behavior, and operational questions.
2. **Data Profiling:** Examined dataset structure, column attributes, record counts, and relationships.
3. **Data Validation:** Performed integrity checks and investigated data quality issues.
4. **Database Preparation:** Loaded the relational datasets into PostgreSQL for analytical querying.
5. **SQL Analysis:** Developed modular SQL scripts for each business domain.
6. **Analytical Validation:** Cross-checked calculations, investigated discrepancies, and validated KPI definitions.
7. **Business Interpretation:** Converted analytical findings into business insights and potential improvement opportunities.

## Data Considerations & Limitations

- The dataset contains historical marketplace transactions from 2016–2018 and does not represent real-time business activity.
- The 2016 and 2018 observation periods are incomplete. Annual comparisons should therefore be interpreted carefully.
- Customer identity analysis uses `customer_unique_id` because `customer_id` represents an order-specific customer record.
- Revenue calculations differ depending on whether they use payment records or order-item prices and freight.
- Delivered-order dashboard metrics use a different scope from the all-status marketplace overview.
- Missing timestamps and inconsistencies in source records may affect certain operational metrics.
- Revenue discrepancies identified during reconciliation were quantified, but the underlying cause of every discrepancy was not established.
- Seller-associated review scores indicate reviews linked to seller orders and should not be interpreted as proof of seller causation.

## How to Run

### Prerequisites

- Python
- PostgreSQL
- VS Code
- Git

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/jahnavi1473/Data-Portfolio.git
   ```

2. Navigate to the project directory:

   ```bash
   cd Data-Portfolio/olist-analytics
   ```

Download the Brazilian E-Commerce Public Dataset by Olist and extract the nine CSV files into the data/raw/ directory.

3. Create and activate a Python virtual environment:

   ```bash
   python -m venv venv
   ```

4. Install the required dependencies:

   ```bash
   pip install -r requirements.txt
   ```

5. Configure PostgreSQL connection details using the environment variable structure documented in `.env.example`.

6. Prepare the PostgreSQL database and load the Olist datasets using the scripts in the `etl/` directory.

7. Execute the SQL scripts in the `sql/` directory using PostgreSQL-compatible SQL tools. Run the RFM view creation script before the RFM analysis script.

## Future Enhancements

- Develop an interactive Power BI dashboard using the completed SQL analysis.
- Create a consolidated business KPI reporting layer.
- Explore customer retention strategies using RFM segments.
- Extend delivery analysis with more detailed regional performance reporting.
- Investigate the underlying causes of order-level revenue discrepancies.
- Explore predictive analytics for customer retention and delivery performance.

## Conclusion

This project demonstrates a business-oriented approach to analyzing a relational e-commerce dataset using PostgreSQL and SQL.

By combining data validation, marketplace analytics, customer segmentation, product performance, seller analysis, operational metrics, and revenue reconciliation, the project provides a structured view of marketplace performance.

The analysis highlights opportunities related to customer retention, product contribution, seller concentration, delivery efficiency, and financial data consistency.

The project demonstrates practical SQL skills, relational data analysis, analytical problem-solving, and the ability to translate raw transactional data into meaningful business insights.

---

## Author

**Jahnavi Rangasai Parimi**

Data Analytics | SQL | PostgreSQL | Business Intelligence

[GitHub Profile](https://github.com/jahnavi1473/Data-Portfolio)
