CREATE DATABASE IF NOT EXISTS hospital_readmissions;
USE hospital_readmissions;

DROP TABLE IF EXISTS diabetic_data_raw;

CREATE TABLE diabetic_data_raw (
    encounter_id              INT,
    patient_nbr               INT,
    race                      VARCHAR(30),
    gender                    VARCHAR(20),
    age                       VARCHAR(10),
    weight                    VARCHAR(15),
    admission_type_id         INT,
    discharge_disposition_id  INT,
    admission_source_id       INT,
    time_in_hospital          INT,
    payer_code                VARCHAR(10),
    medical_specialty         VARCHAR(60),
    num_lab_procedures        INT,
    num_procedures            INT,
    num_medications           INT,
    number_outpatient         INT,
    number_emergency          INT,
    number_inpatient          INT,
    diag_1                    VARCHAR(10),
    diag_2                    VARCHAR(10),
    diag_3                    VARCHAR(10),
    number_diagnoses          INT,
    max_glu_serum             VARCHAR(10),
    A1Cresult                 VARCHAR(10),
    metformin                 VARCHAR(10),
    repaglinide               VARCHAR(10),
    nateglinide               VARCHAR(10),
    chlorpropamide            VARCHAR(10),
    glimepiride               VARCHAR(10),
    acetohexamide             VARCHAR(10),
    glipizide                 VARCHAR(10),
    glyburide                 VARCHAR(10),
    tolbutamide               VARCHAR(10),
    pioglitazone              VARCHAR(10),
    rosiglitazone             VARCHAR(10),
    acarbose                  VARCHAR(10),
    miglitol                  VARCHAR(10),
    troglitazone              VARCHAR(10),
    tolazamide                VARCHAR(10),
    examide                   VARCHAR(10),
    citoglipton               VARCHAR(10),
    insulin                   VARCHAR(10),
    `glyburide-metformin`     VARCHAR(10),
    `glipizide-metformin`     VARCHAR(10),
    `glimepiride-pioglitazone` VARCHAR(10),
    `metformin-rosiglitazone` VARCHAR(10),
    `metformin-pioglitazone`  VARCHAR(10),
    `change`                  VARCHAR(5),
    diabetesMed               VARCHAR(5),
    readmitted                VARCHAR(5)
);

LOAD DATA LOCAL INFILE 'C:/Users/Dell/Downloads/machine learning/diabetes_readmission_project/data/raw/diabetic_data.csv'
INTO TABLE diabetic_data_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT COUNT(*) AS total_rows
FROM diabetic_data_raw;

SELECT *
FROM diabetic_data_raw
LIMIT 10;

SELECT
    readmitted,
    LENGTH(readmitted) AS value_length,
    COUNT(*)           AS total_rows
FROM diabetic_data_raw
GROUP BY readmitted, LENGTH(readmitted);
