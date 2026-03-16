# Healthcare Claims Data Warehouse & SQL Analytics

## Project Overview

This project analyzes healthcare insurance claims to understand patient utilization patterns, provider cost distribution, and potential fraud indicators.

The objective was to transform raw healthcare claim datasets into a structured analytical data warehouse using SQL and perform analytical queries to generate business insights.

Project workflow:

Raw Data → Data Cleaning → Staging Layer → Dimensional Modeling → SQL Analysis

---

## Dataset

The dataset contains healthcare insurance claim records commonly used for healthcare analytics and fraud detection research.

### Dataset Size

| Dataset | Records |
|--------|--------|
| Beneficiary Data | 138,556 |
| Inpatient Claims | 40,474 |
| Outpatient Claims | 517,737 |
| Fraud Labels | 5,410 |

Total claim records analyzed: **558K+**

### Key Entities

- Beneficiaries – patient demographic information and chronic conditions  
- Providers – hospitals and healthcare institutions  
- Claims – inpatient and outpatient medical claim records  
- Fraud Labels – indicators for potentially fraudulent providers  

---

## Tech Stack

**Database & Querying**

- MySQL
- SQL

**Data Processing**

- Data Cleaning
- Data Transformation
- Data Validation

**Analytics Concepts**

- Dimensional Data Modeling
- Star Schema Design
- Data Warehousing
- Analytical SQL Queries

---

## Data Pipeline

```
Raw Dataset
   ↓
Source Tables (MySQL)
   ↓
Data Cleaning & Transformation
   ↓
Staging Tables
   ↓
Dimensional Data Model (Star Schema)
   ↓
SQL Business Analysis
```

---

## Data Cleaning & Transformation

Several preprocessing steps were performed on the raw dataset:

- Handling missing values and null records
- Cleaning categorical values such as fraud labels
- Standardizing date and numeric fields
- Removing CSV formatting artifacts
- Creating staging tables to isolate transformation logic

These steps ensured the dataset was consistent and analysis-ready.

---

## Data Warehouse Design

A **star schema data model** was created to support efficient analytical queries.

### Dimension Tables

**dim_beneficiary**

- Patient demographics
- Chronic conditions
- Insurance coverage metrics

**dim_provider**

- Healthcare provider identifiers
- Fraud indicator flag

**dim_date**

- Claim date attributes used for time-based analysis

### Fact Tables

**fact_inpatient_claims**

- Hospital admissions
- Claim cost
- Diagnosis and procedure codes

**fact_outpatient_claims**

- Outpatient visits
- Claim cost
- Physician interactions

---

## Key Analytical Questions

The project explores several analytical questions:

- What is the total healthcare expenditure across claims?
- How do inpatient and outpatient claims differ in cost and volume?
- Which providers generate the highest healthcare costs?
- How frequently do patients utilize healthcare services?
- What are the most common chronic health conditions?
- Which providers are flagged for potential fraud risk?

---

## SQL Analysis & Insights

### Healthcare Overview

- Total Patients: **138,556**
- Total Providers: **5,410**
- Total Claims: **558K+**
- Total Healthcare Expenditure: **$556M**

---

### Claim Utilization

| Claim Type | Total Claims |
|------------|-------------|
| Inpatient | 40,474 |
| Outpatient | 517,737 |

Outpatient services account for **over 90% of total healthcare interactions**, while inpatient claims represent a smaller but more expensive segment.

---

### Cost Analysis

| Metric | Value |
|------|------|
Average Inpatient Claim Cost | $10,087 |
Average Outpatient Claim Cost | $286 |

Although outpatient claims are more frequent, inpatient claims contribute the majority of healthcare spending.

---

### Provider Cost Concentration

A small group of providers contributes significantly to overall healthcare costs.

Top providers exceed **$5M in inpatient claim reimbursements**, indicating potential cost concentration.

---

### Chronic Disease Prevalence

Two major chronic conditions dominate the dataset:

- Ischemic Heart Disease: **93K patients**
- Diabetes: **83K patients**

These conditions contribute significantly to repeated healthcare utilization.

---

### Fraud Indicators

The dataset contains fraud labels for healthcare providers.

| Fraud Indicator | Providers |
|---------------|-----------|
| Non-Fraud | 4,904 |
| Potential Fraud | 506 |

These labels can be used for future fraud detection analytics.

---

## Project Structure

```
healthcare-claims-analytics
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

## Future Scope

The project can be extended with additional analytics capabilities.

### BI Dashboard Development

Interactive dashboards can be built using:

- Tableau
- Power BI

Possible visualizations include:

- Claim volume trends
- Provider cost distribution
- Fraud risk indicators
- Patient utilization patterns

### Machine Learning Fraud Detection

The structured dataset can be used to train models such as:

- Logistic Regression
- Random Forest
- Gradient Boosting

to predict fraudulent healthcare providers.

---

## Author

**Jahnavi Rangasai Parimi**
