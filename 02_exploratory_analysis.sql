USE hospital_readmissions;

SELECT
    readmitted,
    COUNT(*) AS encounter_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM diabetic_data_dedup), 1) AS pct_of_total
FROM diabetic_data_dedup
GROUP BY readmitted
ORDER BY encounter_count DESC;

SELECT
    age,
    age_midpoint,
    COUNT(*)              AS total_patients,
    SUM(is_readmitted_30) AS readmitted_under_30,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY age, age_midpoint
ORDER BY age_midpoint;

SELECT
    m.description AS admission_type,
    COUNT(*)      AS total_patients,
    ROUND(100.0 * SUM(d.is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup AS d
JOIN admission_type_map  AS m
    ON d.admission_type_id = m.admission_type_id
GROUP BY m.description
ORDER BY total_patients DESC;

SELECT
    CASE
        WHEN number_inpatient = 0 THEN '0 stays'
        WHEN number_inpatient = 1 THEN '1 stay'
        WHEN number_inpatient = 2 THEN '2 stays'
        ELSE '3+ stays'
    END AS prior_inpatient_stays,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY
    CASE
        WHEN number_inpatient = 0 THEN '0 stays'
        WHEN number_inpatient = 1 THEN '1 stay'
        WHEN number_inpatient = 2 THEN '2 stays'
        ELSE '3+ stays'
    END
ORDER BY prior_inpatient_stays;

SELECT
    CASE
        WHEN time_in_hospital <= 3 THEN '1-3 days'
        WHEN time_in_hospital <= 7 THEN '4-7 days'
        ELSE '8-14 days'
    END AS length_of_stay,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY
    CASE
        WHEN time_in_hospital <= 3 THEN '1-3 days'
        WHEN time_in_hospital <= 7 THEN '4-7 days'
        ELSE '8-14 days'
    END
ORDER BY length_of_stay;
