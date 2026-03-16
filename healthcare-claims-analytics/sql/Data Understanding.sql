USE healthcare_claims;

SELECT count(*) from beneficiary_raw; -- 138556
SELECT count(*) from inpatient_claims_raw; -- 40474
SELECT count(*) from outpatient_claims_raw; -- 517737
SELECT count(*) from fraud_labels_raw; -- 5410

-- EXPLORING THE DATA
-- 1) Understand Table Structures
DESCRIBE beneficiary_raw;
DESCRIBE inpatient_claims_raw;
DESCRIBE outpatient_claims_raw;
DESCRIBE fraud_labels_raw;

-- 2) Dataset Size Validation.
SELECT count(*) from beneficiary_raw; -- 138556
SELECT count(*) from inpatient_claims_raw; -- 40474
SELECT count(*) from outpatient_claims_raw; -- 517737
SELECT count(*) from fraud_labels_raw; -- 5410

-- 3) Beneficiary Dataset Exploration
-- A) UNIQUE PATIENTS 
SELECT COUNT(DISTINCT BeneID) FROM beneficiary_raw; -- 138556
-- total beneids rows = total distinct patients

-- B) Gender distribution
SELECT Gender, COUNT(*) AS patients FROM beneficiary_raw
GROUP BY Gender; -- 1 -> 59450, 2 -> 79106
-- 1 -> male, 2 -> female

-- C) Race distribution
SELECT Race, COUNT(*) AS patients FROM beneficiary_raw
GROUP BY Race ORDER BY patients DESC;

-- 1	117057
-- 2	13538
-- 3	5059
-- 5	2902

-- D) Chronic condition prevalence
SELECT
SUM(CASE WHEN Chronic_Cond_Alzheimer = '1' THEN 1 ELSE 0 END) AS alzheimer_patients,
SUM(CASE WHEN Chronic_Cond_Heartfailure = '1' THEN 1 ELSE 0 END) AS heart_failure_patients,
SUM(CASE WHEN Chronic_Cond_KidneyDisease = '1' THEN 1 ELSE 0 END) AS kidney_patients,
SUM(CASE WHEN Chronic_Cond_Cancer = '1' THEN 1 ELSE 0 END) AS cancer_patients,
SUM(CASE WHEN Chronic_Cond_ObstrPulmonary = '1' THEN 1 ELSE 0 END) AS obstructive_pulmonary_patients,
SUM(CASE WHEN Chronic_Cond_Depression = '1' THEN 1 ELSE 0 END) AS depression_patients,
SUM(CASE WHEN Chronic_Cond_Diabetes = '1' THEN 1 ELSE 0 END) AS diabetes_patients,
SUM(CASE WHEN Chronic_Cond_IschemicHeart = '1' THEN 1 ELSE 0 END) AS ischemic_heart_patients,
SUM(CASE WHEN Chronic_Cond_Osteoporasis  = '1' THEN 1 ELSE 0 END) AS osteoporasis_patients,
SUM(CASE WHEN Chronic_Cond_rheumatoidarthritis = '1' THEN 1 ELSE 0 END) AS rheumatoidarthritis_patients,
SUM(CASE WHEN Chronic_Cond_stroke = '1' THEN 1 ELSE 0 END) AS stroke_patients
FROM beneficiary_raw;

-- 46026	68402	43279	16621	32859	49260	83391	93644	38059	35584	10954 i.e., ischemic_heart_patients are more
-- and then diabetes patients

-- 4) Claims Volume Analysis
-- a) total claims 
SELECT
(SELECT COUNT(*) FROM inpatient_claims_raw) AS inpatient_claims,
(SELECT COUNT(*) FROM outpatient_claims_raw) AS outpatient_claims;
-- 40474	517737 --> inpatient claims < outpatient claims

-- b) Unique providers
SELECT COUNT(DISTINCT Provider) FROM inpatient_claims_raw; -- 2092
SELECT COUNT(DISTINCT Provider) FROM outpatient_claims_raw; -- 5012

-- 5) Claim Cost Analysis
-- a) Average inpatient claim cost
SELECT AVG(CAST(InscClaimAmtReimbursed AS UNSIGNED)) AS avg_inpatient_cost
FROM inpatient_claims_raw; -- 10087.8841
-- b) Average outpatient claim cost
SELECT AVG(CAST(InscClaimAmtReimbursed AS UNSIGNED)) AS avg_outpatient_cost
FROM outpatient_claims_raw; -- 286.3348
-- avg inpatient ki claim cost > avg outpatient claim cost 

-- 6) Top Costly Providers
-- a) inpatient
SELECT Provider,
SUM(CAST(InscClaimAmtReimbursed AS UNSIGNED)) AS total_claim_cost
FROM inpatient_claims_raw
GROUP BY Provider
ORDER BY total_claim_cost DESC
LIMIT 10;

-- "PRV52019"	5580870 --> highest 
-- "PRV55462"	4260100 -- > second highest
-- "PRV54367"	3040900
-- "PRV53706"	2776000
-- "PRV55209"	2756100
-- "PRV56560"	2605900
-- "PRV55230"	2518350
-- "PRV54742"	2499900
-- "PRV56416"	2337050
-- "PRV52846"	2099830

-- b) outpatient
SELECT Provider,
SUM(CAST(InscClaimAmtReimbursed AS UNSIGNED)) AS total_claim_cost
FROM outpatient_claims_raw
GROUP BY Provider
ORDER BY total_claim_cost DESC
LIMIT 10;

-- "PRV51459"	2321890 --> highest 
-- "PRV53797"	1303600 --> second highest 
-- "PRV51574"	1281810
-- "PRV53918"	1014510
-- "PRV54895"	1004610
-- "PRV55215"	927260
-- "PRV52064"	769680
-- "PRV56011"	741640
-- "PRV55004"	665610
-- "PRV54772"	631520

-- 7) Fraud Provider Analysis
SELECT PotentialFraud, COUNT(*) FROM fraud_labels_raw
GROUP BY PotentialFraud;

-- "No"	4904
-- "Yes"	506

-- Fraud vs Non-Fraud Claim Costs for 
-- a) inpatient
SELECT f.PotentialFraud, SUM(CAST(i.InscClaimAmtReimbursed AS UNSIGNED)) AS total_cost
FROM inpatient_claims_raw i JOIN
fraud_labels_raw f ON 
i.Provider = f.Provider
GROUP BY f.PotentialFraud;

-- "Yes"	241288510
-- "No"	167008510
-- MEANS CLAIMS W/O FRAUDS HAVE less COST THAN THOSE WITH FRAUDS

-- b) outpatient
SELECT f.PotentialFraud, SUM(CAST(o.InscClaimAmtReimbursed AS UNSIGNED)) AS total_cost
FROM outpatient_claims_raw o JOIN
fraud_labels_raw f ON 
o.Provider = f.Provider
GROUP BY f.PotentialFraud;

-- "Yes"	54392610
-- "No"	93853510
-- MEANS CLAIMS W/O FRAUDS HAVE more COST THAN THOSE WITH FRAUDS

-- 8) Claims per Patient
-- A) COUNT FOR INPATIENT
SELECT BeneID, COUNT(*) AS claim_count
FROM inpatient_claims_raw
GROUP BY BeneID
ORDER BY claim_count DESC
LIMIT 10;
-- "BENE134170"	8 --> highest
-- "BENE62091"	7 --> second highest
-- "BENE64791"	7
-- "BENE119457"	7
-- "BENE121796"	7
-- "BENE117116"	7
-- "BENE119780"	6
-- "BENE126421"	6
-- "BENE117983"	6
-- "BENE124069"	6
-- B) COST
SELECT BeneID, COUNT(*) as claims_per_patient ,
SUM(CAST(InscClaimAmtReimbursed AS UNSIGNED)) as total_cost
from inpatient_claims_raw
GROUP BY BeneID
ORDER BY claims_per_patient DESC
LIMIT 10;
-- "BENE134170"	8	90000 -->highest
-- "BENE121796"	7	89000 --> second highest
-- "BENE117116"	7	64000
-- "BENE119457"	7	96000
-- "BENE62091"	7	76000
-- "BENE64791"	7	68000
-- "BENE72701"	6	37000
-- "BENE78733"	6	34000
-- "BENE120987"	6	78200
-- "BENE119780"	6	41000

-- A) COUNT FOR OUTPATIENT
SELECT BeneID, COUNT(*) AS claim_count
FROM outpatient_claims_raw
GROUP BY BeneID
ORDER BY claim_count DESC
LIMIT 10;
-- "BENE118316"	29 --> highest
-- "BENE42721"	29 --> second highest
-- "BENE143400"	27
-- "BENE63544"	27
-- "BENE63504"	27
-- "BENE59303"	27
-- "BENE44241"	26
-- "BENE36330"	26
-- "BENE40202"	25
-- "BENE87248"	25
-- B) COST
SELECT BeneID, COUNT(ClaimID) as claims_per_patient ,
SUM(CAST(InscClaimAmtReimbursed AS UNSIGNED)) as total_cost
from outpatient_claims_raw
GROUP BY BeneID
ORDER BY claims_per_patient DESC
LIMIT 10;
-- "BENE118316"	29	42950 --> highest
-- "BENE42721"	29	35310 --> second highest
-- "BENE59303"	27	24100
-- "BENE63544"	27	37090
-- "BENE63504"	27	3020
-- "BENE143400"	27	4400
-- "BENE44241"	26	24620
-- "BENE36330"	26	31090
-- "BENE40202"	25	27160
-- "BENE158374"	25	31200

-- 9) Date Range Analysis
SELECT MIN(ClaimStartDt),MAX(ClaimStartDt)
FROM inpatient_claims_raw; -- 2008-11-27	2009-12-31
SELECT MIN(ClaimStartDt),MAX(ClaimStartDt)
FROM outpatient_claims_raw; -- 2008-12-12	2009-12-31

