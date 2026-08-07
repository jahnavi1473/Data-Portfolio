# Healthcare Claims Analytics & Data Warehouse

## 🏥 Project Overview
This project transforms raw, messy healthcare claims data into a structured **Data Warehouse** to uncover critical business insights. The goal was to analyze **558,000+ claims** across **138,000+ patients** to identify cost drivers, utilization patterns, and potential fraud indicators.

**Key Business Outcomes:**
- 💰 Identified **$556M+** in total healthcare expenditure.
- 🚨 Flagged **506 providers** for potential fraud.
- 📉 Discovered that while outpatient claims are frequent (90%), **inpatient claims drive the majority of costs**.
- 🩺 Highlighted **Ischemic Heart Disease** and **Diabetes** as the top chronic conditions driving patient utilization.

---

## 🚀 The Problem & Solution
| The Problem | The Solution |
| :--- | :--- |
| Raw data was scattered across CSVs with missing values, inconsistent formats, and no clear structure. | Built a **Star Schema Data Warehouse** in MySQL to centralize data, enforce data quality, and enable fast analytical queries. |
| Leadership lacked visibility into cost distribution and fraud risks. | Developed **Advanced SQL queries** to answer critical business questions about spending, provider performance, and patient health trends. |

---

## 🛠 Tech Stack
- **Database:** MySQL
- **Data Modeling:** Star Schema, Dimensional Modeling (Fact & Dimension Tables)
- **Languages:** SQL (Joins, CTEs, Window Functions, Aggregations)
- **Tools:** Data Cleaning, ETL Pipelines, Exploratory Data Analysis (EDA)

---

## 🏗️ Data Architecture & Pipeline
The project follows a robust **Data Warehousing** workflow:

```mermaid
graph LR
    A[Raw CSV Data] --> B[Source Layer]
    B --> C[Data Cleaning & Validation]
    C --> D[Staging Layer]
    D --> E[Dimensional Modeling (Star Schema)]
    E --> F[Business Analysis & Insights]
```

---

## 🏗️ Schema Design
A **Star Schema** was implemented to optimize query performance:

**Fact Tables:**
- `fact_inpatient_claims`: Hospital admissions, costs, diagnosis codes.
- `fact_outpatient_claims`: Outpatient visits, costs, physician interactions.

**Dimension Tables:**
- `dim_beneficiary`: Patient demographics, chronic conditions.
- `dim_provider`: Provider details, fraud flags.
- `dim_date`: Time-based analysis attributes.

---

## ❓ Business Questions & Answers
This project answers the following critical business questions using SQL:

### 1. What is the total financial exposure?
> **Answer:** Total healthcare expenditure across all claims is **$556,000,000+**.

### 2. How do Inpatient vs. Outpatient costs compare?
> **Answer:** 
> - **Outpatient:** 517,737 claims (92.8% of volume) but lower average cost (**$286**).
> - **Inpatient:** 40,474 claims (7.2% of volume) but significantly higher cost (**$10,087** average).
> - **Insight:** Inpatient care is the primary cost driver despite lower volume.

### 3. Which providers are the highest cost contributors?
> **Answer:** A small subset of providers accounts for a disproportionate amount of spending. The top providers exceed **$5M** in reimbursements, indicating potential cost concentration.

### 4. What are the most common chronic conditions?
> **Answer:** 
> - **Ischemic Heart Disease:** 93,000 patients.
> - **Diabetes:** 83,000 patients.
> - **Insight:** These two conditions drive the majority of repeated utilization.

### 5. Are there signs of fraud?
> **Answer:** Yes. **506 providers** (approx. 9% of total providers) are flagged with potential fraud indicators, warranting further investigation.

---

## 📊 Key Insights 

| Metric | Value | Insight |
| :--- | :--- | :--- |
| **Total Expenditure** | $556M+ | Massive financial scale requiring strict cost control. |
| **Inpatient Avg Cost** | $10,087 | ~35x higher than outpatient costs. |
| **Fraud Risk** | 506 Providers | High-priority targets for audit. |
| **Top Chronic Disease** | Ischemic Heart Disease | 93K patients require targeted care management. |

---

## Project Structure

```
healthcare-claims-analytics
│
├── data
│   ├── beneficiary.csv
│   ├── inpatient_claims.csv
│   ├── outpatient_claims.csv
│   └── fraud_labels.csv
│  
├── sql
│   ├── source_layer.sql
│   ├── staging_layer.sql
│   ├── data_modeling.sql
│   └── analysis_queries.sql
│
└── README.md
```

---

## 🚀 Future Scope
- **BI Dashboard Integration:** Connect this warehouse to **Power BI** or **Tableau** for real-time executive dashboards.
- **Predictive Modeling:** Use the structured fraud labels to train a **Machine Learning model** (e.g., Random Forest) for automated fraud detection.
- **Patient Risk Scoring:** Develop a scoring system to identify high-risk patients based on chronic conditions and utilization history.

---

## 👨‍💻 Author
**Jahnavi Rangasai Parimi**  
*Data Analyst | BI & Reporting*  
[(LinkedIn Profile)](https://linkedin.com/in/jahnavi-rangasai-parimi-b21364251/) | [(GitHub Profile)](https://github.com/jahnavi1473/Data-Portfolio)
