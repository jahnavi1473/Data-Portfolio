-- data modeling
-- fact and dim tables creation
-- dim_beneficiary
-- dim_provider
-- dim_date
-- fact_inpatient_claims
-- fact_outpatient_claims  

-- DIM BENEFICIARY
CREATE TABLE dim_beneficiary AS
SELECT
BeneID,
DOB,
Gender,
Race,
State,
County,
Chronic_Cond_Alzheimer,
Chronic_Cond_Heartfailure,
Chronic_Cond_KidneyDisease,
Chronic_Cond_Cancer,
Chronic_Cond_ObstrPulmonary,
Chronic_Cond_Depression,
Chronic_Cond_Diabetes,
Chronic_Cond_IschemicHeart,
Chronic_Cond_Osteoporasis,
Chronic_Cond_rheumatoidarthritis,
Chronic_Cond_stroke
FROM stg_beneficiary;

SELECT COUNT(*) FROM dim_beneficiary;

-- DIM PROVIDER
DROP TABLE IF EXISTS dim_provider;

CREATE TABLE dim_provider AS
SELECT
Provider,
CASE
    WHEN REPLACE(PotentialFraud,'"','') = 'Yes' THEN 1
    ELSE 0
END AS FraudFlag
FROM stg_fraud_labels;

SELECT FraudFlag, COUNT(*)
FROM dim_provider
GROUP BY FraudFlag;

SELECT COUNT(*) FROM dim_provider;

-- DIM DATE
CREATE TABLE dim_date AS
SELECT DISTINCT ClaimStartDt AS claim_date
FROM stg_inpatient_claims

UNION

SELECT DISTINCT ClaimStartDt
FROM stg_outpatient_claims;

-- FACT OUTPATIENT
CREATE TABLE fact_outpatient_claims AS
SELECT
ClaimID,
BeneID,
Provider,
ClaimStartDt AS claim_date,
ClaimCost,
DeductibleAmtPaid,
ClmAdmitDiagnosisCode
FROM stg_outpatient_claims;

SELECT COUNT(*) FROM fact_outpatient_claims;

CREATE TABLE fact_inpatient_claims AS
SELECT
ClaimID,
BeneID,
Provider,
ClaimStartDt AS claim_date,
AdmissionDt,
DischargeDt,
ClaimCost,
DeductibleAmtPaid,
ClmAdmitDiagnosisCode,
DiagnosisGroupCode
FROM stg_inpatient_claims;

SELECT COUNT(*) FROM fact_inpatient_claims;

SELECT COUNT(*) FROM dim_beneficiary; -- 138556
SELECT COUNT(*) FROM dim_date; -- 398
SELECT COUNT(*) FROM dim_provider; -- 5410
SELECT COUNT(*) FROM fact_outpatient_claims; -- 517737
SELECT COUNT(*) FROM fact_inpatient_claims; -- 40474


-- Table	                 Rows	                   Meaning
-- dim_beneficiary	       138,556	           total unique patients
-- dim_provider	            5,410	              total healthcare providers
-- dim_date	                 398	                  unique claim dates
-- fact_outpatient_claims   517,737	              outpatient transactions
-- fact_inpatient_claims	40,474	               inpatient transactions

-- SCHEMA
-- dim_beneficiary
--         │
--         │
-- dim_provider ── fact_inpatient_claims ── dim_date
--         │
--         │
-- dim_provider ── fact_outpatient_claims ── dim_date