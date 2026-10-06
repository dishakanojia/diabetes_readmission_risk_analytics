USE hospital_readmissions;

SELECT
    `change`,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY `change`;

SELECT
    m.description AS discharge_disposition,
    COUNT(*)      AS total_patients,
    ROUND(100.0 * SUM(d.is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup       AS d
JOIN discharge_disposition_map AS m
    ON d.discharge_disposition_id = m.discharge_disposition_id
GROUP BY m.description
HAVING COUNT(*) > 100
ORDER BY readmission_rate_pct DESC
LIMIT 10;

SELECT
    A1Cresult,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY A1Cresult
ORDER BY readmission_rate_pct DESC;

SELECT
    CASE WHEN A1Cresult = 'None' THEN 'Not tested' ELSE 'Tested' END AS hba1c_test,
    COUNT(*) AS total_patients,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM diabetic_data_dedup), 1) AS pct_of_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY CASE WHEN A1Cresult = 'None' THEN 'Not tested' ELSE 'Tested' END;

SELECT
    CASE WHEN A1Cresult = 'None' THEN 'Not tested' ELSE 'Tested' END AS hba1c_test,
    CASE WHEN `change` = 'Ch' THEN 'Medicine changed' ELSE 'No change' END AS medicine_change,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY
    CASE WHEN A1Cresult = 'None' THEN 'Not tested' ELSE 'Tested' END,
    CASE WHEN `change` = 'Ch' THEN 'Medicine changed' ELSE 'No change' END
ORDER BY hba1c_test, medicine_change;

SELECT
    insulin,
    COUNT(*) AS total_patients,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM diabetic_data_dedup), 1) AS pct_of_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY insulin
ORDER BY readmission_rate_pct DESC;

SELECT
    CASE
        WHEN metformin <> 'No' AND insulin <> 'No' THEN 'Metformin + Insulin'
        WHEN metformin <> 'No'                     THEN 'Metformin only (no insulin)'
        WHEN insulin   <> 'No'                     THEN 'Insulin only (no metformin)'
        ELSE 'Neither'
    END AS treatment_group,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY
    CASE
        WHEN metformin <> 'No' AND insulin <> 'No' THEN 'Metformin + Insulin'
        WHEN metformin <> 'No'                     THEN 'Metformin only (no insulin)'
        WHEN insulin   <> 'No'                     THEN 'Insulin only (no metformin)'
        ELSE 'Neither'
    END
ORDER BY readmission_rate_pct DESC;

WITH tiered AS (
    SELECT
        is_readmitted_30,
        CASE
            WHEN number_inpatient >= 2
              OR (number_inpatient >= 1 AND number_emergency >= 1) THEN '1 High'
            WHEN number_inpatient = 1 OR number_emergency >= 1     THEN '2 Medium'
            ELSE '3 Low'
        END AS risk_tier
    FROM diabetic_data_dedup
)
SELECT
    risk_tier,
    COUNT(*)              AS patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)                           AS pct_of_patients,
    SUM(is_readmitted_30) AS readmissions,
    ROUND(100.0 * SUM(is_readmitted_30) / SUM(SUM(is_readmitted_30)) OVER (), 1) AS pct_of_all_readmissions,
    ROUND(100.0 * SUM(is_readmitted_30) / COUNT(*), 1)                           AS readmission_rate_pct
FROM tiered
GROUP BY risk_tier
ORDER BY risk_tier;
