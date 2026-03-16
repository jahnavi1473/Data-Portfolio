# 📊 Data Analytics Portfolio – Jahnavi Rangasai Parimi

Welcome to my Data Analytics Portfolio repository.  
This repository showcases end-to-end analytics projects covering data cleaning, SQL transformation, KPI modeling, dashboard development, and business insight generation.

---

## 👩‍💻 About Me

I am a Data Analyst with hands-on experience in SQL, Python, Excel, and Power BI.  
My work focuses on transforming raw data into meaningful business insights through structured analysis and dashboard reporting.

📍 Hyderabad, India  
📧 jahnavirangasai.parimi@gmail.com  

🔗 LinkedIn: https://www.linkedin.com/in/jahnavi-rangasai-parimi-b21364251/ 

🔗 GitHub: https://github.com/jahnavi1473/Data-Portfolio  

---

# 📁 Projects Included

---

## 1️⃣ Retail Sales Performance Analytics  

**Tools:** Microsoft Excel | PivotTables | Data Cleaning | Data Validation | Data Visualization | VBA  

---

### 📌 Project Overview  
Performed transaction-level analysis on 500K+ retail sales records to clean raw data, validate revenue calculations, and build KPI dashboards for business reporting.

---

### 🔍 Key Work Done  

- Cleaned and standardized raw transaction data by handling cancelled invoices, correcting negative quantities, and resolving pricing inconsistencies  
- Validated revenue computation logic (Quantity × Unit Price) to ensure accurate sales reporting  
- Performed data preparation and structured analysis-ready datasets using Excel  
- Built interactive KPI dashboards using PivotTables, slicers, and charts to track:
  - Monthly revenue trends  
  - Product-level performance  
  - Country-level sales distribution  
- Automated recurring report generation and export processes using VBA macros  

---

### 📈 Business Insights  

- Identified revenue concentration among top-performing product categories  
- Analyzed seasonality patterns across months  
- Evaluated country-wise revenue contribution to support regional performance comparison  

📂 Folder: `Retail-Sales-Analytics-Excel`

---

## 2️⃣ PwC Switzerland – Power BI Job Simulation (Forage)  

**Tools:** Power BI | Power Query | DAX  

### 📌 Project Overview
Completed a structured analytics job simulation focused on business KPI reporting and client-style dashboard development.

### 🔍 Key Work Done
- Performed data cleaning and transformation
- Created DAX measures for revenue and performance KPIs
- Built interactive dashboards for executive-level reporting
- Generated insights in a client-ready presentation format

📂 Folder: `pwc-switzerland-powerbi-job-simulation`

---

## 3️⃣ Online Retail Sales Analytics – SQL & Power BI  

**Tools:** PostgreSQL | SQL | Power BI | Data Modeling (Star Schema)

---

### 📌 Project Overview  

Built an end-to-end Business Intelligence solution analyzing **540K+ retail transactions** from an online retailer.  

The project demonstrates the complete analytics workflow from **data cleaning and SQL transformation to dimensional modeling and dashboard development**.

A **3-page Power BI dashboard** was developed to analyze overall business performance, product performance, and customer purchasing behavior.

---

### 🔍 Key Work Done  

**Data Cleaning & Preparation (SQL)**  
- Removed cancelled invoices (`InvoiceNo starting with 'C'`)
- Filtered invalid transactions including negative quantities
- Removed non-product stock codes (`B, D, M, C2, AMAZONFEE, BANK CHARGES, CRUK`)
- Investigated and handled missing product descriptions
- Standardized stock codes using `UPPER()` to ensure data consistency

**Data Modeling**  
- Designed a **Star Schema** data model
- Created fact and dimension tables:
  - `fact_sales`
  - `dim_product`
  - `dim_customer`
  - `dim_country`
  - `dim_date`

**Business Analysis (SQL)**  
Performed analytical queries to answer key business questions:
- Monthly revenue trends
- Top-performing products
- Country-level sales distribution
- Customer revenue contribution
- Customer order frequency

**Dashboard Development (Power BI)**  
Built an interactive **3-page dashboard** including:

1️⃣ Business Overview  
2️⃣ Product Performance Analysis  
3️⃣ Customer Performance Analysis  

---

### 📈 Business Insights  

- Revenue peaks during **November**, indicating strong seasonal demand  
- A small number of products contribute a **large share of total revenue**  
- The **United Kingdom dominates total sales volume**  
- A few high-value customers generate a significant portion of total revenue  
- Product sales follow a **long-tail distribution pattern**

📂 Folder: `Retail-Analysis`

---

## 4️⃣ Healthcare Claims Data Warehouse & SQL Analytics  

**Tools:** MySQL | SQL | Data Cleaning | Dimensional Modeling | Data Warehousing  

---

### 📌 Project Overview  

Developed a **healthcare claims analytics pipeline** to analyze patient utilization patterns, provider costs, and potential fraud indicators using SQL-based data warehousing techniques.

The project demonstrates how raw healthcare datasets can be transformed into **structured analytical models for healthcare cost and utilization analysis**.

---

### 🔍 Key Work Done  

**Data Cleaning & Transformation**

- Processed **558K+ healthcare claim records**
- Handled missing values and inconsistent data formats
- Cleaned categorical fraud indicators
- Standardized numeric and date fields
- Created staging tables for structured data transformations

**Data Modeling**

Designed a **Star Schema data warehouse** including:

- `dim_beneficiary` (patient demographics and chronic conditions)
- `dim_provider` (healthcare providers with fraud flags)
- `dim_date` (date attributes)
- `fact_inpatient_claims`
- `fact_outpatient_claims`

**SQL Analytics**

Performed analytical queries to evaluate:

- Healthcare spending trends
- Provider cost concentration
- Patient claim utilization
- Chronic disease prevalence
- Fraud indicators across healthcare providers

---

### 📈 Key Insights  

- Analyzed **558K+ healthcare claims** across **138K patients** and **5.4K providers**
- Identified **$556M total healthcare expenditure**
- Average **inpatient claim cost (~$10K)** significantly exceeds **outpatient claims (~$286)**
- Outpatient services represent **over 90% of total claims**
- **506 providers flagged for potential fraud risk**

📂 Folder: `healthcare-claims-analytics`

---

## 🛠 Technical Skills Demonstrated

- **SQL:** Joins, Aggregations, CTEs, Window Functions, Data Cleaning, Data Modeling
- **Python:** Pandas, NumPy  
- **Power BI:** Data Modeling, DAX, KPI Reporting  
- **Excel:** PivotTables, Power Query, VBA Automation  
- **Data Cleaning & Validation**
- **Dimensional Modeling & Star Schema Design**
- **Business Insight & Dashboard Reporting**

---

## 🎯 What This Portfolio Demonstrates

- End-to-end analytics workflow
- Data warehouse modeling
- Business KPI development
- Customer & revenue analysis
- Healthcare claims analytics
- Data-driven decision-making support
- Structured and scalable reporting models

---

⭐ Thank you for reviewing my portfolio!