# Hospital Performance SQL Analysis

## Overview
This project analyzes hospital performance using data from the **CMS Hospital Readmissions Reduction Program (HRRP)**.  
The objective is to evaluate excess 30-day readmission patterns across U.S. hospitals, identify high-variability clinical conditions, and surface potential targets for quality improvement using **SQL-based analysis**.

The analysis is conducted using **SQLite**, with queries written directly in SQL to mirror real-world analytics workflows.

---

## Business Context
CMS uses excess readmission metrics to evaluate hospital quality and determine financial penalties under the HRRP.  
Understanding variation across hospitals and conditions can help identify systemic performance issues and opportunities for care standardization.

---

## Objectives
- Evaluate hospital readmission performance across clinical conditions
- Identify conditions with the highest variability in excess readmissions
- Detect hospitals consistently exceeding CMS benchmarks
- Demonstrate SQL proficiency on real healthcare data

---

## Data Source
- **Centers for Medicare & Medicaid Services (CMS)**
- Hospital Readmissions Reduction Program (HRRP)
- Publicly available via https://data.cms.gov

**Note:**  
Due to GitHub file size limits, raw CMS data is not versioned.  
Place the CSV file in the `data/` directory before running the database creation script.

---

## Tools Used
- SQL (SQLite)
- Python (pandas, sqlite3)
- VS Code
- SQLite Viewer extension

---

## How to Run This Project
1. Download the CMS HRRP dataset
2. Place the CSV in the data/ directory
3. Run: python create_db.py
4. Open analysis.sql and run queries against hospital.db

---

## Skills Demonstrated
- SQL aggregation and filtering (GROUP BY, WHERE, HAVING)
- Window functions (RANK, PARTITION BY)
- Data modeling and schema design in SQLite
- Exploratory data analysis using SQL
- Outlier detection and performance benchmarking
- Healthcare data analysis (CMS HRRP)
- Translating raw data into actionable insights

---

## Database Schema
The SQLite database (`hospital.db`) contains one primary table:

### `hrrp_readmissions`
Key columns include:
- `facility_id`
- `facility_name`
- `state`
- `measure_name`
- `number_of_discharges`
- `excess_readmission_ratio`
- `predicted_readmission_rate`
- `expected_readmission_rate`
- `number_of_readmissions`
- `start_date`
- `end_date`

---

## Key Analyses
The SQL analysis includes:
- Aggregation of readmission performance by condition
- Identification of hospitals exceeding CMS benchmarks
- Ranking hospitals **within each condition** using window functions
- Detection of extreme outliers suggesting systemic performance issues

---

## Example Queries
```sql
SELECT
  measure_name,
  ROUND(AVG(excess_readmission_ratio), 3) AS avg_excess_ratio
FROM hrrp_readmissions
GROUP BY measure_name
ORDER BY avg_excess_ratio DESC;

SELECT
  facility_name,
  state,
  measure_name,
  excess_readmission_ratio
FROM hrrp_readmissions
WHERE excess_readmission_ratio > 1.25
ORDER BY excess_readmission_ratio DESC;

```

