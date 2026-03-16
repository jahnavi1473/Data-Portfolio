-- SQL INSIGHTS

USE healthcare_claims;

---------------------------------------------------
-- 1. HEALTHCARE OVERVIEW METRICS
---------------------------------------------------

-- Total Patients
SELECT COUNT(*) AS total_patients
FROM dim_beneficiary;
-- 138556

-- Total Providers
SELECT COUNT(*) AS total_providers
FROM dim_provider; -- 5410

-- Total Inpatient Claims
SELECT COUNT(*) AS inpatient_claims
FROM fact_inpatient_claims; -- 40474

-- Total Outpatient Claims
SELECT COUNT(*) AS outpatient_claims
FROM fact_outpatient_claims; -- 517737

-- Total Healthcare Cost
SELECT
(SELECT SUM(ClaimCost) FROM fact_inpatient_claims) +
(SELECT SUM(ClaimCost) FROM fact_outpatient_claims)
AS total_healthcare_cost;
-- 556543140

---------------------------------------------------
-- 2. CLAIM UTILIZATION
---------------------------------------------------

-- Inpatient vs Outpatient Claims
SELECT 'Inpatient' AS claim_type, COUNT(*) AS total_claims
FROM fact_inpatient_claims
UNION
SELECT 'Outpatient', COUNT(*)
FROM fact_outpatient_claims;
-- Inpatient	40474
-- Outpatient	517737


---------------------------------------------------
-- 3. COST ANALYSIS
---------------------------------------------------

-- Average Inpatient Claim Cost
SELECT AVG(ClaimCost) AS avg_inpatient_cost
FROM fact_inpatient_claims; -- 10087.8841

-- Average Outpatient Claim Cost
SELECT AVG(ClaimCost) AS avg_outpatient_cost
FROM fact_outpatient_claims; -- 286.3348

-- Total Cost by Claim Type
SELECT 'Inpatient' AS claim_type, SUM(ClaimCost) AS total_cost
FROM fact_inpatient_claims
UNION
SELECT 'Outpatient', SUM(ClaimCost)
FROM fact_outpatient_claims;
-- Inpatient	408297020
-- Outpatient	148246120

---------------------------------------------------
-- 4. TOP COSTLY PROVIDERS
---------------------------------------------------

-- Top 10 Providers by Inpatient Cost
SELECT
Provider,
SUM(ClaimCost) AS total_cost
FROM fact_inpatient_claims
GROUP BY Provider
ORDER BY total_cost DESC
LIMIT 10;
-- "PRV52019"	5580870
-- "PRV55462"	4260100
-- "PRV54367"	3040900
-- "PRV53706"	2776000
-- "PRV55209"	2756100
-- "PRV56560"	2605900
-- "PRV55230"	2518350
-- "PRV54742"	2499900
-- "PRV56416"	2337050
-- "PRV52846"	2099830

-- Top 10 Providers by Outpatient Cost
SELECT
Provider,
SUM(ClaimCost) AS total_cost
FROM fact_outpatient_claims
GROUP BY Provider
ORDER BY total_cost DESC
LIMIT 10;

-- "PRV51459"	2321890
-- "PRV53797"	1303600
-- "PRV51574"	1281810
-- "PRV53918"	1014510
-- "PRV54895"	1004610
-- "PRV55215"	927260
-- "PRV52064"	769680
-- "PRV56011"	741640
-- "PRV55004"	665610
-- "PRV54772"	631520

---------------------------------------------------
-- 5. FRAUD ANALYSIS
---------------------------------------------------

-- Fraud vs Non-Fraud Providers
SELECT FraudFlag, COUNT(*)
FROM dim_provider
GROUP BY FraudFlag;
-- 0	4904
-- 1	506

-- Fraud vs Non-Fraud Claim Cost (Inpatient)
SELECT
p.FraudFlag,
SUM(f.ClaimCost) AS total_cost
FROM fact_inpatient_claims f
JOIN dim_provider p
ON f.Provider = p.Provider
GROUP BY p.FraudFlag;
-- 1	241288510
-- 0	167008510

-- Fraud vs Non-Fraud Claim Cost (Outpatient)
SELECT
p.FraudFlag,
SUM(f.ClaimCost) AS total_cost
FROM fact_outpatient_claims f
JOIN dim_provider p
ON f.Provider = p.Provider
GROUP BY p.FraudFlag;
-- 1	54392610
-- 0	93853510

---------------------------------------------------
-- 6. PATIENT UTILIZATION
---------------------------------------------------

-- Top 10 Patients by Total Claim Cost
SELECT
BeneID,
SUM(ClaimCost) AS total_cost
FROM fact_inpatient_claims
GROUP BY BeneID
ORDER BY total_cost DESC
LIMIT 10;
-- "BENE155688"	159000
-- "BENE22137"	153000
-- "BENE14036"	146000
-- "BENE111157"	144000
-- "BENE102690"	143000
-- "BENE83465"	141000
-- "BENE32369"	136000
-- "BENE21360"	136000
-- "BENE94775"	134000
-- "BENE117983"	133000

-- Patients with Highest Outpatient Visits
SELECT
BeneID,
COUNT(*) AS visits
FROM fact_outpatient_claims
GROUP BY BeneID
ORDER BY visits DESC
LIMIT 10;

-- "BENE118316"	29
-- "BENE42721"	29
-- "BENE143400"	27
-- "BENE63544"	27
-- "BENE63504"	27
-- "BENE59303"	27
-- "BENE44241"	26
-- "BENE36330"	26
-- "BENE40202"	25
-- "BENE87248"	25
---------------------------------------------------
-- 7. MONTHLY CLAIM TRENDS
---------------------------------------------------

-- Monthly Outpatient Claims Trend
SELECT
YEAR(claim_date) AS year,
MONTH(claim_date) AS month,
COUNT(*) AS claims
FROM fact_outpatient_claims
GROUP BY year, month
ORDER BY year, month;
-- 2008	12	2019
-- 2009	1	45851
-- 2009	2	41416
-- 2009	3	46047
-- 2009	4	44657
-- 2009	5	45690
-- 2009	6	43933
-- 2009	7	44677
-- 2009	8	44181
-- 2009	9	41662
-- 2009	10	41872
-- 2009	11	39082
-- 2009	12	36650

-- Monthly Inpatient Claims Trend
SELECT
YEAR(claim_date) AS year,
MONTH(claim_date) AS month,
COUNT(*) AS claims
FROM fact_inpatient_claims
GROUP BY year, month
ORDER BY year, month;

-- 2008	11	6
-- 2008	12	680
-- 2009	1	3731
-- 2009	2	3375
-- 2009	3	3587
-- 2009	4	3427
-- 2009	5	3569
-- 2009	6	3467
-- 2009	7	3371
-- 2009	8	3329
-- 2009	9	3238
-- 2009	10	3232
-- 2009	11	3014
-- 2009	12	2448

---------------------------------------------------
-- 8. COST BY STATE
---------------------------------------------------

SELECT
b.State,
SUM(f.ClaimCost) AS total_cost
FROM fact_inpatient_claims f
JOIN dim_beneficiary b
ON f.BeneID = b.BeneID
GROUP BY b.State
ORDER BY total_cost DESC;

-- 5	34206810
-- 10	31095970
-- 45	27220420
-- 33	26588020
-- 39	18915000
-- 36	17566080
-- 14	16082350
-- 34	14630640
-- 11	12648500
-- 31	11573800
-- 23	10681240
-- 15	10605620
-- 49	10333300
-- 26	9439200
-- 22	9127900
-- 21	8723900
-- 44	8178300
-- 3	7738200
-- 1	7704900
-- 52	7599120
-- 50	7559460
-- 24	7158670
-- 19	7132700
-- 18	6789400
-- 42	6763100
-- 7	6323300
-- 37	5999450
-- 25	5521850
-- 4	5452400
-- 16	5043400
-- 6	4997860
-- 17	3881600
-- 51	3670400
-- 28	3555300
-- 38	3366400
-- 54	3313000
-- 29	2486000
-- 46	2485610
-- 13	1945470
-- 30	1894000
-- 32	1790500
-- 27	1456400
-- 43	1383200
-- 47	1354680
-- 12	1255000
-- 20	1092200
-- 8	795800
-- 9	689000
-- 53	672600
-- 35	636000
-- 41	599000
-- 2	574000

---------------------------------------------------
-- 9. CHRONIC CONDITION ANALYSIS
---------------------------------------------------

-- Diabetes Patients
SELECT
COUNT(*) AS diabetes_patients
FROM dim_beneficiary
WHERE Chronic_Cond_Diabetes = 1;
-- 83391
-- Heart Disease Patients
SELECT
COUNT(*) AS ischemic_heart_patients
FROM dim_beneficiary
WHERE Chronic_Cond_IschemicHeart = 1;
-- 93644

---------------------------------------------------
-- 10. HIGH COST CLAIMS
---------------------------------------------------

-- Top 10 Most Expensive Claims
SELECT
ClaimID,
Provider,
ClaimCost
FROM fact_inpatient_claims
ORDER BY ClaimCost DESC
LIMIT 10;

-- "CLM44467"	"PRV53461"	125000
-- "CLM56796"	"PRV54742"	125000
-- "CLM31106"	"PRV52815"	125000
-- "CLM67392"	"PRV55172"	125000
-- "CLM59310"	"PRV56044"	125000
-- "CLM54264"	"PRV54942"	124000
-- "CLM31780"	"PRV52467"	123000
-- "CLM45826"	"PRV57173"	120000
-- "CLM68762"	"PRV53706"	119000
-- "CLM75041"	"PRV52845"	118000