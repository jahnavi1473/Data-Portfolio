CREATE DATABASE healthcare_claims; -- creating a database
USE healthcare_claims; -- use the database to perform the operations.
DROP TABLE IF EXISTS beneficiary_raw;

CREATE TABLE beneficiary_raw (
    BeneID VARCHAR(20),
    DOB VARCHAR(20),
    DOD VARCHAR(20),
    Gender VARCHAR(5),
    Race VARCHAR(5),
    RenalDiseaseIndicator VARCHAR(5),
    State VARCHAR(10),
    County VARCHAR(10),
    NoOfMonths_PartACov VARCHAR(10),
    NoOfMonths_PartBCov VARCHAR(10),
    Chronic_Cond_Alzheimer VARCHAR(5),
    Chronic_Cond_Heartfailure VARCHAR(5),
    Chronic_Cond_KidneyDisease VARCHAR(5),
    Chronic_Cond_Cancer VARCHAR(5),
    Chronic_Cond_ObstrPulmonary VARCHAR(5),
    Chronic_Cond_Depression VARCHAR(5),
    Chronic_Cond_Diabetes VARCHAR(5),
    Chronic_Cond_IschemicHeart VARCHAR(5),
    Chronic_Cond_Osteoporasis VARCHAR(5),
    Chronic_Cond_rheumatoidarthritis VARCHAR(5),
    Chronic_Cond_stroke VARCHAR(5),
    IPAnnualReimbursementAmt VARCHAR(20),
    IPAnnualDeductibleAmt VARCHAR(20),
    OPAnnualReimbursementAmt VARCHAR(20),
    OPAnnualDeductibleAmt VARCHAR(20)
);
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/healthcare-claims-analytics/data/beneficiary.csv'
INTO TABLE beneficiary_raw
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- CREATE TABLE INPATIENTS

DROP TABLE inpatient_claims_raw;
CREATE TABLE inpatient_claims_raw (
BeneID TEXT,
ClaimID TEXT,
ClaimStartDt TEXT,
ClaimEndDt TEXT,
Provider TEXT,
InscClaimAmtReimbursed TEXT,
AttendingPhysician TEXT,
OperatingPhysician TEXT,
OtherPhysician TEXT,
AdmissionDt TEXT,
ClmAdmitDiagnosisCode TEXT,
DeductibleAmtPaid TEXT,
DischargeDt TEXT,
DiagnosisGroupCode TEXT,
ClmDiagnosisCode_1 TEXT,
ClmDiagnosisCode_2 TEXT,
ClmDiagnosisCode_3 TEXT,
ClmDiagnosisCode_4 TEXT,
ClmDiagnosisCode_5 TEXT,
ClmDiagnosisCode_6 TEXT,
ClmDiagnosisCode_7 TEXT,
ClmDiagnosisCode_8 TEXT,
ClmDiagnosisCode_9 TEXT,
ClmDiagnosisCode_10 TEXT,
ClmProcedureCode_1 TEXT,
ClmProcedureCode_2 TEXT,
ClmProcedureCode_3 TEXT,
ClmProcedureCode_4 TEXT,
ClmProcedureCode_5 TEXT,
ClmProcedureCode_6 TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/healthcare-claims-analytics/data/inpatient_claims.csv'
INTO TABLE inpatient_claims_raw
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT count(*) from inpatient_claims_raw;
SELECT count(*) from beneficiary_raw;

DROP TABLE outpatient_claims_raw;
CREATE TABLE outpatient_claims_raw (
BeneID TEXT,
ClaimID TEXT,
ClaimStartDt TEXT,
ClaimEndDt TEXT,
Provider TEXT,
InscClaimAmtReimbursed TEXT,
AttendingPhysician TEXT,
OperatingPhysician TEXT,
OtherPhysician TEXT,
ClmDiagnosisCode_1 TEXT,
ClmDiagnosisCode_2 TEXT,
ClmDiagnosisCode_3 TEXT,
ClmDiagnosisCode_4 TEXT,
ClmDiagnosisCode_5 TEXT,
ClmDiagnosisCode_6 TEXT,
ClmDiagnosisCode_7 TEXT,
ClmDiagnosisCode_8 TEXT,
ClmDiagnosisCode_9 TEXT,
ClmDiagnosisCode_10 TEXT,
ClmProcedureCode_1 TEXT,
ClmProcedureCode_2 TEXT,
ClmProcedureCode_3 TEXT,
ClmProcedureCode_4 TEXT,
ClmProcedureCode_5 TEXT,
ClmProcedureCode_6 TEXT,
DeductibleAmtPaid TEXT,
ClmAdmitDiagnosisCode TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/healthcare-claims-analytics/data/outpatient_claims.csv'
INTO TABLE outpatient_claims_raw
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

CREATE TABLE fraud_labels_raw (
Provider TEXT,
PotentialFraud TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/healthcare-claims-analytics/data/fraud_labels.csv'
INTO TABLE fraud_labels_raw
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT count(*) from beneficiary_raw; -- 138556
SELECT count(*) from inpatient_claims_raw; -- 40474
SELECT count(*) from outpatient_claims_raw; -- 517737
SELECT count(*) from fraud_labels_raw; -- 5410

