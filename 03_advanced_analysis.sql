USE hospital_readmissions;

WITH patient_risk_base AS (
    SELECT
        encounter_id,
        patient_nbr,
        age_midpoint,
        time_in_hospital,
        num_medications,
        num_lab_procedures,
        number_diagnoses,
        number_inpatient,
        number_emergency,
        number_outpatient,
        diag_1,
        readmitted,
        is_readmitted_30
    FROM diabetic_data_dedup
)
SELECT *
FROM patient_risk_base
LIMIT 20;

WITH patient_risk_base AS (
    SELECT encounter_id, age_midpoint, num_medications, is_readmitted_30
    FROM diabetic_data_dedup
)
SELECT
    encounter_id,
    age_midpoint,
    num_medications,
    RANK() OVER (PARTITION BY age_midpoint ORDER BY num_medications DESC) AS med_rank_age_group
FROM patient_risk_base
ORDER BY age_midpoint, med_rank_age_group
LIMIT 200;

WITH ranked AS (
    SELECT
        encounter_id,
        age,
        num_medications,
        is_readmitted_30,
        RANK() OVER (PARTITION BY age_midpoint ORDER BY num_medications DESC) AS med_rank_age_group
    FROM diabetic_data_dedup
)
SELECT *
FROM ranked
WHERE med_rank_age_group <= 3
ORDER BY age, med_rank_age_group;

WITH patient_risk_base AS (
    SELECT encounter_id, number_inpatient, is_readmitted_30
    FROM diabetic_data_dedup
)
SELECT
    encounter_id,
    number_inpatient,
    NTILE(4) OVER (ORDER BY number_inpatient DESC) AS risk_quartile
FROM patient_risk_base
LIMIT 20;

WITH quartiles AS (
    SELECT
        number_inpatient,
        is_readmitted_30,
        NTILE(4) OVER (ORDER BY number_inpatient DESC) AS risk_quartile
    FROM diabetic_data_dedup
)
SELECT
    risk_quartile,
    COUNT(*)              AS patients,
    MIN(number_inpatient) AS min_prior_stays,
    MAX(number_inpatient) AS max_prior_stays,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM quartiles
GROUP BY risk_quartile
ORDER BY risk_quartile;

SELECT
    encounter_id,
    num_medications,
    CASE
        WHEN num_medications <= 10 THEN 'Low'
        WHEN num_medications BETWEEN 11 AND 20 THEN 'Medium'
        ELSE 'High'
    END AS medication_burden_tier,
    number_diagnoses,
    CASE
        WHEN number_diagnoses <= 5 THEN 'Low Complexity'
        WHEN number_diagnoses BETWEEN 6 AND 9 THEN 'Moderate Complexity'
        ELSE 'High Complexity'
    END AS diagnosis_complexity_tier
FROM diabetic_data_dedup
LIMIT 20;

WITH tiers AS (
    SELECT
        is_readmitted_30,
        CASE
            WHEN num_medications <= 10 THEN '1 Low'
            WHEN num_medications BETWEEN 11 AND 20 THEN '2 Medium'
            ELSE '3 High'
        END AS medication_burden_tier,
        CASE
            WHEN number_diagnoses <= 5 THEN '1 Low'
            WHEN number_diagnoses BETWEEN 6 AND 9 THEN '2 Moderate'
            ELSE '3 High'
        END AS diagnosis_complexity_tier
    FROM diabetic_data_dedup
)
SELECT
    medication_burden_tier,
    diagnosis_complexity_tier,
    COUNT(*) AS patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM tiers
GROUP BY medication_burden_tier, diagnosis_complexity_tier
ORDER BY medication_burden_tier, diagnosis_complexity_tier;

WITH diag_categorized AS (
    SELECT
        encounter_id,
        is_readmitted_30,
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury'
            ELSE 'Other'
        END AS diagnosis_category
    FROM diabetic_data_dedup
    WHERE diag_1 IS NOT NULL
)
SELECT
    diagnosis_category,
    COUNT(*) AS total_patients,
    ROUND(AVG(is_readmitted_30) * 100, 1) AS readmission_rate_pct
FROM diag_categorized
GROUP BY diagnosis_category
HAVING AVG(is_readmitted_30) > (SELECT AVG(is_readmitted_30) FROM diag_categorized)
ORDER BY readmission_rate_pct DESC;

WITH diag_categorized AS (
    SELECT
        is_readmitted_30,
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury'
            ELSE 'Other'
        END AS diagnosis_category
    FROM diabetic_data_dedup
    WHERE diag_1 IS NOT NULL
)
SELECT
    diagnosis_category,
    COUNT(*) AS total_patients,
    ROUND(AVG(is_readmitted_30) * 100, 1) AS readmission_rate_pct,
    CASE
        WHEN AVG(is_readmitted_30) > (SELECT AVG(is_readmitted_30) FROM diag_categorized)
        THEN 'Above average' ELSE 'Below average'
    END AS vs_average
FROM diag_categorized
GROUP BY diagnosis_category
ORDER BY readmission_rate_pct DESC;
