USE hospital_readmissions;

SET SQL_SAFE_UPDATES = 0;

UPDATE diabetic_data_raw
SET race              = NULLIF(race, '?'),
    weight            = NULLIF(weight, '?'),
    payer_code        = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    diag_1            = NULLIF(diag_1, '?'),
    diag_2            = NULLIF(diag_2, '?'),
    diag_3            = NULLIF(diag_3, '?');

SELECT
    ROUND(100.0 * SUM(CASE WHEN weight            IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_missing_weight,
    ROUND(100.0 * SUM(CASE WHEN payer_code        IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_missing_payer,
    ROUND(100.0 * SUM(CASE WHEN medical_specialty IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_missing_specialty,
    ROUND(100.0 * SUM(CASE WHEN race              IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_missing_race
FROM diabetic_data_raw;

SELECT
    patient_nbr,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY patient_nbr
HAVING COUNT(*) > 1
ORDER BY encounter_count DESC
LIMIT 10;

DROP TABLE IF EXISTS diabetic_data_dedup;

CREATE TABLE diabetic_data_dedup AS
SELECT t.*
FROM diabetic_data_raw AS t
INNER JOIN (

        SELECT patient_nbr,
               MIN(encounter_id) AS first_encounter
        FROM diabetic_data_raw
        GROUP BY patient_nbr
     ) AS first_enc
    ON  t.patient_nbr  = first_enc.patient_nbr
    AND t.encounter_id = first_enc.first_encounter;

SELECT COUNT(*) AS rows_after_dedup FROM diabetic_data_dedup;

SELECT
    discharge_disposition_id,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY discharge_disposition_id
ORDER BY encounter_count DESC;

DELETE FROM diabetic_data_dedup
WHERE discharge_disposition_id IN (11, 13, 14, 19, 20, 21, 26);

SELECT COUNT(*) AS rows_after_removing_expired FROM diabetic_data_dedup;

DROP TABLE IF EXISTS admission_type_map;
CREATE TABLE admission_type_map (
    admission_type_id INT,
    description       VARCHAR(50)
);
INSERT INTO admission_type_map (admission_type_id, description) VALUES
(1, 'Emergency'),
(2, 'Urgent'),
(3, 'Elective'),
(4, 'Newborn'),
(5, 'Not Available'),
(6, 'NULL'),
(7, 'Trauma Center'),
(8, 'Not Mapped');

DROP TABLE IF EXISTS discharge_disposition_map;
CREATE TABLE discharge_disposition_map (
    discharge_disposition_id INT,
    description              VARCHAR(150)
);
INSERT INTO discharge_disposition_map (discharge_disposition_id, description) VALUES
(1,  'Discharged to home'),
(2,  'Discharged/transferred to another short term hospital'),
(3,  'Discharged/transferred to SNF'),
(4,  'Discharged/transferred to ICF'),
(5,  'Discharged/transferred to another type of inpatient care institution'),
(6,  'Discharged/transferred to home with home health service'),
(7,  'Left AMA'),
(8,  'Discharged/transferred to home under care of Home IV provider'),
(9,  'Admitted as an inpatient to this hospital'),
(10, 'Neonate discharged to another hospital for neonatal aftercare'),
(11, 'Expired'),
(12, 'Still patient or expected to return for outpatient services'),
(13, 'Hospice / home'),
(14, 'Hospice / medical facility'),
(15, 'Discharged/transferred within this institution to Medicare approved swing bed'),
(16, 'Discharged/transferred/referred another institution for outpatient services'),
(17, 'Discharged/transferred/referred to this institution for outpatient services'),
(18, 'NULL'),
(19, 'Expired at home. Medicaid only, hospice.'),
(20, 'Expired in a medical facility. Medicaid only, hospice.'),
(21, 'Expired, place unknown. Medicaid only, hospice.'),
(22, 'Discharged/transferred to another rehab fac including rehab units of a hospital.'),
(23, 'Discharged/transferred to a long term care hospital.'),
(24, 'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare.'),
(25, 'Not Mapped'),
(26, 'Unknown/Invalid'),
(27, 'Discharged/transferred to a federal health care facility.'),
(28, 'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital'),
(29, 'Discharged/transferred to a Critical Access Hospital (CAH).'),
(30, 'Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere');

DROP TABLE IF EXISTS admission_source_map;
CREATE TABLE admission_source_map (
    admission_source_id INT,
    description         VARCHAR(150)
);
INSERT INTO admission_source_map (admission_source_id, description) VALUES
(1,  'Physician Referral'),
(2,  'Clinic Referral'),
(3,  'HMO Referral'),
(4,  'Transfer from a hospital'),
(5,  'Transfer from a Skilled Nursing Facility (SNF)'),
(6,  'Transfer from another health care facility'),
(7,  'Emergency Room'),
(8,  'Court/Law Enforcement'),
(9,  'Not Available'),
(10, 'Transfer from critial access hospital'),
(11, 'Normal Delivery'),
(12, 'Premature Delivery'),
(13, 'Sick Baby'),
(14, 'Extramural Birth'),
(15, 'Not Available'),
(17, 'NULL'),
(18, 'Transfer From Another Home Health Agency'),
(19, 'Readmission to Same Home Health Agency'),
(20, 'Not Mapped'),
(21, 'Unknown/Invalid'),
(22, 'Transfer from hospital inpt/same fac reslt in a sep claim'),
(23, 'Born inside this hospital'),
(24, 'Born outside this hospital'),
(25, 'Transfer from Ambulatory Surgery Center'),
(26, 'Transfer from Hospice');

ALTER TABLE diabetic_data_dedup ADD COLUMN age_midpoint INT;

UPDATE diabetic_data_dedup
SET age_midpoint = CASE
    WHEN age = '[0-10)'   THEN 5
    WHEN age = '[10-20)'  THEN 15
    WHEN age = '[20-30)'  THEN 25
    WHEN age = '[30-40)'  THEN 35
    WHEN age = '[40-50)'  THEN 45
    WHEN age = '[50-60)'  THEN 55
    WHEN age = '[60-70)'  THEN 65
    WHEN age = '[70-80)'  THEN 75
    WHEN age = '[80-90)'  THEN 85
    WHEN age = '[90-100)' THEN 95
END;

ALTER TABLE diabetic_data_dedup ADD COLUMN is_readmitted_30 INT;

UPDATE diabetic_data_dedup
SET is_readmitted_30 = CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END;

SELECT * FROM diabetic_data_dedup LIMIT 50;

SELECT
    COUNT(*)              AS patients,
    SUM(is_readmitted_30) AS readmitted_within_30_days
FROM diabetic_data_dedup;
