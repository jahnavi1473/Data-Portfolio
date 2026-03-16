USE healthcare_claims;

-- create clean staging tables without modifying raw tables
-- a) stg_beneficiary
-- b) stg_inpatient_claims
-- c) stg_outpatient_claims
-- d) stg_fraud_labels

-- 1) BENEFICIARY Issues to fix:
-- Column	Problem -> Fix
-- DOB	text	convert to DATE
-- DOD	text	convert to DATE
-- Gender	varchar	convert to INT
-- Race	varchar	convert to INT
-- Annual amounts	varchar	convert to INT

CREATE TABLE stg_beneficiary AS
SELECT BeneID,
STR_TO_DATE(NULLIF(DOB,'NA'),'%Y-%m-%d') AS DOB,
STR_TO_DATE(NULLIF(DOD,'NA'),'%Y-%m-%d') AS DOD,
CAST(Gender AS UNSIGNED) AS Gender,
CAST(Race AS UNSIGNED) AS Race,
RenalDiseaseIndicator,
State,
CAST(County AS UNSIGNED) AS County,
CAST(NoOfMonths_PartACov AS UNSIGNED) AS PartA_Coverage_Months,
CAST(NoOfMonths_PartBCov AS UNSIGNED) AS PartB_Coverage_Months,
CAST(Chronic_Cond_Alzheimer AS UNSIGNED) AS Chronic_Cond_Alzheimer,
CAST(Chronic_Cond_Heartfailure AS UNSIGNED) AS Chronic_Cond_Heartfailure,
CAST(Chronic_Cond_KidneyDisease AS UNSIGNED) AS Chronic_Cond_KidneyDisease,
CAST(Chronic_Cond_Cancer AS UNSIGNED) AS Chronic_Cond_Cancer,
CAST(Chronic_Cond_ObstrPulmonary AS UNSIGNED) AS Chronic_Cond_ObstrPulmonary,
CAST(Chronic_Cond_Depression AS UNSIGNED) AS Chronic_Cond_Depression,
CAST(Chronic_Cond_Diabetes AS UNSIGNED) AS Chronic_Cond_Diabetes,
CAST(Chronic_Cond_IschemicHeart AS UNSIGNED) AS Chronic_Cond_IschemicHeart,
CAST(Chronic_Cond_Osteoporasis AS UNSIGNED) AS Chronic_Cond_Osteoporasis,
CAST(Chronic_Cond_rheumatoidarthritis AS UNSIGNED) AS Chronic_Cond_rheumatoidarthritis,
CAST(Chronic_Cond_stroke AS UNSIGNED) AS Chronic_Cond_stroke,
CAST(IPAnnualReimbursementAmt AS UNSIGNED) AS IPAnnualReimbursementAmt,
CAST(IPAnnualDeductibleAmt AS UNSIGNED) AS IPAnnualDeductibleAmt,
CAST(OPAnnualReimbursementAmt AS UNSIGNED) AS OPAnnualReimbursementAmt,
CAST(OPAnnualDeductibleAmt AS UNSIGNED) AS OPAnnualDeductibleAmt
FROM beneficiary_raw;

SELECT COUNT(*) FROM stg_beneficiary;
SELECT * FROM stg_beneficiary LIMIT 5;

-- 2) FRAUD LABELS Convert Yes / No → 1 / 0.
CREATE TABLE stg_fraud_labels AS
SELECT Provider,
CASE
    WHEN PotentialFraud = 'Yes' THEN 1
    ELSE 0
END AS FraudFlag
FROM fraud_labels_raw;

SELECT COUNT(*) FROM stg_fraud_labels;
SELECT * FROM stg_fraud_labels LIMIT 5;

-- 3) INPATIENT CLAIMS 
-- Column	Fix
-- ClaimStartDt	DATE
-- ClaimEndDt	DATE
-- AdmissionDt	DATE
-- DischargeDt	DATE
-- InscClaimAmtReimbursed	INT
-- DeductibleAmtPaid	INT
CREATE TABLE stg_inpatient_claims AS
SELECT

BeneID,
ClaimID,
Provider,

STR_TO_DATE(NULLIF(ClaimStartDt,'NA'),'%Y-%m-%d') AS ClaimStartDt,
STR_TO_DATE(NULLIF(ClaimEndDt,'NA'),'%Y-%m-%d') AS ClaimEndDt,

STR_TO_DATE(NULLIF(AdmissionDt,'NA'),'%Y-%m-%d') AS AdmissionDt,
STR_TO_DATE(NULLIF(DischargeDt,'NA'),'%Y-%m-%d') AS DischargeDt,

CAST(NULLIF(InscClaimAmtReimbursed,'NA') AS UNSIGNED) AS ClaimCost,
CAST(NULLIF(DeductibleAmtPaid,'NA') AS UNSIGNED) AS DeductibleAmtPaid,

AttendingPhysician,
OperatingPhysician,
OtherPhysician,

ClmAdmitDiagnosisCode,
DiagnosisGroupCode,

ClmDiagnosisCode_1,
ClmDiagnosisCode_2,
ClmDiagnosisCode_3,
ClmDiagnosisCode_4,
ClmDiagnosisCode_5,
ClmDiagnosisCode_6,
ClmDiagnosisCode_7,
ClmDiagnosisCode_8,
ClmDiagnosisCode_9,
ClmDiagnosisCode_10,

ClmProcedureCode_1,
ClmProcedureCode_2,
ClmProcedureCode_3,
ClmProcedureCode_4,
ClmProcedureCode_5,
ClmProcedureCode_6

FROM inpatient_claims_raw;

SELECT COUNT(*) FROM stg_inpatient_claims;
SELECT * FROM stg_inpatient_claims LIMIT 5;

-- 4) OUTPATIENT CLAIMS
-- Column	Fix
-- ClaimStartDt	DATE
-- ClaimEndDt	DATE
-- InscClaimAmtReimbursed	INT
-- DeductibleAmtPaid	INT

CREATE TABLE stg_outpatient_claims AS
SELECT BeneID, ClaimID, Provider,
STR_TO_DATE(NULLIF(ClaimStartDt,'NA'),'%Y-%m-%d') AS ClaimStartDt,
STR_TO_DATE(NULLIF(ClaimEndDt,'NA'),'%Y-%m-%d') AS ClaimEndDt,
CAST(NULLIF(InscClaimAmtReimbursed,'NA') AS UNSIGNED) AS ClaimCost,
CAST(NULLIF(DeductibleAmtPaid,'NA') AS UNSIGNED) AS DeductibleAmtPaid,
AttendingPhysician,
OperatingPhysician,
OtherPhysician,
ClmAdmitDiagnosisCode,
ClmDiagnosisCode_1,
ClmDiagnosisCode_2,
ClmDiagnosisCode_3,
ClmDiagnosisCode_4,
ClmDiagnosisCode_5,
ClmDiagnosisCode_6,
ClmDiagnosisCode_7,
ClmDiagnosisCode_8,
ClmDiagnosisCode_9,
ClmDiagnosisCode_10,
ClmProcedureCode_1,
ClmProcedureCode_2,
ClmProcedureCode_3,
ClmProcedureCode_4,
ClmProcedureCode_5,
ClmProcedureCode_6
FROM outpatient_claims_raw;

SELECT COUNT(*) FROM stg_outpatient_claims;
SELECT * FROM stg_outpatient_claims LIMIT 5;


SELECT COUNT(*) FROM stg_beneficiary; -- 138556
SELECT COUNT(*) FROM stg_inpatient_claims; -- 40474
SELECT COUNT(*) FROM stg_outpatient_claims; -- 517737
SELECT COUNT(*) FROM stg_fraud_labels; -- 5410

DROP TABLE IF EXISTS stg_beneficiary;
DROP TABLE IF EXISTS stg_inpatient_claims;
DROP TABLE IF EXISTS stg_outpatient_claims;
DROP TABLE IF EXISTS stg_fraud_labels;

-- FOUND NA/NULL/" " VALUES THAT NEED TO BE HANDLED BEFORE CREATING DATA MODELS so we drop them and recreate them handling those
-- values.
CREATE TABLE stg_beneficiary AS
SELECT
BeneID,

STR_TO_DATE(NULLIF(NULLIF(DOB,'NA'),''),'%Y-%m-%d') AS DOB,
STR_TO_DATE(NULLIF(NULLIF(DOD,'NA'),''),'%Y-%m-%d') AS DOD,

CAST(NULLIF(NULLIF(Gender,'NA'),'') AS UNSIGNED) AS Gender,
CAST(NULLIF(NULLIF(Race,'NA'),'') AS UNSIGNED) AS Race,

NULLIF(NULLIF(RenalDiseaseIndicator,'NA'),'') AS RenalDiseaseIndicator,

State,

CAST(NULLIF(NULLIF(County,'NA'),'') AS UNSIGNED) AS County,

CAST(NULLIF(NULLIF(NoOfMonths_PartACov,'NA'),'') AS UNSIGNED) AS PartA_Coverage_Months,
CAST(NULLIF(NULLIF(NoOfMonths_PartBCov,'NA'),'') AS UNSIGNED) AS PartB_Coverage_Months,

CAST(NULLIF(NULLIF(Chronic_Cond_Alzheimer,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Alzheimer,
CAST(NULLIF(NULLIF(Chronic_Cond_Heartfailure,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Heartfailure,
CAST(NULLIF(NULLIF(Chronic_Cond_KidneyDisease,'NA'),'') AS UNSIGNED) AS Chronic_Cond_KidneyDisease,
CAST(NULLIF(NULLIF(Chronic_Cond_Cancer,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Cancer,
CAST(NULLIF(NULLIF(Chronic_Cond_ObstrPulmonary,'NA'),'') AS UNSIGNED) AS Chronic_Cond_ObstrPulmonary,
CAST(NULLIF(NULLIF(Chronic_Cond_Depression,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Depression,
CAST(NULLIF(NULLIF(Chronic_Cond_Diabetes,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Diabetes,
CAST(NULLIF(NULLIF(Chronic_Cond_IschemicHeart,'NA'),'') AS UNSIGNED) AS Chronic_Cond_IschemicHeart,
CAST(NULLIF(NULLIF(Chronic_Cond_Osteoporasis,'NA'),'') AS UNSIGNED) AS Chronic_Cond_Osteoporasis,
CAST(NULLIF(NULLIF(Chronic_Cond_rheumatoidarthritis,'NA'),'') AS UNSIGNED) AS Chronic_Cond_rheumatoidarthritis,
CAST(NULLIF(NULLIF(Chronic_Cond_stroke,'NA'),'') AS UNSIGNED) AS Chronic_Cond_stroke,

CAST(NULLIF(NULLIF(IPAnnualReimbursementAmt,'NA'),'') AS UNSIGNED) AS IPAnnualReimbursementAmt,
CAST(NULLIF(NULLIF(IPAnnualDeductibleAmt,'NA'),'') AS UNSIGNED) AS IPAnnualDeductibleAmt,
CAST(NULLIF(NULLIF(OPAnnualReimbursementAmt,'NA'),'') AS UNSIGNED) AS OPAnnualReimbursementAmt,
CAST(NULLIF(NULLIF(OPAnnualDeductibleAmt,'NA'),'') AS UNSIGNED) AS OPAnnualDeductibleAmt

FROM beneficiary_raw;

DROP TABLE IF EXISTS stg_fraud_labels;

CREATE TABLE stg_fraud_labels AS
SELECT
Provider,
PotentialFraud
FROM fraud_labels_raw;

CREATE TABLE stg_inpatient_claims AS
SELECT

BeneID,
ClaimID,
Provider,

STR_TO_DATE(NULLIF(NULLIF(ClaimStartDt,'NA'),''),'%Y-%m-%d') AS ClaimStartDt,
STR_TO_DATE(NULLIF(NULLIF(ClaimEndDt,'NA'),''),'%Y-%m-%d') AS ClaimEndDt,

STR_TO_DATE(NULLIF(NULLIF(AdmissionDt,'NA'),''),'%Y-%m-%d') AS AdmissionDt,
STR_TO_DATE(NULLIF(NULLIF(DischargeDt,'NA'),''),'%Y-%m-%d') AS DischargeDt,

CAST(NULLIF(NULLIF(InscClaimAmtReimbursed,'NA'),'') AS UNSIGNED) AS ClaimCost,
CAST(NULLIF(NULLIF(DeductibleAmtPaid,'NA'),'') AS UNSIGNED) AS DeductibleAmtPaid,

NULLIF(NULLIF(AttendingPhysician,'NA'),'') AS AttendingPhysician,
NULLIF(NULLIF(OperatingPhysician,'NA'),'') AS OperatingPhysician,
NULLIF(NULLIF(OtherPhysician,'NA'),'') AS OtherPhysician,

NULLIF(NULLIF(ClmAdmitDiagnosisCode,'NA'),'') AS ClmAdmitDiagnosisCode,
NULLIF(NULLIF(DiagnosisGroupCode,'NA'),'') AS DiagnosisGroupCode,

NULLIF(NULLIF(ClmDiagnosisCode_1,'NA'),'') AS ClmDiagnosisCode_1,
NULLIF(NULLIF(ClmDiagnosisCode_2,'NA'),'') AS ClmDiagnosisCode_2,
NULLIF(NULLIF(ClmDiagnosisCode_3,'NA'),'') AS ClmDiagnosisCode_3,
NULLIF(NULLIF(ClmDiagnosisCode_4,'NA'),'') AS ClmDiagnosisCode_4,
NULLIF(NULLIF(ClmDiagnosisCode_5,'NA'),'') AS ClmDiagnosisCode_5,
NULLIF(NULLIF(ClmDiagnosisCode_6,'NA'),'') AS ClmDiagnosisCode_6,
NULLIF(NULLIF(ClmDiagnosisCode_7,'NA'),'') AS ClmDiagnosisCode_7,
NULLIF(NULLIF(ClmDiagnosisCode_8,'NA'),'') AS ClmDiagnosisCode_8,
NULLIF(NULLIF(ClmDiagnosisCode_9,'NA'),'') AS ClmDiagnosisCode_9,
NULLIF(NULLIF(ClmDiagnosisCode_10,'NA'),'') AS ClmDiagnosisCode_10,

NULLIF(NULLIF(ClmProcedureCode_1,'NA'),'') AS ClmProcedureCode_1,
NULLIF(NULLIF(ClmProcedureCode_2,'NA'),'') AS ClmProcedureCode_2,
NULLIF(NULLIF(ClmProcedureCode_3,'NA'),'') AS ClmProcedureCode_3,
NULLIF(NULLIF(ClmProcedureCode_4,'NA'),'') AS ClmProcedureCode_4,
NULLIF(NULLIF(ClmProcedureCode_5,'NA'),'') AS ClmProcedureCode_5,
NULLIF(NULLIF(ClmProcedureCode_6,'NA'),'') AS ClmProcedureCode_6

FROM inpatient_claims_raw;

CREATE TABLE stg_outpatient_claims AS
SELECT

BeneID,
ClaimID,
Provider,

STR_TO_DATE(NULLIF(NULLIF(ClaimStartDt,'NA'),''),'%Y-%m-%d') AS ClaimStartDt,
STR_TO_DATE(NULLIF(NULLIF(ClaimEndDt,'NA'),''),'%Y-%m-%d') AS ClaimEndDt,

CAST(NULLIF(NULLIF(InscClaimAmtReimbursed,'NA'),'') AS UNSIGNED) AS ClaimCost,
CAST(NULLIF(NULLIF(DeductibleAmtPaid,'NA'),'') AS UNSIGNED) AS DeductibleAmtPaid,

NULLIF(NULLIF(AttendingPhysician,'NA'),'') AS AttendingPhysician,
NULLIF(NULLIF(OperatingPhysician,'NA'),'') AS OperatingPhysician,
NULLIF(NULLIF(OtherPhysician,'NA'),'') AS OtherPhysician,

NULLIF(NULLIF(ClmAdmitDiagnosisCode,'NA'),'') AS ClmAdmitDiagnosisCode,

NULLIF(NULLIF(ClmDiagnosisCode_1,'NA'),'') AS ClmDiagnosisCode_1,
NULLIF(NULLIF(ClmDiagnosisCode_2,'NA'),'') AS ClmDiagnosisCode_2,
NULLIF(NULLIF(ClmDiagnosisCode_3,'NA'),'') AS ClmDiagnosisCode_3,
NULLIF(NULLIF(ClmDiagnosisCode_4,'NA'),'') AS ClmDiagnosisCode_4,
NULLIF(NULLIF(ClmDiagnosisCode_5,'NA'),'') AS ClmDiagnosisCode_5,
NULLIF(NULLIF(ClmDiagnosisCode_6,'NA'),'') AS ClmDiagnosisCode_6,
NULLIF(NULLIF(ClmDiagnosisCode_7,'NA'),'') AS ClmDiagnosisCode_7,
NULLIF(NULLIF(ClmDiagnosisCode_8,'NA'),'') AS ClmDiagnosisCode_8,
NULLIF(NULLIF(ClmDiagnosisCode_9,'NA'),'') AS ClmDiagnosisCode_9,
NULLIF(NULLIF(ClmDiagnosisCode_10,'NA'),'') AS ClmDiagnosisCode_10,

NULLIF(NULLIF(ClmProcedureCode_1,'NA'),'') AS ClmProcedureCode_1,
NULLIF(NULLIF(ClmProcedureCode_2,'NA'),'') AS ClmProcedureCode_2,
NULLIF(NULLIF(ClmProcedureCode_3,'NA'),'') AS ClmProcedureCode_3,
NULLIF(NULLIF(ClmProcedureCode_4,'NA'),'') AS ClmProcedureCode_4,
NULLIF(NULLIF(ClmProcedureCode_5,'NA'),'') AS ClmProcedureCode_5,
NULLIF(NULLIF(ClmProcedureCode_6,'NA'),'') AS ClmProcedureCode_6

FROM outpatient_claims_raw;

SELECT COUNT(*) FROM stg_beneficiary; -- 138556
SELECT COUNT(*) FROM stg_inpatient_claims; -- 40474
SELECT COUNT(*) FROM stg_outpatient_claims; -- 517737
SELECT COUNT(*) FROM stg_fraud_labels; -- 5410

SELECT * FROM stg_beneficiary LIMIT 5; -- 138556
SELECT * FROM stg_inpatient_claims LIMIT 5; -- 40474
SELECT * FROM stg_outpatient_claims LIMIT 5; -- 517737
SELECT * FROM stg_fraud_labels LIMIT 5; -- 5410

SELECT DISTINCT PotentialFraud FROM stg_fraud_labels;