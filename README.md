# Diabetes Patient Readmission Risk Analytics

**Tools:** SQL (MySQL) · Python (pandas, scikit-learn, SciPy) · Power BI
**Data:** 69,973 diabetes patients from 130 US hospitals (1999–2008)

---

## The problem
When a diabetes patient leaves hospital, about **9 in every 100 come back within 30 days**. Each of these readmissions costs around **$15,200** and usually means the patient's recovery at home went wrong.

A pharma company wants to run a **patient-support programme**: nurse follow-up calls and a medicine review after discharge. The budget is limited, so it can't support everyone. This project answers three questions:

1. **Who** is most likely to come back to hospital, and **why**?
2. **Which patients** should the programme focus on?
3. **Is the programme worth the money?**

## What I did
1. **Cleaned the data in SQL.** I turned 101,766 raw hospital visits into one clean record per patient: fixing missing values, keeping each patient's first visit, and removing patients who died or went to hospice.
2. **Explored it in SQL.** I compared readmission rates by age, past hospital stays, discharge destination, diagnosis, blood-sugar testing and medicines.
3. **Tested the patterns statistically in Python.** Chi-square tests show which differences are real and which are just chance.
4. **Built a risk model in Python.** A logistic regression gives every patient a risk score and explains which factors raise or lower the risk.
5. **Turned the model into a business decision.** I ranked patients into 10 risk groups and calculated the cost and savings of targeting different groups.
6. **Built a 4-page Power BI dashboard:** Overview, Drivers, Treatment, and Targeting & ROI.

## What I found
- **Past hospital stays are the biggest warning sign.** Patients with no stays in the past year came back 8.1% of the time; patients with 3 or more came back **26.5%** of the time.
- **Where a patient goes after discharge matters.** Patients sent to a nursing or rehab facility had **more than double** the odds of returning compared with patients sent home.
- **The model ranks risk well.** The riskiest 20% of patients account for **34.8% of all readmissions**.
- **Focusing pays off; supporting everyone doesn't.** Supporting the riskiest 30% saves about **$417K per 10,000 patients**, while supporting everyone **loses about $273K**.
- **Blood-sugar (HbA1c) testing helps a little.** Tested patients came back slightly less often, and 4 in 5 patients were never tested.

![Gains chart](outputs/charts/10_deciles_gains.png)

## What I recommend
1. Use the risk score to **focus the programme on the riskiest 10–30% of patients**.
2. As a quick rule, prioritise patients with **2+ hospital stays last year** or **discharged to a facility**.
3. **Test HbA1c before changing diabetes medicines.**

## Techniques used
| Area | What I used |
|---|---|
| **SQL** | `CREATE TABLE`, `LOAD DATA`, `UPDATE` with `NULLIF`, `DELETE`, `JOIN`s with lookup tables, `GROUP BY` / `HAVING`, `CASE WHEN`, subqueries, **CTEs**, **window functions** (`RANK`, `NTILE`, `SUM() OVER ()`) |
| **Python** | pandas (cleaning, grouping), matplotlib / seaborn (charts), SciPy `chi2_contingency` (statistical tests), scikit-learn `Pipeline`, `OneHotEncoder`, `LogisticRegression`, `RandomForestClassifier`, `train_test_split`, ROC-AUC, recall, precision |
| **Analysis** | Chi-square tests, odds ratios, risk deciles, gains chart, ROI and break-even analysis |
| **Power BI** | Power Query, DAX measures (`COUNTROWS`, `SUM`, `DIVIDE`, `AVERAGE`, `CALCULATE`, `ALL`), slicers, custom theme |

**Model results:** logistic regression AUC 0.638 (Random Forest gave the same), recall 53%.

## Project files
```
├── data/raw/                 original data (UCI)
├── sql/                      SQL queries with explanations (run 00 → 04)
├── sql_no_comments/          the same SQL queries without comments
├── notebooks/                Python analysis, statistics and model
├── outputs/charts/           12 charts
├── outputs/powerbi_data/     data files for the dashboard
├── powerbi/                  Power BI dashboard (open readmission_dashboard.pbip)
└── docs/                     project guide, key decisions, dashboard booklet (PDF), theme
```

## How to run
```bash
pip install -r requirements.txt
jupyter notebook notebooks/readmission_analysis.ipynb
```
- **SQL:** run the files in `sql/` in order (00 → 04) in MySQL Workbench.
- **Power BI:** open `powerbi/readmission_dashboard.pbip`. If your project folder is in a different location, update the file paths under **Transform data → Data source settings**.

## Limitations
- The data is from 1999–2008, so newer diabetes medicines aren't included. The same method works on current data.
- The results show links, not proof of cause. For example, sicker patients receive more insulin.

## Data source
*Diabetes 130-US Hospitals for Years 1999–2008*, UCI Machine Learning Repository (CC BY 4.0). Strack et al., *BioMed Research International*, 2014. Readmission cost: AHRQ HCUP Statistical Brief #278.
