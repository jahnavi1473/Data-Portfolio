# Retail Sales Analytics & Power BI Dashboard

## 📊 Project Overview

This project analyzes **541,000+ retail transactions** from the Online Retail dataset to understand sales performance, product trends, geographic distribution, and customer purchasing behavior.

The project transforms raw transactional data into a structured **PostgreSQL data warehouse using a Star Schema** and connects it to an interactive **3-page Power BI dashboard** for business analysis.

### Key Business Outcomes

- 💰 Generated **£10.06M** in total revenue across **24,156 orders**.
- 🛍️ Sold **5.38M+ units** across the analyzed transactions.
- 👥 Identified **4,363 customers** with available Customer IDs.
- 📊 Calculated an overall **Average Order Value of £416.58**.
- 🇬🇧 The **United Kingdom is the dominant market** by order volume and revenue contribution.
- 📈 **November 2011** was the strongest revenue month, generating approximately **£1.48M**.
- 🏆 **REGENCY CAKESTAND 3 TIER** generated the highest product revenue at approximately **£164.8K**.
- 📦 **SMALL POPCORN HOLDER** was the highest-selling product by quantity, with **56,450 units sold**.
- ⚠️ Transactions with missing Customer IDs generated **£1.70M**, representing **16.87% of total revenue**, demonstrating why unidentified transactions should not simply be removed from revenue analysis.

---

## 🚀 Business Problem & Solution

| Business Problem | Solution |
| :--- | :--- |
| Raw transactional data contained cancellations, invalid records, missing customer IDs, and non-product transactions. | Cleaned and transformed the dataset using **PostgreSQL SQL**. |
| Revenue analysis could be distorted if transactions with missing Customer IDs were removed. | Preserved unidentified transactions and labeled them as **"Unknown Customer"** for customer-level analysis. |
| Raw transactional data was difficult to analyze efficiently. | Designed a **Star Schema data warehouse** with fact and dimension tables. |
| Business users needed a consolidated view of sales performance. | Built a **3-page interactive Power BI dashboard** covering business, product, and customer performance. |
| Product analysis needed to distinguish actual products from non-product transactions. | Classified transactions into **Product, Shipping, Gift Voucher, and Sample** categories and excluded non-product transactions from product-level analysis. |

---

## 🛠️ Tech Stack

- **Database:** PostgreSQL
- **Visualization:** Microsoft Power BI
- **Languages:** SQL
- **Analytics:** Aggregations, JOINs, CASE statements, Window Functions
- **Data Modeling:** Star Schema
- **BI:** Power BI Data Modeling & DAX
- **Data Preparation:** SQL-based ETL and data cleaning

---

## 🧹 Data Cleaning & Preparation

The raw Online Retail dataset contained **541,000+ transaction records**.

Data preparation was performed in PostgreSQL before analysis.

### Key Cleaning Steps

- **Removed cancelled transactions** where `InvoiceNo` begins with `C`.
- **Filtered invalid records** and non-standard transaction codes.
- **Calculated revenue** using:

```sql
Quantity * UnitPrice
```

- **Standardized Stock Codes** using uppercase formatting.
- **Preserved transactions with missing Customer IDs** instead of removing their revenue.
- Labeled missing Customer IDs as **"Unknown Customer"** in customer-level analysis.
- Classified transaction types to distinguish:
  - Product
  - Shipping
  - Gift Voucher
  - Sample

### Important Data Treatment

Customer-level metrics only include transactions with identified Customer IDs.

However, **overall revenue, order, and unit metrics include valid transactions from both identified and unidentified customers**.

This prevents the loss of legitimate revenue simply because a Customer ID was unavailable.

---

## 🏗️ Data Warehouse Design

A **Star Schema** was implemented to organize the transactional data for analytical reporting.

### Fact Table

**`fact_sales`**

Contains transactional-level business metrics:

- InvoiceNo
- StockCode
- CustomerID
- Country
- Order Date
- Quantity
- Unit Price
- Revenue

### Dimension Tables

**`dim_product`**

- StockCode
- Product Name
- Product Type

**`dim_customer`**

- CustomerID
- Customer information

**`dim_country`**

- Country

**`dim_date`**

- Order Date
- Day
- Month
- Year

### Simplified Architecture

```text
                  dim_product
                       |
                       |
dim_customer ---- fact_sales ---- dim_country
                       |
                       |
                    dim_date
```

This structure separates transactional measures from descriptive attributes and supports efficient Power BI analysis.

---

# ❓ Business Questions & Answers

## 1. How much revenue did the business generate?

**Answer:** The analyzed transactions generated **£10.06M in total revenue** across **24,156 orders**.

The overall Average Order Value was approximately **£416.58**.

---

## 2. How important are unidentified customers?

A significant amount of revenue comes from transactions where Customer ID is unavailable.

| Customer Status | Orders | Revenue | Revenue Share |
| :--- | ---: | ---: | ---: |
| Identified Customer | 21,906 | £8,365,279.92 | 83.13% |
| Unknown Customer | 2,250 | £1,697,541.50 | 16.87% |
| **Total** | **24,156** | **£10,062,821.42** | **100%** |

### Business Insight

Approximately **£1.70M (16.87%) of revenue** is associated with unidentified customers.

Therefore, removing NULL Customer IDs before calculating total revenue would have resulted in a significant understatement of business performance.

---

## 3. When are sales highest?

**November 2011** was the strongest month in the dataset, generating approximately:

**£1.48M in revenue**

This makes November an important period for inventory planning, sales preparation, and marketing activity.

---

## 4. Which products generate the most revenue?

Product-level analysis excludes non-product transactions such as Shipping, Gift Vouchers, and Samples.

### Top Products by Revenue

| Product | Revenue |
| :--- | ---: |
| REGENCY CAKESTAND 3 TIER | £164,762.19 |
| WHITE HANGING HEART T-LIGHT HOLDER | £99,846.98 |
| PARTY BUNTING | £98,302.98 |
| JUMBO BAG RED RETROSPOT | £92,356.03 |
| RABBIT NIGHT LIGHT | £66,756.59 |

**REGENCY CAKESTAND 3 TIER** was the highest-revenue product.

---

## 5. Which products sell the highest volume?

The highest-selling product by quantity was:

**SMALL POPCORN HOLDER — 56,450 units**

Other high-volume products included:

- WORLD WAR 2 GLIDERS ASSTD DESIGNS
- JUMBO BAG RED RETROSPOT
- WHITE HANGING HEART T-LIGHT HOLDER
- ASSORTED COLOUR BIRD ORNAMENT

This demonstrates that **high sales volume and high revenue are not necessarily the same thing**, making both metrics important for product analysis.

---

## 6. Which customers generate the most revenue?

The highest-value identified customer was:

**Customer 14646 — £279,801.02**

Other high-value customers included:

- Customer 18102 — £259,657.30
- Customer 17450 — £188,797.13
- Customer 14911 — £128,882.13
- Customer 12415 — £123,725.45

These customers represent potential targets for retention and loyalty initiatives.

---

## 7. Which markets contribute most to sales?

The **United Kingdom** is the dominant market in the dataset by order volume and revenue contribution.

The dashboard provides a geographic view of revenue distribution across countries, allowing the business to identify its strongest markets and evaluate opportunities for international expansion.

---

# 📊 Power BI Dashboard

The final solution consists of **3 interactive Power BI pages**.

## 1️⃣ Business Overview

Provides a high-level view of overall business performance.

### KPIs

- Total Revenue — **£10.06M**
- Total Orders — **24.2K**
- Total Customers — **4.36K**
- Average Order Value — **£416.58**
- Total Units Sold — **5.38M**

### Visuals

- Monthly Revenue Trend
- Top Products by Revenue
- Revenue by Country

---

## 2️⃣ Product Performance

Analyzes product-level sales performance.

### Visuals

- Revenue Distribution by Product Type
- Top 10 Products by Units Sold
- Product Sales Details
- Product Revenue vs Sales Volume
- Sales Volume by Product Type

### Key Finding

Actual products account for approximately **97.27% of revenue**, while the remaining revenue comes primarily from transaction types such as Shipping and other non-product categories.

---

## 3️⃣ Customer Performance

Analyzes customer revenue contribution and purchasing behavior.

### Visuals

- Customer Revenue Table
- Top 10 Customers by Revenue
- Orders by Country
- Customers with Highest Order Frequency

### Key Finding

The dashboard explicitly separates **identified customers from Unknown Customers**, ensuring that missing Customer IDs do not cause legitimate revenue to disappear from the analysis.

---

# 📈 Key Metrics

| Metric | Value |
| :--- | ---: |
| Total Revenue | **£10,062,821.42** |
| Total Orders | **24,156** |
| Total Units Sold | **5,381,202** |
| Identified Customers | **4,363** |
| Average Order Value | **£416.58** |
| Identified Customer Revenue | **£8,365,279.92** |
| Unknown Customer Revenue | **£1,697,541.50** |
| Unknown Customer Revenue Share | **16.87%** |
| Peak Revenue Month | **November 2011** |
| Peak Monthly Revenue | **£1,479,061.84** |
| Top Product by Revenue | **REGENCY CAKESTAND 3 TIER** |
| Top Product Revenue | **£164,762.19** |
| Top Product by Units | **SMALL POPCORN HOLDER** |
| Top Product Units Sold | **56,450** |

---

# 🖼️ Dashboard Preview

## Business Overview

![Business Overview](Images/overview.png)

*High-level KPIs, monthly revenue trends, top products, and geographic revenue distribution.*

## Product Performance

![Product Insights](Images/product_insights.png)

*Product revenue contribution, sales volume, and product-level performance.*

## Customer Performance

![Customer Insights](Images/customer_insights.png)

*Customer revenue contribution, top customers, order frequency, and geographic order distribution.*

---

# 📂 Project Structure

```text
Retail_Analysis/
│
├── Dataset/
│   └── online_retail.csv
│
├── SQL/
│   ├── data_cleaning.sql
│   ├── data_modeling.sql
│   └── analysis_queries.sql
│
├── PowerBI/
│   └── retail_sales_dashboard.pbix
│
├── Images/
│   ├── overview.png
│   ├── product_insights.png
│   └── customer_insights.png
│
└── README.md
```

---

# 🔄 Analytical Workflow

```text
Raw Online Retail Dataset
          ↓
     Data Cleaning
       PostgreSQL
          ↓
   Data Transformation
          ↓
    Star Schema Model
          ↓
       SQL Analysis
          ↓
    Power BI Data Model
          ↓
   Interactive Dashboard
          ↓
 Business Insights & Decisions
```

---

# 🚀 Future Scope

The current project focuses on descriptive and diagnostic analytics.

Potential extensions include:

### Predictive Sales Forecasting

Use historical revenue trends to forecast future sales and improve inventory and marketing planning.

### RFM Customer Segmentation

Apply Recency, Frequency, and Monetary analysis to identify high-value, loyal, and at-risk customers.

### Customer Retention Analysis

Investigate repeat purchasing behavior and develop strategies to increase customer retention.

### Automated Data Refresh

Connect the Power BI model to the PostgreSQL database and configure scheduled refresh for a more automated reporting workflow.

---

# 👩‍💻 Author

**Jahnavi Rangasai Parimi**

*Data Analyst | BI & Reporting*

**LinkedIn:** linkedin.com/in/jahnavi-rangasai-parimi-b21364251/

**GitHub:** github.com/jahnavi1473/Data-Portfolio
